module PipeFlow
  module Parser
    module Visitors
      class Validator < Visitors::Visitor
        alias validate visit

        def visit_PipeFlow_Parser_AST_Pipe(pipe)
          src = pipe.source
          dst = pipe.destination

          raise Errors::InvalidSource[src] unless src.valid_source_node?
          raise Errors::InvalidDestination[dst] unless dst.valid_destination_node?

          visit src
          visit dst
        end

        alias visit_PipeFlow_Parser_AST_Hole do_nothing
        alias visit_PipeFlow_Parser_AST_Literal do_nothing
        alias visit_PipeFlow_Parser_AST_MethodCall do_nothing
      end
    end
  end
end
