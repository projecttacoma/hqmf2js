module JSON
  # Represents a bound within a HQMF pauseQuantity, has a value, a unit and an
  # inclusive/exclusive indicator
  class Value
    include HQMF::Utilities
    
    attr_reader :type,:unit,:value,:expression
    
    def initialize(json)
      @type = json[:type] if json[:type]
      @unit = json[:unit] if json[:unit]
      @value = json[:value] if json[:value]
      @inclusive = json[:inclusive?] if json[:inclusive?]
      @derived = json[:derived?] if json[:derived?]
      @expression = json[:expression] if json[:expression]
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
    
    def initialize(json)
      @type = json[:type] if json[:type]
      @low = JSON::Value.new(json[:low]) if json[:low]
      @high = JSON::Value.new(json[:high]) if json[:high]
      @width = JSON::Value.new(json[:width]) if json[:width]
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
    
    def initialize(json)
      @type = json[:type] if json[:type]
      @system = json[:system] if json[:system]
      @code = json[:code] if json[:code]
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
    
    def initialize(id)
      @id = id
    end
    
  end
  
end