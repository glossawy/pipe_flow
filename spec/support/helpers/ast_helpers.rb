node_base_class = PipeFlow::Parser::AST::Base

RSpec::Matchers.define :be_an_ast_node do
  match do |actual|
    actual.kind_of?(node_base_class)
  end
end

node_types = ObjectSpace.each_object(Class).select { |c| c < node_base_class }

node_types.each do |node_type|
  simple_name = node_type.name.split('::').last.downcase

  RSpec::Matchers.define "be_an_ast_#{simple_name}" do
    match do |actual|
      actual.instance_of?(node_type)
    end
  end

  RSpec::Matchers.alias_matcher "an_ast_#{simple_name}", "be_an_ast_#{simple_name}"
end

RSpec::Matchers.define :be_a_literal do |value_matcher = anything|
  match do |actual|
    an_ast_literal.matches?(actual) &&
      match(value_matcher).matches?(actual.value)
  end
end

RSpec::Matchers.define :be_pipeline_with do |source_matcher, destination_matcher|
  match do |actual|
    an_ast_pipe.matches?(actual) &&
      source_matcher.matches?(actual.source) &&
      destination_matcher.matches?(actual.destination)
  end
end

RSpec::Matchers.alias_matcher :a_pipeline_with, :be_pipeline_with

