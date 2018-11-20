RSpec.describe PipeFlow::Parser::AST::Pipe do
  it_behaves_like 'a PipeFlow AST Node'

  let(:instance) { described_class.new(source, destination) }
  let(:source) { double('Source', to_h: {}, to_s: 'src') }
  let(:destination) { double('Destination', to_h: {}, to_s: 'dest') }

  subject { instance }

  describe '#to_h' do
    let(:source) { double('Source', to_h: {}) }
    let(:destination) { double('Destination', to_h: {}) }

    subject { super().to_h }

    it 'calls source and destination to_h', aggregate_failures: true do
      expect(source).to receive(:to_h)
      expect(destination).to receive(:to_h)
      subject
    end
  end

  describe '#to_s' do
    subject { super().to_s }

    it 'calls source and destination to_s', aggregate_failures: true do
      expect(source).to receive(:to_s)
      expect(destination).to receive(:to_s)
      subject
    end
  end

  describe '#==' do
    let(:other_pipe) { described_class.new(other_source, other_destination) }

    let(:other_source) { double('Other Source') }
    let(:other_destination) { double('Other Destination') }

    context 'matching source and destination' do
      it 'considers the two pipes equivalent', aggregate_failures: true do
        expect(source).to receive(:==).with(other_source).and_return(true)
        expect(destination).to receive(:==).with(other_destination).and_return(true)
        expect(subject).to eq(other_pipe)
      end
    end

    context 'non-equivalent sources or destinations' do
      before do
        allow(source).to receive(:==).with(anything).and_return(true)
        allow(destination).to receive(:==).with(anything).and_return(true)
      end

      %i[source destination].each do |let_name|
        it "considers two pipes equivalents when #{let_name}s are not equivalent", aggregate_failures: true do
          expect(send(let_name)).to receive(:==).with(send("other_#{let_name}")).and_return(false)
          expect(subject).not_to eq(other_pipe)
        end
      end
    end
  end
end
