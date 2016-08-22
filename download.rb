require 'bundler'
Bundler.require
require 'json'

# for a given library (rubygem/node module etc)

library_name = 'redis'
platform = 'rubygems'

# download a list of every release number

response = Typhoeus.get("https://libraries.io/api/#{platform}/#{library_name}")
library = JSON.parse(response.body)

versions = library['versions']

version_numbers = versions.map{|v| v['number']}

# delete any existing tarballs

`rm -f ./tarballs/*.tar`

# download each release tarball into /tarballs/:name

version_numbers.each do |version_number|

  tarball_url = case platform
  when 'rubygems'
    "https://rubygems.org/downloads/#{library_name}-#{version_number}.gem"
  else
    raise "unknown tarball url for #{platform}"
  end

  `wget -O ./tarballs/#{version_number}.tar '#{tarball_url}'`

end

# create a new git repository in /gitballs/:name

`git init ./gitballs/`

# sort releases by semver

version_numbers.sort! do |a,b|
  begin
    Semantic::Version.new(a) <=> Semantic::Version.new(b)
  rescue
    a <=> b
  end
end

# for each release
version_numbers.each do |version_number|
  # delete the contents of the directory

  `cd gitballs && git rm -rf .`

  # untar the release into the directory

  `tar -C ./gitballs -xvf ./tarballs/#{version_number}.tar`
  `cd gitballs && tar -C . -zxvf data.tar.gz && rm -f data.tar.gz metadata.gz` # rubygems specific

  # add and commit all files and folders with the release number as the message

  `cd gitballs && git add . && git commit -am '#{version_number}'`
end

# optimize the git repo size

`cd gitballs && git gc --aggressive --prune`

# calculate the size of the git repository (git count-objects -vH)

gitball_size = `du -sh ./gitballs | cut -f1`.strip

# calculate the size of the folder of tarballs (du -sh .)

tarball_size = `du -sh ./tarballs | cut -f1`.strip

# output comparison

puts "gitballs: #{gitball_size}"
puts "tarballs: #{tarball_size}"

# Extras
  # make a branch for each major semver number
  # handle invalid semver numbers by sorting by publish date
  # how does it handle .gitignore files in tarballs?
