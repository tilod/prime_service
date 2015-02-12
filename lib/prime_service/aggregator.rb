module PrimeService
  class Aggregator < Base
    def self.delegate_attr(model, *attrs)
      attrs.each do |attribute|
        define_method attribute do
          send(model).send(attribute)
        end

        setter_name = "#{attribute}="
        define_method setter_name do |value|
          send(model).send(setter_name, value)
        end
      end
    end


    def self.delegate_id_to(model)
      define_method :id do
        send(model).id
      end

      define_method :to_key do
        send(model).to_key
      end

      define_method :new_record? do
        send(model).new_record?
      end

      define_method :persisted? do
        send(model).persisted?
      end
    end


    def self.load_data(*attrs, &block)
      attr_accessor *attrs

      define_method :load_data, &block
    end


    def initialize(*)
      super
      load_data
    end


    private

    def load_data
    end
  end
end
