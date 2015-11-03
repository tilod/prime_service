module PrimeService
  class Action < Service
    attr_accessor :model


    def self.use_form(form_class, &block)
      attr_accessor :form
      private       :form=

      mod = Module.new do
        define_method :initialize_form do |*args|
          self.form =
            if block_given?
              Class.new(form_class, &block).new(*args)
            else
              form_class.new(*args)
            end
        end

        define_method :errors do
          form.errors
        end
      end

      self.include mod
    end


    def initialize(*)
      super

      setup
    end


    private

    def setup
    end
  end
end
