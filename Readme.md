# Gitballs :8ball: :basketball: :soccer:

An investigation into storing package manager release tarballs in a space efficient way using git.

## Theory

Each release of a library to a package manager is usually a few line changes, but is stored as a complete copy of the changes, git is good at efficiently storing diffs so perhaps we can put each release in a git repo as a commit and see how much smaller the result will be.

## Results

#### Rubygems

| gem name | number of releases | tarball size  | gitball size | % saving |
|---|---|---|---|
| split | 48 | 2.5MB | 380K | 85 |
| redis | 52 | 1.7MB | 400K | 76 |
| capistrano | 82 | 7.0MB | 772K | 89 |
| rake | 71 | 7.0MB | 624K | 91 |
| bundler | 225 | 42MB | 1.9M | 95 |
| rails | 288 | 159M | 7.4M | 95 |
| nokogiri | 94 | 275M | 33M | 88 |
| sass | 309 | 74M | 2.0M | 97 |
| font-awesome-rails | 34 | 55MB | 16MB | 70 |
| i18n-active_record | 4 | 52K | 360K | -590 |
