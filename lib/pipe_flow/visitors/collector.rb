module PipeFlow
  module Visitors
    #
    # AST visitor specialized to collecting derived values from the tree into
    # an array.
    #
    # @note +Collector+ is stateful and should only be used once.
    #
    class Collector < Visitors::Visitor
      extend Visitors::DSL

      #
      # Traverse AST collecting values into an internal array which is then
      # returned once collection is finished.
      #
      # @param object (see Visitor#visit)
      #
      # @return [Array] list of collected values
      #
      def collect(object)
        visit(object)
        collected
      end

      #
      # @return [Array] current list of collected values
      #
      def collected
        @collected ||= []
      end

      on_visit AST::Hole do |_hole|
        collected << ->(x) { x }
      end

      on_visit AST::Literal do |literal|
        value = literal.value
        collected << ->(_input) { value }
      end

      on_visit AST::MethodCall do |method_call|
        receiver = method_call.env.eval('self')
        method_name = method_call.method_id
        args = method_call.arguments

        collected << ->(x) { receiver.send(method_name, x, *args) }
      end

      on_visit AST::Pipe do |pipe|
        visit(pipe.source)
        visit(pipe.destination)
      end

      on_visit AST::Block do |block|
        collected << block.original_proc
      end
    end
  end
end
