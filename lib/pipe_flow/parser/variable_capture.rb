module PipeFlow
  module Parser
    #
    # Utilities for managing local variables in a bound environment.
    #
    # @note It is expected that a {#bound_env} method exist
    #
    module VariableCapture
      #
      # Collect all captured variables from the local environment. The types representing the
      # variables are determined by the types of the values. That is, if a variable has a value
      # that is also a {Proc}, then it will be represented as a {CapturedProc}. The default is
      # {CapturedVar}.
      #
      # @return [Array<CapturedVar>] all local variables in the bound environment
      #
      def bound_local_variables
        lvars = bound_env.local_variables
        lvars.map { |varname| capture_variable(varname) }
      end

      private

      def capture_variable(varname)
        value = bound_env.local_variable_get(varname)
        typename = value.class.name.gsub(/\A::/, '')

        preferred_capture_type = "Captured#{typename}"
        capture_type = VariableCapture::CapturedVar

        if VariableCapture.const_defined?(preferred_capture_type)
          capture_type = VariableCapture.const_get(preferred_capture_type)
        end

        capture_type.new(bound_env, varname, value, true)
      end
    end
  end
end
