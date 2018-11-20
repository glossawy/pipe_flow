module PipeFlow
  module Parser
    module AST
      class Literal < AST::Base
        attr_reader :value

        source_only_node!

        def initialize(value)
          @value = value
        end

        def to_s
          "Literal(#{value.inspect})"
        end

        def input_needed?
          false
        end

        def ==(other)
          self.class == other.class &&
            value == other.value
        end
      end
    end
  end
end
