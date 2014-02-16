module PrimeService
  class Form
    include ActiveModel::Model
    include Virtus.model


    delegate :persisted?, :to_key, :to_param, :id,
              to: :main_model, allow_nil: true

#
#   macro class methods
#

    def self.form_name(name, namespace = nil)
      @_form_name_      = name.to_s
      @_form_namespace_ = namespace
    end


    def self.model(model_name, type: nil, main: :_unset_, build: nil,
                               reject_if: ->{ false })

      build_method = if build
        build
      else
        model_class = type || model_name.to_s.camelize.constantize

        lambda do
          if (model_id = send "#{model_name}_id")
            model_class.find(model_id)
          else
            model_class.new
          end
        end
      end

      mod = Module.new do
        attr_writer model_name
        attr_accessor "#{model_name}_id"

        define_method model_name do
          instance_variable_get :"@#{model_name}" or
          instance_variable_set :"@#{model_name}", send("build_#{model_name}")
        end

        define_method "build_#{model_name}", build_method

        define_method "reject_#{model_name}?", reject_if

        unless main == :_unset_
          if main
            define_method :main_model_name do
              model_name
            end
          else
            define_method :main_model_name do
              nil
            end
          end
          private :main_model_name
        end
      end
      include mod

      _own_models_ << model_name
    end


    def self.option(option_name)
      mod = Module.new do
        attr_accessor option_name
      end
      include mod
    end


    def self.persistent(attribute_name, options = {})
      on = options.has_key?(:on) ? options[:on] : :main_model
      as = options.has_key?(:as) ? options[:as] : attribute_name

      define_method attribute_name do
        send(on).send(as)
      end

      define_method "#{attribute_name}=" do |value|
        send(on).send("#{as}=", value)
      end

      define_method "model_for_#{attribute_name}" do
        send(on)
      end

      _own_attributes_ << attribute_name
    end


    def self.transient(attribute_name, options = {})
      type = options[:type] || String
      attribute attribute_name, type, options

      _own_attributes_ << attribute_name
    end


    def self.validates_uniqueness_of(attribute_name, options = true)
      validates attribute_name, uniqueness: options
    end

#
#   class methods
#

    def self.model_name
      @_model_name_ ||=
        if @_form_name_
          ActiveModel::Name.new(self, @_form_namespace_, @_form_name_)
        else
          base_name = self.name.demodulize
          base_name.gsub!(/Form$/, "") unless base_name == "Form"
          ActiveModel::Name.new(self, nil, base_name)
        end
    end


    def self.attributes(attrs = [])
      @_all_attributes_ ||=
        if superclass == ::PrimeService::Form
          _own_attributes_
        else
          _own_attributes_ + superclass.attributes(attrs)
        end
    end


    def self.models(models = [])
      @_all_models_ ||=
        if superclass == ::PrimeService::Form
          _own_models_
        else
          _own_models_ + superclass.models(models)
        end
    end


    def self._own_attributes_
      @_own_attributes_ ||= []
    end


    def self._own_models_
      @_own_models_ ||= []
    end

#
#   instance methods
#

    def submit(params = nil)
      self.attributes = params if params

      valid? and process
    end


    def attributes=(params)
      attribute_names.each do |attribute|
        self.send "#{attribute}=", params[attribute]
      end
    end


    def process
      persist
    end


    def persist
      model_names.reject { |model_name| send "reject_#{model_name}?" }
                 .map    { |model_name| send model_name }
                 .map(&:save)
                 .all?
    end


    def main_model
      @main_model ||= (main_model_name && send(main_model_name))
    end

#
#   private instance methods
#

    private

    def attribute_names
      @_attribute_names_ ||= self.class.attributes
    end

    def model_names
      @_model_names_ ||= self.class.models
    end

    def main_model_name
      @_main_model_name_ ||= (model_names.size != 1 ? nil : model_names.first)
    end
  end
end
