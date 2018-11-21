module PipeFlow
  module Parser
    module AST
      module Parameterized
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
            (lower_bound..upper_bound)
          end
        end

        private

        def lower_bound
          parameters.count(&:req?) +
            (has_keyreq_param? ? 1 : 0)
        end

        def upper_bound
          return Float::INFINITY if has_rest_param?

          parameters.count { |param| param.positional? && !param.rest? } +
            (has_keyword_param? ? 1 : 0)
        end

        def parameter_list
          parameters.map(&:to_s).join(', ')
        end

        Parameter::TYPES.each do |type|
          type_pred = "#{type}?".to_sym
          define_method("has_#{type}_param?") do
            parameters.any?(&type_pred)
          end
        end

        def has_keyword_param?
          parameters.any?(&:keyword?)
        end

        # rubocop:disable Style/AccessModifierDeclarations
        alias accepts_block? has_block_param?
        public(:accepts_block?)
        # rubocop:enable Style/AccessModifierDeclarations
      end
    end
  end
end
