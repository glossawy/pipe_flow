RSpec.describe PipeFlow::Parser::AST::Parameterized do
  include RandomDataHelpers

  let(:parameterized_double) { double('Parameterized') }
  let(:parameters) { [] }

  before do
    parameter_list = parameters.map { |(type, name)| PipeFlow::Parser::AST::Parameterized::Parameter.new(type, name) }
    allow(parameterized_double).to receive(:parameters).and_return(parameter_list)
    parameterized_double.singleton_class.send(:include, described_class)
  end

  describe '.to_s' do
    subject { parameterized_double.to_s }
    context 'when object is reifiable' do
      before do
        allow(parameterized_double).to receive(:reifiable?).and_return(true)
      end

      it 'calls #to_representation', :aggregate_failures do
        test_result = random_string
        expect(parameterized_double).to receive(:to_representation).and_return(test_result)
        is_expected.to eq(test_result)
      end
    end

    context 'when object is not reifiable' do
      before do
        allow(parameterized_double).to receive(:reifiable?).and_return(false)
      end

      it 'calls #to_definition', :aggregate_failures do
        test_result = random_string
        expect(parameterized_double).to receive(:to_definition).and_return(test_result)
        is_expected.to eq(test_result)
      end
    end
  end
end
