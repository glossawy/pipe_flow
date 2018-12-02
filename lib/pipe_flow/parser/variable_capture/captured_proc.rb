module PipeFlow
  module Parser
    module VariableCapture
      #
      # Representation of a variable containing a {Proc} in an environment.
      #
      class CapturedProc < CapturedVar
        # (see CapturedVar#proc?)
        def proc?
          true
        end

        #
        # @return [Boolean] whether or not this proc is a lambda.
        #
        def lambda?
          value.lambda?
        end

        #
        # Create a new proc with some additional operations performed around the current
        # implementation. This works by passing the current {Proc} and received arguments/block
        # to the decorator.
        #
        # @note It is expected that the decorator function call the original implementation at
        #   some point.
        #
        # @yieldparam [Proc] current_proc The current value of this captured proc
        # @yieldparam *args received arguments
        # @yieldparam &block received block
        #
        # @return [CapturedProc] New captured proc with a new value representing the decorated
        #   proc
        #
        def decorate(&decorator)
          decorated_value = dispatch_by_type(__method__, &decorator)
          CapturedProc.new(env, name, decorated_value, false)
        end

        private

        def decorate_lambda(&decorator)
          current_value = value
          ->(*args, &block) { decorator.call(current_value, *args, &block) }
        end

        def decorate_proc(&decorator)
          current_value = value
          proc { |*args, &block| decorator.call(current_value, *args, &block) }
        end

        def dispatch_by_type(id_prefix, *args, &block)
          return __send__("#{id_prefix}_lambda", *args, &block) if lambda?

          __send__("#{id_prefix}_proc", *args, &block)
        end
      end
    end
  end
end
