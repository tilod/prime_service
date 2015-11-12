module PrimeService
  module ActionController
    def assign(action_instance, *params, as: :@action)
      instance_variable_set as, action_instance
    end


    def submit(*params, to: :@action)
      action = instance_variable_get to
      result = action.submit(*params)

      yield result if block_given?

      result
    end
  end
end
