module PipeFlow
  module Parser
    module AST
      #
      # Base PipeFlow AST Node, all other nodes should have this node as
      # an ancestor
      #
      # @abstract All subclasses should consider whether or not to declare itself as a
      #   {.source_only_node!} or {.destination_only_node!}, and should override {#to_h},
      #   {#to_s}, and {#input_needed?} as appropriate.
      class Base
        using CoreRefinements::ClassAttributes
        using CoreRefinements::PipeFlowNodes

        # @!method self.valid_source_node?
        #   Check if this node is a valid source node (not destination-only)
        #   @return [Boolean]
        # @!method self.valid_destination_node?
        #   Check if this node is a valid destination node (not source-only)
        #   @return [Boolean]

        # @!method valid_source_node?
        #   {include:Base.valid_source_node?}
        #   @return [Boolean]
        # @!method valid_destination_node?
        #   {include:Base.valid_destination_node?}
        #   @return [Boolean]
        class_attribute valid_source_node: true, valid_destination_node: true

        #
        # Mark node as a source-only node.
        #
        # This implies that this node is valid only as the left-hand side
        # (source end) of a pipeline. This provides metadata for future operations.
        #
        # As an example of such operations, {Visitors::Validator} will raise
        # {Errors::InvalidSource} if a source-only node is encountered on the
        # destination side of a {AST::Pipe}.
        #
        # @return [void]
        def self.source_only_node!
          self.valid_destination_node = false
        end

        #
        # Mark node as a destination-only node.
        #
        # This implies that this node is valid only as the right-hand side
        # (destination end) of a pipeline. This provides metadata for future operations.
        #
        # As an example of such operations, {Visitors::Validator} will raise
        # {Errors::InvalidDestination} if a destination-only node is encountered on the
        # source side of a {AST::Pipe}.
        #
        # @return [void]
        def self.destination_only_node!
          self.valid_source_node = false
        end

        #
        # Combine this node with a destination node as a {AST::Pipe}, treating
        # this node as the source.
        #
        # @param [AST::Base] other
        #
        # @return [AST::Pipe] resulting pipe where the output of this node is piped into the other
        #
        def >>(other)
          AST::Pipe.new(self, other.to_pipe_flow_node)
        end

        #
        # If this node is in the source position of a pipeline, does it need input?
        #
        # +false+ in this case means no input is needed and the pipeline can be immediately executed
        # +true+ would indicate that input is needed and the pipeline is non-executable at creation.
        #
        # @return [Boolean]
        #
        def input_needed?
          false
        end

        #
        # A human-readable representation of this node.
        #
        # @return [String]
        #
        def to_s
          self.class.name
        end

        #
        # Hash representation of the current AST, containing per-node metadata
        # with a minimum of the node type.
        #
        # @return [Hash]
        #
        def to_h
          { type: self.class }
        end

        # @!method to_pipe_flow_node
        #   @return [self]
        alias to_pipe_flow_node itself

        # @!method ==(other_node)
        #   @return [Boolean] whether or not this node is <i>structurally equivalent</i> to
        #           +other_node+
      end
    end
  end
end
