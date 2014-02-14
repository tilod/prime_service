require "spec_helper"

module PrimeService
  describe MetaForm do
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

    class ::TaskForm < Form
      model      :task
      persistent :description
    end

    class ProjectTasksForm < MetaForm
      form :project_form
      form :task_form
    end

    let(:form) { ProjectTasksForm.new }

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
        expect(form.task_form).to be_a TaskForm
      end

      it "defines the setter to rebuild the form when called with a hash" do
        old_project      = Project.new.tap { |project| project.name = "old" }
        new_project      = Project.new.tap { |project| project.name = "new" }
        old_project_form = ProjectForm.new(project: old_project)
        form             = ProjectTasksForm.new(project_form: old_project_form)

        expect { form.project_form = { project: new_project } }
          .to change { form.project_form.project.name }.from("old").to("new")
      end

      describe "defines the getters to build the forms when they are not "\
               "assigned" do
        context "initializer was called without args for the form" do
          it "builds the form without any arguments" do
            expect(form).to receive(:build_project_form).with(no_args)
            form.project_form
          end
        end

        context "initializer was called with args for the form" do
          it "builds the form with the passed arguments" do
            project = Project.new.tap { |project| project.name = "custom init" }
            form    = ProjectTasksForm.new(project_form: { project: project })
            expect(form.project_form.project.name).to eq "custom init"
          end
        end
      end

      context "form type has to be inferred" do
        it "defines a build_[form_name] method inferring the class of the "\
           "form" do
          expect(form.build_project_form).to be_a ProjectForm
        end
      end

      context "model type explicitly given" do
        class ProjectFormOther < Form
        end

        class ProjectTasksFormExplicit < MetaForm
          form :project_form, type: ProjectFormOther
        end

        let(:form) { ProjectTasksFormExplicit.new }

        it "defines a build_[form_name] method using class passed as type" do
          expect(form.build_project_form).to be_a ProjectFormOther
        end
      end

      context "model build lambda explicitly given" do
        class ProjectTasksFormLambda < MetaForm
          form :project_form, build: ->(args) { :custom_build_lambda }
        end

        let(:form) { ProjectTasksFormLambda.new }

        it "defines a build_[form_name] method using the passed lambda" do
          expect(form.build_project_form).to eq :custom_build_lambda
        end
      end

      describe "generated build_[form_name] method can be overridden" do
        class ProjectTasksFormCustomBuilder < MetaForm
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
          expect(project_form.project.name).to eq "overridden"
        end
      end
    end
  end
end
