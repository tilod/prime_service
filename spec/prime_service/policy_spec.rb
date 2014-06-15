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
  end
end
