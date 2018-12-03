RSpec.describe PipeFlow::AST::Hole do
  it_behaves_like 'a PipeFlow AST Node'

  let(:instance) { described_class.instance }
  subject { instance }

  it 'cannot be instantiated' do
    expect { described_class.new }.to raise_error(::NoMethodError)
  end

  it 'requires input' do
    expect(subject.input_needed?).to be true
  end
end
