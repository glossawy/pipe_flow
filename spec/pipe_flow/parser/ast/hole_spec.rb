RSpec.describe PipeFlow::Parser::AST::Hole do
  it_behaves_like 'a PipeFlow AST Node'

  let(:instance) { described_class.instance }

  it 'cannot be instantiated' do
    expect { described_class.new }.to raise_error(::NoMethodError)
  end
end
