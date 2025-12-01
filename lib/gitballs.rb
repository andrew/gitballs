# frozen_string_literal: true

require_relative "gitballs/version"
require_relative "gitballs/client"
require_relative "gitballs/registry"
require_relative "gitballs/stats"
require_relative "gitballs/compressor"
require_relative "gitballs/cli"

module Gitballs
  class Error < StandardError; end
end
