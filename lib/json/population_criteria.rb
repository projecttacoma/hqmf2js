module JSON
  # Represents an HQMF population criteria, also supports all the same methods as
  # HQMF::Precondition
  class PopulationCriteria
  
    attr_reader :preconditions, :id
    
    # Create a new population criteria from the supplied HQMF entry
    # @param [Nokogiri::XML::Element] the HQMF entry
    def initialize(id, json)
      @id = id
      @preconditions = json[:preconditions].map {|preciondition| JSON::Precondition.new(preciondition)} 
    end
    
    # Return true of this precondition represents a conjunction with nested preconditions
    # or false of this precondition is a reference to a data criteria
    def conjunction?
      true
    end

    # Get the conjunction code, e.g. allTrue, allFalse
    # @return [String] conjunction code
    def conjunction_code
      case id
      when 'IPP', 'DENOM', 'NUMER'
        'allTrue'
      when 'DENEXCEP'
        'atLeastOneTrue'
      else
        raise "Unknown population type [#{id}]"
      end
    end
    
  end
  
end