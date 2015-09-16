module PrimeService
  module ActionController
    def present(action_class, *params, as: :action)
      instance_variable_set "@#{as}", action_class.for(*params)
    end


    def run(action_class, *params, as: :action)
      present(action_class, *params, as: as).call
    end
  end
end
