# frozen_string_literal: true

module Gitballs
  class Stats
    attr_reader :repo_dir, :tarball_size

    def initialize(repo_dir, tarball_size = nil)
      @repo_dir = repo_dir
      @tarball_size = tarball_size
    end

    def release_count
      return 0 unless File.directory?(File.join(@repo_dir, ".git"))

      `git -C #{@repo_dir} rev-list --count HEAD 2>/dev/null`.strip.to_i
    end

    def repo_size
      return 0 unless File.directory?(@repo_dir)

      `du -sk #{@repo_dir}`.strip.split.first.to_i * 1024
    end

    def compression_ratio
      return nil unless @tarball_size && @tarball_size > 0

      ((@tarball_size - repo_size).to_f / @tarball_size * 100).round(1)
    end

    def to_h
      {
        releases: release_count,
        repo_size: repo_size,
        tarball_size: tarball_size,
        compression_ratio: compression_ratio
      }
    end

    def to_s
      lines = []
      lines << "releases: #{release_count}"
      lines << "repo size: #{format_size(repo_size)}"
      if @tarball_size && @tarball_size > 0
        lines << "tarball size: #{format_size(@tarball_size)}"
        lines << "savings: #{compression_ratio}%"
      end
      lines.join("\n")
    end

    def format_size(bytes)
      return "0B" if bytes.zero?

      units = %w[B KB MB GB]
      exp = (Math.log(bytes) / Math.log(1024)).to_i
      exp = units.size - 1 if exp >= units.size
      "%.1f%s" % [bytes.to_f / (1024**exp), units[exp]]
    end
  end
end
