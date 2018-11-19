module PipeFlow
  module Parser
    def self.parse!(env = nil, &block)
      env ||= block.binding
      Parser::Context.new(env).parse!(&block)
    end
  end
end
