# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "gitballs"
require "webmock/minitest"
require "minitest/autorun"
require "fileutils"
require "tmpdir"
