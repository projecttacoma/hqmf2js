module JSON
  # Represents a bound within a HQMF pauseQuantity, has a value, a unit and an
  # inclusive/exclusive indicator
  class Value
    include HQMF::Utilities
    
    attr_reader :type,:unit,:value,:expression
    
    # Create a new JSON::Value
    # @param [String] type
    # @param [String] unit
    # @param [String] value
    # @param [String] inclusive
    # @param [String] derived
    # @param [String] expression
    def initialize(type,unit,value,inclusive,derived,expression)
      @type = type
      @unit = unit
      @value = value
      @inclusive = inclusive
      @derived = derived
      @expression = expression
    end
    
    def self.from_json(json)
      type = json[:type] if json[:type]
      unit = json[:unit] if json[:unit]
      value = json[:value] if json[:value]
      inclusive = json[:inclusive?] if json[:inclusive?]
      derived = json[:derived?] if json[:derived?]
      expression = json[:expression] if json[:expression]
      
      JSON::Value.new(type,unit,value,inclusive,derived,expression)
    end
    
    
    def inclusive?
      @inclusive
    end

    def derived?
      @derived
    end
    
  end
  
  # Represents a HQMF physical quantity which can have low and high bounds
  class Range
    attr_reader :low, :high, :width, :type
    
    # Create a new JSON::Value
    # @param [String] type
    # @param [Value] low
    # @param [Value] high
    # @param [Value] width
    def initialize(type,low,high,width)
      @type = type
      @low = low
      @high = high
      @width = width
    end
    
    def self.from_json(json)
      type = json[:type] if json[:type]
      low = JSON::Value.from_json(json[:low]) if json[:low]
      high = JSON::Value.from_json(json[:high]) if json[:high]
      width = JSON::Value.from_json(json[:width]) if json[:width]
      
      JSON::Range.new(type,low,high,width)
    end
    
    
  end
  
  # Represents a HQMF effective time which is a specialization of a interval
  class EffectiveTime < Range
    def initialize(entry)
      super
    end
    
    def type
      'IVL_TS'
    end
  end
  
  # Represents a HQMF CD value which has a code and codeSystem
  class Coded
    attr_reader :type, :system, :code
    
    # Create a new JSON::Coded
    # @param [String] type
    # @param [String] system
    # @param [String] code
    def initialize(type,system,code)
      @type = type
      @system = system
      @code = code
    end
    
    def self.from_json(json)
      type = json[:type] if json[:type]
      system = json[:system] if json[:system]
      code = json[:code] if json[:code]
      
      JSON::Coded.new(type,system,code)
    end
    
    
    def value
      code
    end

    def derived?
      false
    end

    def unit
      nil
    end
    
  end
  
  # Represents a HQMF reference from a precondition to a data criteria
  class Reference
    include HQMF::Utilities
    
    attr_reader :id
    
    # Create a new JSON::Reference
    # @param [String] id
    def initialize(id)
      @id = id
    end
    
  end
  
end