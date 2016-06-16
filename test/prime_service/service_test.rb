require 'test_helper'

module PrimeService
  TestArg = Struct.new(:arg)

  class TestService < Service
    call_with :test_arg

    def call
      test_arg.arg = '#call was called'
    end
  end

  class MockedTestService < Service
    call_with :test_arg

    def self.for(test_arg)
      test_arg.arg = '.for was called'
      new(test_arg)
    end
  end

  class EmptyTestService < Service
    call_with :test_arg
  end

  class NotAllowedTestService < Service
    call_with :test_arg

    def call
      test_arg.arg = '#call was called'
    end

    def allowed?
      false
    end
  end


  describe Service do
    describe '.call' do
      it 'initializes the service with the factory method' do
        test_arg = TestArg.new('foo')
        MockedTestService.call(test_arg)
        test_arg.arg.must_equal '.for was called'
      end

      it '... and calls it' do
        test_arg = TestArg.new('foo')
        TestService.call(test_arg)
        test_arg.arg.must_equal '#call was called'
      end

      it 'returns what #call returned' do
        test_arg = TestArg.new('foo')
        TestService.call(test_arg).must_equal '#call was called'
      end

      describe 'when service is not allowed to run' do
        it 'does not call #call' do
          test_arg = TestArg.new('foo')
          NotAllowedTestService.call(test_arg)
          test_arg.arg.must_equal 'foo'
        end

        it 'returns false' do
          NotAllowedTestService.call('foo').must_equal false
        end
      end
    end


    describe '.call!' do
      describe 'when service is allowed to run' do
        it 'behaves like .call' do
          test_arg = TestArg.new('foo')
          TestService.call!(test_arg).must_equal '#call was called'
        end
      end

      describe 'when service is not allowed to run' do
        it 'raises an error' do
          ->{ NotAllowedTestService.call!('foo') }.must_raise ServiceNotAllowedError
        end
      end
    end


    describe '#allowed?' do
      it 'has a default implementation that returns `true`' do
        TestService.for('foo').allowed?.must_equal true
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
