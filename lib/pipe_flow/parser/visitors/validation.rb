module PipeFlow
  module Parser
    module Visitors
      #
      # AST Visitor specialized in validating AST structure.
      #
      class Validator < Visitors::Visitor
        extend Visitors::DSL

        #
        # Traverse AST tree rooted at +object+ and ensure validity
        # of tree structure.
        #
        # @param (see Visitor#visit)
        #
        # @return (see Visitor#visit)
        # @raise [Errors::InvalidSource] if any node is in a source position, but is not a valid
        #                                source in the pipeline.
        # @raise [Errors::InvalidDestination] if any node is in a destination position, but is
        #                                     not a valid destination in the pipeline.
        # @raise [Errors::UnreifiableNodeError] if any parameterized node is non-reifiable.
        #
        def validate(object)
          visit(object)
        end

        # @!visibility private

        on_visit AST::Pipe do |pipe|
          src = pipe.source
          dst = pipe.destination

          raise Errors::InvalidSource[src] unless src.valid_source_node?
          raise Errors::InvalidDestination[dst] unless dst.valid_destination_node?

          visit src
          visit dst
        end

        def verify_reification(node)
          raise Errors::UnreifiableNodeError, "Cannot reify #{node}" unless node.reifiable?
        end

        on_visit_skip AST::Hole
        on_visit_skip AST::Literal

        alias_visit AST::MethodCall, to: :verify_reification
        alias_visit AST::Block, to: :verify_reification
      end
    end
  end
end
