require "spec_helper"

module PrimeService
  shared_examples_for :a_form_object do

#
#   Form#submit
#


    describe "#submit" do
      subject { form.submit(params) }

      context "when called with params" do
        it "calls #assign" do
          expect(form).to receive(:assign).with(params).and_call_original
          subject
        end
      end

      context "when called without params" do
        subject { form.submit }

        it "does not call #assign" do
          expect(form).not_to receive(:assign).with(params)
          subject
        end
      end

      context "form is valid" do
        before { allow(form).to receive(:valid?).and_return(true) }

        it "calls #process" do
          expect(form).to receive(:process).and_call_original
          subject
        end

        context "#process returns a truthy value" do
          before { allow(form).to receive(:persist).and_return(true) }
          it { should be_true }
        end

        context "#process returns false" do
          before { allow(form).to receive(:persist).and_return(false) }
          it { should be_false }
        end
      end

      context "form is not valid" do
        before { allow(form).to receive(:valid?).and_return(false) }

        it "does not call #process" do
          expect(form).not_to receive(:process)
          subject
        end

        it { should be_false }
      end
    end
  end




  describe Form do
    class FeedbackForm < Form
      transient :subject
      transient :grade,    type: Integer
      transient :feedback, default: "Enter Feedback"

      validates :subject, presence: true
    end

    describe "Form without a model" do
      let(:form)   { FeedbackForm.new }
      let(:params) { Hash[subject: "Subject", grade: 2] }
      
      it_behaves_like :a_form_object

#
#   FeedbackForm.transient
#

      describe ".transient" do
        it "defines a setter and a getter for the attribute" do
          form.subject = "Test Subject"
          expect(form.subject).to eq "Test Subject"
        end

        it "has an option :type for coercion" do
          form.grade = "1"
          expect(form.grade).to eq 1
        end

        it "uses String as default type" do
          form.subject = 1234
          expect(form.subject).to eq "1234"
        end

        it "passes other options to Virtus#attribute" do
          expect(form.feedback).to eq "Enter Feedback"
        end
      end

#
#   FeedbackForm.validates
#

      describe ".validates" do
        it "can use the validations of ActiveModel" do
          expect(form.valid?).to be_false
          expect(form.errors[:subject].size).to eq 1
        end
      end

#
#   FeedbackForm#assign
#


      describe "#assign" do
        subject { form.assign(params) }

        it "assigns the params to the attributes" do
          subject
          expect(form.subject).to eq "Subject"
          expect(form.grade).to eq 2
        end
      end
    end




    class ::Post
      attr_accessor :headline, :content

      def save
        true
      end
    end
    class ::PostOther
      attr_accessor :other

      def save
        true
      end
    end

    class PostForm < Form
      model :post

      persistent :headline
      persistent :content

      validates :headline, presence: true
    end

    class PostFormWithExplicitModelType < Form
      model post: ::PostOther
    end

    describe "Form for one model" do
      let(:form)   { PostForm.new }
      let(:params) { Hash[headline: "Headline", content: "My Post"] }

      it_behaves_like :a_form_object

#
#   PostForm.model
#

      describe ".model" do
        context "model type explicitly given" do
          let(:form) { PostFormWithExplicitModelType.new }

          it "defines #model which returns the model instance" do
            expect(form.model).to be_a PostOther
          end

          it "defines a getter for the model (equivalent to #model)" do
            expect(form.post).to be_a PostOther
          end

          it "defines the initializer to build the model when called with "\
             "no arguments" do
            expect(form.post.other).to eq nil
          end

          it "defines the initializer to assign the model to an instance "\
             "variable when passed as argument" do
            post = PostOther.new.tap do |post|
              post.other = "passed as argument"
            end
            form = PostFormWithExplicitModelType.new(post)
            expect(form.post.other).to eq "passed as argument"
          end
        end

        context "model type has to be inferred" do
          let(:form) { PostForm.new }

          it "defines #model which returns the model instance" do
            expect(form.model).to be_a Post
          end

          it "defines a getter for the model (equivalent to #model)" do
            expect(form.post).to be_a Post
          end

          it "defines the initializer to build the model when called with "\
             "no arguments" do
            expect(form.post.headline).to eq nil
          end

          it "defines the initializer to assign the model to an instance "\
             "variable when passed as argument" do
            post = Post.new.tap do |post|
              post.headline = "passed as argument"
            end
            form = PostForm.new(post)
            expect(form.post.headline).to eq "passed as argument"
          end
        end
      end

#
#   PostForm.persistent
#

      describe ".persistent" do
        it "defines a setters and a getters for the attributes" do
          form.headline = "Test Headline"
          form.content  = "Test Content"
          expect(form.headline).to eq "Test Headline"
          expect(form.content).to eq "Test Content"
        end

        it "delegates the setters to the model" do
          form.headline = "Test Setter"
          form.content  = "Test Content"
          expect(form.post.headline).to eq "Test Setter"
          expect(form.post.content).to eq "Test Content"
        end

        it "delegates the getters to the model" do
          form.post.headline = "Test Getter"
          form.post.content  = "Test Content"
          expect(form.headline).to eq "Test Getter"
          expect(form.content).to eq "Test Content"
        end
      end

#
#   PostForm.validates
#

      describe ".validates" do
        it "can use the validations of ActiveModel" do
          expect(form.valid?).to be_false
          expect(form.errors[:headline].size).to eq 1
        end
      end

#
#   PostForm#assign
#

      describe "#assign" do
        subject { form.assign(params) }

        it "assigns the params to the attributes" do
          subject
          expect(form.headline).to eq "Headline"
          expect(form.content).to eq "My Post"
        end

        it "assigns the params to the models" do
          subject
          expect(form.post.headline).to eq "Headline"
          expect(form.post.content).to eq "My Post"
        end
      end

#
#   PostForm#process
#

      describe "#process" do
        subject { form.process }

        it "has a default implementation that calls #persist" do
          expect(form).to receive(:persist)
          subject
        end
      end

#
#   PostForm#persist
#

      describe "#persist" do
        subject { form.persist }

        it "calls save on the model" do
          expect(form.model).to receive(:save)
          subject
        end

        context "the #save method of the model returns true" do
          it { should be_true }
        end

        context "the #save method of the model returns false" do
          before { allow(form.model).to receive(:save).and_return(false) }
          it { should be_false }
        end
      end
    end




    class ::User
      attr_accessor :email

      def save
        true
      end
    end

    class ::Enterprise
      attr_accessor :name

      def save
        true
      end
    end

    class UserCompanyForm < Form
      models :user, company: ::Enterprise

      persistent :email,        on: :user
      persistent :company_name, on: :company, as: :name

      validates :email, presence: true
      validates :company_name, presence: true
    end

    class UserCompanyFormOnlySymbols < Form
      models :user, :enterprise
    end

    class UserCompanyFormTwoHashes < Form
      models user: ::User, company: ::Enterprise
    end

    describe "Form for multiple models" do
      let(:form)   { UserCompanyForm.new }
      let(:params) { Hash[email:        "test@example.com",
                          password:     "123456",
                          company_name: "ACME"] }

      it_behaves_like :a_form_object

#
#   UserCompanyForm.models
#

      describe ".models" do
        context "one model type explicitly given, the other has to be "\
                "inferred" do
          it "defines getters for the models" do
            expect(form.user).to be_a User
            expect(form.company).to be_an Enterprise
          end

          it "defines the initializer to build the models when called with "\
             "no arguments" do
            expect(form.user.email).to eq nil
            expect(form.company.name).to eq nil
          end

          it "defines the initializer to assign all models to instance "\
             "variables when passed as arguments" do
            user = User.new.tap do |user|
              user.email = "all@example.com"
            end
            company = Enterprise.new.tap do |company|
              company.name = "ALL"
            end
            form = UserCompanyForm.new(user: user, company: company)
            expect(form.user.email).to eq "all@example.com"
            expect(form.company.name).to eq "ALL"
          end

          it "defines the initializer to assign some models to instance "\
             "variables when passed as arguments" do
            user = User.new.tap do |user|
              user.email = "some@example.com"
            end
            form = UserCompanyForm.new(user: user)
            expect(form.user.email).to eq "some@example.com"
            expect(form.company.name).to eq nil
          end
        end

        context "all models types have to be inferred" do
          let(:form) { UserCompanyFormOnlySymbols.new }

          it "defines getters for the models" do
            expect(form.user).to be_a User
            expect(form.enterprise).to be_a Enterprise
          end

          it "defines the initializer to build the models when called with "\
             "no arguments" do
            expect(form.user.email).to eq nil
            expect(form.enterprise.name).to eq nil
          end

          it "defines the initializer to assign all models to instance "\
             "variables when passed as arguments" do
            user = User.new.tap do |user|
              user.email = "all@example.com"
            end
            company = Enterprise.new.tap do |company|
              company.name = "ALL"
            end
            form = UserCompanyFormOnlySymbols.new(user: user,
                                                  enterprise: company)
            expect(form.user.email).to eq "all@example.com"
            expect(form.enterprise.name).to eq "ALL"
          end

          it "defines the initializer to assign some models to instance "\
             "variables when passed as arguments" do
            user = User.new.tap do |user|
              user.email = "some@example.com"
            end
            form = UserCompanyFormOnlySymbols.new(user: user)
            expect(form.user.email).to eq "some@example.com"
            expect(form.enterprise.name).to eq nil
          end
        end

        context "all models types explicitly given" do
          let(:form) { UserCompanyFormTwoHashes.new }

          it "defines getters for the models" do
            expect(form.user).to be_a User
            expect(form.company).to be_an Enterprise
          end

          it "defines the initializer to build the models when called with "\
             "no arguments" do
            expect(form.user.email).to eq nil
            expect(form.company.name).to eq nil
          end

          it "defines the initializer to assign all models to instance "\
             "variables when passed as arguments" do
            user = User.new.tap do |user|
              user.email = "all@example.com"
            end
            company = Enterprise.new.tap do |company|
              company.name = "ALL"
            end
            form = UserCompanyFormTwoHashes.new(user: user, company: company)
            expect(form.user.email).to eq "all@example.com"
            expect(form.company.name).to eq "ALL"
          end

          it "defines the initializer to assign some models to instance "\
             "variables when passed as arguments" do
            user = User.new.tap do |user|
              user.email = "some@example.com"
            end
            form = UserCompanyFormTwoHashes.new(user: user)
            expect(form.user.email).to eq "some@example.com"
            expect(form.company.name).to eq nil
          end
        end
      end

#
#   UserCompanyForm.persistent
#

      describe ".persistent" do
        it "defines a setters and a getters for the attributes" do
          form.email        = "test@example.com"
          form.company_name = "ACME"
          expect(form.email).to eq "test@example.com"
          expect(form.company_name).to eq "ACME"
        end

        it "delegates the setters to the models" do
          form.email        = "test@example.com"
          form.company_name = "ACME"
          expect(form.user.email).to eq "test@example.com"
          expect(form.company.name).to eq "ACME"
        end

        it "delegates the getters to the models" do
          form.user.email  = "test@example.com"
          form.company.name = "ACME"
          expect(form.email).to eq "test@example.com"
          expect(form.company_name).to eq "ACME"
        end
      end

#
#   UserCompanyForm.validates
#

      describe ".validates" do
        it "can use the validations of ActiveModel" do
          expect(form.valid?).to be_false
          expect(form.errors[:email].size).to eq 1
          expect(form.errors[:company_name].size).to eq 1
        end
      end

#
#   UserCompanyForm#assign
#

      describe "#assign" do
        subject { form.assign(params) }

        it "assigns the params to the attributes" do
          subject
          expect(form.email).to eq "test@example.com"
          expect(form.company_name).to eq "ACME"
        end

        it "assigns the params to the models" do
          subject
          expect(form.user.email).to eq "test@example.com"
          expect(form.company.name).to eq "ACME"
        end
      end
    end




    class ::CategorizedPost < ::Post
      attr_accessor :category

      def save
        true
      end
    end

    class CategorizedPostForm < PostForm
      model :categorized_post

      persistent :category

      validates :category, presence: true
    end    

    describe "Derived form" do
      let(:form)   { CategorizedPostForm.new }
      let(:params) { Hash[headline: "Headline", content: "My Post"] }

      it_behaves_like :a_form_object

      it "has the model of the derived class" do
        expect(form.model).to be_a ::CategorizedPost
      end

      it "has the attributes of the base form" do
        form.headline = "Test Headline"
        form.content  = "Test Content"

        expect(form.headline).to eq "Test Headline"
        expect(form.content).to eq "Test Content"
      end

      it "has the attributes of the derived form" do
        form.category = "Test Category"
        expect(form.category).to eq "Test Category"
      end

      it "has the validations of the base form" do
        expect(form.valid?).to be_false
        expect(form.errors[:headline].size).to eq 1
      end

      it "has the validations of the derived form" do
        expect(form.valid?).to be_false
        expect(form.errors[:category].size).to eq 1
      end
    end
  end
end
