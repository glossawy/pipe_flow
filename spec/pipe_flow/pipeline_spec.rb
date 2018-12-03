# These are effectively basic integration tests
RSpec.describe PipeFlow::Pipeline do
  def do_nothing(x)
    :test_result
  end

  def reflect(*args)
    args
  end

  def hypotenuse(a, b)
    Math.sqrt(a*a + b*b)
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

    context 'a pipeline with a side-effecting proc' do
      context 'with a partial as an argument' do
        subject do
          side_effect = 20
          local_proc = -> (x) { side_effect += x }
          described_class.from_block do
            input(10) >> reflect(local_proc[hypotenuse(4)], side_effect)
          end
        end

        it 'raises a misplaced partial error' do
          expect { subject }.to raise_error(PipeFlow::Errors::MisplacedPartialError)
        end
      end

      context 'with a complete method as an argument' do
        subject do
          side_effect = 20
          local_proc = ->(x) { side_effect += x }
          described_class.from_block do
            input(10) >> reflect(side_effect, hypotenuse(3, 4), local_proc[hypotenuse(3, 4)], side_effect)
          end
        end

        it 'returns the expected output' do
          is_expected.to contain_exactly(10, 20, 5, 25, 25)
        end
      end

      context 'with a partial method as an argument to a proc' do
        subject do
          side_effect = 20
          local_proc = proc { |x| side_effect += x }
          described_class.from_block do
            input(10) >> reflect(side_effect, hypotenuse(3, 4), local_proc[hypotenuse(4)], side_effect)
          end
        end

        it 'raises a misplaced partial error' do
          expect { subject }.to raise_error(PipeFlow::Errors::MisplacedPartialError)
        end
      end
    end

    context 'a pipeline with a partial method as an argument' do
      subject do
        described_class.from_block do
          input(10) >> reflect(hypotenuse(4))
        end
      end

      it 'raises a misplaced partial error' do
        expect { subject }.to raise_error(PipeFlow::Errors::MisplacedPartialError)
      end
    end

    context 'a pipeline using a proxied value' do
      context 'correctly' do
        subject do
          described_class.from_block do
            input(/\Atest_/) >> on('test_string').gsub('changed_')
          end
        end

        it 'returns the expected ouput' do
          is_expected.to eq('changed_string')
        end
      end

      context 'correctly with a constant' do
        subject do
          described_class.from_block do
            input(25) \
              >> on(Math).sqrt \
              >> on(Math).hypot(12) \
              >> reflect(:test_symbol)
          end
        end

        it 'returns the expected output' do
          is_expected.to contain_exactly(13, :test_symbol)
        end
      end

      context 'incorrectly by not calling a method on the proxy' do
        subject do
          described_class.from_block do
            input(25) >> on(Math)
          end
        end

        it 'raises an unreifiable node error' do
          expect { subject }.to raise_error(PipeFlow::Errors::UnreifiableNodeError)
        end
      end
    end
  end

  context 'as a refinement' do
    using PipeFlow::Pipeline

    subject do
      pipeline do
        side_effect = 20
        local_proc = ->(x) { side_effect += x }
        inpurt(10) >> reflect(side_effect, hypotenuse(3, 4), local_proc[hypotenuse(3,4)], side_effect)
      end

      it 'returns the expected output' do
        is_expected.to contain_exactly(10, 20, 5, 25, 25)
      end
    end
  end
end
