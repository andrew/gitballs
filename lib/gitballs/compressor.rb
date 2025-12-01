# frozen_string_literal: true

require "fileutils"
require "purl"
require "vers"

module Gitballs
  class Compressor
    attr_reader :purl, :output_dir, :quiet

    def initialize(purl_string, output: nil, quiet: false)
      @purl = Purl.parse(purl_string)
      @output_dir = output || File.join(".", "gitballs", @purl.name)
      @quiet = quiet
      @client = Client.new
      @registry = Registry.new(@purl.type)
      @tarball_dir = File.join(@output_dir, ".tarballs")
    end

    def run
      setup_directories
      versions = fetch_and_sort_versions
      download_tarballs(versions)
      @tarball_size = dir_size(@tarball_dir)
      init_git_repo
      commit_versions(versions)
      optimize_repo
      cleanup_tarballs
      stats
    end

    def stats
      Stats.new(@output_dir, @tarball_size)
    end

    def dir_size(path)
      return 0 unless File.directory?(path)

      `du -sk #{path}`.strip.split.first.to_i * 1024
    end

    def setup_directories
      FileUtils.rm_rf(@output_dir)
      FileUtils.mkdir_p(@output_dir)
      FileUtils.mkdir_p(@tarball_dir)
    end

    def fetch_and_sort_versions
      log "Fetching versions..."
      versions = @client.fetch_versions(@purl.to_s)

      versions.sort_by do |v|
        Vers::Version.new(v["number"])
      rescue ArgumentError
        Vers::Version.new("0.0.0")
      end
    end

    def download_tarballs(versions)
      log "Downloading #{versions.size} versions..."
      versions.each_with_index do |version, index|
        number = version["number"]
        url = version["download_url"]
        next unless url

        log "  [#{index + 1}/#{versions.size}] #{number}"
        extension = tarball_extension(url)
        destination = File.join(@tarball_dir, "#{number}#{extension}")
        @client.download_tarball(url, destination)
      rescue Error => e
        log "    skipping: #{e.message}"
      end
    end

    def init_git_repo
      log "Initializing git repository..."
      system("git", "init", @output_dir, out: File::NULL, err: File::NULL, exception: true)
    end

    def commit_versions(versions)
      log "Committing versions..."
      versions.each_with_index do |version, index|
        number = version["number"]
        tarball = find_tarball(number)
        next unless tarball

        log "  [#{index + 1}/#{versions.size}] #{number}"
        clear_working_dir
        @registry.extract(tarball, @output_dir)
        git_add_and_commit(number)
      end
    end

    def optimize_repo
      log "Optimizing repository..."
      Dir.chdir(@output_dir) do
        system("git", "gc", "--aggressive", "--prune=now", out: File::NULL, err: File::NULL, exception: true)
        system("git", "rm", "-rf", ".", out: File::NULL, err: File::NULL, exception: true)
      end
    end

    def cleanup_tarballs
      FileUtils.rm_rf(@tarball_dir)
    end

    def clear_working_dir
      Dir.chdir(@output_dir) do
        Dir.children(".").reject { |f| f == ".git" || f == ".tarballs" }.each do |entry|
          FileUtils.rm_rf(entry)
        end
      end
    end

    def git_add_and_commit(version_number)
      Dir.chdir(@output_dir) do
        system("git", "add", "-A", out: File::NULL, err: File::NULL, exception: true)
        system("git", "commit", "-m", version_number, "--allow-empty", out: File::NULL, err: File::NULL, exception: true)
      end
    end

    def find_tarball(version_number)
      Dir.glob(File.join(@tarball_dir, "#{version_number}.*")).first
    end

    def tarball_extension(url)
      case url
      when /\.gem$/ then ".gem"
      when /\.tgz$/ then ".tgz"
      when /\.tar\.gz$/ then ".tar.gz"
      when /\.zip$/ then ".zip"
      when /\.nupkg$/ then ".nupkg"
      else ".tar.gz"
      end
    end

    def log(message)
      puts message unless @quiet
    end
  end
end
