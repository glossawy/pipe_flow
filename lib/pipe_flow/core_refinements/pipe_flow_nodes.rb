module PipeFlow
  module CoreRefinements
    module PipeFlowNodes
      refine Object do
        def to_pipe_flow_node
          Parser::AST::Literal.new(self)
        end
      end

      refine NilClass do
        def to_pipe_flow_node
          Parser::AST::Hole.instance
        end
      end
    end
  end
end
