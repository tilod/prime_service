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
        run TestUpdateAction, 'foo value' do |success|
          @action_returned = success

          # in a real controller most of the time you will do:
          #
          # if success
          #   flash.notice = 'successful updated whatever'
          #   redirect_to test_index_url
          # else
          #   render 'edit'
          # end
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
      let(:action) { controller.instance_variable_get(:@action) }

      it 'initializes the action and calls it' do
        controller.update
        action.was_called.must_equal true
      end

      it 'passes the params to the action' do
        controller.update
        action.foo.must_equal 'foo value'
      end

      it 'yields the return value of Action#call' do
        controller.update
        controller.instance_variable_get(:@action_returned).must_equal 'called'
      end

      it 'returns what the action returns (also: runs without block defined)' do
        controller.run(TestUpdateAction, 'foo value').must_equal 'called'
      end
    end
  end
end
