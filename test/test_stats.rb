# frozen_string_literal: true

require "test_helper"

class TestStats < Minitest::Test
  def init_repo(dir)
    system("git", "init", dir, out: File::NULL, err: File::NULL)
    system("git", "-C", dir, "config", "user.email", "test@example.com", out: File::NULL, err: File::NULL)
    system("git", "-C", dir, "config", "user.name", "Test", out: File::NULL, err: File::NULL)
  end

  def git_commit(dir, message)
    system("git", "-C", dir, "add", ".", out: File::NULL, err: File::NULL)
    system("git", "-C", dir, "commit", "-m", message, out: File::NULL, err: File::NULL)
  end

  def test_release_count_with_git_repo
    Dir.mktmpdir do |dir|
      init_repo(dir)
      File.write(File.join(dir, "file.txt"), "content")
      git_commit(dir, "1.0.0")
      File.write(File.join(dir, "file.txt"), "updated")
      git_commit(dir, "1.0.1")

      stats = Gitballs::Stats.new(dir)

      assert_equal 2, stats.release_count
    end
  end

  def test_release_count_without_git_repo
    Dir.mktmpdir do |dir|
      stats = Gitballs::Stats.new(dir)

      assert_equal 0, stats.release_count
    end
  end

  def test_repo_size
    Dir.mktmpdir do |dir|
      File.write(File.join(dir, "file.txt"), "x" * 1000)

      stats = Gitballs::Stats.new(dir)

      assert stats.repo_size > 0
    end
  end

  def test_format_size_bytes
    stats = Gitballs::Stats.new(".")
    assert_equal "500.0B", stats.format_size(500)
  end

  def test_format_size_kilobytes
    stats = Gitballs::Stats.new(".")
    assert_equal "1.5KB", stats.format_size(1536)
  end

  def test_format_size_megabytes
    stats = Gitballs::Stats.new(".")
    assert_equal "10.0MB", stats.format_size(10 * 1024 * 1024)
  end

  def test_format_size_zero
    stats = Gitballs::Stats.new(".")
    assert_equal "0B", stats.format_size(0)
  end

  def test_to_s_without_tarball
    Dir.mktmpdir do |dir|
      init_repo(dir)
      File.write(File.join(dir, "file.txt"), "content")
      git_commit(dir, "1.0.0")

      stats = Gitballs::Stats.new(dir)
      output = stats.to_s

      assert_match(/releases: 1/, output)
      assert_match(/repo size:/, output)
      refute_match(/tarball size:/, output)
    end
  end

  def test_compression_ratio
    stats = Gitballs::Stats.new(".", 1000)
    def stats.repo_size = 100

    assert_equal 90.0, stats.compression_ratio
  end

  def test_to_s_with_tarball_size
    Dir.mktmpdir do |dir|
      init_repo(dir)
      File.write(File.join(dir, "file.txt"), "content")
      git_commit(dir, "1.0.0")

      stats = Gitballs::Stats.new(dir, 1024 * 1024)
      output = stats.to_s

      assert_match(/releases: 1/, output)
      assert_match(/repo size:/, output)
      assert_match(/tarball size: 1.0MB/, output)
      assert_match(/savings:/, output)
    end
  end
end
