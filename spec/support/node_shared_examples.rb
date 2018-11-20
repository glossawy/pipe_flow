RSpec.shared_examples 'a PipeFlow AST Node' do
  it 'is a descendant of the base node class' do
    expect(described_class).to be < PipeFlow::Parser::AST::Base
  end

  describe '#to_h' do
    it 'includes node type' do
      expect(instance.to_h).to include(type: described_class)
    end
  end

  context 'interface' do
    %i[== to_s input_needed?].each do |method_id|
      it "implements #{method_id}" do
        expect(described_class.instance_methods(false)).to include(method_id)
      end
    end
  end
end
