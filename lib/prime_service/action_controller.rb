module PrimeService
  module ActionController
    def assign_as(as, action_instance)
      instance_variable_set as, action_instance
    end


    def assign(action_instance)
      @action = action_instance
    end


    def submit_to(to, *params)
      action = instance_variable_get to
      result = action.submit(*params)

      yield result if block_given?

      result
    end


    def submit(*params)
      result = @action.submit(*params)

      yield result if block_given?

      result
    end


    def run(action_instance)
      assign(action_instance)
      action_instance.submit
    end
  end
end
