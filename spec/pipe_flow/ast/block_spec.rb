RSpec.describe PipeFlow::AST::Block do
  include MethodCallHelpers

  it_behaves_like 'a PipeFlow AST Node'

  let(:input_proc) { instance_double(Proc, parameters: parameters, lambda?: lambda?) }
  let(:parameters) { [] }
  let(:lambda?) { true }

  let(:instance) { described_class.new(input_proc) }
  subject { instance }

  describe '#reifiable?' do
    context 'given a nil-ary proc' do
      let(:input_proc) { proc { :test_value } }
      it { is_expected.not_to be_reifiable }
      it { is_expected.not_to be_lambda }
      context 'definition' do
        subject { super().to_definition }
        it { is_expected.to eq('proc { ... }') }
      end
    end

    context 'given a unary proc' do
      let(:input_proc) { proc { |x| x } }
      it { is_expected.to be_reifiable }
      it { is_expected.not_to be_lambda }
      context 'definition' do
        subject { super().to_definition }
        it { is_expected.to match(/proc { |x = [^,]+| ... }/) }
      end
    end

    context 'given an n-ary proc (n > 1)' do
      let(:input_proc) { proc { |a, b| a + b } }
      it { is_expected.to be_reifiable }
      it { is_expected.not_to be_lambda }
      context 'definition' do
        subject { super().to_definition }
        it { is_expected.to match(/proc { |a = [^,]+, b = [^,]+| ... }/) }
      end
    end

    context 'given a unary lambda' do
      let(:input_proc) { ->(x) { x } }
      it { is_expected.to be_reifiable }
      it { is_expected.to be_lambda }
      context 'definition' do
        subject { super().to_definition }
        it { is_expected.to eq('->(x) { ... }') }
      end
    end

    context 'given a nil-ary lambda' do
      let(:input_proc) { lambda { :test_value } }
      it { is_expected.not_to be_reifiable }
      it { is_expected.to be_lambda }
      context 'definition' do
        subject { super().to_definition }
        it { is_expected.to eq('-> { ... }') }
      end
    end

    context 'given a binary lambda' do
      let(:input_proc) { ->(x, y) { x + y } }
      it { is_expected.not_to be_reifiable }
    end

    context 'given a binary lambda with one optional parameter' do
      let(:input_proc) { ->(x, y = 2) { x + y } }
      it { is_expected.to be_reifiable }
    end
  end

  describe '#==' do
    let(:other_block) { described_class.new(other_proc) }

    context 'when a block uses an equivalent proc' do
      let(:other_proc) { input_proc }
      it 'considers the other block equivalent' do
        is_expected.to eq(other_block)
      end
    end

    context 'when a block uses a non-equivalent proc' do
      let(:other_proc) { instance_double(Proc, parameters: [], lambda?: false) }
      it 'considers the other block non-equivalent' do
        is_expected.not_to eq(other_block)
      end
    end
  end
end
