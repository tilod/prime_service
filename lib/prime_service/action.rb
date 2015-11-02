module PrimeService
  class Action < Service
    attr_accessor :model


    def self.use_form(form_class, &block)
      attr_accessor :form
      private       :form=

      mod = Module.new do
        define_method :set_form do
          self.form =
            if block_given?
              Class.new(form_class, &block).new(model)
            else
              form_class.new(model)
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
      set_form
    end


    private

    def setup
    end

    def set_form
    end
  end
end
