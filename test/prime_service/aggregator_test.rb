require 'test_helper'

module PrimeService
  describe Aggregator do
    class TestAggregator < Aggregator
      call_with           :model
      pretend_to_be_model :model

      attr_accessor :loaded_from_model
      def setup
        self.loaded_from_model = model.attr_1
      end

      delegate_attr :model, :attr_1, :attr_2
    end

    TestModel = Struct.new(:attr_1, :attr_2, :attr_3) do
      def id;          end
      def to_key;      end
      def new_record?; end
      def persisted?;  end
    end

    let(:model)      { TestModel.new(:foo, :bar, :baz) }
    let(:aggregator) { TestAggregator.for(model) }


    describe '.delegate_accessor (alias to .delegate_attr)' do
      it 'defines readers for all passed attributes, delegating to the model' do
        aggregator.attr_1.must_equal :foo
        aggregator.attr_2.must_equal :bar
      end

      it 'defines writers for all passed attributes, delegating to the model' do
        aggregator.attr_1 = :new_foo
        aggregator.attr_2 = :new_bar

        aggregator.attr_1.must_equal :new_foo
        aggregator.attr_2.must_equal :new_bar

        model.attr_1.must_equal :new_foo
        model.attr_2.must_equal :new_bar
      end

      describe 'super calls in reader and writer' do
        class TestAggregatorWithSuper < Aggregator
          call_with :model

          delegate_attr :model, :attr_1

          def attr_1
            super.to_s + '_reader_super'
          end

          def attr_1=(value)
            super(value + '_writer_super')
          end
        end
        let(:aggregator) { TestAggregatorWithSuper.for(model) }

        it 'makes super usable in reader' do
          model.attr_1.must_equal :foo
          aggregator.attr_1.must_equal 'foo_reader_super'
        end

        it 'makes super usable in writer' do
          aggregator.attr_1 = 'bar'
          aggregator.attr_1.must_equal 'bar_writer_super_reader_super'
          model.attr_1.must_equal 'bar_writer_super'
        end
      end

      describe 'reader and writer are inheritable' do
        class InheritedTestAggregator < TestAggregator
          delegate_attr :model, :attr_3
        end
        let(:aggregator) { InheritedTestAggregator.for(model) }

        it 'uses the readers and writers from the superclass' do
          aggregator.attr_1.must_equal :foo
          aggregator.attr_2.must_equal :bar

          aggregator.attr_1 = :new_foo
          aggregator.attr_2 = :new_bar

          aggregator.attr_1.must_equal :new_foo
          aggregator.attr_2.must_equal :new_bar
        end

        it 'defines it own readers and writers' do
          aggregator.attr_3.must_equal :baz
          aggregator.attr_3 = :new_baz
          aggregator.attr_3.must_equal :new_baz
        end
      end
    end


    describe '.delegate_reader' do
      class TestAggregatorOnlyReader < Aggregator
        call_with :model
        delegate_reader :model, :attr_1
      end
      let(:aggregator) { TestAggregatorOnlyReader.for(model) }

      it 'defines readers for all passed attributes, delegating to the model' do
        aggregator.attr_1.must_equal :foo
      end

      it 'does not define writers for the passed attributes' do
        aggregator.wont_respond_to :attr_1=
      end
    end


    describe '.delegate_writer' do
      class TestAggregatorOnlyWriter < Aggregator
        call_with :model
        delegate_writer :model, :attr_1
      end
      let(:aggregator) { TestAggregatorOnlyWriter.for(model) }

      it 'does not define readers for the passed attributes' do
        aggregator.wont_respond_to :attr_1
      end

      it 'defines writers for all passed attributes, delegating to the model' do
        aggregator.attr_1 = :new_foo
        model.attr_1.must_equal :new_foo
      end
    end


    describe '.pretend_to_be_model (with argument)' do
      let(:model) {
        mock = MiniTest::Mock.new
        mock.expect(:attr_1, 'attr_1')
        mock
      }

      it 'defines a delegator for #id to the given model' do
        model.expect(:id, 'id')
        aggregator.id
        model.verify
      end

      it 'defines a delegator for #to_key to the given model' do
        model.expect(:to_key, 'to_key')
        aggregator.to_key
        model.verify
      end

      it 'defines a delegator for #to_param to the given model' do
        model.expect(:to_param, 'to_param')
        aggregator.to_param
        model.verify
      end

      it 'defines a delegator for #to_model to the given model' do
        model.expect(:to_model, 'to_model')
        aggregator.to_model
        model.verify
      end

      it 'defines a delegator for #new_record? to the given model' do
        model.expect(:new_record?, 'new_record?')
        aggregator.new_record?
        model.verify
      end

      it 'defines a delegator for #persisted? to the given model' do
        model.expect(:persisted?, 'persisted?')
        aggregator.persisted?
      end
    end


    describe '.pretend_to_be_model (without argument)' do
      class TestAggregatorAsNewRecord < Aggregator
        call_with :model
        pretend_to_be_model
      end
      let(:aggregator) { TestAggregatorAsNewRecord.for(model) }

      it 'defines #new_record? with true' do
        aggregator.new_record?.must_equal true
      end

      it 'defines #persisted? with false' do
        aggregator.persisted?.must_equal false
      end

      it 'does not define (nor delegate) #id' do
        aggregator.wont_respond_to :id
      end

      it 'does not define (nor delegate) #to_key' do
        aggregator.wont_respond_to :to_key
      end

      it 'does not define (nor delegate) #to_param' do
        aggregator.wont_respond_to :to_param
      end

      it 'does not define (nor delegate) #to_model' do
        aggregator.wont_respond_to :to_model
      end
    end


    describe '#setup' do
      it 'gets called by the initializer' do
        aggregator.loaded_from_model.must_equal :foo
      end

      it 'also works when #setup is not defined' do
        class TestAggregatorWithoutLoadData < Aggregator
        end

        TestAggregatorWithoutLoadData.new.must_be_kind_of Aggregator
      end

      describe 'with an inherited aggregator that calls super in #setup' do
        class InheritedTestAggregatorWithSuper < TestAggregator
          attr_accessor :loaded_only_here
          def setup
            super()
            self.loaded_only_here = model.attr_2
          end
        end
        let(:aggregator) { InheritedTestAggregatorWithSuper.for(model) }

        it 'loads the data for the base class' do
          aggregator.loaded_from_model.must_equal :foo
        end

        it 'loads the data for the inherited class' do
          aggregator.loaded_only_here.must_equal :bar
        end
      end

      describe 'with an inherited aggregator that does not call super in '\
               '#setup' do
        class InheritedTestAggregatorWithoutSuper < TestAggregator
          attr_accessor :loaded_only_here
          def setup
            self.loaded_only_here = model.attr_2
          end
        end

        let(:aggregator) { InheritedTestAggregatorWithoutSuper.for(model) }

        it 'defines the attribute accessors for the data of the base class '\
           'but does not load the data itself' do
          aggregator.loaded_from_model.must_be_nil
        end

        it 'loads the data for the inherited class' do
          aggregator.loaded_only_here.must_equal :bar
        end
      end
    end
  end
end
