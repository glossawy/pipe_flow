module PipeFlow
  module Parser
    module Visitors
      #
      # AST visitor specialized to collecting derived values from the tree into
      # an array.
      #
      # @note +Collector+ is stateful and should only be used once.
      #
      class Collector < Visitors::Visitor
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

        # @!visibility

        # rubocop:disable Naming/MethodName
        def visit_PipeFlow_Parser_AST_Hole(_hole)
          collected << ->(x) { x }
        end

        def visit_PipeFlow_Parser_AST_Literal(literal)
          value = literal.value
          collected << ->(_input) { value }
        end

        def visit_PipeFlow_Parser_AST_MethodCall(method_call)
          receiver = method_call.env.eval('self')
          method_name = method_call.method_id
          args = method_call.arguments

          collected << ->(x) { receiver.send(method_name, x, *args) }
        end

        def visit_PipeFlow_Parser_AST_Pipe(pipe)
          visit(pipe.source)
          visit(pipe.destination)
        end

        def visit_PipeFlow_Parser_AST_Block(block)
          collected << block.original_proc
        end
        # rubocop:enable Naming/MethodName
      end
    end
  end
end
