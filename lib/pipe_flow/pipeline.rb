module PipeFlow
  module Pipeline
    using CoreRefinements::FunctionalProcs

    #
    # Evaluate the given block as a Pipeline definition within the
    # scope of a {Parser::Context}.
    #
    # @yield A pipeline definition
    # @return [Object,Proc] If the input of the pipeline is a defined value, then the pipeline
    #   is immediately evaluated and the result is returned, otherwise the pipeline is returned as
    #   a unary proc.
    #
    def self.from_block(&block)
      validator = Parser::Visitors::Validator.new
      collector = Parser::Visitors::Collector.new

      ast = Parser::Context.new(block.binding).parse!(&block)
      validator.validate(ast)

      operations = collector.collect(ast)
      pipeline = operations.reduce do |source, destination|
        destination.compose_with(source)
      end

      return pipeline.call(nil) unless ast.input_needed?

      pipeline
    end

    # (see Pipeline.from_block)
    def pipeline(&block)
      Pipeline.from_block(&block)
    end

    refine Object do
      include PipeFlow::Pipeline
    end
  end
end
