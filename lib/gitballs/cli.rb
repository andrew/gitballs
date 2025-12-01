# frozen_string_literal: true

require "optparse"

module Gitballs
  class CLI
    def initialize(argv)
      @argv = argv
      @options = {}
    end

    def run
      parser = build_parser
      args = parser.parse(@argv)
      command = args.shift

      case command
      when "init"
        run_init(args)
      when "stats"
        run_stats(args)
      when "version", "-v", "--version"
        puts "gitballs #{VERSION}"
      when "help", nil
        puts parser
      else
        warn "Unknown command: #{command}"
        puts parser
        exit 1
      end
    end

    def build_parser
      OptionParser.new do |opts|
        opts.banner = "Usage: gitballs <command> [options]"
        opts.separator ""
        opts.separator "Commands:"
        opts.separator "  init <purl>     Download and compress package versions into git repo"
        opts.separator "  stats <path>    Show stats for an existing gitballs repo"
        opts.separator "  version         Show version"
        opts.separator ""
        opts.separator "Options:"

        opts.on("-o", "--output DIR", "Output directory (default: ./gitballs/<package>)") do |dir|
          @options[:output] = dir
        end

        opts.on("-q", "--quiet", "Suppress progress output") do
          @options[:quiet] = true
        end

        opts.on("-h", "--help", "Show this help") do
          puts opts
          exit
        end
      end
    end

    def run_init(args)
      purl = args.first
      unless purl
        warn "Error: purl argument required"
        warn "Usage: gitballs init <purl>"
        warn "Example: gitballs init pkg:gem/rails"
        exit 1
      end

      compressor = Compressor.new(purl, output: @options[:output], quiet: @options[:quiet])
      compressor.run
      puts compressor.stats unless @options[:quiet]
      puts "output: #{compressor.output_dir}"
    rescue Error => e
      warn "Error: #{e.message}"
      exit 1
    end

    def run_stats(args)
      path = args.first
      unless path
        warn "Error: path argument required"
        warn "Usage: gitballs stats <path>"
        exit 1
      end

      unless File.directory?(path)
        warn "Error: #{path} is not a directory"
        exit 1
      end

      stats = Stats.new(path)
      puts stats
    rescue Error => e
      warn "Error: #{e.message}"
      exit 1
    end
  end
end
