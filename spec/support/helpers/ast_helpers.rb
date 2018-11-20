module ASTHelpers
  module_function

  def base_class
    PipeFlow::Parser::AST::Base
  end

  def all_node_classes
    PipeFlow::Parser::AST
      .constants
      .map { |c| PipeFlow::Parser::AST.const_get(c) }
      .select { |c| c < base_class }
  end
end

RSpec::Matchers.define :be_an_ast_node do
  match do |actual|
    actual.kind_of?(ASTHelpers.base_class)
  end
end

ASTHelpers.all_node_classes.each do |node_type|
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

