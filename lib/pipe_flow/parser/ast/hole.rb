require 'singleton'

module PipeFlow
  module Parser
    module AST
      class Hole < AST::Base
        include ::Singleton

        def to_s
          'hole(·)'
        end

        alias == equal?
      end
    end
  end
end
