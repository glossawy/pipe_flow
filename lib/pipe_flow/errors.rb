module PipeFlow
  module Errors
    class InvalidSource < StandardError
      #
      # Create an instance of this error for the given {Parser::AST::Base} node.
      #
      # @param [Parser::AST::Base] source
      #
      # @return [InvalidSource]
      #
      def self.[](source)
        new msg_for(source)
      end

      def self.msg_for(node)
        case node
        when Parser::AST::MethodCall
          'An incomplete method call is a valid right-hand side of a pipeline but not ' \
          "a valid left-hand side (#{node} >> ... is invalid)"
        else
          "#{node.class.name} is unexpected on the left-hand side of a pipeline " \
          "(#{node} >> ... is unexpected)"
        end
      end
    end

    class InvalidDestination < StandardError
      #
      # {include:InvalidSource.[]}
      #
      # @param [Parser::AST::Base] destination
      #
      # @return [InvalidDestination]
      #
      def self.[](destination)
        new msg_for(destination)
      end

      def self.msg_for(node)
        case node
        when Parser::AST::Literal
          "#{node.value} cannot be the right-hand side of a pipeline " \
          "(... >> #{node} is invalid)"
        else
          "#{node.class.name} is unexpected on the right-hand side of a pipeline " \
          "(... >> #{node} is unexpected)"
        end
      end
    end

    UnreifiableNodeError = Class.new(StandardError)
    MisplacedPartialError = Class.new(StandardError)
  end
end
