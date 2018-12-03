RSpec.describe PipeFlow::Parser::BasicObject do
  class Test < PipeFlow::Parser::BasicObject; end
  let(:test_instance) { Test.new }
  describe '#class' do
    subject { test_instance.class }
    it 'returns the class of the object' do
      is_expected.to eq(Test)
    end
  end
end
