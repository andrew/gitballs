# frozen_string_literal: true

require "test_helper"

class TestCompressor < Minitest::Test
  def test_initialization
    compressor = Gitballs::Compressor.new("pkg:gem/rails")

    assert_equal "rails", compressor.purl.name
    assert_equal "gem", compressor.purl.type
    assert_match %r{gitballs/rails$}, compressor.output_dir
  end

  def test_initialization_with_output
    compressor = Gitballs::Compressor.new("pkg:gem/rails", output: "/tmp/custom")

    assert_equal "/tmp/custom", compressor.output_dir
  end

  def test_initialization_with_quiet
    compressor = Gitballs::Compressor.new("pkg:gem/rails", quiet: true)

    assert compressor.quiet
  end

  def test_tarball_extension_gem
    compressor = Gitballs::Compressor.new("pkg:gem/rails")

    assert_equal ".gem", compressor.tarball_extension("https://rubygems.org/downloads/rails-7.0.0.gem")
  end

  def test_tarball_extension_tgz
    compressor = Gitballs::Compressor.new("pkg:npm/lodash")

    assert_equal ".tgz", compressor.tarball_extension("https://registry.npmjs.org/lodash/-/lodash-4.0.0.tgz")
  end

  def test_tarball_extension_tar_gz
    compressor = Gitballs::Compressor.new("pkg:pypi/requests")

    assert_equal ".tar.gz", compressor.tarball_extension("https://example.com/requests-2.0.0.tar.gz")
  end

  def test_tarball_extension_default
    compressor = Gitballs::Compressor.new("pkg:gem/rails")

    assert_equal ".tar.gz", compressor.tarball_extension("https://example.com/unknown")
  end

  def test_fetch_and_sort_versions
    stub_request(:get, "https://packages.ecosyste.ms/api/v1/registries/rubygems.org/packages/test/versions")
      .to_return(
        status: 200,
        body: [
          { "number" => "2.0.0", "download_url" => "https://example.com/2.0.0.gem" },
          { "number" => "1.0.0", "download_url" => "https://example.com/1.0.0.gem" },
          { "number" => "1.10.0", "download_url" => "https://example.com/1.10.0.gem" },
          { "number" => "1.2.0", "download_url" => "https://example.com/1.2.0.gem" }
        ].to_json
      )

    compressor = Gitballs::Compressor.new("pkg:gem/test", quiet: true)
    versions = compressor.fetch_and_sort_versions

    assert_equal %w[1.0.0 1.2.0 1.10.0 2.0.0], versions.map { |v| v["number"] }
  end

  def test_fetch_and_sort_versions_with_invalid_version
    stub_request(:get, "https://packages.ecosyste.ms/api/v1/registries/rubygems.org/packages/test/versions")
      .to_return(
        status: 200,
        body: [
          { "number" => "1.0.0", "download_url" => "https://example.com/1.0.0.gem" },
          { "number" => "invalid", "download_url" => "https://example.com/invalid.gem" }
        ].to_json
      )

    compressor = Gitballs::Compressor.new("pkg:gem/test", quiet: true)
    versions = compressor.fetch_and_sort_versions

    assert_equal 2, versions.size
  end
end
