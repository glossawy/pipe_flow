module PipeFlow
  module Parser
    module Visitors
      class Collector < Visitors::Visitor
        alias collect visit

        def collected
          @collected ||= []
        end

        # rubocop:disable Naming/MethodName
        def visit_PipeFlow_Parser_AST_Hole(_hole)
          collected << ->(x) { x }
        end

        def visit_PipeFlow_Parser_AST_Literal(literal)
          value = literal.value
          value = ->(_input) { value } unless value.is_a?(Proc)
          collected << value
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
        # rubocop:enable Naming/MethodName
      end
    end
  end
end
