require 'test_helper'

module PrimeService
  class TestQuery < Query
    scope_with [:foo]
  end

  class TestQueryWithSymbolScope < Query
    scope_with :foo
  end

  class TestQueryWithStringScope < Query
    scope_with 'foo'
  end


  class TestQueryWithoutDefaultScope < Query
  end


  describe Query do
    describe 'query with default scope' do
      describe '.scope_with' do
        describe 'when called with a symbol' do
          let(:query) { TestQueryWithSymbolScope.new(:test_foo) }

          it 'defines an attribute reader of this name' do
            query.foo.must_equal :test_foo
          end

          it 'defines an attribute writer of this name' do
            query.foo = :new_foo
            query.foo.must_equal :new_foo
          end
        end

        describe 'when called with a string' do
          let(:query) { TestQueryWithStringScope.new(:test_foo) }

          it 'defines an attribute reader of this name' do
            query.foo.must_equal :test_foo
          end

          it 'defines an attribute writer of this name' do
            query.foo = :new_foo
            query.foo.must_equal :new_foo
          end
        end

        describe 'when called with something else' do
          it 'assigns the #default_scope' do
            TestQuery.new.default_scope.must_equal [:foo]
          end
        end
      end

      describe 'when no scope is passed' do
        let(:query) { TestQuery.new }

        describe '#initialize' do
          it 'assigns the default scope as scope' do
            query.scope.must_equal [:foo]
          end
        end
      end

      describe 'when scope is passed' do
        let(:query) { TestQuery.for(:bar) }

        describe '#initialize' do
          it 'assigns the passed scope as scope' do
            query.scope.must_equal :bar
          end

          it 'leaves the default scope' do
            query.default_scope.must_equal [:foo]
          end
        end
      end

      it 'defines an attribute writer for :scope' do
        query = TestQuery.new
        query.scope = :bar
        query.scope.must_equal :bar
      end
    end


    describe 'query without initializer params' do
      describe 'when initialized without scope' do
        let(:query) { TestQueryWithoutDefaultScope.new }

        it 'raises an error on initialization' do
          ->{ query }.must_raise Query::NoScopeError
        end
      end

      describe 'when initialized with scope' do
        let(:query) { TestQueryWithoutDefaultScope.new(:baz) }

        it 'works just fine' do
          query.scope.must_equal :baz
        end

        it 'returns nil as default scope' do
          query.default_scope.must_be_nil
        end
      end
    end


    describe 'query with symbol or string default scope' do
      describe 'when initialized without scope' do
        let(:query_symbol) { TestQueryWithSymbolScope.new }
        let(:query_string) { TestQueryWithStringScope.new }

        it 'raises an error on initialization' do
          ->{ query_symbol }.must_raise Query::NoScopeError
          ->{ query_string }.must_raise Query::NoScopeError
        end
      end

        describe 'when initialized with scope' do
          let(:query_symbol) { TestQueryWithSymbolScope.new(:test_symbol) }
          let(:query_string) { TestQueryWithStringScope.new(:test_string) }

          it 'works just fine' do
            query_symbol.foo.must_equal :test_symbol
            query_string.foo.must_equal :test_string
          end

          it 'returns the nil as default scope' do
            query_symbol.default_scope.must_be_nil
            query_string.default_scope.must_be_nil
          end
        end
    end
  end
end
