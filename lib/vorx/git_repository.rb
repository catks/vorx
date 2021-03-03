# frozen_string_literal: true

module Vorx
  class GitRepository < Dry::Struct
    attribute :git, Types::String
    attribute :version, Types::String.default('master')
    attribute :cloned, Types::Bool.optional.default(nil)

    include Dry::Equalizer(:git, :version)

    def self.by_reference(git_reference)
      GitReference.resolve(git_reference)
    end

    def folder_name
      @folder_name ||= "#{git.split('/').last.chomp('.git')}@#{version}"
    end

    def cloned?
      !!cloned
    end

    def to_s
      "git: #{git} version: #{version}"
    end

    def update(**params)
      self.class.new(to_h.merge(**params))
    end
  end
end
