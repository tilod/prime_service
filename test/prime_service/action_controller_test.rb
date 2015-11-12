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

    class TestDestroyAction < Action
      call_with :foo

      attr_reader :submit_was_called_with
      def submit(*params)
        @submit_was_called_with = params
        'destroy action was called'
      end
    end

    class TestController
      include ActionController

      attr_reader :action_returned

      def new
        assign_as :@create_action, TestUpdateAction.for('foo', 'bar')
      end

      def create
        assign_as :@create_action, TestUpdateAction.for('foo', 'bar')

        submit_to :@create_action, 'params' do |success|
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

      def destroy
        run TestDestroyAction.for('foo')
      end
    end

    let(:controller) { TestController.new }


    describe '#assign' do
      it 'assigns the action to @action' do
        controller.edit
        controller.instance_variable_get(:@action)
                  .must_be_kind_of TestUpdateAction
      end

      it 'returns the action' do
        controller.assign(TestUpdateAction.for('foo', 'bar'))
                  .must_equal controller.instance_variable_get(:@action)
      end
    end


    describe '#assign_as' do
      it 'allows to set the name of the instance variable (leaving @action '\
         'nil)' do
        controller.new
        controller.instance_variable_get(:@create_action)
                  .must_be_kind_of TestUpdateAction
        controller.instance_variable_get(:@action).must_be_nil
      end

      it 'returns the action' do
        controller.assign_as(:@create_action, TestUpdateAction.for('f', 'b'))
                  .must_equal controller.instance_variable_get(:@create_action)
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
        controller.action_returned.must_equal 'called with: params'
      end

      it 'returns what the action returns (this test also: runs without block '\
         'defined)' do
        controller.assign TestUpdateAction.for('foo', 'bar')
        controller.submit('params').must_equal 'called with: params'
      end

      it 'can be called with {} as argument (yep, this is a regression test)' do
        controller.assign TestUpdateAction.for('foo', 'bar')
        controller.submit({})
        action.submit_was_called_with.must_equal({})
      end
    end


    describe '#submit_to' do
      let(:action) { controller.instance_variable_get(:@create_action) }

      it 'allows to choose the action where the params are submited to' do
        controller.create
        action.submit_was_called_with.must_equal 'params'
      end

      it 'calls @action#submit and passes the params' do
        controller.create
        action.submit_was_called_with.must_equal 'params'
      end

      it 'yields the return value of Action#call' do
        controller.create
        controller.action_returned.must_equal 'called with: params'
      end

      it 'returns what the action returns (this test also: runs without block '\
         'defined)' do
        controller.assign_as :@create_action, TestUpdateAction.for('foo', 'bar')
        controller.submit_to(:@create_action, 'params')
                  .must_equal 'called with: params'
      end

      it 'can be called with {} as argument (yep, this is a regression test)' do
        controller.assign_as :@create_action, TestUpdateAction.for('foo', 'bar')
        controller.submit_to(:@create_action, {})
        action.submit_was_called_with.must_equal({})
      end
    end


    describe '#run' do
      let(:action) { controller.instance_variable_get(:@action) }

      it 'initializes the action (via #assign) and calls #submit' do
        controller.destroy.must_equal 'destroy action was called'
      end

      it 'calls #submit without arguments' do
        controller.destroy
        action.submit_was_called_with.must_equal []
      end
    end
  end
end
