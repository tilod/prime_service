require 'spec_helper'

module PrimeService
  class TestQuery < Query
    scope_with :foo
  end


  class TestQueryWithoutDefaultScope < Query
  end


  describe Query do
    describe "query with default scope" do
      describe ".scope_with" do
        it "assigns the :default_scope" do
          expect(TestQuery.new.default_scope).to eq :foo
        end
      end

      context "when no scope is passed" do
        let(:test_query) { TestQuery.new }

        describe "#initialize" do
          it "assigns the default scope as scope" do
            expect(test_query.scope).to eq :foo
          end
        end
      end

      context "when scope is passed" do
        let(:test_query) { TestQuery.for(:bar) }

        describe "#initialize" do
          it "assigns the passed scope as scope" do
            expect(test_query.scope).to eq :bar
          end

          it "leaves the default scope" do
            expect(test_query.default_scope).to eq :foo
          end
        end
      end

      it "defines an attribute writer for :scope" do
        query = TestQuery.new
        query.scope = :bar
        expect(query.scope).to eq :bar
      end
    end


    describe "policy without initializer params" do
      context "when initialized without scope" do
        let(:test_query) { TestQueryWithoutDefaultScope.new }

        it "raises an error on initialization" do
          expect { test_query }.to raise_error Query::NoScopeError
        end
      end

      context "when initialized with scope" do
        let(:test_query) { TestQueryWithoutDefaultScope.new(:baz) }

        it "works just fine" do
          expect(test_query.scope).to eq :baz
        end

        it "returns nil as default scope" do
          expect(test_query.default_scope).to be_nil
        end
      end
    end
  end
end
