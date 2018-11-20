module PipeFlow
  module Parser
    module AST
      class Base
        using CoreRefinements::PipeFlowNodes

        def >>(other)
          AST::Pipe.new(self, other.to_pipe_flow_node)
        end

        def to_h
          { type: self.class }
        end

        alias to_pipe_flow_node itself
      end
    end
  end
end
