module PrimeService
  class Service < Policy
    def self.call(*params)
      self.for(*params).call
    end


    def call
      nil
    end
  end
end
