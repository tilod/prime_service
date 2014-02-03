require "spec_helper"

describe UniquenessValidator do
  TestUser = Struct.new(:email) do
    def self.where(*)
      []
    end
  end

  class TestForm < PrimeService::Form
    model      user: TestUser
    persistent :email

    validates :email, uniqueness: true
  end

  class TestForm2 < PrimeService::Form
    model      user: TestUser
    persistent :email

    validates_uniqueness_of :email
  end


  shared_examples_for :a_uniqueness_validator do
    context "when field value is unique" do
      it "marks the model valid" do
        expect(form).to be_valid
      end
    end

    context "when field value is not unique" do
      before { allow(TestUser).to receive(:where)
                              .with(email: "test@example.com")
                              .and_return([TestUser.new]) }

      it "marks the model invalid" do
        expect(form).not_to be_valid
      end

      it "adds an error to the attribute" do
        form.valid?
        expect(form.errors[:email].size).to eq 1
      end
    end
  end


  describe "called with `validates :attribute_name, uniquness: true`" do
    let(:form) { TestForm.new(user) }
    let(:user) { TestUser.new("test@example.com") }

    it_behaves_like :a_uniqueness_validator
  end


  describe "called with `validates_uniqueness_of ::attribute_name`" do
    let(:form) { TestForm2.new(user) }
    let(:user) { TestUser.new("test@example.com") }

    it_behaves_like :a_uniqueness_validator
  end
end
