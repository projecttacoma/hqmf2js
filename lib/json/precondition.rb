module JSON
  
  class Precondition
  
    attr_reader :preconditions, :reference, :conjunction_code
  
    def initialize(json)
      @preconditions = []
      @preconditions = json[:preconditions].map {|preciondition| JSON::Precondition.new(preciondition)} if json[:preconditions]
      @reference = Reference.new(json[:reference]) if json[:reference] 
      @conjunction_code = json[:conjunction_code] if json[:conjunction_code]
    end
    
    # Return true of this precondition represents a conjunction with nested preconditions
    # or false of this precondition is a reference to a data criteria
    def conjunction?
      @preconditions.length>0
    end
    
  end
    
end