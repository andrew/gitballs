# frozen_string_literal: true

require_relative "lib/gitballs/version"

Gem::Specification.new do |spec|
  spec.name = "gitballs"
  spec.version = Gitballs::VERSION
  spec.authors = ["Andrew Nesbitt"]
  spec.email = ["andrewnez@gmail.com"]

  spec.summary = "Space-efficient storage of package release tarballs using git"
  spec.description = "Downloads all versions of a package and commits them into a git repository, leveraging git delta compression to reduce storage."
  spec.homepage = "https://github.com/andrew/gitballs"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/andrew/gitballs"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "typhoeus", "~> 1.4"
  spec.add_dependency "purl", "~> 1.6"
  spec.add_dependency "vers", "~> 1.0"
end
