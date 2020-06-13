# frozen_string_literal: true

module PipeFlow
  module Parser
    #
    # A minimal parsing context that any pipeline code is executed within, handling partial
    # method evaluation.
    #
    class Context < Parser::BasicObject
      include Parser::VariableCapture
      include Errors

      SPECIAL_METHODS |= %i[input on].freeze

      # Environment to which pipeline evaluation should be considered
      # bound.
      attr_reader :bound_env

      def initialize(env)
        @bound_env = env
        rewrite_local_procs
      end

      alias parse! instance_eval

      private

      def method_missing(method_id, *args, &block)
        # `input` is considered a special, parser context method
        return super if SPECIAL_METHODS.include?(method_id)

        # This is done here because the AST is not expressive enough to capture all forms of
        # method calls, we let all complete calls or "too-partial" calls forward to the original
        # intended receiver.
        #
        # However, at this point we have the opportunity to catch potential misuse of partial
        # method calls as arguments to procs/other methods.
        reject_partials(method_id, args)

        AST::MethodCall.new(bound_env, method_id, args, &block).tap do |mc|
          # If we can't reify, just pass the call off to the original receiver and let the method
          # call happen, or raise a NoMethodError. Seems the best way to provide the proper error
          # context.
          return bound_env.receiver.public_send(method_id, *args, &block) unless mc.reifiable?
        end
      end

      def respond_to_missing?(method_id, include_private)
        # All method calls happen within the context of the bound_env, except
        # input. The parser context provides that method.
        SPECIAL_METHODS.include?(method_id) ||
          bound_env.receiver.send(:respond_to?, method_id, include_private)
      end

      def input(value = nil)
        return AST::Hole.instance if value.nil?

        AST::Literal.new(value)
      end

      def on(value)
        reject_partials(::Kernel.__method__, [value])
        ObjectProxy.new(value)
      end

      #
      # Take all local variables in the bound environment representing {Proc}s and
      # redefine them to raise a pipeline specific error if and only if any of the
      # arguments received are {AST::MethodCall partial method calls}.
      #
      # @return [void]
      # @raise (see #reject_partials)
      #
      def rewrite_local_procs
        bound_local_variables.select(&:proc?).each do |captured_proc|
          decorate_for_argument_check(captured_proc).write_to_env!
        end
      end

      #
      # Decorates a captured local {Proc} to reject any arguments that are
      # {AST::MethodCall partial method calls}.
      #
      # @param [VariableCapture::CapturedProc] captured_proc
      #
      # @return [VariableCapture::CapturedProc] unwritten proc variable with new, decorated value
      # @note The new value will not be written to the end, you must call
      # {VariableCapture::CapturedVar#write_to_env!} on the return value.
      #
      def decorate_for_argument_check(captured_proc)
        captured_proc.decorate do |original_proc, *args, &block|
          reject_partials(captured_proc.name, args)
          original_proc.call(*args, &block)
        end
      end
    end
  end
end
