# frozen_string_literal: true

require "test_helper"

class TestClient < Minitest::Test
  def setup
    @client = Gitballs::Client.new
  end

  def test_registry_for_gem
    assert_equal "rubygems.org", @client.registry_for("gem")
  end

  def test_registry_for_npm
    assert_equal "npmjs.org", @client.registry_for("npm")
  end

  def test_registry_for_unknown_raises
    assert_raises(Gitballs::Error) { @client.registry_for("unknown") }
  end

  def test_fetch_versions
    stub_request(:get, "https://packages.ecosyste.ms/api/v1/registries/rubygems.org/packages/semantic/versions")
      .to_return(
        status: 200,
        body: [{ "number" => "1.0.0", "download_url" => "https://rubygems.org/downloads/semantic-1.0.0.gem" }].to_json
      )

    versions = @client.fetch_versions("pkg:gem/semantic")

    assert_equal 1, versions.size
    assert_equal "1.0.0", versions.first["number"]
  end

  def test_fetch_versions_with_namespace
    stub_request(:get, "https://packages.ecosyste.ms/api/v1/registries/npmjs.org/packages/%40babel%2Fcore/versions")
      .to_return(
        status: 200,
        body: [{ "number" => "7.0.0", "download_url" => "https://registry.npmjs.org/@babel/core/-/core-7.0.0.tgz" }].to_json
      )

    versions = @client.fetch_versions("pkg:npm/%40babel/core")

    assert_equal 1, versions.size
    assert_equal "7.0.0", versions.first["number"]
  end

  def test_fetch_versions_failure
    stub_request(:get, "https://packages.ecosyste.ms/api/v1/registries/rubygems.org/packages/nonexistent/versions")
      .to_return(status: 404)

    assert_raises(Gitballs::Error) { @client.fetch_versions("pkg:gem/nonexistent") }
  end

  def test_download_tarball
    stub_request(:get, "https://rubygems.org/downloads/test-1.0.0.gem")
      .to_return(status: 200, body: "fake gem content")

    Dir.mktmpdir do |dir|
      destination = File.join(dir, "test.gem")
      @client.download_tarball("https://rubygems.org/downloads/test-1.0.0.gem", destination)

      assert File.exist?(destination)
      assert_equal "fake gem content", File.read(destination)
    end
  end
end
