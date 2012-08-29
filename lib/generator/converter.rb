module HQMF2JS
  class Converter
    def self.generate_map_reduce(hqmf_contents, codes=nil)
      # First compile the CoffeeScript that enables our converted HQMF JavaScript
      hqmf_utils = HQMF2JS::Generator::JS.library_functions

      if !codes
        # Parse the code systems that are mapped to the OIDs we support
        codes_file_path = File.expand_path("../../../test/fixtures/codes/codes.xml", __FILE__)
        codes = HQMF2JS::Generator::CodesToJson.from_xml(codes_file_path)
      end
      codes_json = HQMF2JS::Generator::CodesToJson.hash_to_js(codes)

      # Convert the HQMF document included as a fixture into JavaScript
      converter = HQMF2JS::Generator::JS.new(hqmf_contents)
      converted_hqmf = [
        "#{converter.js_for_data_criteria}",
        "#{converter.js_for('IPP', nil, true)}",
        "#{converter.js_for('DENOM', nil, true)}",
        "#{converter.js_for('NUMER', nil, true)}",
        "#{converter.js_for('DENEXCEP', nil, false)}",
        "#{converter.js_for('EXCL', nil, false)}"].join("\n")
      
      # Pretty stock map/reduce functions that call out to our converted HQMF code stored in the functions variable
      map = "function map(patient) {
  if (typeof(hqmfjs.IPP)==='function' && hqmfjs.IPP(patient).isTrue()) {
    emit('ipp', 1);
    if (typeof(hqmfjs.DENEXCEP)==='function' && hqmfjs.DENEXCEP(patient).isTrue()) {
        emit('denexcep', 1);    
    } else if (typeof(hqmfjs.DENOM)==='function' && hqmfjs.DENOM(patient).isTrue()) {
      if (typeof(hqmfjs.NUMER)==='function' && hqmfjs.NUMER(patient).isTrue()) {
        emit('denom', 1);
        emit('numer', 1);
      } else if (typeof(hqmfjs.EXCL)==='function' && hqmfjs.EXCL(patient).isTrue()) {
        emit('excl', 1);
      } else {
        emit('denom', 1);
        emit('antinum', 1);
      }
    }
  }
};"
      reduce = "function reduce(bucket, counts) {
  var sum = 0;
  while(counts.hasNext()){
    sum += counts.next();
  }
  return sum;
};"
      functions = "#{hqmf_utils}\nvar OidDictionary = #{codes_json};\n#{converted_hqmf}"

      return { :map => map, :reduce => reduce, :functions => functions }
    end
  end
end