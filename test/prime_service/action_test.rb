require 'test_helper'

module PrimeService
  describe Action do
    class TestForm
      attr_accessor :model
      def initialize(model)
        @model = model
      end
    end

    class TestAction < Action
      call_with :arg_1, :arg_2
      use_form  TestForm

      private

      def setup
        self.model = 'model_loaded_in_setup'
      end
    end

    class TestActionNoSetup < Action
      call_with :arg
    end

    let(:action) { TestAction.for('arg_1', 'arg_2') }


    it 'is initialized like a service' do
      action.arg_1.must_equal 'arg_1'
      action.arg_2.must_equal 'arg_2'
    end

    it 'defines an attr_accessor for :model' do
      action.model = 'test_model'
      action.model.must_equal 'test_model'
    end

    it 'defines an attr_accessor for :form' do
      action.form = 'test_form'
      action.form.must_equal 'test_form'
    end

    it 'runs the private #setup method after initialize' do
      action.model.must_equal 'model_loaded_in_setup'
    end

    it 'also works when #setup is not overridden' do
      TestActionNoSetup.for('arg').arg.must_equal 'arg'
    end


    describe '.use_form' do
      it 'initializes the form of the action after #setup' do
        action.form.must_be_kind_of TestForm
      end

      it '...and passes the model' do
        action.form.model.must_equal 'model_loaded_in_setup'
      end
    end
  end
end
