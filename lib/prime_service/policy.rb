module PrimeService
  class Policy
    def self.call_with(*call_params)
      _definition_.args = call_params

      call_params.each do |param|
        attr_accessor param
      end
    end


    def self.option(option_name, option_default = nil)
      _definition_.options[option_name] = option_default

      attr_accessor option_name
    end


    def self.flag(flag_name, flag_default = false)
      _definition_.flags[flag_name] = flag_default

      define_method "#{flag_name}?" do
        !!(instance_variable_get "@#{flag_name}")
      end
      attr_accessor flag_name
    end


    def initialize(*args)
      definition = self.class._definition_

      definition.args.each_with_index do |attribute, index|
        instance_variable_set "@#{attribute}", args[index]
      end

      if args.size > definition.args.size && args.last.class == Hash
        options_hash = args.last

        definition.options.each do |option_name, option_default|
          instance_variable_set "@#{option_name}",
                                 options_hash[option_name] || option_default
        end

        definition.flags.each do |flag_name, flag_default|
          instance_variable_set "@#{flag_name}",
                                 options_hash[flag_name] || flag_default
        end
      end
    end


    private

    def self._definition_
      @_definition_ ||= Definition.new
    end

    class Definition
      attr_accessor :args, :options, :flags

      def initialize
        @args    = []
        @options = {}
        @flags   = {}
      end
    end
  end
end
