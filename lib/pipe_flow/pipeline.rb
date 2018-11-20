module PipeFlow
  module Pipeline
    using CoreRefinements::FunctionalProcs

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

    def pipeline(&block)
      Pipeline.from_block(&block)
    end

    refine Object do
      include PipeFlow::Pipeline
    end
  end
end
