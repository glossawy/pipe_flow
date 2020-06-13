# frozen_string_literal: true

module PipeFlow
  module CoreRefinements
    module ClassAttributes
      refine Class do
        def class_attribute(*attrs, **predef_attrs)
          attrs = predef_attrs.merge(attrs.map { |name| [name, nil] }.to_h)

          attrs.each do |name, initial_value|
            define_shared_singleton_method(name) { initial_value }
            define_shared_singleton_method("#{name}?") { public_send(name) }

            define_singleton_method("#{name}=") do |new_value|
              redefine_singleton_method(name) { new_value }
            end
          end
        end

        def redefine_singleton_method(method_id, &body)
          singleton_class.class_eval { redefine_method(method_id, &body) }
        end

        def redefine_method(method_id, &body)
          if method_defined?(method_id) || private_method_defined?(method_id)
            undef_method(method_id)
          end

          define_method(method_id, &body)
        end

        def define_shared_singleton_method(method_id, &body)
          redefine_singleton_method(method_id, &body)
          redefine_method(method_id) { self.class.public_send(method_id) }
        end
      end
    end
  end
end
