RSpec.describe PipeFlow::Parser::Visitors::DSL do
  include RandomDataHelpers

  let(:example_visitor) { Class.new(PipeFlow::Parser::Visitors::Visitor) }
  let(:class_definition) { proc {} }
  let(:visit_type_name) { "Test#{random_string}" }
  let(:test_visit_type) { Struct.new(visit_type_name) }

  let(:visit_method) { "visit_Struct_#{visit_type_name}".to_sym }
  let(:visit_method_params) { example_visitor.instance_method(visit_method).parameters }

  let(:perform_definition) do
    example_visitor.send(:extend, described_class)
    example_visitor.send(:class_eval, &class_definition)
  end

  subject do
    perform_definition
    example_visitor.instance_methods
  end

  describe '.on_visit' do
    let(:class_definition) { ty = test_visit_type; proc { on_visit(ty) { |_| }  } }

    it 'defines a new visit method', :aggregate_failures do
      method_name = "visit_Struct_#{visit_type_name}".to_sym
      is_expected.to include(method_name)

      parameters = example_visitor.instance_method(method_name).parameters
      expect(parameters).to match_array([[:req, anything]])
    end
  end

  describe '.on_visit_skip' do
    let(:class_definition) { ty = test_visit_type; proc { on_visit_skip(ty) } }

    it 'defines a new visit method', :aggregate_failures do
      is_expected.to include(visit_method)
      expect(visit_method_params).to match_array([[:req, anything]])
    end
  end

  describe '.alias_visit' do
    context 'aliasing another type' do
      let(:other_type_name) { "Other#{random_string}" }
      let(:other_type) { Struct.new(other_type_name) }
      let(:other_visit_method) { "visit_Struct_#{other_type_name}" }
      let(:class_definition) do
        ty = test_visit_type
        other_ty = other_type

        proc do
          on_visit(other_ty) { |_| }
          alias_visit(ty, to: other_ty)
        end
      end

      it 'defines a new visit method', :aggregate_failures do
        is_expected.to include(visit_method)
        expect(visit_method_params).to match_array([[:req, anything]])
      end

      it 'uses an alias of the other visitor method' do
        perform_definition
        test_method = example_visitor.instance_method(visit_method)
        other_method = example_visitor.instance_method(other_visit_method)

        expect(test_method.original_name).to eq(other_method.original_name)
      end
    end

    context 'aliasing a method' do
      let(:aliased_method) { "test#{random_string}" }
      let(:class_definition) do
        ty = test_visit_type
        method_id = aliased_method

        proc do
          define_method(method_id) { |_| }
          alias_visit(ty, to: method_id)
        end
      end

      it 'defines a new visit method', :aggregate_failures do
        is_expected.to include(visit_method)
        expect(visit_method_params).to match_array([[:req, anything]])
      end

      it 'uses an alias of the other visitor method' do
        perform_definition
        test_method = example_visitor.instance_method(visit_method)
        other_method = example_visitor.instance_method(aliased_method)

        expect(test_method.original_name).to eq(other_method.original_name)
      end
    end

    context 'some other class of value' do
      let(:class_definition) do
        ty = test_visit_type

        proc do
          alias_visit ty, to: 23
        end
      end

      it 'raises a type error' do
        expect { perform_definition }.to raise_error(TypeError)
      end
    end
  end
end
