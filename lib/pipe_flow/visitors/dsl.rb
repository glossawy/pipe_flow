module PipeFlow
  module Visitors
    #
    # A DSL for defining visit methods for various types, with support for aliasing
    # on types and methods. The main utility is deriving the visit method name that
    # is compatible with {Visitor#visit}.
    #
    module DSL
      #
      # Define a visit method for the given type with the specified
      # method definition given as a block.
      #
      # @param [Class] type Class that may be visited
      #
      # @yieldparam object object being visited
      # @return [void]
      #
      def on_visit(type, &block)
        define_method(method_name_for(type), &block)
      end

      #
      # Define a visit method for the given type that does nothing,
      # the method body is literally blank.
      #
      # @param (see #on_visit)
      #
      # @return (see #on_visit)
      #
      def on_visit_skip(type)
        on_visit(type) { |_| }
      end

      #
      # Define a visit method for the given type that aliases another
      # visit method, or aliases any other method.
      #
      # When given a {Class} to alias to, the visit method name will
      # be derived an aliased to, otherwise, given a symbol or string,
      # a direct alias via {Module#alias_method}.
      #
      # @param (see #on_visit)
      # @param [Class,Symbol,String] to Type or method name to alias to
      #
      # @return (see #on_visit)
      # @raise [TypeError] if given neither a {Class}, {Symbol}, or {String}
      #
      def alias_visit(type, to:)
        case to
        when Class then alias_to_type(type, to)
        when String, Symbol then alias_to_method(type, to)
        else raise TypeError, 'Can only alias visit to types (Classes) or ' \
                              'method names (Strings/Symbols).'
        end
      end

      private

      def alias_to_type(type, other_type)
        alias_to_method(type, method_name_for(other_type))
      end

      def alias_to_method(type, method)
        alias_method(method_name_for(type), method)
      end

      def method_name_for(type)
        path = type.name.split('::')
        path.shift if path.first.empty?

        underscored = path.join('_')
        "visit_#{underscored}"
      end
    end
  end
end
