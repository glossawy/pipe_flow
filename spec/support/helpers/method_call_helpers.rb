module MethodCallHelpers
  def self.define_param_generator(name, rb_representation)
    define_method("#{name}_param") do |param_name|
      [rb_representation.to_sym, param_name.to_sym]
    end
    alias_method "#{rb_representation}_param", "#{name}_param"
  end

  define_param_generator :required, :req
  define_param_generator :optional, :opt
  define_param_generator :variadic, :rest
  define_param_generator :keyword, :key
  define_param_generator :required_keyword, :keyreq
  define_param_generator :variadic_keyword, :keyrest

  def self.random_for(type, name)
    if %i[req opt].include?(type)
      RandomDataHelpers.random_string
    elsif %i[key keyreq].include?(type)
      { name.to_s => RandomDataHelpers.random_string }
    elsif type == :rest
      0.upto(rand(0..3)).map { RandomDataHelpers.random_string }
    elsif type == :keyrest
      0.upto(rand(0..3)).map { [RandomDataHelpers.random_string.to_sym, RandomDataHelpers.random_string] }.to_h
    end
  end

  RSpec.shared_examples 'AST::MethodCall method definition' do |description:, expected_arity:, expected_definition:, params:|
    required_pos_count = params.count { |(type, _)| type == :req } + (params.any? { |(type, _)| type == :keyreq } ? 1 : 0)
    optional_pos_count = params.count { |(type, _)| type == :opt } + (params.any? { |(type, _)| type == :key } ? 1 : 0)

    has_rest = params.any? { |(type, _)| type == :rest }
    has_keyrest = params.any? { |(type,_)| type == :keyrest }

    context description do
      let(:parameters) { params }
      let(:parameter_values) do
        values = params.map { |(type, n)| MethodCallHelpers.random_for(type, n) }
        values.group_by { |x| x.is_a?(Hash) }.map do |(is_hashes, vals)|
          next vals unless is_hashes
          [vals.reduce { |a, e| a.merge(e) }]
        end.reduce { |a, e| a + e }
      end

      let(:parameter_names) { params.map { |(_, name)| name } }

      it 'has an appropriate arity' do
        expect(subject.arity).to eq(expected_arity)
      end

      it 'derives a sane definition' do
        expect(subject.definition).to match(expected_definition)
      end

      if required_pos_count == 0 then
        if has_rest
          it 'is reifiable' do
            is_expected.to be_reifiable
          end
        elsif has_keyrest
          context 'with optional kwargs' do
            let(:parameter_values) { [{z: 2}] }
            it 'is not reifiable' do
              is_expected.not_to be_reifiable
            end
          end

          context 'without optional kwargs' do
            let(:parameter_values) { [] }
            it 'is reifiable' do
              is_expected.to be_reifiable
            end
          end
        else
          it 'is not reifiable' do
            is_expected.not_to be_reifiable
          end
        end
      elsif required_pos_count == 1 then
        context 'with parameter' do
          let(:parameter_values) { [MethodCallHelpers.random_for(*params.find { |(type, _)| %i[req keyreq].include?(type) })] }

          if optional_pos_count > 0 || has_rest
            it 'is reifiable' do
              is_expected.to be_reifiable
            end
          else
            it 'is not reifiable' do
              is_expected.not_to be_reifiable
            end
          end
        end

        context 'without parameter' do
          let(:parameter_values) { super().drop(1) }

          it 'is reifiable' do
            is_expected.to be_reifiable
          end
        end
      else
        context 'all parameters filled' do
          it 'is not reifiable' do
            is_expected.not_to be_reifiable
          end
        end

        context 'missing exactly one required' do
          let(:parameter_values) { super().take(required_pos_count - 1) }

          it 'is reifiable' do
            is_expected.to be_reifiable
          end
        end

        context 'missing too many parameters' do
          let(:parameter_values) { super().take(required_pos_count - 2) }

          it 'is not reifiable' do
            is_expected.not_to be_reifiable
          end
        end
      end
    end
  end
end
