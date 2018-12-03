RSpec.describe PipeFlow::AST::MethodCall do
  include RandomDataHelpers
  include MethodCallHelpers
  extend MethodCallHelpers

  it_behaves_like 'a PipeFlow AST Node'

  let(:fake_env) { object_double(binding) }
  let(:method_id) { :test_method }
  let(:parameters) { [] }
  let(:parameter_values) { parameters.map { |p| MethodCallHelpers.random_for(*p) } }
  let(:instance) { described_class.new(fake_env, method_id, parameter_values) }

  subject { instance }

  before do
    allow(fake_env).to receive(:eval).with(/\Amethod(.+?)\.parameters\z/).and_return(parameters)
  end

  context 'for a method with' do
    include_examples 'AST::MethodCall method definition',
      description: 'only required positional arguments',
      params: [req_param(:a), req_param(:b), req_param(:c)],
      expected_arity: (3..3),
      expected_definition: 'test_method(a, b, c)'

    include_examples 'AST::MethodCall method definition',
      description: 'required and optional arguments',
      params: [req_param(:a), req_param(:b), opt_param(:c)],
      expected_arity: (2..3),
      expected_definition: /test_method\(a, b, c = [^,]+\)/

    include_examples 'AST::MethodCall method definition',
      description: 'required and keyword arguments',
      params: [req_param(:a), req_param(:b), key_param(:c)],
      expected_arity: (2..3),
      expected_definition: /test_method\(a, b, c: [^,]+\)/

    include_examples 'AST::MethodCall method definition',
      description: 'required, keyword, and required keyword arguments',
      params: [req_param(:a), req_param(:b), key_param(:c), keyreq_param(:d)],
      expected_arity: (3..3),
      expected_definition: /test_method\(a, b, c: [^,]+, d:\)/

    include_examples 'AST::MethodCall method definition',
      description: 'only optional arguments',
      params: [opt_param(:a), opt_param(:b), key_param(:c)],
      expected_arity: (0..3),
      expected_definition: /test_method\(a = [^,]+, b = [^,]+, c: [^,]+\)/

    include_examples 'AST::MethodCall method definition',
      description: 'only optional positional parameters, but a required keyword parameter',
      params: [opt_param(:a), opt_param(:b), keyreq_param(:c)],
      expected_arity: (1..3),
      expected_definition: /test_method\(a = [^,]+, b = [^,]+, c:\)/

    include_examples 'AST::MethodCall method definition',
      description: 'with positional rest args and required keyword',
      params: [rest_param(:args), keyreq_param(:a)],
      expected_arity: (1..Float::INFINITY),
      expected_definition: 'test_method(*args, a:)'

    include_examples 'AST::MethodCall method definition',
      description: 'with postional and keyword rest args',
      params: [rest_param(:args), keyrest_param(:kwargs)],
      expected_arity: (0..Float::INFINITY),
      expected_definition: 'test_method(*args, **kwargs)'

    include_examples 'AST::MethodCall method definition',
      description: 'with only rest parameters',
      params: [rest_param(:args)],
      expected_arity: (0..Float::INFINITY),
      expected_definition: 'test_method(*args)'

    include_examples 'AST::MethodCall method definition',
      description: 'with only keyrest parameters',
      params: [keyrest_param(:kwargs)],
      expected_arity: (0..1),
      expected_definition: 'test_method(**kwargs)'

    include_examples 'AST::MethodCall method definition',
      description: 'like a native C method (e.g. `puts(*)`)',
      params: [[:rest]],
      expected_arity: (0..Float::INFINITY),
      expected_definition: 'test_method(*)'

    include_examples 'AST::MethodCall method definition',
      description: 'just takes a block',
      params: [block_param(:block)],
      expected_arity: (0..0),
      expected_definition: 'test_method(&block)'

    include_examples 'AST::MethodCall method definition',
      description: 'parameters and a block parameter',
      params: [req_param(:a), req_param(:b), opt_param(:c), keyreq_param(:d), block_param(:block)],
      expected_arity: (3..4),
      expected_definition: /test_method\(a, b, c = [^,]+, d:, &block\)/
  end

  describe '#==' do
    let(:other_fake_env) { fake_env }
    let(:other_method_id) { method_id }
    let(:other_parameters) { parameters }
    let(:other_parameter_values) { parameters.map { |p| MethodCallHelpers.random_for(*p) } }
    let(:other_method_call) { described_class.new(other_fake_env, other_method_id, other_parameter_values) }

    before do
      allow(other_fake_env).to receive(:eval).with(/\Amethod(.+?)\.parameters\z/).and_return(other_parameters)
    end

    context 'when all internal values are the same' do
      it 'considers the other method call equivalent' do
        is_expected.to eq(other_method_call)
      end
    end

    context 'when method_ids differ' do
      let(:other_method_id) { :other_test_method }

      it 'considers the other methods call non-equivalent' do
        is_expected.not_to eq(other_method_call)
      end
    end

    context 'when parameter lists differ' do
      let(:other_parameters) { [req_param(:definitely_not_real)] }

      it 'considers the other methods call non-equivalent' do
        is_expected.not_to eq(other_method_call)
      end
    end

    context 'when provided argument lists differ' do
      let(:parameter_values) { [random_string] }

      it 'considers the other methods call non-equivalent' do
        is_expected.not_to eq(other_method_call)
      end
    end

    context 'when environments differ' do
      let(:other_fake_env) { object_double(binding) }

      it 'considers the other methods call non-equivalent' do
        is_expected.not_to eq(other_method_call)
      end
    end
  end

  describe '#input_needed?' do
    subject { super().input_needed? }
    context 'with a reifiable method (one with a missing argument)' do
      let(:parameters) { [req_param(:a), req_param(:b)] }
      let(:parameter_values) { super().drop(1) }

      it 'requires input' do
        is_expected.to be true
      end
    end

    context 'with a non-reifiable method (one without a missing argument)' do
      it 'does not require input' do
        is_expected.to be false
      end
    end
  end
end
