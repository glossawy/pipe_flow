RSpec.describe PipeFlow::Parser::AST::Literal do
  it_behaves_like 'a PipeFlow AST Node'

  subject { instance }
  let(:instance) { described_class.new(input_value) }
  let(:input_value) { double('Input') }

  describe '#==' do
    let(:other_literal) { described_class.new(other_value) }
    let(:other_value) { double('Other Input') }

    context 'when internal values are equivalent', aggregate_failures: true do
      it 'considers the literals equivalent' do
        expect(input_value).to receive(:==).with(other_value).and_return(true)
        expect(subject).to eq(other_literal)
      end
    end

    context 'when internal values are not equivalent' do
      it 'considers the literals non-equivalent', aggregate_failures: true do
        expect(input_value).to receive(:==).with(other_value).and_return(false)
        expect(subject).not_to eq(other_literal)
      end
    end
  end
end
