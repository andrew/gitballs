# frozen_string_literal: true

require "typhoeus"
require "json"
require "purl"

module Gitballs
  class Client
    BASE_URL = "https://packages.ecosyste.ms/api/v1"

    REGISTRY_MAP = {
      "gem" => "rubygems.org",
      "npm" => "npmjs.org",
      "pypi" => "pypi.org",
      "cargo" => "crates.io",
      "nuget" => "nuget.org",
      "maven" => "repo1.maven.org",
      "go" => "proxy.golang.org",
      "hex" => "hex.pm",
      "packagist" => "packagist.org"
    }.freeze

    def initialize
      @hydra = Typhoeus::Hydra.new
    end

    def fetch_versions(purl_string)
      purl = Purl.parse(purl_string)
      registry = registry_for(purl.type)
      package_name = package_name_for(purl)

      url = "#{BASE_URL}/registries/#{registry}/packages/#{package_name}/versions"
      response = Typhoeus.get(url)

      raise Error, "Failed to fetch versions: #{response.code}" unless response.success?

      JSON.parse(response.body)
    end

    def download_tarball(url, destination)
      response = Typhoeus.get(url, followlocation: true)
      raise Error, "Failed to download #{url}: #{response.code}" unless response.success?

      File.binwrite(destination, response.body)
    end

    def registry_for(purl_type)
      REGISTRY_MAP[purl_type] || raise(Error, "Unsupported purl type: #{purl_type}")
    end

    def package_name_for(purl)
      if purl.namespace
        "#{purl.namespace}%2F#{purl.name}"
      else
        purl.name
      end
    end
  end
end
