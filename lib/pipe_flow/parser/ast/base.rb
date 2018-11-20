module PipeFlow
  module Parser
    module AST
      class Base
        using CoreRefinements::ClassAttributes
        using CoreRefinements::PipeFlowNodes

        class_attribute valid_source_node: true, valid_destination_node: true

        def self.source_only_node!
          self.valid_destination_node = false
        end

        def self.destination_only_node!
          self.valid_source_node = false
        end

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
