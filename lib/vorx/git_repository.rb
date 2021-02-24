module Vorx
  class GitRepository < Dry::Struct

    attribute :git, Types::String
    attribute :version, Types::String.default('master'.freeze)
    attribute :cloned, Types::Bool.optional.default(nil)

    include Dry::Equalizer(:git, :version)

    def self.by_reference(git_reference)
      GitReference.resolve(git_reference)
    end

    def cloned?
      cloned
    end

    def to_s
      "git: #{git} version: #{version}"
    end
  end
end
