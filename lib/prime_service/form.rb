module PrimeService
  class Form
    include ActiveModel::Model
    include Virtus.model

#
#   macro class methods
#

    def self.form_name(name, namespace = nil)
      @_form_name_      = name.to_s
      @_form_namespace_ = namespace
    end


    def self.model(model)
      if model.kind_of? Hash
        lambda_or_class = model.values.first

        model_name = model.keys.first
        model_new  = if lambda_or_class.respond_to? :call
          lambda_or_class
        else
          ->{ lambda_or_class.new }
        end
      else
        model_name = model
        model_new  = ->{ model.to_s.camelize.constantize.new }
      end

      mod = Module.new do
        define_method model_name do
          instance_variable_get :@model
        end

        define_method :build_model, model_new

        define_method "build_#{model_name}" do
          build_model
        end

        define_method :initialize do |model = nil|
          @model = model || build_model

          models << @model
        end

        attr_reader :model
      end
      include mod

      main_model(:model)
    end


    def self.models(*model_names, model_hash)
      unless model_hash.kind_of? Hash
        model_names << model_hash
        model_hash  = {}
      end

      model_new = {}

      model_names.each do |model_name|
        model_new[model_name] = ->{ model_name.to_s.camelize.constantize.new }
      end
      model_hash.each do |model_name, model_class_or_lambda|
        model_new[model_name] = if model_class_or_lambda.respond_to? :call
          model_class_or_lambda
        else
          ->{ model_class_or_lambda.new }
        end
      end

      mod = Module.new do
        model_new.each do |model_name, model_lambda|
          define_method model_name do
            instance_variable_get :"@#{model_name}"
          end

          define_method "build_#{model_name}", model_lambda
        end

        define_method :initialize do |params = {}|
          model_new.each do |model_name, model_lambda|
            model_instance = params[model_name] || send("build_#{model_name}")
            instance_variable_set :"@#{model_name}", model_instance

            models << model_instance
          end
        end
      end
      include mod
    end


    def self.main_model(model_name)
      delegate :persisted?, :to_key, :to_param, :id, to: model_name
    end

    
    def self.persistent(attribute_name, options = {})
      on = options.has_key?(:on) ? options[:on] : :model
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
      options[:type] ||= String
      attribute attribute_name, options[:type], options

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


    def self._own_attributes_
      @_own_attributes_ ||= []
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
      models.all? &:save
    end

#
#   private instance methods
#

    private

    def models
      @models ||= []
    end

    
    def attribute_names
      self.class.attributes
    end
  end
end
