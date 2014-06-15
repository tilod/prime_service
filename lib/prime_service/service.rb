module PrimeService
  class Service < Policy
    def self.call(*params)
      self.for(*params).call
    end


    def self.for(*params)
      new(*params)
    end


    def call
      nil
    end
  end
end
