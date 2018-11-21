module PipeFlow
  module Parser
    class Context < BasicObject
      attr_reader :bound_env

      def initialize(env)
        @bound_env = env
      end

      alias parse! instance_eval

      def method_missing(method_id, *args, &block)
        return super if method_id == :input

        AST::MethodCall.new(bound_env, method_id, args, &block).tap do |mc|
          unless mc.reifiable?
            return bound_env.receiver.instance_eval { send(method_id, *args, &block) }
          end
        end
      end

      def respond_to_missing?(method_id, include_private)
        bound_env.receiver.send(:respond_to?, method_id, include_private) ||
          (method_id == :input && super)
      end

      private

      def input(value = nil)
        return AST::Hole.instance if value.nil?

        AST::Literal.new(value)
      end
    end
  end
end
