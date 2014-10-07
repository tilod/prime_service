require 'spec_helper'

module PrimeService
  class TestPolicy < Policy
    call_with :foo, :bar
  end


  class TestPolicyWithoutParams < Policy
  end


  class TestPolicyWithFactory < Service
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


  describe Policy do
    describe "policy with initializer params" do
      let(:test_policy) { TestPolicy.for("foo value", "bar value") }

      describe ".call_with" do
        it "defines attribute readers for the call params" do
          expect(test_policy).to respond_to :foo
          expect(test_policy).to respond_to :bar
        end

        it "defines attribute writers for the call params" do
          test_policy.foo = "new foo"
          expect(test_policy.foo).to eq "new foo"
        end
      end

      describe "#initialize" do
        it "assigns the params to instance variables" do
          expect(test_policy.foo).to eq "foo value"
          expect(test_policy.bar).to eq "bar value"
        end
      end
    end


    describe "policy without initializer params" do
      let(:test_policy) { TestPolicyWithoutParams.new }

      it "works" do
        expect(test_policy).to be_a Policy
      end
    end


    describe "policy with a factory which does the same as the default" do
      let(:test_policy) { TestPolicyWithFactory.for(:subclass_1, :bar) }


      describe ".for" do
        it "calls the factory method defined by .factory" do
          expect(test_policy).to be_a TestPolicyWithFactory::TestSubclassOne
        end
      end
    end
  end
end
