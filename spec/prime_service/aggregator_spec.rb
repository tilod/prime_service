require "spec_helper"

module PrimeService
  describe Aggregator do
    class TestAggregator < described_class
      call_with :model

      delegate_attr :model, :attr_1, :attr_2
    end

    TestModel = Struct.new(:attr_1, :attr_2)


    describe ".delegate_attr" do
      let(:model)      { TestModel.new(:foo, :bar) }
      let(:aggregator) { TestAggregator.for(model) }

      it "defines getters for all passed attributes, delegating to the model" do
        expect(aggregator.attr_1).to eq :foo
        expect(aggregator.attr_2).to eq :bar
      end

      it "defines setters for all passed attributes, delegating to the model" do
        aggregator.attr_1 = :new_foo
        aggregator.attr_2 = :new_bar

        expect(aggregator.attr_1).to eq :new_foo
        expect(aggregator.attr_2).to eq :new_bar

        expect(model.attr_1).to eq :new_foo
        expect(model.attr_2).to eq :new_bar
      end
    end
  end
end
