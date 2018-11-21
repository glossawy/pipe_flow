module PipeFlow
  module Parser
    module Visitors
      class Visitor
        def visit(object)
          visit_method = method_for_class(object.class)
          dispatch(visit_method, object)
        end

        private

        def do_nothing(object)
          object
        end

        def dispatch(method_id, object)
          return send(method_id, object) if respond_to?(method_id, true)

          visitable_super = visitable_supermethod_for(object.class)
          return dispatch(visitable_super, object) if visitable_super

          raise TypeError, "Unable to visit #{object.class}"
        end

        def method_for_class(klass)
          method_suffix = (klass.name || '').gsub('::', '_')
          "visit_#{method_suffix}"
        end

        def visitable_supermethod_for(klass)
          klass.ancestors
               .map { |superclass| method_for_class(superclass) }
               .find { |supermethod| respond_to?(supermethod) }
        end
      end
    end
  end
end
