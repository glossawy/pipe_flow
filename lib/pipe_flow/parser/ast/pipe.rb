module PipeFlow
  module Parser
    module AST
      class Pipe < AST::Base
        attr_reader :source, :destination
        def initialize(source, destination)
          @source = source
          @destination = destination
        end

        def to_h
          super.merge(
            source: source.to_h,
            destination: destination.to_h
          )
        end

        def to_s
          "#{source} >> #{destination}"
        end

        def ==(other)
          self.class == other.class &&
            source == other.source &&
            destination == other.destination
        end
      end
    end
  end
end
