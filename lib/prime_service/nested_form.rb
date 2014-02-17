module PrimeService
  class NestedForm
    include ActiveModel::Model

#
#   macro class methods
#

    def self.form(form_name, type: nil, build: nil)
      build_method = if build
        lambda do
          instance_variable_set :"@#{form_name}", build.call
        end
      else
        form_class = type || form_name.to_s.camelize.constantize
        lambda do
          instance_variable_set :"@#{form_name}", form_class.new
        end
      end

      mod = Module.new do
        attr_writer   form_name

        define_method form_name do
          instance_variable_get :"@#{form_name}" or send("build_#{form_name}")
        end

        define_method "build_#{form_name}", build_method
      end
      include mod

      _own_forms_ << form_name
    end

    def self.collection(collection_name, type: nil, build: nil)
      singular_name = collection_name.to_s.singularize

      build_method = if build
        build
      else
        collection_class = type || singular_name.to_s.camelize.constantize
        lambda { collection_class.new }
      end

      mod = Module.new do
        attr_writer collection_name

        define_method collection_name do
          instance_variable_get :"@#{collection_name}" or
          instance_variable_set :"@#{collection_name}", Hash.new
        end

        define_method "build_#{singular_name}" do |key = nil|
          form = build_method.call
          send(collection_name)[key || SecureRandom.urlsafe_base64] = form

          form
        end
      end
      include mod

      _own_collections_ << collection_name
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


    def self.collections(collections = [])
      @_all_collections ||=
        if superclass == ::PrimeService::NestedForm
          _own_collections_
        else
          _own_collections_ + superclass.collections(collections)
        end
    end


    def self._own_forms_
      @_own_forms_ ||= []
    end


    def self._own_collections_
      @_own_collections_ ||= []
    end

#
#   instance methods
#

    def submit(params = nil)
      self.attributes = params if params

      if form_names.map { |form_name| send form_name }
                   .map(&:valid?).all? \
         && collection_names.map { |collection_name| send collection_name }
                            .flat_map(&:values).map(&:valid?).all? \
         && valid?
        process
      end
    end


    def attributes=(params)
      form_names.each do |form_name|
        if (form_attributes = params[:"#{form_name}_attributes"])
          send(form_name).attributes = form_attributes
        end
      end

      collection_names.each do |collection_name|
        singular_name = collection_name.to_s.singularize

        if (collection_array = params[:"#{singular_name}"])
          form_collection = send(collection_name)

          collection_array.each do |index, attributes|
            form = form_collection[index] ||
                   send("build_#{singular_name}", index)
            form.attributes = attributes
          end
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

    def collection_names
      @_collection_names ||= self.class.collections
    end

    def forms
      form_names.map { |form_name| send form_name }
    end
  end
end
