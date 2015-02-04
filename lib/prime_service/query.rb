module PrimeService
  class Query
    NoScopeError = Class.new(StandardError)


    def self.scope_with(default_scope)
      define_method :default_scope do
        default_scope
      end
    end


    def self.for(scope)
      new(scope)
    end


    def initialize(scope = nil)
      @scope = scope || default_scope || raise(NoScopeError)
    end
    attr_accessor :scope


    def default_scope
      nil
    end
  end
end
