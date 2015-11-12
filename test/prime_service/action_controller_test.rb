require 'test_helper'

module PrimeService
  describe ActionController do
    class TestUpdateAction < Action
      call_with :foo, :bar

      attr_reader :submit_was_called_with
      def submit(params)
        @submit_was_called_with = params
        "called with: #{params}"
      end
    end

    class TestController
      include ActionController

      def new
        assign TestUpdateAction.for('foo', 'bar'), as: :@create_action
      end

      def create
        assign TestUpdateAction.for('foo', 'bar'), as: :@create_action

        submit 'params', to: :@create_action do |success|
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

      def edit
        assign TestUpdateAction.for('foo', 'bar')
      end

      def update
        assign TestUpdateAction.for('foo', 'bar')

        submit 'params' do |success|
          @action_returned = success
        end
      end
    end

    let(:controller) { TestController.new }


    describe '#assign' do
      it 'initializes the Action and assigns it to @action' do
        controller.edit
        controller.instance_variable_get(:@action)
                  .must_be_kind_of TestUpdateAction
      end

      it 'allows to assign the set the name of the instance variable (leaving '\
         '@action nil)' do
        controller.new
        controller.instance_variable_get(:@create_action)
                  .must_be_kind_of TestUpdateAction
        controller.instance_variable_get(:@action).must_be_nil
      end

      it 'passes the params to the action' do
        controller.edit
        controller.instance_variable_get(:@action).foo.must_equal 'foo'
        controller.instance_variable_get(:@action).bar.must_equal 'bar'
      end

      it 'returns the action to present' do
        controller.assign(TestUpdateAction.for('foo', 'bar'))
                  .must_equal controller.instance_variable_get(:@action)
      end
    end


    describe '#submit' do
      let(:action) { controller.instance_variable_get(:@action) }

      it 'calls @action#submit and passes the params' do
        controller.update
        action.submit_was_called_with.must_equal 'params'
      end

      it 'yields the return value of Action#call' do
        controller.update
        controller.instance_variable_get(:@action_returned)
                  .must_equal 'called with: params'
      end

      it 'returns what the action returns (this test also: runs without block '\
         'defined)' do
        controller.assign TestUpdateAction.for('foo', 'bar')
        controller.submit('params').must_equal 'called with: params'
      end
    end
  end
end
