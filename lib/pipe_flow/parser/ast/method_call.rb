module PipeFlow
  module Parser
    module AST
      class MethodCall < AST::Base
        include AST::Parameterized

        destination_only_node!

        attr_reader :env, :method_id, :arguments, :parameters, :block
        def initialize(env, method_id, arguments, &block)
          @env = env
          @method_id = method_id
          @arguments = arguments
          @block = block
          @parameters = env.eval("method('#{method_id}').parameters")
                           .map { |metadata| Parameter.new(*metadata) }
        end

        def reifiable?
          # For a method call to be reifiable into a PipeFlow representation, it must
          # be resolvable in the bound environment and we must be given enough arguments
          # such that only 1 required argument could remain (the leftmost one) to be filled.

          !contains_method_call? && required_arity?
        end

        def definition
          derive_definition_with(parameter_list)
        end

        def input_needed?
          reifiable?
        end

        def to_h
          super.merge(
            derived_definition: definition,
            method_id: method_id,
            parameters: parameters.map(&:to_h),
            derived_arity: arity,
            arg_count: arguments.size,
            reifiable: reifiable?
          )
        end

        def to_s
          return definition unless reifiable?

          param_list = parameter_list.gsub(/\A.+?,\s*(.+)\z/, '·, \1')
          derive_definition_with(param_list)
        end

        # rubocop:disable Metrics/AbcSize
        def ==(other)
          self.class == other.class &&
            method_id == other.method_id &&
            env == other.env &&
            parameters == other.parameters &&
            arguments == other.arguments
        end
        # rubocop:enable Metrics/AbcSize

        private

        def contains_method_call?
          # If one of the arguments is also a method call then that would mean we are
          # expected to fill a hole from the pipeline. This is not supported, all parameters
          # to a pipelined method must resolve to a value/object.

          arguments.any? { |arg| arg.is_a?(MethodCall) }
        end

        def required_arity?
          return false if arity.size.zero? # Nil arity

          # The focus here is to ensure that we have exactly the right
          # number of arguments to leave the left-most argument open for the
          # pipeline to fill.

          nargs = arguments.size
          minimum_for_pipeline = arity.min - 1

          (minimum_for_pipeline...arity.max).cover?(nargs)
        end

        def derive_definition_with(param_list)
          "#{method_id}(#{param_list})"
        end
      end
    end
  end
end
