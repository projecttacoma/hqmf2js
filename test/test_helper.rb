require 'cover_me'
require 'test/unit'
require 'turn'

if RUBY_PLATFORM=='java'
  require 'rhino'
else
  require 'v8'
end

# allows import of patient api without rails
module HqueryPatientApi 
  module Rails
    class Engine

    end
  end
end


PROJECT_ROOT = File.expand_path("../../", __FILE__)
require File.join(PROJECT_ROOT, 'lib', 'hqmf2js')

def get_js_context(javascript)
  if RUBY_PLATFORM=='java'
    @context = Rhino::Context.new
  else
    @context = V8::Context.new
  end
  @context.eval(javascript)
  @context
end
