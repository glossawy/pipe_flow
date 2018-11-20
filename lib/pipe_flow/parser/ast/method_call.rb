module PipeFlow
  module Parser
    module AST
      class MethodCall < AST::Base
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

        def accepts_block?
          parameters.any?(&:block?)
        end

        # :reek:TooManyStatements
        # rubocop:disable Metrics/AbcSize
        def arity
          @arity ||= begin
            # Because of ruby's support for optional positional and keyword parameters, the real
            # arity of a method is a range of values. Additionally, because of support for rest
            # parameters the upper limit can be, conceptually, infinite.
            #
            # 1. For the lower bound:
            #   a. (# of required positional parameters) + (1 if keyword parameters are required)
            #
            # 2. For the upper bound:
            #   a. (# of positional parameters) + (1 if any keyword parameters exist)
            #   b. OR, Infinity if a rest arguments exists.
            #
            # N.B.:
            #   - 2b) does not include keyrest (e.g. **kwargs)
            #   - #keyword? includes keyrest (thus contributing the the +1 in 2a)
            #   - #positional? includes rest, but is excluded in 2a from the count
            #

            lower_bound = parameters.count(&:req?)
            lower_bound += 1 if parameters.any?(&:keyreq?)

            upper_bound = parameters.count { |param| param.positional? && !param.rest? }
            upper_bound += 1 if parameters.any?(&:keyword?)

            upper_bound = Float::INFINITY if parameters.any?(&:rest?)

            (lower_bound..upper_bound)
          end
        end
        # rubocop:enable Metrics/AbcSize

        def definition
          "#{method_id}(#{parameters.map(&:to_s).join(', ')})"
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

          params = parameters.drop(1) | ['.']
          "#{method_id}(#{params.join(', ')})"
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
      end
    end
  end
end
