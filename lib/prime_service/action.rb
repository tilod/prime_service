module PrimeService
  class Action < Service
    attr_accessor :model


    def self.use_form(form_class)
      attr_accessor :form

      define_method :set_form do
        self.form = form_class.new(model)
      end

      define_method :errors do
        form.errors
      end
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
