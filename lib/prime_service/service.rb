module PrimeService
  class Service
#
#  macro class methods
#

    def self.call_with(*call_params)
      define_method :_call_params_ do
        call_params
      end

      call_params.each do |param|
        attr_reader param
      end
    end

#
#  class methods
#

    def self.call(*params)
      self.for(*params).call
    end


    def self.for(*params)
      new(*params)
    end


    def initialize(*params)
      _call_params_.each_with_index do |attribute, index|
        instance_variable_set "@#{attribute}", params[index]
      end
    end

#
#  instance methods
#

    def call
      nil
    end



    private

    def _call_params_
      []
    end
  end
end
