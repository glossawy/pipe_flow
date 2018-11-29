module PipeFlow
  module Parser
    module AST
      #
      # <Description>
      #
      class Pipe < AST::Base
        attr_reader :source, :destination
        def initialize(source, destination)
          @source = source
          @destination = destination
        end

        # (see AST::Base#input_needed?)
        def input_needed?
          source.input_needed?
        end

        # (see AST::Base#to_h)
        def to_h
          super.merge(
            source: source.to_h,
            destination: destination.to_h
          )
        end

        # (see AST::Base#to_s)
        def to_s
          "#{source} >> #{destination}"
        end

        # (see Base#==)
        def ==(other)
          self.class == other.class &&
            source == other.source &&
            destination == other.destination
        end
      end
    end
  end
end
