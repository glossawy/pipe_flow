require 'singleton'

module PipeFlow
  module Parser
    module AST
      #
      # A PipeFlow AST representing a _missing_ value. This should only appear
      # at the front of a pipeline, but does not need to. If a destination is a {Hole}
      # then it's behavior is equivalent to the identity function.
      #
      # Since this is similar to a +nil+, only a single instance exists.
      class Hole < AST::Base
        include ::Singleton

        # (see AST::Base#to_s)
        def to_s
          'hole(·)'
        end

        # (see AST::Base#input_needed?)
        def input_needed?
          true
        end

        alias == equal?
      end
    end
  end
end
