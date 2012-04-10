module JSON
  # Represents a data criteria specification
  class DataCriteria

    include HQMF::Utilities
  
    attr_reader :id,:title,:section,:subset_code,:code_list_id, :property, :type, :status, :value, :effective_time, :inline_code_list
  
    # Create a new instance based on the supplied HQMF entry
    # @param [Nokogiri::XML::Element] entry the parsed HQMF entry
    def initialize(id, json)
      @id = id
      @title = json[:title] if json[:title]
      @section = json[:section] if json[:section]
      @subset_code = json[:subset_code] if json[:subset_code]
      @code_list_id = json[:code_list_id] if json[:code_list_id]
      @property = json[:property].to_sym if json[:property]
      @type = json[:type].to_sym if json[:type]
      @status = json[:status] if json[:status]

      @value = convert_value(json[:value]) if json[:value]
      @effective_time = JSON::Range.new(json[:effective_time]) if json[:effective_time]
      @inline_code_list = json[:inline_code_list].inject({}){|memo,(k,v)| memo[k.to_s] = v; memo} if json[:inline_code_list]
      
    end
    
    private 
    
    def convert_value(json)
      value = nil
      type = json[:type]
      case type
        when 'TS'
          value = JSON::Value.new(json)
        when 'IVL_PQ'
          value = JSON::Range.new(json)
        when 'CD'
          value = JSON::Coded.new(json)
        else
          raise "Unknown value type [#{value_type}]"
        end
      value
    end
    

  end
  
end