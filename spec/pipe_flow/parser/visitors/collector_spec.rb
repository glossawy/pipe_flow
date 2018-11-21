RSpec.describe PipeFlow::Parser::Visitors::Collector do
  let(:instance) { described_class.new }

  context '#visit' do
    subject { instance.collect(input) }
    let(:collected) { instance.collected }

    context 'for a AST::Hole' do
      let(:input) { PipeFlow::Parser::AST::Hole.instance }
      before { subject }

      it 'collects a single result' do
        expect(collected.size).to eq(1)
      end

      it 'results in a proc' do
        expect(collected.first).to be_a(Proc)
      end
    end

    context 'for a AST::Literal' do
      let(:input) { PipeFlow::Parser::AST::Literal.new(double('Literal Value')) }
      before { subject }

      it 'collects a single result' do
        expect(collected.size).to eq(1)
      end

      it 'results in a proc' do
        expect(collected.first).to be_a(Proc)
      end
    end

    context 'for a AST::MethodCall' do
      let(:fake_env) { object_double(binding) }
      let(:fake_self) { double('Receiver') }

      let(:input) { PipeFlow::Parser::AST::MethodCall.new(fake_env, :test_method, []) }

      before do
        allow(fake_env).to receive(:eval).with(anything).and_return([], fake_self)
        subject
      end

      it 'collects a single result' do
        expect(collected.size).to eq(1)
      end

      it 'results in a proc' do
        expect(collected.first).to be_a(Proc)
      end
    end

    context 'for a AST::Block' do
      let(:block_value) { proc { |x| x } }
      let(:input) { PipeFlow::Parser::AST::Block.new(block_value) }

      before { subject }

      it 'collects a single result' do
        expect(collected.size).to eq(1)
      end

      it 'results in a proc' do
        expect(collected.first).to be_a(Proc)
      end
    end

    context 'for a AST::Pipe' do
      let(:input) { PipeFlow::Parser::AST::Pipe.new(source, destination) }
      let(:source) { PipeFlow::Parser::AST::Hole.instance }
      let(:destination) { PipeFlow::Parser::AST::Literal.new(double('Literal Value')) }

      it 'collects two results' do
        subject
        expect(collected.size).to eq(2)
      end

      it 'visits the source and destination nodes as a pre-order traversal', aggregate_failures: true do
        allow(instance).to receive(:visit).with(input).and_call_original
        expect(instance).to receive(:visit).with(source).and_call_original.ordered
        expect(instance).to receive(:visit).with(destination).and_call_original.ordered
        subject
      end

      it 'results in only procs' do
        subject
        expect(collected).to all(be_a Proc)
      end
    end
  end
end
