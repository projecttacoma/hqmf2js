module HQMF2JS
  module Generator
    
    # Utility class used to supply a binding to Erb. Contains utility functions used
    # by the erb templates that are used to generate code.
    class ErbContext < OpenStruct
    
      # Create a new context
      # @param [Hash] vars a hash of parameter names (String) and values (Object).
      # Each entry is added as an accessor of the new Context
      def initialize(vars)
        super(vars)
      end
    
      # Get a binding that contains all the instance variables
      # @return [Binding]
      def get_binding
        binding
      end
      
      def js_for_value(value)
        if value
          if value.derived?
            value.expression
          else
            if value.type=='TS'
              "new TS(\"#{value.value}\")"
            elsif value.unit != nil
              "new #{value.type}(#{value.value}, \"#{value.unit}\")"
            else
              "new #{value.type}(\"#{value.value}\")"
            end
          end
        else
          'null'
        end
      end

      def js_for_bounds(bounds)
        if (bounds.respond_to?(:low) && bounds.respond_to?(:high))
          "new IVL(#{js_for_value(bounds.low)}, #{js_for_value(bounds.high)})"
        else
          "#{js_for_value(bounds)}"
        end
      end
      
      def js_for_date_bound(criteria)
        bound = nil
        if criteria.effective_time
          if criteria.effective_time.high
            bound = criteria.effective_time.high
          elsif criteria.effective_time.low
            bound = criteria.effective_time.low
          end
        end
        
        if bound
          "#{js_for_value(bound)}.asDate()"
        else
          'EndDate.asDate()'
        end
      end
      
      def js_for_code_list(criteria)
        if criteria.inline_code_list
          criteria.inline_code_list.to_json
        else
          "getCodes(\"#{criteria.code_list_id}\")"
        end
      end
      
      # Returns the JavaScript generated for a HQMF::Precondition
      def js_for_precondition(precondition, indent)
        template_str = File.read(File.expand_path("../precondition.js.erb", __FILE__))
        template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
        params = {'doc' => doc, 'precondition' => precondition, 'indent' => indent}
        context = ErbContext.new(params)
        template.result(context.get_binding)
      end
      
      # Returns a Javascript compatable name based on an entity's identifier
      def js_name(entity)
        if !entity.id
          raise "No identifier for #{entity.to_json}"
        end
        entity.id.gsub(/\W/, '_')
      end
      
    end

    class JS
  
      # Entry point to JavaScript generator
      def initialize(doc)
        @doc = doc
      end
      
      # Generate JS for a HQMF2::PopulationCriteria
      def js_for(criteria_code)
        template_str = File.read(File.expand_path("../population_criteria.js.erb", __FILE__))
        template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
        criteria = @doc.population_criteria(criteria_code)
        if criteria
          params = {'doc' => @doc, 'criteria' => criteria}
          context = ErbContext.new(params)
          template.result(context.get_binding)
        else
          ''
        end
      end
      
      # Generate JS for a HQMF2::DataCriteria
      def js_for_data_criteria
        template_str = File.read(File.expand_path("../data_criteria.js.erb", __FILE__))
        template = ERB.new(template_str, nil, '-', "_templ#{TemplateCounter.instance.new_id}")
        params = {'all_criteria' => @doc.all_data_criteria, 'measure_period' => @doc.measure_period}
        context = ErbContext.new(params)
        template.result(context.get_binding)
      end
      
      def self.library_functions
        ctx = Sprockets::Environment.new(File.expand_path("../../..", __FILE__))
        Tilt::CoffeeScriptTemplate.default_bare = true 
        ctx.append_path "app/assets/javascripts"
        
        ["// #########################\n// ###### PATIENT API ######\n// #########################\n",
         HqueryPatientApi::Generator.patient_api_javascript.to_s,
         "// #########################\n// ### LIBRARY FUNCTIONS ###\n// #########################\n",
         ctx.find_asset('hqmf_util').to_s, 
         "// #########################\n// ### PATIENT EXTENSION ###\n// #########################\n",
         ctx.find_asset('attribute_mapper').to_s].join("\n")
      end
  
    end
  
    # Simple class to issue monotonically increasing integer identifiers
    class Counter
      def initialize
        @count = 0
      end
      
      def new_id
        @count+=1
      end
    end
      
    # Singleton to keep a count of function identifiers
    class FunctionCounter < Counter
      include Singleton
    end
    
    # Singleton to keep a count of template identifiers
    class TemplateCounter < Counter
      include Singleton
    end
  end
end