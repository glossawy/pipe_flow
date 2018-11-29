module PipeFlow
  module Parser
    module AST
      #
      # A PipeFlow AST node representing a literal +proc+ (lambda or not).
      # As a destination node, the input is simply passed to the +proc+ it
      # is wrapping and the result is forwarded on.
      #
      # @pipe_flow.destination_only
      class Block < AST::Base
        include AST::Parameterized

        # N.B. input(<proc>) => Literal(<proc>), not Block(<proc>)
        destination_only_node!

        attr_reader :original_proc, :parameters

        def initialize(original_proc)
          @original_proc = original_proc
          @parameters = original_proc.parameters.map { |metadata| Parameter.new(*metadata) }
        end

        #
        # {include:Parameterized#reifiable?}
        #
        # Whether or not it is possible to use the +proc+ in a pipeline.
        # There must be exactly one _required_ parameter OR zero required
        # parameters and at least one optional parameter.
        #
        # @example Reifiable procs
        #   ->(x) { ... }                  # One required parameter
        #   ->(x, y = 2, z: 3) { ... }     # Many parameters, only one is required
        #   proc { |x, y, z, *args| ... }  # all parameters are optional in a proc
        # @example Non-reifiable proc
        #   # two required parameters
        #   ->(x, y) { ... }
        #
        # @return (see Parameterized#reifiable?)
        #
        def reifiable?
          arity.min == 1 ||
            (arity.min.zero? && arity.max > 0)
        end

        alias input_needed? reifiable?

        # (see Base#to_h)
        def to_h
          super.merge(
            derived_definition: to_definition,
            parameters: parameters.map(&:to_h),
            derived_arity: arity,
            reifiable: reifiable?
          )
        end

        #
        # {include:Parameterized#to_definition}
        #
        # @example Proc
        #   block = AST::Block.new(proc { |x, y = 2| x + y })
        #   block.definition  # => "proc { |x, y = <value>| ... }"
        # @example Lambda
        #   block = AST::Block.new(->(x, y = 2, *args, z:) { x + y + args.sum - z })
        #   block.definition  # => "->(x, y = <value>, *args, z:) { ... }"
        #
        # @return (see Parameterized#to_definition)
        #
        def to_definition
          derive_definition_with(parameter_list)
        end

        #
        # {include:Parameterized#to_representation}
        #
        # @example Proc
        #   block = AST::Block.new(proc { |x, y = 2| x + y })
        #   block.definition  # => "proc { |·, y = <value>| ... }"
        # @example Lambda
        #   block = AST::Block.new(->(x, y = 2, *args, z: 2) { x + y + args.sum - z })
        #   block.definition  # => "->(·, y = <value>, *args, z: <value>) { ... }"
        #
        # @return (see Parameterized#to_representation)
        #
        def to_representation
          derive_definition_with(parameter_list_with_hole)
        end

        # (see Base#==)
        def ==(other)
          self.class == other.class &&
            original_proc == other.original_proc
        end

        # @see Proc#lambda?
        def lambda?
          original_proc.lambda?
        end

        private

        def derive_definition_with(param_list)
          if lambda?
            derive_lambda_definition(param_list)
          else
            derive_proc_definition(param_list)
          end
        end

        def derive_lambda_definition(param_list)
          return '-> { ... }' if parameters.empty?

          "->(#{param_list}) { ... }"
        end

        def derive_proc_definition(param_list)
          return 'proc { ... }' if parameters.empty?

          "proc { |#{param_list}| ... }"
        end
      end
    end
  end
end
