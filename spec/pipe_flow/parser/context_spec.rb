RSpec.describe PipeFlow::Parser::Context do
  let(:instance) { described_class.new(test_env) }
  subject { instance }

  describe '#parse!' do
    class ContextTester
      def trim(a)
        a.strip
      end

      def intercept(x, &block)
        block.call(x)
        x
      end
    end

    let(:test_env) { ContextTester.new.instance_eval { binding } }
    let(:test_block) { proc {} }

    subject { super().parse!(&test_block) }

    it 'returns nil if the block does nothing' do
      is_expected.to be_nil
    end

    context 'given a simple block with just a hole' do
      let(:test_block) { proc { input } }

      it 'returns an AST' do
        is_expected.to be_an_ast_node
      end

      it 'returns just a hole' do
        is_expected.to be_an_ast_hole
      end
    end

    context 'given a simple block with just an input value' do
      let(:input_value) { double('Input') }
      let(:test_block) { inp = input_value; proc { input(inp) } }

      it 'returns a literal value' do
        is_expected.to be_a_literal(input_value)
      end
    end

    context 'given a simple pipeline' do
      let(:test_block) { proc { input >> trim >> intercept  } }

      it 'returns the correct AST' do
        is_expected.to be_pipeline_with(
          a_pipeline_with(an_ast_hole, an_ast_methodcall),
          an_ast_methodcall
        )
      end
    end

    context 'given a pipeline with a method that takes a block' do
      let(:test_block) { proc { input >> trim >> intercept { |x| puts x } } }
      let(:last_methodcall) { subject.destination }

      it 'returns the correct AST' do
        is_expected.to be_pipeline_with(
          a_pipeline_with(an_ast_hole, an_ast_methodcall),
          an_ast_methodcall
        )
      end

      context 'the last method call' do
        subject { super().destination }

        it 'has a block parameter' do
          is_expected.to be_accepts_block
        end

        it 'is reifiable' do
          is_expected.to be_reifiable
        end
      end
    end

    context 'given a pipeline with a proc as a destination' do
      subject { instance.parse! { input >> proc { |x| x } } }

      it 'returns the correct AST' do
        is_expected.to be_pipeline_with(
          an_ast_hole,
          an_ast_block
        )
      end
    end

    context 'given a pipeline with a lambda as a destination' do
      let(:test_block) { proc { input >> lambda { |x| x } } }

      it 'returns the correct AST' do
        is_expected.to be_pipeline_with(
          an_ast_hole,
          an_ast_block
        )
      end
    end

    context 'given a pipeline with a lambda (->) as a destination' do
      let(:test_block) { proc { input >> ->(x) { x } } }

      it 'returns the correct AST' do
        is_expected.to be_pipeline_with(
          an_ast_hole,
          an_ast_block
        )
      end
    end

    context 'given a pipeline whose input is a proc' do
      let(:test_block) { proc { input(proc { |x| x }) >> ->(x) { x } } }

      it 'returns the correct AST' do
        is_expected.to be_pipeline_with(
          an_ast_literal,
          an_ast_block
        )
      end
    end
  end
end
