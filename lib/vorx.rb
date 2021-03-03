# frozen_string_literal: true

require 'dry-struct'
require 'git'

require 'vorx/version'
require 'vorx/types'
require 'vorx/git_repository'
require 'vorx/git_reference'
require 'vorx/store'

module Vorx
  class Error < StandardError; end

  def self.root_path
    Pathname.new File.expand_path("#{__dir__}/..")
  end
end
