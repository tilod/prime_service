require "spec_helper"

module PrimeService
  describe NestedForm do
    class ::Project
      attr_accessor :name
      def save; true; end
    end

    class ::Task
      attr_accessor :description
      def save; true; end
    end

    class ::ProjectForm < Form
      model      :project
      persistent :name
    end

    class ::UserForm < Form
      model      :user
      persistent :email
    end

    class ::TaskForm < Form
      model      :task
      persistent :description
    end

    class ProjectTasksForm < NestedForm
      form :project_form
      form :user_form

      collection :task_forms
    end

    let(:form) { ProjectTasksForm.new }

    let(:params) {
      Hash[project_form_attributes: { name:  "project name" },
           user_form_attributes:    { email: "user@example.com" },
           task_form: {      "1" => { description: "task 1"  },
                             "2" => { description: "task 2" } }
      ]
    }

#
#   ProjectTaskForm.new
#

    describe "initializer" do
      it "assigns the passed models and options to instance variables" do
        project      = Project.new.tap { |project| project.name = "custom" }
        project_form = ProjectForm.new(project: project)
        form         = ProjectTasksForm.new(project_form: project_form)
        expect(form.project_form.project.name).to eq "custom"
      end
    end

#
#   ProjectTaskForm.form
#

    describe ".form" do
      it "defines getters for the forms" do
        expect(form.project_form).to be_a ProjectForm
        expect(form.user_form).to be_a UserForm
      end

      describe "defines the getters to build the forms when they are not "\
               "assigned" do
        it "builds the form" do
          expect(form).to receive(:build_project_form).with(no_args)
          form.project_form
        end
      end

      context "form type has to be inferred" do
        it "defines a build_[form_name] method inferring the class of the "\
           "form" do
          expect(form.build_project_form).to be_a ProjectForm
        end
      end

      context "form type explicitly given" do
        class ProjectFormOther < Form
        end

        class ProjectTasksFormExplicit < NestedForm
          form :project_form, type: ProjectFormOther
        end

        let(:form) { ProjectTasksFormExplicit.new }

        it "defines a build_[form_name] method using the class passed in as "\
           "type" do
          expect(form.build_project_form).to be_a ProjectFormOther
        end
      end

      context "model build lambda explicitly given" do
        class ProjectTasksFormLambda < NestedForm
          form :project_form, build: ->{ :custom_build_lambda }
        end

        let(:form) { ProjectTasksFormLambda.new }

        it "defines a build_[form_name] method using the passed lambda" do
          expect(form.build_project_form).to eq :custom_build_lambda
        end
      end

      describe "generated build_[form_name] method can be overridden" do
        class ProjectTasksFormCustomBuilder < NestedForm
          form :project_form

          def build_project_form
            project = Project.new.tap { |project| project.name = "overridden" }
            ProjectForm.new(project: project)
          end
        end

        let(:form) { ProjectTasksFormCustomBuilder.new }

        it "gets called instead of the generated method" do
          project_form = form.build_project_form

          expect(project_form).to be_a ProjectForm
          expect(project_form.name).to eq "overridden"
        end
      end
    end

#
#   ProjectTaskForm.collection
#

    describe ".collection" do
      it "defines getters for the collections" do
        expect(form.task_forms).to be_a Hash
      end

      it "adds the built form to the collection" do
        expect { form.build_task_form }.to change { form.task_forms.size }.by(1)
      end

      context "no key given" do
        it "generates a random key for the built form" do
          3.times { form.build_task_form }
          expect(form.task_forms.size).to eq 3
        end
      end

      context "key given" do
        it "assigns the given key in the collection" do
          3.times { |i| form.build_task_form(i.to_s) }
          expect(form.task_forms.keys).to match_array %w(0 1 2)
        end
      end

      describe "defines a build_[collection_name_in_singular] method" do
        context "form type has to be inferred" do
          it "infers the class of the form" do
            expect(form.build_task_form).to be_a TaskForm
          end
        end

        context "collection type explicitly given" do
          class TaskFormOther < Form
          end

          class ProjectTasksFormExplicit2 < NestedForm
            collection :task_forms, type: TaskFormOther
          end

          let(:form) { ProjectTasksFormExplicit2.new }

          it "uses the class passed in as type" do
            expect(form.build_task_form).to be_a TaskFormOther
          end
        end

        context "model build lambda explicitly given" do
          class ProjectTasksFormLambda2 < NestedForm
            collection :task_forms, build: ->{ :custom_build_lambda }
          end

          let(:form) { ProjectTasksFormLambda2.new }

          it "uses the passed lambda" do
            expect(form.build_task_form).to eq :custom_build_lambda
          end
        end
      end

      describe "generated build_[collection_name_in_singular] method can be "\
               "overridden" do
        class ProjectTasksFormCustomBuilder2 < NestedForm
          collection :task_forms

          def build_task_form
            task      = Task.new.tap { |task| task.description = "overridden" }
            task_form = TaskForm.new(task: task)
            task_forms[:new_keys] = task_form

            task_form
          end
        end

        let(:form) { ProjectTasksFormCustomBuilder2.new }

        it "gets called instead of the generated method" do
          task_form = form.build_task_form

          expect(task_form).to be_a TaskForm
          expect(task_form.description).to eq "overridden"
          expect(form.task_forms.size).to eq 1
        end
      end
    end

#
#   ProjectTasksForm.forms
#

    describe ".forms" do
      subject { ProjectTasksForm.forms }

      it "returns all form names embedded in the nested form" do
        should match_array [:project_form, :user_form]
      end
    end

#
#   ProjectTasksForm.collections
#

    describe ".collections" do
      subject { ProjectTasksForm.collections }

      it "returns all collection names embedded in the nested form" do
        should match_array [:task_forms]
      end
    end

#
#   ProjectTasksForm#submit
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

      context "all nested forms are valid" do
        before do
          allow(form.project_form).to receive(:valid?).and_return(true)
          allow(form.user_form).to receive(:valid?).and_return(true)
        end

        it "calls #process" do
          expect(form).to receive(:process).and_call_original
          subject
        end

        context "#process returns a truthy value" do
          before { allow(form).to receive(:process).and_return(true) }
          it { should be_true }
        end

        context "#process returns false" do
          before { allow(form).to receive(:process).and_return(false) }
          it { should be_false }
        end
      end

      context "at least one nested form is not valid" do
        before do
          allow(form.project_form).to receive(:valid?).and_return(true)
          allow(form.user_form).to receive(:valid?).and_return(false)
        end

        it "does not call #process" do
          expect(form).not_to receive(:process)
          subject
        end

        it { should be_false }
      end

      context "at least one form of a collection is not valid" do
        before do
          task_form   = form.build_task_form
          task_form_2 = form.build_task_form
          allow(form.project_form).to receive(:valid?).and_return(true)
          allow(form.user_form).to receive(:valid?).and_return(true)
          allow(task_form).to receive(:valid?).and_return(true)
          allow(task_form_2).to receive(:valid?).and_return(false)
        end

        it "does not call #process" do
          expect(form).not_to receive(:process)
          subject
        end

        it { should be_false }
      end
    end

#
#   ProjectTasksForm#attributes=
#

    describe "#attributes=" do
      subject { form.attributes = params }

      it "assigns the attributes to the embedded forms" do
        subject
        expect(form.project_form.name).to eq "project name"
        expect(form.user_form.email).to eq "user@example.com"
      end

      it "also works with only partial params" do
        user_form       = form.build_user_form
        user_form.email = "leave_untouched@example.com"
        params.delete(:user_form_attributes)

        subject
        expect(form.project_form.name).to eq "project name"
        expect(form.user_form.email).to eq "leave_untouched@example.com"
      end

      it "assigns the attributes to the embedded collections" do
        subject
        expect(form.task_forms["1"].description).to eq "task 1"
        expect(form.task_forms["2"].description).to eq "task 2"
      end
    end

#
#   ProjectTasksForm#process
#

    describe "#process" do
      subject { form.process }

      it "calls process on all it's forms" do
        expect(form.project_form).to receive(:process).with(no_args)
        expect(form.user_form).to receive(:process).with(no_args)
        subject
      end

      context "all forms return true on process" do
        it { should be_true }
      end

      context "at least on form returns false on process" do
        before { allow(form.user_form).to receive(:process).and_return(false) }
        it { should be_false }
      end
    end
  end
end
