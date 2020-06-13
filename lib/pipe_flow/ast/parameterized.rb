# frozen_string_literal: true

module PipeFlow
  module AST
    #
    # General utilities for managing nodes representing parameterized logic,
    # like blocks and method calls (i.e. thouse that have parameter lists).
    #
    # It is expected that the including +module+/+class+ defines a +#parameters+
    # method that returns an array of parameters in the format used by {Proc#parameters}.
    # That is +param_type+, +param_name+ pairs.
    #
    module Parameterized
      #
      # Returns an arity {Range} where the lower bound is the required number of arguments
      # (including a required options hash if a required keyword parameter exists) and the
      # upper bound is the maximum number of arguments (including an options hash if a
      # keyword parameter exists) which may be infinite.
      #
      # Because of ruby's support for optional positional and keyword parameters, the real
      # arity of a method is a range of values. Additionally, because of support for rest
      # parameters the upper limit can be, conceptually, infinite. To represent an infinite
      # upper bound, {Float::INFINITY} is used.
      #
      # @return [Range]
      #
      def arity
        @arity ||= begin
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

      #
      # Checks if any parameters are a block parameter (e.g. +&block+)
      #
      # @return [Boolean]
      #
      def accepts_block?
        has_block_param?
      end

      # @!method has_req_param?
      #   Checks if any parameters are positional and required
      #   @return [Boolean]

      # @!method has_opt_param?
      #   Checks if any parameters are positional and optional
      #   @return [Boolean]

      # @!method has_keyreq_param?
      #   Checks if any parameters are both a keyword parameter and required
      #   @return [Boolean]

      # @!method has_key_param?
      #   Checks if any parameters are both a keyword parameter and optional
      #   @return [Boolean]

      # @!method has_rest_param?
      #   Checks if any parameters are a rest parameter (e.g. +*args+)
      #   @return [Boolean]

      # @!method has_keyrest_param?
      #   Checks if any parameters are a keyword rest parameter
      #   (e.g. +**kwargs+)
      #   @return [Boolean]

      # @!method has_block_param?
      #   {include:Parameterized#accepts_block?}
      #   @return [Boolean]

      Parameter::TYPES.each do |type|
        type_pred = "#{type}?".to_sym
        define_method("has_#{type}_param?") do
          parameters.any?(&type_pred)
        end
      end

      #
      # checks if any parameters are a keyword parameter
      #
      # @return [Boolean]
      #
      def has_keyword_param?
        parameters.any?(&:keyword?)
      end

      #
      # checks if any parameters are a positional parameter
      #
      # @return [Boolean]
      #
      def has_positional_param?
        parameters.any?(:positional?)
      end

      # @!method reifiable?
      #   Reifiability determines representability and usability within the context of a pipeline.
      #   A parameterized node is reifiable if and only if it, with the metadata available, can
      #   reasonably be used as a _hole_ or _destination_ within a pipeline.
      #
      #   @example Distinction between Reifiable and Non-Reifiable for Method Calls
      #     def method_call(x, y, z)
      #       # ...
      #     end
      #     # Partial method calls *can* be conceived to have holes:
      #     method_call(1)          # => Possibly method_call(·, ·, z = 1) but is not reifiable
      #                             #    since it cannot fit in a single-value pipeline
      #     method_call(1, :a)      # => Possibly method_call(·, y = 1, z = :a) which is reifiable
      #     # Complete method calls *cannot* be conceived to have holes:
      #     method_call(1, :a, :b)  # => method_call(x = 1, y = :a, z = :b) and not reifiable
      #
      #
      #   @abstract
      #   @return [Boolean]
      #   @see AST::MethodCall example use in MethodCall
      #   @see AST::Block example use in Block

      # @!method to_representation
      #   Attempts to derive a sane string representing the conceptual meaning
      #   of the parameterized node in the pipeline.
      #
      #   @note Often this involves representing some parameter as a hole, hence the
      #         provision of {#parameter_list} and {#parameter_list_with_hole}.
      #
      #   @abstract
      #   @return [String]
      #   @see AST::MethodCall example use in MethodCall
      #   @see AST::Block example use in Block

      # @!method to_definition
      #   Attempts to derive a sane string representing a likely definition
      #   for the parameterized object.
      #
      #   @abstract
      #   @return [String]
      #   @see AST::MethodCall example use in MethodCall
      #   @see AST::Block example use in Block

      #
      # Attempts to determine a valid representation of the node, based on reifiability.
      #
      # If the node is reifiable, it will attempt to send {#to_representation}, otherwise it will
      # be considered not representable in the pipeline and a call to {#to_definition} will be
      # made.
      #
      # @note A client may decide to override and not use this method and may then forego defining
      #       {#reifiable?}, {#to_definition}, and {#to_representation}
      #
      # @return [String]
      # @see AST::MethodCall example use in MethodCall
      # @see AST::Block example use in Block
      #
      def to_s
        return to_definition unless reifiable?

        to_representation
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

      def parameter_list_with_hole
        parameters.drop(1)
                  .insert(0, '·')
                  .map(&:to_s)
                  .join(', ')
      end
    end
  end
end
