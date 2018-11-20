RSpec.describe PipeFlow::Parser::Visitors::Validator do
  include ASTHelpers

  let(:instance) { described_class.new }
  subject { instance }

  context '#visit' do
    subject { super().visit(input) }
    let(:input) { PipeFlow::Parser::AST::Pipe.new(source, destination) }
    let(:source) { double('Source Node', valid_source_node?: true) }
    let(:destination) { double('Destination Node', valid_destination_node?: true) }

    it 'raises an invalid source error when the source is invalid' do
      allow(source).to receive(:valid_source_node?).and_return(false)
      allow(destination).to receive(:valid_destination_node?).and_return(true)
      expect { subject }.to raise_error(PipeFlow::Errors::InvalidSource)
    end

    it 'raises an invalid destination error when the destination is invalid' do
      allow(source).to receive(:valid_source_node?).and_return(true)
      allow(destination).to receive(:valid_destination_node?).and_return(false)
      expect { subject }.to raise_error(PipeFlow::Errors::InvalidDestination)
    end

    it 'visits the source and destination if both are valid', aggregate_failures: true do
      expect(instance).to receive(:visit).with(input).and_call_original
      expect(instance).to receive(:visit).with(source)
      expect(instance).to receive(:visit).with(destination)
      subject
    end
  end
end
