module PipeFlow
  module Parser
    class Context < BasicObject
      using CoreRefinements::PipeFlowNodes

      attr_reader :bound_env

      def initialize(env)
        @bound_env = env
      end

      alias parse! instance_eval

      def method_missing(method_id, *args)
        return super if method_id == :input

        AST::MethodCall.new(bound_env, method_id, args).tap do |mc|
          return bound_env.receiver.instance_eval { send(method_id, *args) } unless mc.reifiable?
        end
      end

      def respond_to_missing?(method_id, *args)
        bound_env.receiver.send(:respond_to?, method_id, include_private) ||
          (method_id == :input && super)
      end

      private

      def input(value = nil)
        value.to_pipe_flow_node
      end
    end
  end
end
