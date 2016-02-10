require 'test_helper'

module PrimeService
  class RepositoryTest < Minitest::Spec
    class Project
      def tasks
        [:task_1, :task_2]
      end
    end

    class TaskRepository < Repository
      scope_with :project do
        project.tasks
      end

      delegate_to_scope :include?
    end

    class ProjectRepository < Repository
      scope_with do
        :no_model
      end
    end


    let(:project_model)   { Project.new }
    let(:task_repository) { TaskRepository.for(project_model) }


    describe '.for' do
      it 'returns a new instance of the repository' do
        task_repository.must_be_kind_of TaskRepository
      end
    end


    describe '.scope_with' do
      it 'defines attr_reader for all arguments' do
        task_repository.project.must_equal project_model
      end

      it 'defines attr_writer for all arguments' do
        task_repository.project = :new_project
        task_repository.project.must_equal :new_project
      end

      it 'defines #scope to call the passed block' do
        task_repository.scope.must_equal [:task_1, :task_2]
      end
    end


    describe '.delegate_to_scope' do
      it 'delegates the passed methods to the scope' do
        task_repository.include?(:task_1).must_equal true
      end
    end


    describe 'when Repository is defined without arguments in .scope_with' do
      it '#scope still works' do
        ProjectRepository.new.scope.must_equal :no_model
      end
    end
  end
end
