require 'spec_helper'

module PrimeService
  class TestPolicy < Policy
    call_with :foo, :bar
  end


  class TestPolicyWithoutParams < Policy
  end


  class TestPolicyWithOptionsAndFlags < Policy
    call_with :foo

    option    :option_1
    option    :option_2, "default value"
    option    :option_3

    flag      :flag_1
    flag      :flag_2, true
    flag      :flag_3
  end


  describe Policy do
    let(:test_policy) { TestPolicy.new("foo value", "bar value") }


    describe "policy with initializer arguments" do
      describe ".call_with" do
        it "defines attribute readers for the call arguments" do
          expect(test_policy).to respond_to :foo
          expect(test_policy).to respond_to :bar
        end

        it "defines attribute writers for the call arguments" do
          test_policy.foo = "new foo"
          expect(test_policy.foo).to eq "new foo"
        end
      end

      describe "#initialize" do
        it "assigns the arguments to instance variables" do
          expect(test_policy.foo).to eq "foo value"
          expect(test_policy.bar).to eq "bar value"
        end
      end
    end


    describe "policy without initializer arguments" do
      let(:test_policy) { TestPolicyWithoutParams.new }

      it "works" do
        expect(test_policy).to be_a Policy
      end
    end


    describe "policy with options and flags" do
      let(:test_policy) {
        TestPolicyWithOptionsAndFlags.new("foo value",
                                           option_1: "option 1 argument",
                                           flag_1:    true)
      }

      describe ".option" do
        it "defines attribute reader for the options" do
          expect(test_policy).to respond_to :option_1
          expect(test_policy).to respond_to :option_2
          expect(test_policy).to respond_to :option_3
        end

        it "defines attribute writers for the options" do
          test_policy.option_1 = "new value"
          expect(test_policy.option_1).to eq "new value"
        end

        it "uses `nil` as default value for the options when no default value "\
           "is defined" do
          expect(test_policy.option_3).to be_nil
        end
      end

      describe "#initialize" do
        it "assigns the option arguments to the options" do
          expect(test_policy.option_1).to eq "option 1 argument"
        end

        it "it keeps the default value in place when no value for an option "\
           "is passed" do
          expect(test_policy.option_2).to eq "default value"
        end
      end


      describe ".flag" do
        it "defines attribute reader with question marks for the flags" do
          expect(test_policy).to respond_to :flag_1?
          expect(test_policy).to respond_to :flag_2?
          expect(test_policy).to respond_to :flag_3?
        end

        it "defines attribute writers for the flags" do
          test_policy.flag_3 = :truthy
          expect(test_policy.flag_3?).to be true
        end

        it "uses `false` as default value for the flags when no default value "\
           "is defined" do
          expect(test_policy.flag_3?).to be false
        end
      end

      describe "#initialize" do
        it "assigns the flag arguments to the flags" do
          expect(test_policy.flag_1?).to be true
        end

        it "it keeps the default value in place when no value for an flag "\
           "is passed" do
          expect(test_policy.flag_2?).to be true
        end
      end
    end
  end
end
