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
      let(:base_class) { TestClass.for('foo value', 'bar value') }

      describe '.call_with' do
        it 'defines attribute readers for the call params' do
          base_class.must_respond_to :foo
          base_class.must_respond_to :bar
        end

        it 'defines attribute writers for the call params' do
          base_class.foo = 'new foo'
          base_class.foo.must_equal 'new foo'
        end
      end

      describe '#initialize' do
        it 'assigns the params to instance variables' do
          base_class.foo.must_equal 'foo value'
          base_class.bar.must_equal 'bar value'
        end
      end
    end


    describe 'class without initializer params' do
      let(:base_class) { TestClassWithoutParams.new }

      it 'works' do
        base_class.must_be_kind_of TestClassWithoutParams
      end
    end


    describe 'class with a factory which does the same as the default' do
      let(:base_class) { TestClassWithFactory.for(:subclass_1, :bar) }


      describe '.for' do
        it 'calls the factory method defined by .factory' do
          base_class.must_be_kind_of TestClassWithFactory::TestSubclassOne
        end
      end
    end
  end
end
