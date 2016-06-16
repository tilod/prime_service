module PrimeService
  class ServiceNotAllowedError < RuntimeError; end

  class Service < Base
    def self.call(*params)
      instance = self.for(*params)

      if instance.allowed?
        instance.call
      else
        false
      end
    end


    def self.call!(*params)
      instance = self.for(*params)

      if instance.allowed?
        instance.call
      else
        raise ServiceNotAllowedError.new
      end
    end


    def call
      nil
    end


    def allowed?
      true
    end
  end
end
