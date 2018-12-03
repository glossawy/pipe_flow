require 'pipe_flow/version'
require 'pipe_flow/errors'

require 'pipe_flow/parser/basic_object'
require 'pipe_flow/parser/object_proxy'

require 'pipe_flow/core_refinements/class_attributes'
require 'pipe_flow/core_refinements/pipe_flow_nodes'
require 'pipe_flow/core_refinements/functional_procs'

require 'pipe_flow/parser/ast/parameterized/parameter'
require 'pipe_flow/parser/ast/parameterized'

require 'pipe_flow/parser/variable_capture/captured_var'
require 'pipe_flow/parser/variable_capture/captured_proc'
require 'pipe_flow/parser/variable_capture'

require 'pipe_flow/parser/ast/base'
require 'pipe_flow/parser/ast/hole'
require 'pipe_flow/parser/ast/literal'
require 'pipe_flow/parser/ast/block'
require 'pipe_flow/parser/ast/method_call'
require 'pipe_flow/parser/ast/pipe'

require 'pipe_flow/parser/visitors/dsl'
require 'pipe_flow/parser/visitors/visitor'
require 'pipe_flow/parser/visitors/validation'
require 'pipe_flow/parser/visitors/collector'

require 'pipe_flow/parser/context'

require 'pipe_flow/pipeline'
