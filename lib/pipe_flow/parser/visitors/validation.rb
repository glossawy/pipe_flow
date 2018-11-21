module PipeFlow
  module Parser
    module Visitors
      class Validator < Visitors::Visitor
        alias validate visit

        # rubocop:disable Naming/MethodName
        def visit_PipeFlow_Parser_AST_Pipe(pipe)
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

        alias visit_PipeFlow_Parser_AST_Hole do_nothing
        alias visit_PipeFlow_Parser_AST_Literal do_nothing

        alias visit_PipeFlow_Parser_AST_MethodCall verify_reification
        alias visit_PipeFlow_Parser_AST_Block verify_reification
        # rubocop:enable Naming/MethodName
      end
    end
  end
end
