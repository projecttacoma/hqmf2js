require 'pathname'
require 'fileutils'

namespace :hqmf do
  desc 'Convert a HQMF file to JavaScript'
  task :convert, [:hqmf, :codes, :hqmf_version, :patient] do |t, args|
    
    FileUtils.mkdir_p File.join(".","tmp",'js')
    file = File.expand_path(args.hqmf)
    version = args.version || HQMF::Parser::HQMF_VERSION_1
    filename = Pathname.new(file).basename
    doc = HQMF::Parser.parse(File.open(file).read, version)
    
    gen = HQMF2JS::Generator::JS.new(doc)

    binding.pry

    codes = HQMF2JS::Generator::CodesToJson.new(File.expand_path("../../../test/fixtures/codes.xml", __FILE__))
    codes_json = codes.to_json
    
    File.open(File.join(".","tmp",'js',"#{filename}.js"), 'w') do |f| 

      ctx = Sprockets::Environment.new(File.expand_path("../../..", __FILE__))
      Tilt::CoffeeScriptTemplate.default_bare = true 
      ctx.append_path "app/assets/javascripts"
      hqmf_utils = ctx.find_asset('hqmf_util').to_s
      
      f.write("// #########################\n")
      f.write("// ### LIBRARY FUNCTIONS ###\n")
      f.write("// #########################\n\n")
      
      f.write(hqmf_utils)
      
      f.write("// #########################\n")
      f.write("// ##### DATA ELEMENTS #####\n")
      f.write("// #########################\n\n")
      
      f.write("var OidDictionary = #{codes_json};\n\n")
      f.write(gen.js_for_data_criteria())
  
      f.write("// #########################\n")
      f.write("// ####### PATIENT API #####\n")
      f.write("// #########################\n\n")
      
      f.write(File.open('test/fixtures/patient_api.js').read + "\n\n")
      
      f.write("// #########################\n")
      f.write("// ##### MEASURE LOGIC #####\n")
      f.write("// #########################\n\n")
           
      f.write("// INITIAL PATIENT POPULATION\n")
      f.write(gen.js_for('IPP'))
      f.write("// DENOMINATOR\n")
      f.write(gen.js_for('DENOM'))
      f.write("// NUMERATOR\n")
      f.write(gen.js_for('NUMER'))
      f.write(gen.js_for('DENEXCEP'))
  
      
      f.write("// #########################\n")
      f.write("// ######### PATIENT #######\n")
      f.write("// #########################\n\n")

      fixture_json = File.read('test/fixtures/patients/francis_drake.json')
      f.write("var patient_json = #{fixture_json};\n")
      initialize_patient = 'var patient = new hQuery.Patient(patient_json);'
      f.write("#{initialize_patient}\n")
      
    end
    
    true
    
    
  end
end
    