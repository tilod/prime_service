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
  end
end
