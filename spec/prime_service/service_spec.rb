require "spec_helper"

module PrimeService
  class TestService < Service
    call_with :foo, :bar
  end


  class TestService < Service
    call_with :test_arg
  end


  describe Service do
    describe ".call" do
      it "initializes the service with the factory method and calls it" do
        service_double = instance_double Service
        expect(TestService).to receive(:for).with("test_value")
                           .and_return(service_double)
        expect(service_double).to receive(:call)

        TestService.call("test_value")
      end
    end


    describe "#call" do
      let(:service) { TestService.for("test_value") }

      it "has a fallback #call method that does nothing" do
        expect(service.call).to be_nil
      end
    end
  end
end
