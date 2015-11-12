module PrimeService
  class Base
    def self.call_with(*call_args)
      define_method :call_args do
        call_args
      end

      call_args.each do |param|
        attr_accessor param
      end
    end


    def self.for(*params)
      new(*params)
    end


    def initialize(*params)
      call_args.each_with_index do |attribute, index|
        instance_variable_set "@#{attribute}", params[index]
      end
    end


    def call_args
      []
    end
  end
end
