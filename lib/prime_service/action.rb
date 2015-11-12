module PrimeService
  class Action < Base
    attr_accessor :model


    def self.use_form(form_base_class, &block)
      attr_accessor :form,  :form_class
      private       :form=, :form_class=

      mod = Module.new do
        define_method :initialize_form do |*args|
          self.form_class =
            if block_given?
              Class.new(form_base_class, &block)
            else
              form_base_class
            end
          self.form = form_class.new(*args)
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


    def submit(*)
      raise NotImplementedError, 'implement in subclass'
    end


    private

    def setup
    end
  end
end
