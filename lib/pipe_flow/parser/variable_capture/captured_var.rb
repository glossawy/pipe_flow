module PipeFlow
  module Parser
    module VariableCapture
      #
      # Representation of a local variable in an environment.
      #
      class CapturedVar
        attr_reader :env, :name, :value

        # Whether or not the value is "written"/set in the environment.
        attr_reader :written

        def initialize(env, name, value, written)
          @env = env
          @name = name
          @value = value
          @written = written
        end

        alias written? written

        #
        # @return [Boolean] is this variable a {Proc}?
        #
        def proc?
          value.is_a? Proc
        end

        #
        # Set the current value of this variable in the bound environment. This
        # effectively delegates to #{Binding#local_variable_set} and ensures
        # {#written} is set to +true+.
        #
        # @return [void]
        #
        def write_to_env!
          env.local_variable_set(name, value)
          @written = true
        end
      end
    end
  end
end
