module PipeFlow
  module Parser
    module AST
      class MethodCall
        class Parameter
          attr_reader :type, :name

          def initialize(type, name = nil)
            @type = type
            @name = name
          end

          %i[req keyreq opt key rest keyrest].each do |param_type|
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

          # :reek:TooManyStatements
          # rubocop:disable Metrics/CyclomaticComplexity
          def to_s
            case type
            when :req     then name.to_s
            when :opt     then "#{name} = <value>"
            when :rest    then "*#{name || 'args'}"
            when :key     then "#{name}: <value>"
            when :keyreq  then "#{name}:"
            when :keyrest then "**#{name || 'kwargs'}"
            else "<unknwon representation: #{type}>"
            end
          end
          # rubocop:enable Metrics/CyclomaticComplexity
        end
      end
    end
  end
end
