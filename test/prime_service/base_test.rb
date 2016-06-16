require 'test_helper'

module PrimeService
  describe Base do
    class TestClass < Base
      call_with :foo, :bar
    end

    class TestClassWithoutParams < Base
    end

    class TestClassWithFactory < Base
      call_with :foo, :bar

      def self.for(foo, bar)
        if foo == :subclass_1
          TestSubclassOne.new(foo, bar)
        else
          TestSubclassTwo.new(foo, bar)
        end
      end

      class TestSubclassOne < self
      end

      class TestSubclassTwo < self
      end
    end


    describe 'class with initializer params' do
      let(:base) { TestClass.for('foo value', 'bar value') }

      describe '`call_with`' do
        it 'defines attribute readers for the call params' do
          base.must_respond_to :foo
          base.must_respond_to :bar
        end

        it 'defines attribute writers for the call params' do
          base.foo = 'new foo'
          base.foo.must_equal 'new foo'
        end
      end

      describe '#initialize' do
        it 'assigns the params to instance variables' do
          base.foo.must_equal 'foo value'
          base.bar.must_equal 'bar value'
        end

        it 'may be called with less params then defined with .call_with' do
          base = TestClass.for('foo value')
          base.foo.must_equal 'foo value'
          base.bar.must_be_nil
        end
      end

      describe '#call_args' do
        it 'returns the list of arguments that must be passed to .call' do
          base.call_args.must_equal [:foo, :bar]
        end
      end
    end


    describe 'class without initializer params' do
      let(:base) { TestClassWithoutParams.new }

      it 'works' do
        base.must_be_kind_of TestClassWithoutParams
      end

      describe '#call_args' do
        it 'returns an empty array' do
          base.call_args.must_equal []
        end
      end
    end


    describe 'class with a factory' do
      let(:base) { TestClassWithFactory.for(:subclass_1, :bar) }

      describe '.for' do
        it 'calls the factory to create the instance' do
          base.must_be_kind_of TestClassWithFactory::TestSubclassOne
        end
      end
    end
  end
end
