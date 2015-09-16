require 'test_helper'

module PrimeService
  class TestService < Service
    call_with :test_arg

    def call
      '#call called with ' + test_arg
    end
  end

  class MockedTestService < Service
    call_with :test_arg

    def self.for(test_arg)
      ->() { '.for called with ' + test_arg }
    end
  end

  class EmptyTestService < Service
    call_with :test_arg
  end


  describe Service do
    describe '.call' do
      it 'initializes the service with the factory method' do
        MockedTestService.call('foo').must_equal '.for called with foo'
      end

      it '...and calls it' do
        TestService.call('foo').must_equal '#call called with foo'
      end
    end


    describe '#call' do
      let(:service) { EmptyTestService.for('foo') }

      it 'has a fallback #call method that does nothing' do
        service.call.must_be_nil
      end
    end
  end
end
