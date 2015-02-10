module PrimeService
  class Service < Base
    def self.call(*params)
      self.for(*params).call
    end


    def call
      nil
    end
  end
end
