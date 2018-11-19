module PipeFlow
  module Parser
    module AST
      class Base
        def >>(other)
          AST::Pipe.new(self, other)
        end

        def to_h
          { type: self.class }
        end
      end
    end
  end
end
