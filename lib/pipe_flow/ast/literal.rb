module PipeFlow
  module AST
    #
    # A PipeFlow AST node capturing literal values
    #
    # Currently, this node is source-only and as a source it represents
    # a constant function that always returns the literal value it
    # encapsulates.
    #
    # @pipe_flow.source_only
    class Literal < AST::Base
      source_only_node!

      # The captured literal value
      attr_reader :value

      #
      # @param [Object] value value to capture as a literal
      #
      def initialize(value)
        @value = value
      end

      # (see AST::Base#to_s)
      def to_s
        "Literal(#{value.inspect})"
      end

      # (see AST::Base#input_needed?)
      def input_needed?
        false
      end

      # (see Base#==)
      def ==(other)
        self.class == other.class &&
          value == other.value
      end
    end
  end
end
