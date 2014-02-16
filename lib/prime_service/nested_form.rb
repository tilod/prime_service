module PrimeService
  class NestedForm
    include ActiveModel::Model

#
#   macro class methods
#

    def self.form(form_name, type: nil, build: nil)
      build_method = if build
        build
      else
        form_class = type || form_name.to_s.camelize.constantize
        lambda { form_class.new }
      end

      mod = Module.new do
        attr_writer   form_name
        attr_accessor "new_#{form_name}"

        define_method form_name do
          instance_variable_get :"@#{form_name}" or
          instance_variable_set :"@#{form_name}", send("build_#{form_name}")
        end

        define_method "build_#{form_name}", build_method
      end
      include mod

      _own_forms_ << form_name
    end

#
#   class methods
#

    def self.forms(forms = [])
      @_all_forms_ ||=
        if superclass == ::PrimeService::NestedForm
          _own_forms_
        else
          _own_forms_ + superclass.forms(forms)
        end
    end


    def self._own_forms_
      @_own_forms_ ||= []
    end

#
#   instance methods
#

    def submit(params = nil)
      self.attributes = params if params

      if form_names.map{|form_name| send form_name}.map(&:valid?).all? && valid?
        process
      end
    end


    def attributes=(params)
      form_names.each do |form_name|
        if (form_attributes = params[:"#{form_name}_attributes"])
          send(form_name).attributes = form_attributes
        end
      end
    end


    def process
      forms.map(&:process).all?
    end

#
#   private instance methods
#

    private

    def form_names
      @_form_names_ ||= self.class.forms
    end

    def forms
      form_names.map { |form_name| send form_name }
    end
  end
end
