require 'spec_helper'

module PrimeService
  class TestPolicy < Policy
    call_with :foo, :bar
  end


  class TestPolicyWithoutParams < Policy
  end


  describe Policy do
    let(:test_policy) { TestPolicy.new("foo value", "bar value") }


    describe "policy with initializer params" do
      describe "#initialize" do
        it "assigns the params to instance variables" do
          expect(test_policy.foo).to eq "foo value"
          expect(test_policy.bar).to eq "bar value"
        end
      end

      it "defines attribute writers for the call params" do
        test_policy.foo = "new foo"
        expect(test_policy.foo).to eq "new foo"
      end
    end


    describe "policy without initializer params" do
      let(:test_policy) { TestPolicyWithoutParams.new }

      describe "#initialize" do
        it "works" do
          expect(test_policy).to be_a Policy
        end
      end
    end
  end
end
