module PrimeService
  class MetaForm
    include ActiveModel::Model

#
#   macro class methods
#

    def self.form(form_name, type: nil, build: nil)
      build_method = if build
        build
      else
        form_class = type || form_name.to_s.camelize.constantize
        ->(args) { args ? form_class.new(args) : form_class.new }
      end

      mod = Module.new do
        define_method "#{form_name}=" do |args|
          if args.kind_of? Hash
            instance_variable_set :"@_#{form_name}_args_", args
            instance_variable_set :"@#{form_name}", nil
          else
            instance_variable_set :"@_#{form_name}_args_", nil
            instance_variable_set :"@#{form_name}", args
          end
        end

        define_method form_name do
          instance_variable_get :"@#{form_name}" or
          instance_variable_set :"@#{form_name}", send("build_#{form_name}")
        end

        define_method "build_#{form_name}" do |args = nil|
          args ||= instance_variable_get :"@_#{form_name}_args_"
          build_method.call(args)
        end
      end
      include mod
    end
  end
end
