require "spec_helper"

module PrimeService
  class TestService < Service
    call_with :foo, :bar
  end


  class TestServiceWithoutParams < Service
  end


  class TestServiceWithFactory < Service
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




  shared_examples_for :a_service_object do
    describe ".call" do
      it "initializes the service with the factory method and calls it" do
        service_double = instance_double Service
        expect(test_class).to receive(:for).with("foo value", "bar value")
                          .and_return(service_double)
        expect(service_double).to receive(:call)

        test_class.call("foo value", "bar value")
      end
    end


    describe "#call" do
      it "has a fallback #call method that does nothing" do
        expect(test_service.call).to be_nil
      end
    end
  end




  describe Service do
    describe "Service without factory" do
      let(:test_class)   { TestService }
      let(:test_service) { test_class.for("foo value", "bar value") }


      describe ".for" do
        it "initializes the service" do
          expect(test_service).to be_a TestService
        end
      end


      it_behaves_like :a_service_object
    end


    describe "Service without params" do
      let(:test_class)   { TestServiceWithoutParams }
      let(:test_service) { test_class.new }

      it_behaves_like :a_service_object
    end


    describe "Service with a factory which does the same as the default" do
      let(:test_class)   { TestServiceWithFactory }
      let(:test_service) { test_class.for(:subclass_1, "bar value") }


      describe ".for" do
        it "calls the factory method defined by .factory" do
          expect(test_service).to be_a TestServiceWithFactory::TestSubclassOne
        end
      end


      it_behaves_like :a_service_object
    end
  end
end
