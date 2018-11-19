module PipeFlow
  module Parser
    module AST
      class Literal < AST::Base
        attr_reader :value
        def initialize(value)
          @value = value
        end

        def to_s
          "Literal(#{value.inspect})"
        end

        def ==(other)
          self.class == other.class &&
            self.value == other.value
        end
      end
    end
  end
end
