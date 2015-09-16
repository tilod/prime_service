require 'test_helper'

module PrimeService
  describe ActionController do
    class TestUpdateAction < Action
      call_with :foo, :bar

      attr_reader :was_called
      def call
        @was_called = true
        'called'
      end
    end

    class TestController
      include ActionController

      def show
        present TestUpdateAction, as: :show_action
      end

      def edit
        present TestUpdateAction, 'foo value', 'bar value'
      end

      def update
        if run TestUpdateAction, 'foo value'
          # when successful
        else
          # when failure
        end
      end
    end

    let(:controller) { TestController.new }


    describe '#present' do
      it 'initializes the Action and assigns it to @action' do
        controller.edit
        controller.instance_variable_get(:@action)
                  .must_be_kind_of TestUpdateAction
      end

      it 'allows to assign the set the name of the instance variable' do
        controller.show
        controller.instance_variable_get(:@show_action)
                  .must_be_kind_of TestUpdateAction
        controller.instance_variable_get(:@action).must_be_nil
      end

      it 'passes the params to the action' do
        controller.edit
        controller.instance_variable_get(:@action).foo.must_equal 'foo value'
        controller.instance_variable_get(:@action).bar.must_equal 'bar value'
      end

      it 'returns the action to present' do
        controller.present(TestUpdateAction)
                  .must_equal controller.instance_variable_get(:@action)
      end
    end


    describe '#run' do
      it 'initializes the action and calls it' do
        controller.update
        controller.instance_variable_get(:@action).was_called.must_equal true
      end

      it 'passes the params to the action' do
        controller.update
        controller.instance_variable_get(:@action).foo.must_equal 'foo value'
      end

      it 'return what the action returns' do
        controller.run(TestUpdateAction, 'foo value').must_equal 'called'
      end
    end
  end
end
