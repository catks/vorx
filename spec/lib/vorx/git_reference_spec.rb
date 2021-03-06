# frozen_string_literal: true

RSpec.describe Vorx::GitReference do
  def self.gr(**params)
    Vorx::GitRepository.new(**params)
  end

  describe '.resolve' do
    [
      ['catks/djin', gr(git: 'https://github.com/catks/djin.git')],
      ['github:catks/djin', gr(git: 'https://github.com/catks/djin.git')],
      ['gitlab:catks/djin', gr(git: 'https://gitlab.com/catks/djin.git')],
      ['bitbucket:catks/djin', gr(git: 'https://bitbucket.org/catks/djin.git')],
      ['http://gitserver/myrepo.git', gr(git: 'http://gitserver/myrepo.git')],
      ['catks/djin:master', gr(git: 'https://github.com/catks/djin.git', version: 'master')],
      ['catks/djin:0.1.1', gr(git: 'https://github.com/catks/djin.git', version: '0.1.1')],
      ['gitlab:catks/djin:1.0.2', gr(git: 'https://gitlab.com/catks/djin.git', version: '1.0.2')],
      ['bitbucket:catks/djin:3.10.4', gr(git: 'https://bitbucket.org/catks/djin.git', version: '3.10.4')],
      [['catks/djin', { prefix: 'vorx-' }], gr(git: 'https://github.com/catks/vorx-djin.git')],
      [['catks/djin:1.0.0', { prefix: 'vorx-' }], gr(git: 'https://github.com/catks/vorx-djin.git', version: '1.0.0')],
      [['github:catks/djin', { prefix: 'vorx-' }], gr(git: 'https://github.com/catks/vorx-djin.git')],
      [['bitbucket:catks/djin', { prefix: 'vorx-' }], gr(git: 'https://bitbucket.org/catks/vorx-djin.git')],
      [['gitlab:catks/djin', { prefix: 'vorx-' }], gr(git: 'https://gitlab.com/catks/vorx-djin.git')],
      [['gitlab:catks/djin:0.1.0', { prefix: 'vorx-' }],
       gr(git: 'https://gitlab.com/catks/vorx-djin.git', version: '0.1.0')],
      [['catks/docker-ruby', { prefix: 'vorx-' }], gr(git: 'https://github.com/catks/vorx-docker-ruby.git')],
      [['catks/docker_ruby', { prefix: 'vorx-' }], gr(git: 'https://github.com/catks/vorx-docker_ruby.git')],
      [['http://gitserver/myrepo.git', { prefix: 'vorx-' }], gr(git: 'http://gitserver/myrepo.git')]
    ].each do |input, expected_output|
      it "#{input} to return #{expected_output}" do
        expect(described_class.resolve(*input)).to eq(expected_output)
      end
    end
  end
end
