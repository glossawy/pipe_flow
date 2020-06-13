# frozen_string_literal: true

module PipeFlow
  module CoreRefinements
    module PipeFlowNodes
      refine PipeFlow::Parser::ObjectProxy do
        def to_pipe_flow_node
          ::Kernel.raise Errors::UnreifiableNodeError,
                         'Proxies cannot be used as pipeline objects. For example, ' \
                         '`input(10) >> on(Math)` is invalid; however, ' \
                         '`input(10) >> on(Math).sqrt` is not.'
        end
      end

      refine Object do
        def to_pipe_flow_node
          AST::Literal.new(self)
        end
      end

      refine NilClass do
        def to_pipe_flow_node
          AST::Hole.instance
        end
      end

      refine Proc do
        def to_pipe_flow_node
          AST::Block.new(self)
        end
      end
    end
  end
end
