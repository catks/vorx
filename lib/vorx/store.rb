# frozen_string_literal: true

require 'yaml/store'

module Vorx
  class Store
    def initialize(base_path = '~/.vorx/store', stderr: $stderr, store_file: 'vorx_store.yml')
      @base_path = Pathname.new(base_path.to_s)
      @stderr = stderr

      @base_path.mkpath

      @store = YAML::Store.new(@base_path.join(store_file).to_s)
      @store.transaction { @store[:repositories] ||= Set.new }
    end

    def fetch(git_reference)
      git_repository = find(git_reference) || add(git_reference)

      git_fetch_references(git_repository)

      update_repository(git_repository, cloned: true)
    end

    def fetch_all
      all.each do |repo|
        fetch(repo)
      end
    end

    def add(git_reference)
      git_repository = resolve_git_reference(git_reference)

      @store.transaction { @store[:repositories] << git_repository }

      git_repository
    end

    def find(git_reference)
      git_repository = resolve_git_reference(git_reference)

      git_repositories.detect do |gr|
        gr == git_repository
      end
    end

    def delete(git_reference)
      git_repository = resolve_git_reference(git_reference)

      `rm -rf #{git_folder(git_repository)}`

      @store.transaction { @store[:repositories].delete(git_repository) }
    end

    def delete_all
      all.each do |repo|
        delete(repo)
      end
    end

    def all
      @store.transaction { @store[:repositories] }
    end

    def reload
      @store.transaction do
        repos = @store[:repositories]

        repos.select { |r| git_folder(r).exist? }.each do |repo|
          repos.delete(repo)
          repos << repo.update(cloned: true)
        end
      end
    end

    private

    def resolve_git_reference(git_reference)
      return git_reference if git_reference.is_a?(GitRepository)

      GitReference.resolve(git_reference)
    end

    def update_repository(git_repository, **params)
      @store.transaction do
        repos = @store[:repositories]

        repos.delete(git_repository)
        repos << git_repository.update(**params)
      end
    end

    attr_accessor :stderr, :base_path

    def git_repositories
      @store.transaction { @store[:repositories] }
    end

    def git_fetch_references(git_repository)
      return git_clone(git_repository) unless git_repository.cloned?

      git_fetch(git_repository)
      git_pull(git_repository)
    end

    def git_clone(git_repository)
      Git.clone(git_repository.git.to_s, git_folder(git_repository), branch: git_repository.version)
    end

    def git_fetch(git_repository)
      git_repo = Git.open(git_folder(git_repository))
      git_repo.fetch
    end

    def git_pull(git_repository)
      git_repo = Git.open(git_folder(git_repository))

      git_repo.pull
    end

    def git_folder(git_repository)
      @base_path.join(git_repository.folder_name)
    end
  end
end
