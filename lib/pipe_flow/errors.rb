module PipeFlow
  module Errors
    class InvalidSource < StandardError
      #
      # Create an instance of this error for the given {AST::Base} node.
      #
      # @param [AST::Base] source
      #
      # @return [InvalidSource]
      #
      def self.[](source)
        new msg_for(source)
      end

      def self.msg_for(node)
        case node
        when AST::MethodCall
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
      # @param [AST::Base] destination
      #
      # @return [InvalidDestination]
      #
      def self.[](destination)
        new msg_for(destination)
      end

      def self.msg_for(node)
        case node
        when AST::Literal
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

    #
    # Raises an error if and only if any values in the array of values are partial method
    # calls.
    #
    # @param [String,Symbol] referenced_name Name of containing scope
    #                        (i.e. name of method/proc variable)
    # @param [Array] values
    #
    # @return [values] if no partial method calls are found
    # @raise [Errors::MisplacedPartialError] if any of +values+ is a partial method call
    #
    def reject_partials(referenced_name, values)
      return values unless values.any? { |val| val.is_a? AST::MethodCall }

      ::Kernel.raise Errors::MisplacedPartialError,
                     'Found a partial method call as an argument to a proc or method' \
                     "(specifically to `#{referenced_name}`), this is likely programmer error. " \
                     'All non-pipeline methods should not be missing any arguments.'
    end
  end
end
