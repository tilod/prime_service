require "spec_helper"

describe UniquenessValidator, :database do
  class UniqueUser < ActiveRecord::Base
  end

  shared_examples_for :a_uniqueness_validator do
    context "when field value is unique" do
      before { UniqueUser.create(email: "other@example.com") }

      it { should be_valid }
    end

    context "when field value is not unique" do
      before { UniqueUser.create(email: "test@example.com") }

      it { should_not be_valid }

      it "adds an error to the attribute" do
        subject.valid?
        expect(subject.errors[:email].size).to eq 1
      end
    end
  end


  let(:user) { UniqueUser.new(email: "test@example.com",
                              name:  "test name",
                              group: "admin") }


  describe "called with `validates :attribute_name, uniquness: true`" do
    class TestForm < PrimeService::Form
      model      :user
      persistent :email

      validates :email, uniqueness: true
    end

    subject { TestForm.new(user) }

    it_behaves_like :a_uniqueness_validator
  end


  describe "called with `validates_uniqueness_of ::attribute_name`" do
    class TestForm2 < PrimeService::Form
      model      :user
      persistent :email

      validates_uniqueness_of :email
    end

    subject { TestForm2.new(user) }

    it_behaves_like :a_uniqueness_validator
  end


  describe "called with :scope option with one scope" do
    class TestForm3 < PrimeService::Form
      model      :user
      persistent :email
      persistent :name

      validates :email, uniqueness: { scope: :name }
    end

    subject { TestForm3.new(user) }

    context "email and name are unique" do
      before { UniqueUser.create(email: "other@example.com", name: "other") }
      it { should be_valid }
    end

    context "email is unique but name is not" do
      before { UniqueUser.create(email: "other@example.com", name: "test name") }
      it { should be_valid }
    end

    context "email is unique for name" do
      before { UniqueUser.create(email: "test@example.com", name: "other") }
      it { should be_valid }
    end

    context "email is not unique for name" do
      before { UniqueUser.create(email: "test@example.com", name: "test name") }
      it { should_not be_valid }
    end
  end


  describe "called with :scope option with scope array" do
    class TestForm4 < PrimeService::Form
      model      :user
      persistent :email
      persistent :name
      persistent :group

      validates :email, uniqueness: { scope: [:name, :group] }
    end

    subject { TestForm4.new(user) }

    context "email and name and group are unique" do
      before { UniqueUser.create(email: "other@example.com", name: "other",
                                 group: "other") }
      it { should be_valid }
    end

    context "email and name are unique but group is not" do
      before { UniqueUser.create(email: "other@example.com", name: "other",
                                 group: "admin") }
      it { should be_valid }
    end

    context "email is unique but name and group are not" do
      before { UniqueUser.create(email: "other@example.com", name: "test name",
                                 group: "admin") }
      it { should be_valid }
    end

    context "email is unique for name and group" do
      before { UniqueUser.create(email: "test@example.com", name: "other",
                                 group: "other") }

      it { should be_valid }
    end

    context "email is unique for name but not for group" do
      before { UniqueUser.create(email: "test@example.com", name: "other",
                                 group: "admin") }

      it { should be_valid }
    end

    context "email is not unique for name" do
      before { UniqueUser.create(email: "test@example.com", name: "test name",
                                 group: "admin") }

      it { should_not be_valid }
    end
  end
end
