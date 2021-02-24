# frozen_string_literal: true

module Vorx
  class Storage
    def initialize(base_path = Pathname.new('~/.vorx/storage'), stderr: $stderr)
      @git_repositories = Set.new
      @base_path = base_path
      @stderr = stderr
    end

    def add(git_reference)
      git_repository = GitReference.resolve(git_reference)

      @git_repositories << git_repository
      git_repository
    end

    def fetch(git_reference)
      git_repository = find(git_reference) || add(git_reference)

      git_fetch_references(git_repository)
    end

    def find(git_reference)
      git_repository = GitReference.resolve(git_reference)

      @git_repositories.detect do |gr|
        gr == git_repository
      end
    end

    def delete(git_repository)
      stderr.puts "Removing #{rc.folder_name} repository..."
      `rm -rf #{git_folder(git_repository)}`
    end

    def delete_all
      remove_remote_folder
    end

    private

    attr_accessor :stderr, :base_path

    def remove_remote_folder
      stderr.puts "Removing #{base_path}..."
      `rm -rf #{base_path}`
    end

    def git_fetch_references(git_repository)
      return git_clone(git_repository) unless git_repository.cloned?

      git_fetch(git_repository)
    end

    def git_clone(git_repository)
      stderr.puts "Missing #{@base_path} repository, cloning in #{git_folder(git_repository)}"
      Git.clone(git_repository.git.to_s, git_folder(git_repository), branch: git_repository.version)
    end

    def git_fetch(git_repository)
      stderr.puts "#{remote_config.git} repository already cloned, fetching..."
      git_repo = Git.open(git_folder(git_repository))
      git_repo.fetch
    end

    def git_folder(git_repository)
      @base_path.join(git_repository)
    end
  end
end
