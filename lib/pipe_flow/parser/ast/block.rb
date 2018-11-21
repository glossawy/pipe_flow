module PipeFlow
  module Parser
    module AST
      class Block < AST::Base
        include AST::Parameterized

        destination_only_node!

        attr_reader :original_proc, :parameters

        def initialize(original_proc)
          @original_proc = original_proc
          @parameters = original_proc.parameters.map { |metadata| Parameter.new(*metadata) }
        end

        def reifiable?
          arity.min == 1 ||
            (arity.min.zero? && arity.max > 0)
        end

        alias input_needed? reifiable?

        def definition
          derive_definition_with(parameter_list)
        end

        def to_s
          return definition unless reifiable?

          params = parameter_list.gsub(/\A.+?,\s*(.+)\z/, '·, \1')
          derive_definition_with(params)
        end

        def to_h
          super.merge(
            derived_definition: definition,
            parameters: parameters.map(&:to_h),
            derived_arity: arity,
            reifiable: reifiable?
          )
        end

        def ==(other)
          self.class == other.class &&
            original_proc == other.original_proc
        end

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
