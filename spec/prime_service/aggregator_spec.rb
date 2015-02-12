require "spec_helper"

module PrimeService
  describe Aggregator do
    class TestAggregator < described_class
      call_with          :model
      delegate_record_id :model

      load_data :loaded_from_model do
        self.loaded_from_model = model.attr_1
      end

      delegate_attr :model, :attr_1, :attr_2
    end

    class TestAggregatorAsNewRecord < described_class
      call_with :model
      define_as_new_record
    end

    class TestAggregatorWithoutLoadData < described_class
    end

    class InheritedTestAggregatorWithSuper < TestAggregator
      load_data :loaded_only_here do
        super()
        self.loaded_only_here = model.attr_2
      end
    end

    class InheritedTestAggregatorWithoutSuper < TestAggregator
      load_data :loaded_only_here do
        self.loaded_only_here = model.attr_2
      end
    end

    TestModel = Struct.new(:attr_1, :attr_2) do
      def id;          end
      def to_key;      end
      def new_record?; end
      def persisted?;  end
    end

    let(:model)      { TestModel.new(:foo, :bar) }
    let(:aggregator) { TestAggregator.for(model) }


    describe ".delegate_attr" do
      it "defines readers for all passed attributes, delegating to the model" do
        expect(aggregator.attr_1).to eq :foo
        expect(aggregator.attr_2).to eq :bar
      end

      it "defines writers for all passed attributes, delegating to the model" do
        aggregator.attr_1 = :new_foo
        aggregator.attr_2 = :new_bar

        expect(aggregator.attr_1).to eq :new_foo
        expect(aggregator.attr_2).to eq :new_bar

        expect(model.attr_1).to eq :new_foo
        expect(model.attr_2).to eq :new_bar
      end
    end


    describe ".delegate_record_id" do
      it "defines a delegator for #id to the given model" do
        expect(model).to receive(:id).with(no_args)
        aggregator.id
      end

      it "defines a delegator for #to_key to the given model" do
        expect(model).to receive(:to_key).with(no_args)
        aggregator.to_key
      end

      it "defines a delegator for #to_param to the given model" do
        expect(model).to receive(:to_param).with(no_args)
        aggregator.to_param
      end

      it "defines a delegator for #new_record? to the given model" do
        expect(model).to receive(:new_record?).with(no_args)
        aggregator.new_record?
      end

      it "defines a delegator for #persisted? to the given model" do
        expect(model).to receive(:persisted?).with(no_args)
        aggregator.persisted?
      end
    end


    describe ".define_as_new_record" do
      let(:aggregator) { TestAggregatorAsNewRecord.for(model) }

      it "defines #new_record? with true" do
        expect(aggregator.new_record?).to be true
      end

      it "defines #persisted? with false" do
        expect(aggregator.persisted?).to be false
      end

      it "does not define (nor delegate) #id" do
        expect(aggregator).not_to respond_to :id
      end

      it "does not define (nor delegate) #to_key" do
        expect(aggregator).not_to respond_to :to_key
      end

      it "does not define (nor delegate) #to_param" do
        expect(aggregator).not_to respond_to :to_param
      end
    end


    describe ".load_data" do
      it "defines readers for all passed attributes" do
        expect(aggregator).to respond_to :loaded_from_model
      end

      it "defines writers for all passed attributes" do
        aggregator.loaded_from_model = :new_foo
        expect(aggregator.loaded_from_model).to eq :new_foo
      end

      it "makes the block to be called by the initializer" do
        expect(aggregator.loaded_from_model).to eq :foo
      end

      it "also works when .load_data is not called" do
        expect { TestAggregatorWithoutLoadData.new }.not_to raise_error
      end

      context "with an inherited aggregator that calls super in .load_data" do
        let(:aggregator) { InheritedTestAggregatorWithSuper.for(model) }

        it "loads the data for the base class" do
          expect(aggregator.loaded_from_model).to eq :foo
        end

        it "loads the data for the inherited class" do
          expect(aggregator.loaded_only_here).to eq :bar
        end
      end

      context "with an inherited aggregator that does not call super in "\
              ".load_data" do
        let(:aggregator) { InheritedTestAggregatorWithoutSuper.for(model) }

        it "defines the attribute accessors for the data of the base class "\
           "but does not load the data itself" do
          expect(aggregator.loaded_from_model).to be_nil
        end

        it "loads the data for the inherited class" do
          expect(aggregator.loaded_only_here).to eq :bar
        end
      end
    end
  end
end
