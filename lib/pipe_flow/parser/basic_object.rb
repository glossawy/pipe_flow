# frozen_string_literal: true

module PipeFlow
  module Parser
    class BasicObject < ::BasicObject
      # All method names that are accessible via this specialization of
      # {::BasicObject}. When subclasses implement dynamic method handling, they
      # are expected to allow these methods to bubble up via +super+.
      SPECIAL_METHODS = %i[class __send__ proc lambda exit exit!].freeze

      #
      # Define a delegate method that takes all arguments/blocks and
      # calls the method on {Kernel} with the same name.
      #
      # @param [Symbol,String] name
      #
      # @return dependent on return value of the corresponding {Kernel} method
      # @!macro [attach] kernel_method
      #   @!method $1(*args, &block)
      #     @note This method simply delegates to +Kernel.$1+, see core documentation
      #       corresponding to +Kernel.$1+ for more information.
      #
      def self.kernel_method(name)
        class_eval <<-RUBY, __FILE__, __LINE__ + 1
          def #{name}(*args, &block)
            ::Kernel.#{name}(*args, &block)
          end
        RUBY
      end

      #
      # Get the actual class of this object, this is a ruby re-implementation of
      # {::Kernel#class} for {Parser::BasicObject}s because {::BasicObject} itself
      # does not support a +class+ method.
      #
      # @return [Class] class of this object
      #
      def class
        # The superclass of a singleton class is the class it is a singleton of.
        # This is implied by method resolution.
        (class << self; self end).superclass
      end

      kernel_method :proc
      kernel_method :lambda
    end
  end
end
