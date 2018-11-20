require 'singleton'

module PipeFlow
  module Parser
    module AST
      class Hole < AST::Base
        include ::Singleton

        def to_s
          'hole(·)'
        end

        def input_needed?
          true
        end

        alias == equal?
      end
    end
  end
end
