module PipeFlow
  module CoreRefinements
    module FunctionalProcs
      refine Proc do
        def compose(other_proc)
          lambda do |input|
            # f(g(x))
            # where f = self
            #       g = other_proc
            inner_result = other_proc.call(input)
            call(inner_result)
          end
        end

        alias_method :compose_with, :compose
      end
    end
  end
end
