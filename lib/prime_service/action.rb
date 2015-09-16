module PrimeService
  class Action < Service
    attr_accessor :model, :form


    def self.use_form(form_class)
      define_method :_set_form do
        self.form = form_class.new(model)
      end
    end


    def initialize(*)
      super
      
      setup
      _set_form
    end


    private

    def setup
    end

    def _set_form
    end
  end
end
