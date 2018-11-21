# frozen_string_literal: true

module PipeFlow
  module Parser
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

          TYPES.each do |param_type|
            define_method("#{param_type}?") do
              param_type == type
            end
          end

          def positional?
            %i[req opt rest].include?(type)
          end

          def keyword?
            %i[keyreq key keyrest].include?(type)
          end

          def to_s
            method_id = "to_#{type}_s"
            return send(method_id) if respond_to?(method_id)

            "<unknown representation for #{type}>"
          end

          TYPE_FORMATS.each do |param_type, fmt|
            define_method("to_#{param_type}_s") do
              format(fmt, name)
            end
          end
        end
      end
    end
  end
end
