require "spec_helper"

module PrimeService
  describe Base do
    class TestClass < described_class
      call_with :foo, :bar
    end

    class TestClassWithoutParams < described_class
    end

    class TestClassWithFactory < described_class
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


    describe "class with initializer params" do
      let(:test_class) { TestClass.for("foo value", "bar value") }

      describe ".call_with" do
        it "defines attribute readers for the call params" do
          expect(test_class).to respond_to :foo
          expect(test_class).to respond_to :bar
        end

        it "defines attribute writers for the call params" do
          test_class.foo = "new foo"
          expect(test_class.foo).to eq "new foo"
        end
      end

      describe "#initialize" do
        it "assigns the params to instance variables" do
          expect(test_class.foo).to eq "foo value"
          expect(test_class.bar).to eq "bar value"
        end
      end
    end


    describe "class without initializer params" do
      let(:test_class) { TestClassWithoutParams.new }

      it "works" do
        expect(test_class).to be_a described_class
      end
    end


    describe "class with a factory which does the same as the default" do
      let(:test_class) { TestClassWithFactory.for(:subclass_1, :bar) }


      describe ".for" do
        it "calls the factory method defined by .factory" do
          expect(test_class).to be_a TestClassWithFactory::TestSubclassOne
        end
      end
    end
  end
end
