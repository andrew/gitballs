# frozen_string_literal: true

require "test_helper"

class TestCLI < Minitest::Test
  def test_version_command
    cli = Gitballs::CLI.new(["version"])
    assert_output("gitballs #{Gitballs::VERSION}\n") { cli.run }
  end

  def test_help_command
    cli = Gitballs::CLI.new(["help"])
    assert_output(/Usage: gitballs/) { cli.run }
  end

  def test_no_command_shows_help
    cli = Gitballs::CLI.new([])
    assert_output(/Usage: gitballs/) { cli.run }
  end

  def test_init_without_purl_exits
    cli = Gitballs::CLI.new(["init"])
    assert_raises(SystemExit) do
      capture_io { cli.run }
    end
  end

  def test_stats_without_path_exits
    cli = Gitballs::CLI.new(["stats"])
    assert_raises(SystemExit) do
      capture_io { cli.run }
    end
  end

  def test_stats_with_nonexistent_path_exits
    cli = Gitballs::CLI.new(["stats", "/nonexistent/path"])
    assert_raises(SystemExit) do
      capture_io { cli.run }
    end
  end

  def test_unknown_command_exits
    cli = Gitballs::CLI.new(["unknown"])
    assert_raises(SystemExit) do
      capture_io { cli.run }
    end
  end

  def test_quiet_option_parsed
    cli = Gitballs::CLI.new(["--quiet", "help"])
    assert_output(/Usage:/) { cli.run }
  end

  def test_output_option_parsed
    cli = Gitballs::CLI.new(["--output", "/tmp/test", "help"])
    assert_output(/Usage:/) { cli.run }
  end
end
