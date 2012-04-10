module JSON
  # Class representing an HQMF document
  class Document

    attr_reader :title, :description, :measure_period
  
    # Create a new HQMF::Document instance by parsing at file at the supplied path
    # @param [String] path the path to the HQMF document
    def initialize(json)
      
      @title = json[:title]
      @description = json[:description]

      @population_criteria = []
      json[:population_criteria].each {|key, population_criteria| @population_criteria << JSON::PopulationCriteria.new(key.to_s, population_criteria)} if json[:population_criteria]

      @data_criteria = []
      json[:data_criteria].each {|key, data_criteria| @data_criteria << JSON::DataCriteria.new(key.to_s, data_criteria)} if json[:data_criteria]

      @measure_period = JSON::Range.new(json[:measure_period]) if json[:measure_period]
      
    end
    
    # Get all the population criteria defined by the measure
    # @return [Array] an array of HQMF::PopulationCriteria
    def all_population_criteria
      @population_criteria
    end
    
    # Get a specific population criteria by id.
    # @param [String] id the population identifier
    # @return [HQMF::PopulationCriteria] the matching criteria, raises an Exception if not found
    def population_criteria(id)
      find(@population_criteria, :id, id)
    end
    
    # Get all the data criteria defined by the measure
    # @return [Array] an array of HQMF::DataCriteria describing the data elements used by the measure
    def all_data_criteria
      @data_criteria
    end
    
    # Get a specific data criteria by id.
    # @param [String] id the data criteria identifier
    # @return [HQMF::DataCriteria] the matching data criteria, raises an Exception if not found
    def data_criteria(id)
      find(@data_criteria, :id, id)
    end
    
    private
    
    def find(collection, attribute, value)
      collection.find {|e| e.send(attribute)==value}
    end
  end
end