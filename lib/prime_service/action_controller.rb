module PrimeService
  module ActionController
    def assign(action_instance, as: :@action)
      instance_variable_set as, action_instance
    end


    def submit(params = :_no_params_passed, to: :@action)
      action = instance_variable_get to

      result =
        if params == :_no_params_passed
          action.submit
        else
          action.submit(params)
        end

      yield result if block_given?

      result
    end

    def run(action_instance, as: :@action)
      assign(action_instance, as: as)
      action_instance.submit
    end
  end
end
