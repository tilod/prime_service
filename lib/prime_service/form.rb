module PrimeService
  class Form
    include ActiveModel::Model
    include Virtus.model

#
#   macro class methods
#

    def self.model(model)
      if model.kind_of? Hash
        model_name  = model.keys.first
        model_class = model.values.first
      else
        model_name  = model
        model_class = model.to_s.camelize.constantize
      end

      define_method model_name do
        instance_variable_get :@model
      end

      define_method :initialize do |model = nil|
        @model = model || model_class.new

        models << @model
      end

      attr_reader :model
    end

    
    def self.persistent(attribute_name, options = {})
      delegate attribute_name, "#{attribute_name}=", to: :model

      _attribute_names_ << attribute_name
    end

    
    def self.transient(attribute_name, options = {})
      options[:type] ||= String
      attribute attribute_name, options[:type], options

      _attribute_names_ << attribute_name
    end

#
#   class methods
#

    def self._attribute_names_
      @_attribute_names_ ||= []
    end

#
#   instance methods
#

    def submit(params = nil)
      assign(params) if params

      valid? and process
    end


    def assign(params)
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
      self.class._attribute_names_
    end
  end
end
