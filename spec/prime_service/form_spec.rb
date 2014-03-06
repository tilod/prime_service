require "spec_helper"

module PrimeService
  class Post
    attr_accessor :title, :content
    def save; true; end
  end

  class TestForm < Form
    property :title
    property :content
  end


  describe Form do
    let(:form) { TestForm.new(Post.new) }

#
#   Form#submit
#

    describe "#submit" do
      shared_examples_for :submit_a_valid_form do
        it "calls #process" do
          expect(form).to receive(:process).with(no_args)
          subject
        end

        it "returns the return value of process" do
          allow(form).to receive(:process).and_return(:return_of_process)
          expect(subject).to eq :return_of_process
        end
      end

      shared_examples_for :submit_an_invalid_form do
        it "does not call #process" do
          expect(form).not_to receive(:process)
          subject
        end

        it { should be_false }
      end

      context "when called with args" do
        subject { form.submit(params) }

        let(:params) { Hash[title: "Test Title"] }

        it "calls #validate and passes the args" do
          expect(form).to receive(:validate).with(params)
          subject
        end

        context "when #validate returns true" do
          before { allow(form).to receive(:validate).and_return(true) }

          it_behaves_like :submit_a_valid_form
        end

        context "when #validate returns false" do
          before { allow(form).to receive(:validate).and_return(false) }

          it_behaves_like :submit_an_invalid_form
        end
      end

      context "when called without args" do
        subject { form.submit }

        it "does not call #validate (but validates the form with #valid?)" do
          expect(form).not_to receive(:validate)
          subject
        end

        context "when form is valid" do
          before { allow(form).to receive(:valid?).and_return(true) }

          it_behaves_like :submit_a_valid_form
        end

        context "when form is not valid" do
          before { allow(form).to receive(:valid?).and_return(false) }

          it_behaves_like :submit_an_invalid_form
        end
      end
    end

#
#   Form#process
#

    describe "#process" do
      subject { form.process }

      it "has a default implementation calling #save with no args" do
        expect(form).to receive(:save).with(no_args)
        subject
      end
    end
  end
end
