module PrimeService
  class Service
#
#  macro class methods
#

    def self.call_with(*call_params)
      define_method :__call_params__ do
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
      __call_params__.each_with_index do |attribute, index|
        instance_variable_set "@#{attribute}", params[index]
      end
    end

#
#  instance methods
#

    def call
      nil
    end
  end
end
