RSpec.describe PipeFlow::Parser::Visitors::Visitor do
  let(:instance) { described_class.new }
  subject { instance }

  SuperTestClass = Class.new
  TestClass = Class.new(SuperTestClass)
  TestError = Class.new(StandardError)

  describe '#visit' do
    let(:input) { TestClass.new }
    subject { super().visit(input) }

    it 'tries to call visit_TestClass' do
      expect(instance).to receive(:visit_TestClass).with(input)
      subject
    end

    context 'without visit_TestClass defined' do
      it 'raises a type error' do
        expect { subject }.to raise_error(TypeError)
      end
    end

    context 'with visit_TestClass defined' do
      before { allow(instance).to receive(:visit_TestClass).with(input, &method_body) }
      let(:method_body) { proc {} }

      context 'that raises an error' do
        let(:method_body) { proc { raise TestError } }

        it 'allows that error to bubble up' do
          expect { subject }.to raise_error(TestError)
        end
      end

      context 'that calls an undefined method' do
        let(:method_body) { proc { undefined_method } }

        it 'allows that error to bubble up' do
          expect { subject }.to raise_error(NameError)
        end
      end
    end

    context 'with visit_SuperTestClass defined' do
      before { allow(instance).to receive(:visit_SuperTestClass).with(input) }

      it 'does not raise an error' do
        expect { subject }.not_to raise_error
      end

      it 'calls the visit method for the superclass instead (visit_SuperTestClass)' do
        expect(instance).to receive(:visit_SuperTestClass).with(input)
        subject
      end
    end
  end
end
