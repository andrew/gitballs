# frozen_string_literal: true

require "test_helper"

class TestRegistry < Minitest::Test
  def test_supported_types
    %w[gem npm pypi cargo].each do |type|
      registry = Gitballs::Registry.new(type)
      assert_kind_of Gitballs::Registry, registry
    end
  end

  def test_unsupported_type_raises
    assert_raises(Gitballs::Error) { Gitballs::Registry.new("unknown") }
  end

  def test_move_nested_package_dir
    Dir.mktmpdir do |dir|
      nested = File.join(dir, "package")
      FileUtils.mkdir_p(nested)
      File.write(File.join(nested, "index.js"), "content")

      registry = Gitballs::Registry.new("npm")
      registry.move_nested_package_dir(dir)

      assert File.exist?(File.join(dir, "index.js"))
      refute File.exist?(nested)
    end
  end

  def test_move_nested_package_dir_multiple_entries
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "dir1"))
      FileUtils.mkdir_p(File.join(dir, "dir2"))

      registry = Gitballs::Registry.new("npm")
      registry.move_nested_package_dir(dir)

      assert File.exist?(File.join(dir, "dir1"))
      assert File.exist?(File.join(dir, "dir2"))
    end
  end
end
