RSpec.describe PipeFlow::Pipeline do
  def do_nothing(x)
    :test_result
  end

  describe '.from_block' do
    context 'a pipeline with immediate input' do
      subject do
        described_class.from_block do
          input(123) >> do_nothing
        end
      end

      it 'evaluates the block' do
        expect(self).to receive(:do_nothing).with(123)
        subject
      end

      it 'returns the expected result' do
        is_expected.to eq :test_result
      end
    end

    context 'a pipeline with non-immediate input' do
      subject do
        described_class.from_block do
          input >> do_nothing
        end
      end

      it 'does not evaluate the block' do
        expect(self).not_to receive(:do_nothing)
        subject
      end

      it 'returns a proc' do
        is_expected.to be_a Proc
      end

      it 'can be called', aggregate_failures: true do
        expect(self).to receive(:do_nothing).with(123).and_call_original
        expect(subject.call(123)).to eq(:test_result)
      end
    end

    context 'a pipeline with proc input' do
      let(:destination) { ->(x) { x } }
      let(:input) { ->(x) { x } }
      subject do
        described_class.from_block do
          input(input) >> destination
        end
      end

      it 'evaluates the block' do
        expect(destination).to receive(:call).with(input)
        subject
      end
    end
  end
end
