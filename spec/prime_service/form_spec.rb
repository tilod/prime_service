require "spec_helper"

module PrimeService
  shared_examples_for :a_form_object do

#
#   Form#submit
#

    describe "#submit" do
      subject { form.submit(params) }

      context "when called with params" do
        it "calls #attributes=" do
          expect(form).to receive(:attributes=).with(params).and_call_original
          subject
        end
      end

      context "when called without params" do
        subject { form.submit }

        it "does not call #attributes=" do
          expect(form).not_to receive(:attributes=).with(params)
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
    describe "Form without a model" do
      class FeedbackForm < Form
        transient :subject
        transient :grade,    type: Integer
        transient :feedback, default: "Enter Feedback"

        validates :subject, presence: true
      end

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

        it "has a :type options for coercion" do
          form.grade = "1"
          expect(form.grade).to eq 1
        end

        it "uses String as default type if :type option is omitted" do
          form.subject = 1234
          expect(form.subject).to eq "1234"
        end

        it "passes other options to Virtus.attribute" do
          pending
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
#   FeedbackForm.attributes
#

      describe ".attributes" do
        it "returns an array with all attribute names" do
          expect(FeedbackForm.attributes)
            .to match_array [:subject, :grade, :feedback]
        end
      end

#
#   FeedbackForm.model_name
#

      describe ".model_name" do
        class NamedFeedbackForm < Form
          form_name "SetByFormName"
        end

        context "when .form_name is not used to set the name" do
          subject { FeedbackForm.model_name }

          it { should be_an ActiveModel::Name }

          it "is derived from the class name" do
            should eq "Feedback"
          end
        end

        context "when .form_name is used to set the name" do
          subject { NamedFeedbackForm.model_name }

          it { should be_an ActiveModel::Name }

          it "uses the set name" do
            should eq "SetByFormName"
          end
        end
      end

#
#   FeedbackForm#main_model
#

      describe "#main_model" do
        subject { form.main_model }
        it { should be_nil }
      end

#
#   FeedbackForm#attributes=
#


      describe "#attributes=" do
        subject { form.attributes = params }

        it "assigns the params to the attributes" do
          subject
          expect(form.subject).to eq "Subject"
          expect(form.grade).to eq 2
        end
      end
    end




    describe "Form for one model" do
      class ::Post
        attr_accessor :headline, :content
        def save; true; end
      end

      class PostForm < Form
        model :post

        persistent :headline
        persistent :content

        validates :headline, presence: true
      end

      let(:form)   { PostForm.new }
      let(:params) { Hash[headline: "Headline", content: "My Post"] }

      it_behaves_like :a_form_object

#
#   delegate
#

      describe "Delegations of ActiveModel::Conversion" do
        class PostFormNoMain < Form
          model :post, main: false
        end

        it "delegates #persisted? to the set main model" do
          expect(form.post).to receive(:persisted?).with(no_args)
          form.persisted?
        end

        it "delegates #to_key to the model" do
          expect(form.post).to receive(:to_key).with(no_args)
          form.to_key
        end

        it "delegates #to_param to the model" do
          expect(form.post).to receive(:to_param).with(no_args)
          form.to_param
        end

        it "delegates #id to the model" do
          expect(form.post).to receive(:id).with(no_args)
          form.id
        end

        context "when model is set to be no main model (with "\
                "`model ..., main: false`)" do
          let(:form) { PostFormNoMain.new }

          specify { expect(form.persisted?).to be_nil }
          specify { expect(form.to_key).to be_nil }
          specify { expect(form.to_param).to be_nil }
          specify { expect(form.id).to be_nil }
        end
      end

#
#   PostForm.new
#

      describe "initializer" do
        it "assigns the passed models and options to instance variables" do
          post = Post.new.tap do |post|
            post.headline = "passed as argument"
          end
          form = PostForm.new(post: post)
          expect(form.post.headline).to eq "passed as argument"
        end
      end

#
#   PostForm.model
#

      describe ".model" do
        let(:form) { PostForm.new }

        it "defines a getter for the model" do
          expect(form.post).to be_a Post
        end

        it "defines the getter to build the model when model is not assigned" do
          expect(form).to receive(:build_post).with(no_args)
          form.post
        end

        describe "defines a build_[model_name] method" do
          context "when initializer was called with :[model_name]_id "\
                  "argument" do
            it "trys to load the model from the database" do
              form = PostForm.new(post_id: "1")
              expect(Post).to receive(:find).with("1")
              form.build_post
            end
          end

          context "when initializer was not called with :[model_name]_id "\
                  "param" do
            it "initializes the model with no arguments" do
              expect(Post).to receive(:new).with(no_args)
              form.build_post
            end
          end

          context "model type has to be inferred" do
            it "defines a build_[model_name] method inferring the class of the "\
               "model" do
              expect(form.build_post).to be_a Post
            end
          end

          context "model type explicitly given" do
            class PostOther
              attr_accessor :other
              def save; true; end
            end

            class PostFormWithExplicitModelType < Form
              model :post, type: PostOther
            end

            let(:form) { PostFormWithExplicitModelType.new }

            it "defines a build_[model_name] method using class passed as type" do
              expect(form.build_post).to be_a PostOther
            end
          end

          context "model build lambda explicitly given" do
            class PostFormWithBuildLambda < Form
              model :post, build: ->{ :custom_build_lambda }
            end

            let(:form) { PostFormWithBuildLambda.new }

            it "defines a build_[model_name] method using the passed lambda" do
              expect(form.build_post).to eq :custom_build_lambda
            end
          end

          describe "generated build_[model_name] method can be overridden" do
            class PostWithCustomBuilderForm < Form
              model :post

              def build_post
                Post.new.tap { |post| post.content = "custom builder" }
              end
            end

            let(:form) { PostWithCustomBuilderForm.new }

            it "gets called instead of the generated method" do
              new_model = form.build_post

              expect(new_model).to be_a Post
              expect(new_model.content).to eq "custom builder"
            end
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

        it "defines #model_for_[attribute_name] that returns the model for "\
           "the attribute" do
          expect(form.model_for_headline).to eq form.post
          expect(form.model_for_content).to eq form.post
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
#   PostForm.attributes
#

      describe ".attributes" do
        it "returns an array with all attribute names" do
          expect(PostForm.attributes)
            .to match_array [:headline, :content]
        end
      end

#
#   PostForm#main_model
#

      describe "#main_model" do
        it "returns the model of the form" do
          expect(form.main_model).to be form.post
        end
      end

#
#   PostForm#attributes=
#

      describe "#attributes=" do
        subject { form.attributes = params }

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
          expect(form.post).to receive(:save)
          subject
        end

        context "when the #save method of the model returns true" do
          it { should be_true }
        end

        context "when the #save method of the model returns false" do
          before { allow(form.post).to receive(:save).and_return(false) }
          it { should be_false }
        end
      end
    end




    describe "Form for multiple models" do
      class ::User
        attr_accessor :email
        def save; true; end
      end

      class ::Company
        attr_accessor :name
        def save; true; end
      end

      class ::Account
        attr_accessor :user

        def initialize
          @user = ::User.new.tap { |user| user.email = "account@example.com" }
        end

        def save; true; end
      end

      class UserCompanyForm < Form
        model :user,    main: true
        model :company

        persistent :email,        on: :user
        persistent :company_name, on: :company, as: :name

        validates :email, presence: true
        validates :company_name, presence: true
      end

      let(:form)   { UserCompanyForm.new }
      let(:params) { Hash[email:        "test@example.com",
                          password:     "123456",
                          company_name: "ACME"] }

      it_behaves_like :a_form_object

#
#   delegate
#

      describe "Delegations of ActiveModel::Conversion" do
        class UserCompanyNoMainForm < Form
          model :user
          model :company
        end

        it "delegate #persisted? to the set main model" do
          expect(form.user).to receive(:persisted?).with(no_args)
          form.persisted?
        end

        it "delegates #to_key to the set main model" do
          expect(form.user).to receive(:to_key).with(no_args)
          form.to_key
        end

        it "delegates #to_param to the set main model" do
          expect(form.user).to receive(:to_param).with(no_args)
          form.to_param
        end

        it "delegates #id to the set main model" do
          expect(form.user).to receive(:id).with(no_args)
          form.id
        end

        context "when no main model is set" do
          let(:form) { UserCompanyNoMainForm.new }

          specify { expect(form.persisted?).to be_nil }
          specify { expect(form.to_key).to be_nil }
          specify { expect(form.to_param).to be_nil }
          specify { expect(form.id).to be_nil }
        end
      end

#
#   UserCompanyForm.option
#
  
      describe ".option" do
        class UserFormWithOption < Form
          model  :user
          option :predefined_email

          persistent :email

          def build_user
            User.new.tap { |user| user.email = predefined_email }
          end
        end

        let(:form) { UserFormWithOption.new(predefined_email: "test email") }

        it "defines a getter for the option" do
          expect(form.predefined_email).to eq "test email"
        end

        it "allows using an option in an overridden build_[attribute_name] "\
           "method" do
          expect(form.user.email).to eq "test email"
        end

        context "initializer is called without option" do
          let(:form) { UserFormWithOption.new }

          it "returns nil for the option" do
            expect(form.predefined_email).to be_nil
          end
        end
      end

#
#   UserCompanyForm.persistent
#

      describe ".persistent" do
        it "defines setters and a getters for the attributes" do
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

        it "defines #model_for_[attribute_name] that returns the model for "\
           "the attribute" do
          expect(form.model_for_email).to eq form.user
          expect(form.model_for_company_name).to eq form.company
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
#   UserCompanyForm.attributes
#

      describe ".attributes" do
        it "returns an array with all attribute names" do
          expect(UserCompanyForm.attributes)
            .to match_array [:email, :company_name]
        end
      end

#
#   UserCompanyForm#main_model
#

      describe "#main_model" do
        it "returns the main model of the form" do
          expect(form.main_model).to be form.user
        end
      end

#
#   UserCompanyForm#attributes=
#

      describe "#attributes=" do
        subject { form.attributes = params }

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

#
#   UserCompanyForm#persist
#

      describe "#persist" do
        subject { form.persist }

        it "calls save on the models" do
          expect(form.user).to receive(:save)
          expect(form.company).to receive(:save)
          subject
        end

        context "when all #save methods of the models return true" do
          it { should be_true }
        end

        context "when some #save methods of the models return false" do
          before { allow(form.company).to receive(:save).and_return(false) }
          it { should be_false }
        end

        context "when a model is set to be not persisted (by overridding the "\
                "#build_[model_name] method)"do
          class UserCompanyFormRejectMethod < Form
            model :user
            model :company
            
            def reject_company?
              true
            end
          end

          let(:form) { UserCompanyFormRejectMethod.new }

          it "does not call #save on the not to persist model" do
            expect(form.user).to receive(:save)
            expect(form.company).not_to receive(:save)
            subject
          end
        end

        context "when a model is set to be not persisted (by using the "\
                ":reject_if option)"do
          class UserCompanyFormRejectLambda < Form
            model :user
            model :company, reject_if: ->{ !persist_company }
            
            option :persist_company
          end

          let(:form) { UserCompanyFormRejectLambda.new(persist_company: false) }

          it "does not call #save on the not to persist model" do
            expect(form.user).to receive(:save)
            expect(form.company).not_to receive(:save)
            subject
          end
        end
      end
    end




    describe "Inherited form" do
      class ::Product
        attr_accessor :name
        def save; true; end
      end

      class ::Category
        attr_accessor :name
        def save; true; end
      end

      class ProductForm < Form
        model :product, main: true

        persistent :name

        validates :name, presence: true
      end

      class CategorizedProductForm < ProductForm
        model :category

        persistent :category_name, on: :category, as: :name

        validates :category_name, presence: true
      end

      let(:form)   { CategorizedProductForm.new }
      let(:params) { Hash[name: "TestProduct", category_name: "TestCategory"] }

      it_behaves_like :a_form_object

      it "has the model of the base class" do
        expect(form.product).to be_a Product
      end

      it "has both the models of the base and inherited class" do
        expect(form.category).to be_a Category
      end

      it "has the attributes of the base form" do
        form.name = "Test Product Name"
        expect(form.name).to eq "Test Product Name"
      end

      it "has the attributes of the inherited form" do
        form.category_name = "Test Category Name"
        expect(form.category_name).to eq "Test Category Name"
      end

      it "has the validations of the base form" do
        expect(form.valid?).to be_false
        expect(form.errors[:name].size).to eq 1
      end

      it "has the validations of the inherited form" do
        expect(form.valid?).to be_false
        expect(form.errors[:category_name].size).to eq 1
      end

#
#   CategorizedPostForm.attributes
#

      describe ".attributes" do
        it "returns an array with all attribute names" do
          expect(CategorizedProductForm.attributes)
            .to match_array [:name, :category_name]
        end
      end

#
#   CategorizedPostForm.models
#

      describe ".models" do
        it "returns an array with all model names" do
          expect(CategorizedProductForm.models)
            .to match_array [:product, :category]
        end
      end
    end
  end
end
