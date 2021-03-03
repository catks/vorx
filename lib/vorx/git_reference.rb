# frozen_string_literal: true

module Vorx
  class GitReference
    GIT_URI_REGEXP = Regexp.new('(\w+://)(.+@)*([\w\d\.]+)(:[\d]+){0,1}/*(.*)')
    PROVIDERS = {
      'github' => 'https://github.com',
      'gitlab' => 'https://gitlab.com',
      'bitbucket' => 'https://bitbucket.org',
      nil => 'https://github.com'
    }.freeze

    class << self
      def resolve(git_reference)
        git_uri = git_reference if GIT_URI_REGEXP.match?(git_reference)

        provider, reference, version = extract_params(git_reference) unless git_uri

        # TODO: Improve
        raise 'Invalid git uri or git reference' if !reference && !git_uri

        git_uri ||= "#{PROVIDERS[provider]}/#{reference}.git"
        version ||= 'master'

        GitRepository.new(
          git: git_uri,
          version: version
        )
      end

      private

      def extract_params(git_reference)
        provider, reference, version = %r{([[:alnum:]]+:)?([[[:alnum:]]|/]+)(:\S+)?}.match(git_reference).captures

        provider&.tr!(':', '')
        version&.tr!(':', '')

        [provider, reference, version]
      end
    end
  end
end
