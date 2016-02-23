require 'test_helper'

module PrimeService
  describe Action do
    class TestForm
      attr_accessor :model
      def initialize(model)
        @model = model
      end

      def errors
        'form_errors'
      end

      def validate(params)
        raise StandardError if params.nil?
        params == 'valid params'
      end
    end

    class TestAction < Action
      call_with :arg_1, :arg_2
      use_form  TestForm

      private

      def setup
        self.model = 'model_loaded_in_setup'
        self.form  = initialize_form(model)
      end
    end

    class TestActionNoSetup < Action
      call_with :arg
    end

    class TestActionWithBlockForm < Action
      call_with :arg

      use_form TestForm do
        def inherited_from_test_form?
          self.class.ancestors.include? TestForm
        end
      end

      private

      def setup
        self.form = initialize_form('nothing')
      end
    end

    let(:action) { TestAction.for('arg_1', 'arg_2') }


    it 'is initialized like PrimeService::Base' do
      action.arg_1.must_equal 'arg_1'
      action.arg_2.must_equal 'arg_2'
    end

    it 'defines an attr_accessor for #model' do
      action.model = 'test_model'
      action.model.must_equal 'test_model'
    end

    it 'runs the private #setup method after initialize' do
      action.model.must_equal 'model_loaded_in_setup'
    end

    it 'also works when #setup is not overridden' do
      TestActionNoSetup.for('arg').arg.must_equal 'arg'
    end


    describe '.use_form' do
      it 'defines #initialize_form (to be called in #setup)' do
        action.form.must_be_kind_of TestForm
      end

      it 'makes #initialize_form to pass the model to the initializer of the '\
         'form' do
        action.form.model.must_equal 'model_loaded_in_setup'
      end

      it 'defines #form_class to return... well... the form class' do
        action.form_class.must_equal TestForm
      end

      it 'delegates #errors to the form' do
        action.errors.must_equal action.form.errors
      end


      describe 'defines #validate' do
        it 'which yields the block when the form is valid' do
          block_called = false

          action.validate('valid params') do
            block_called = 'block was called'
          end
          block_called.must_equal 'block was called'
        end

        it 'which returns false when form is NOT valid' do
          block_called = false
          action.validate('invalid params') do
            block_called = 'block was called'
          end
          block_called.must_equal false
        end

        it 'still works when nil is passed as params (even if the form '\
           'itself would raise an exception when form#validate is called with '\
           'nil) ...did anybody said "Reform"?' do
          action.validate(nil).must_equal false
        end
      end


      describe 'when .use_form is not used' do
        let(:action) { TestActionNoSetup.for('arg') }

        it 'does NOT define #form and #form_class' do
          action.wont_respond_to :form
          action.wont_respond_to :form_class
        end

        it 'does NOT delegate errors to form (actually it does NOT respond to '\
           '#errors at all)' do
          action.wont_respond_to :errors
        end

        it 'does NOT define #validate' do
          action.wont_respond_to :validate
        end
      end

      describe 'when .use_form is called with a block' do
        let(:action) { TestActionWithBlockForm.for('arg') }

        it 'inherits from the passed form class with the passed block (test '\
           'uses #form)' do
          action.form.inherited_from_test_form?.must_equal true
        end

        it 'inherits from the passed form class with the passed block (test '\
           'uses #form_class)' do
          action.form_class.ancestors.must_include TestForm
          action.form_class.wont_equal TestForm
        end
      end


      describe '#submit' do
        it 'throws a NotImplementedError' do
          ->{ action.submit }.must_raise NotImplementedError
        end
      end
    end
  end
end
