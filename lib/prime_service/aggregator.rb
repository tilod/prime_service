module PrimeService
  class Aggregator < Base
    class << self
      def delegate_accessor(model, *attrs)
        mod = Module.new
        mod.module_exec do
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

        include mod
      end
      alias_method :delegate_attr, :delegate_accessor


      def delegate_reader(model, *attrs)
        mod = Module.new
        mod.module_exec do
          attrs.each do |attribute|
            define_method attribute do
              send(model).send(attribute)
            end
          end
        end

        include mod
      end


      def delegate_writer(model, *attrs)
        mod = Module.new
        mod.module_exec do
          attrs.each do |attribute|
            setter_name = "#{attribute}="
            define_method setter_name do |value|
              send(model).send(setter_name, value)
            end
          end
        end

        include mod
      end


      def pretend_model(model = false)
        if model
          define_method :id do
            send(model).id
          end

          define_method :to_key do
            send(model).to_key
          end

          define_method :to_param do
            send(model).to_param
          end

          define_method :to_model do
            send(model).to_model
          end

          define_method :new_record? do
            send(model).new_record?
          end

          define_method :persisted? do
            send(model).persisted?
          end
        else
          define_method :new_record? do
            true
          end

          define_method :persisted? do
            false
          end
        end
      end


      def load_data(*attrs, &block)
        attr_accessor(*attrs)

        define_method :setup, &block
      end


      private

      def delegator_module
        @_delegator_module ||= Module.new
      end
    end


    def initialize(*)
      super
      setup
    end


    private

    def setup
    end
  end
end
