module PipeFlow
  module Errors
    class InvalidSource < StandardError
      def self.[](source)
        new msg_for(source)
        new "#{source.class.name} is an invalid pipeline source"
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
  end
end
