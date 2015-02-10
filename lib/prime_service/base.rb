module PrimeService
  class Base
    def self.call_with(*call_params)
      define_method :_call_params_ do
        call_params
      end

      call_params.each do |param|
        attr_accessor param
      end
    end


    def self.for(*params)
      new(*params)
    end


    def initialize(*params)
      _call_params_.each_with_index do |attribute, index|
        instance_variable_set "@#{attribute}", params[index]
      end
    end


    private

    def _call_params_
      []
    end
  end
end
