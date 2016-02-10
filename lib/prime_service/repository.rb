module PrimeService
  class Repository
    def self.for(*params)
      new(*params)
    end


    def self.scope_with(*scope_args, &block)
      define_method :scope_args do
        scope_args
      end

      scope_args.each do |param|
        attr_accessor param
      end

      define_method :scope, block
    end


    def self.delegate_to_scope(*methods)
      methods.each do |method|
        define_method method do |*args|
          scope.send(method, *args)
        end
      end
    end


    def initialize(*params)
      scope_args.each_with_index do |attribute, index|
        instance_variable_set "@#{attribute}", params[index]
      end
    end


    def scope_args
      []
    end
  end
end
