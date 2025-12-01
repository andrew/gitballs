# frozen_string_literal: true

module Gitballs
  class Registry
    EXTRACTORS = {
      "gem" => :extract_gem,
      "npm" => :extract_tgz,
      "pypi" => :extract_tgz,
      "cargo" => :extract_tgz,
      "nuget" => :extract_nupkg,
      "go" => :extract_zip,
      "hex" => :extract_tgz,
      "packagist" => :extract_zip
    }.freeze

    def initialize(purl_type)
      @purl_type = purl_type
      @extractor = EXTRACTORS[purl_type] || raise(Error, "Unsupported type: #{purl_type}")
    end

    def extract(tarball_path, destination)
      send(@extractor, tarball_path, destination)
    end

    def extract_gem(tarball_path, destination)
      system("tar", "-C", destination, "-xf", tarball_path, exception: true)
      data_tar = File.join(destination, "data.tar.gz")
      if File.exist?(data_tar)
        system("tar", "-C", destination, "-xzf", data_tar, exception: true)
        FileUtils.rm_f([data_tar, File.join(destination, "metadata.gz"), File.join(destination, "checksums.yaml.gz")])
      end
    end

    def extract_tgz(tarball_path, destination)
      system("tar", "-C", destination, "-xzf", tarball_path, exception: true)
      move_nested_package_dir(destination)
    end

    def extract_zip(tarball_path, destination)
      system("unzip", "-q", "-o", tarball_path, "-d", destination, exception: true)
      move_nested_package_dir(destination)
    end

    def extract_nupkg(tarball_path, destination)
      system("unzip", "-q", "-o", tarball_path, "-d", destination, exception: true)
      cleanup_nupkg_metadata(destination)
    end

    def move_nested_package_dir(destination)
      entries = Dir.children(destination).reject { |f| f.start_with?(".") }
      return unless entries.size == 1

      nested = File.join(destination, entries.first)
      return unless File.directory?(nested)

      Dir.children(nested).each do |child|
        FileUtils.mv(File.join(nested, child), destination)
      end
      FileUtils.rmdir(nested)
    end

    def cleanup_nupkg_metadata(destination)
      FileUtils.rm_rf(Dir.glob(File.join(destination, "_rels")))
      FileUtils.rm_rf(Dir.glob(File.join(destination, "[Content_Types].xml")))
      FileUtils.rm_rf(Dir.glob(File.join(destination, "*.nuspec")))
    end
  end
end
