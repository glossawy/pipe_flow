# frozen_string_literal: true

module PipeFlow
  module Visitors
    #
    # Specialized class for traversing a pipeline AST
    #
    class Visitor
      #
      # Start a visitation recurrence for the given AST. It is expected that for any relevant
      # visitable <i>classes</i> of objects there exist a method for that class. Given a class
      # with the name +Some::Module::Path+, there ought to be a +visit_Some_Module_Path+ method
      # taking the visited object as an argument.
      #
      # If a method is not defined for the object's class, then if any methods are defined for
      # visiting any of an object's superclasses, visitation will be attempted on that method.
      #
      # @example Visiting an Object by Class
      #   class SomeVisitor < Visitor
      #     def visit_String(str)
      #       # ...
      #     end
      #   end
      #   SomeVisitor.new.visit('abc')
      #
      # @example Visiting an Object by Superclass
      #   class SomeVisitor < Visitor
      #     def visit_Object(obj)
      #       # ...
      #     end
      #   end
      #   SomeVisitor.new.visit('abc')
      #
      # @note It is recommended that visitor implementations extend {Visitors::DSL} rather
      #       than write method names manually.
      #
      # @param object Any object, though typically an {AST::Base} instance
      #
      # @return a visitor dependent value, possibly meaningless
      # @raise [TypeError] if no +visit_+ method exists for the class of +object+ nor any
      #                    of it's superclasses.
      #
      def visit(object)
        find_visitable_method_for(object.class) do |visit_method_id|
          return send(visit_method_id, object)
        end

        raise TypeError, "Unable to visit #{object.class}"
      end

      #
      # Does nothing with the given object, this is provided as a utility for visitors to
      # point methods to when a class is valid to visit, but has no meaningful semantics.
      #
      #
      # @param object
      #
      # @return [object] the given object
      #
      def do_nothing(object)
        object
      end

      private

      #
      # Attempts to derive an appropriate +visit_+ method to call based on a class
      # and it's superclasses.
      #
      # @param [Class] klass class we are trying to visit
      #
      # @yieldparam [Symbol] method_id if a visitable method is found
      # @return [Object,nil] result of block, or nil if no method found
      #
      def find_visitable_method_for(klass)
        method_id = method_for_class(klass)
        method_id = visitable_supermethod_for(klass) unless respond_to?(method_id, true)

        yield method_id if method_id
      end

      def method_for_class(klass)
        method_suffix = (klass.name || '').gsub('::', '_')
        "visit_#{method_suffix}"
      end

      #
      # Find a +visit_+ method for one of a class' parents.
      #
      # @param [Class] klass class we are trying to visit
      #
      # @return [Symbol,nil] a method id to visit, or nil if none found
      #
      def visitable_supermethod_for(klass)
        klass.ancestors
             .map { |superclass| method_for_class(superclass) }
             .find { |supermethod| respond_to?(supermethod) }
      end
    end
  end
end
