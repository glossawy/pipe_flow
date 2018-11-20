RSpec.describe PipeFlow::Pipeline do
  def puts_and_return(x)
    puts x
    :test_result
  end

  describe '.from_block' do
    context 'a pipeline with immediate input' do
      subject do
        described_class.from_block do
          input(123) >> puts_and_return
        end
      end

      it 'evaluates the block' do
        expect(self).to receive(:puts).with(123)
        subject
      end

      it 'returns the expected result' do
        is_expected.to eq :test_result
      end
    end

    context 'a pipeline with non-immediate input' do
      subject do
        described_class.from_block do
          input >> puts_and_return
        end
      end

      it 'does not evaluate the block' do
        expect(self).not_to receive(:puts)
        subject
      end

      it 'returns a proc' do
        is_expected.to be_a Proc
      end

      it 'can be called', aggregate_failures: true do
        expect(self).to receive(:puts).with(123)
        expect(subject.call(123)).to eq(:test_result)
      end
    end
  end
end
