RSpec.describe PipeFlow::Parser::ObjectProxy do
  class TestProxyable
    def hypot2(a, b)
      (a ** 2) + (b ** 2)
    end
  end

  let(:instance) { described_class.new(proxied_object) }
  let(:proxied_object) { TestProxyable.new }

  context 'when calling methods that exist on the proxied object' do
    context 'that are partial' do
      subject { instance.hypot2(3) }

      it 'captures the call' do
        is_expected.to be_an_ast_methodcall
      end

      it 'does not execute the call' do
        expect(proxied_object).not_to receive(:hypot2)
        subject
      end

      it 'uses the proxied objects environment' do
        expect(subject.env.receiver).to eq(proxied_object)
      end
    end

    context 'that are complete' do
      subject { instance.hypot2(2, 3) }

      it 'executes the call on the proxied object' do
        allow_any_instance_of(Method).to receive(:parameters).and_return(TestProxyable.instance_method(:hypot2).parameters)
        expect(proxied_object).to receive(:hypot2).with(2, 3)
        subject
      end
    end

    context 'that have too few arguments to be useful' do
      subject { instance.hypot2 }

      it 'forwards the call to the proxied object', :aggregate_failures do
        allow_any_instance_of(Method).to receive(:parameters).and_return(TestProxyable.instance_method(:hypot2).parameters)
        expect(proxied_object).to receive(:hypot2).and_call_original
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  context 'when calling methods that do not exist on the proxied object' do
    subject { instance.not_real(23) }

    it 'forwards the call to the proxied object', :aggregate_failures do
      expect(proxied_object).to receive(:method).with('not_real').and_call_original
      expect { subject }.to raise_error(NameError)
    end
  end
end
