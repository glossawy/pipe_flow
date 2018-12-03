# frozen_string_literal: true

module PipeFlow
  module AST
    module Parameterized
      class Parameter
        attr_reader :type, :name

        TYPE_FORMATS = {
          req: '%s',
          opt: '%s = <value>',
          rest: '*%s',
          key: '%s: <value>',
          keyreq: '%s:',
          keyrest: '**%s',
          block: '&%s',
        }.freeze

        TYPES = TYPE_FORMATS.keys.freeze

        def initialize(type, name = nil)
          @type = type
          @name = name
        end

        # @!method req?
        #   Is this a required, positional parameter?
        #   @return [Boolean]
        # @!method opt?
        #   Is this an optional, positional parameter?
        #   @return [Boolean]
        # @!method keyreq?
        #   Is this a required, keyword parameter?
        #   @return [Boolean]
        # @!method key?
        #   Is this an optional, keyword parameter?
        #   @return [Boolean]
        # @!method rest?
        #   Is this a positional _rest_ parameter?
        #   @return [Boolean]
        # @!method keyrest?
        #   Is this a keyword _rest_ parameter?
        #   @return [Boolean]
        # @!method block?
        #   Is this a block parameter?
        #   @return [Boolean]
        TYPES.each do |param_type|
          define_method("#{param_type}?") do
            param_type == type
          end
        end

        #
        # Is this a positional parameter (ignoring necessity)?
        #
        # @return [Boolean]
        #
        def positional?
          %i[req opt rest].include?(type)
        end

        #
        # Is this a keyword parameter (ignoring necessity)?
        #
        # @return [Boolean]
        #
        def keyword?
          %i[keyreq key keyrest].include?(type)
        end

        #
        # Determine a representation for this parameter based on the
        # {TYPE_FORMATS format table}.
        #
        # @return [String]
        #
        def to_s
          method_id = "to_#{type}_s"
          return send(method_id) if respond_to?(method_id, true)

          "<unknown representation for #{type}>"
        end

        private

        # @!method to_req_s
        # @!method to_opt_s
        # @!method to_keyreq_s
        # @!method to_key_s
        # @!method to_rest_s
        # @!method to_keyrest_s
        # @!method to_block_s
        TYPE_FORMATS.each do |param_type, fmt|
          define_method("to_#{param_type}_s") do
            format(fmt, name)
          end
        end
      end
    end
  end
end
