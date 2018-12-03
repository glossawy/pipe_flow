module PipeFlow
  module Parser
    class ObjectProxy < Parser::BasicObject
      include Errors

      attr_reader :bound_env, :receiver

      def initialize(receiver)
        @bound_env = receiver.instance_eval { binding }
        @receiver = receiver
      end

      private

      def method_missing(method_id, *args, &block)
        return super if SPECIAL_METHODS.include?(method_id)

        reject_partials(method_id, args)

        AST::MethodCall.new(bound_env, method_id, args, &block).tap do |mc|
          return receiver.public_send(method_id, *args, &block) unless mc.reifiable?
        end
      end

      def respond_to_missing?(method_id, include_private)
        SPECIAL_METHODS.include?(method_id) ||
          receiver.respond_to?(method_id, include_private)
      end
    end
  end
end
