require 'JSON'
namespace :js do

  desc 'Open a console for interacting with JS Generation'
  task :console do
    
    def init
      hqmf_contents = File.open(File.expand_path(File.join(".","test","fixtures","NQF59New.xml"))).read
      @gen2 = Generator::JS.new(hqmf_contents)
      #File.open(File.expand_path(File.join(".","test","fixtures","json","59New.json")), 'w') {|f| f.write @doc.to_json}

      json = JSON.parse(File.open(File.expand_path(File.join(".","test","fixtures","json","59New.json"))).read,symbolize_names: true);
      doc = JSON::Document.new(json)

      @gen = Generator::JS.new(nil, doc)

      
    end
    
    def write_js(gen, file)
      
      codes = Generator::CodesToJson.new(File.expand_path("../../../test/fixtures/codes.xml", __FILE__))
      codes_json = codes.json

      ctx = Sprockets::Environment.new(File.expand_path("../../..", __FILE__))
      Tilt::CoffeeScriptTemplate.default_bare = true 
      ctx.append_path "app/assets/javascripts"
      hqmf_utils = ctx.find_asset('hqmf_util').to_s
      
      File.open(File.expand_path(File.join(".","test","fixtures","js",file)), 'w') do |f| 
        f.write("var OidDictionary = #{codes_json};")
        
        f.write(hqmf_utils)
        f.write(gen.js_for_data_criteria())
        f.write(gen.js_for('IPP'))
        f.write(gen.js_for('DENOM'))
        f.write(gen.js_for('NUMER'))
        f.write(gen.js_for('DENEXCEP'))
        
      end
    end
    
    Pry.start
  end

  
end