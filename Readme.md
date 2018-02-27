# Gitballs :8ball: :basketball: :soccer:

An investigation into storing package manager release tarballs in a space efficient way using git.

## Theory

Each release of a library to a package manager is usually a few line changes, but is stored as a complete copy of the changes, git is good at efficiently storing diffs so perhaps we can put each release in a git repo as a commit and see how much smaller the result will be.

## Results

#### Rubygems

| gem name           | # of releases | tarball size | gitball size | % saving |
| ------------------ | ------------- | ------------ | ------------ | -------- |
| split              | 48            | 2.5M         | 380K         | 85       |
| redis              | 52            | 1.7M         | 400K         | 76       |
| capistrano         | 82            | 7.0M         | 772K         | 89       |
| rake               | 71            | 7.0M         | 624K         | 91       |
| bundler            | 225           | 42M          | 1.9M         | 95       |
| rails              | 288           | 159M         | 7.4M         | 95       |
| nokogiri           | 94            | 275M         | 33M          | 88       |
| sass               | 309           | 74M          | 2.0M         | 97       |
| font-awesome-rails | 34            | 55M          | 16M          | 70       |
| i18n-active_record | 4             | 52K          | 360K         | -590     |

#### NPM

| module name | # of releases | tarball size | gitball size | % saving |
| ----------- | ------------- | ------------ | ------------ | -------- |
| base62      | 6             | 36K          | 100K         | -277     |
| express     | 274           | 23M          | 9.8M         | 57       |
| mocha       | 118           | 10M          | 1.1M         | 89       |
| node-sass   | 94            | 111M         | 22M          | 80       |
| request     | 111           | 6.7M         | 844K         | 87       |
| left-pad    | 11            | 52K          | 348K         | -569     |
| react       | 87            | 40M          | 4.8M         | 88       |
| chai        | 64            | 3.4M         | 780K         | 77       |
| lodash      | 88            | 79M          | 8.1          | 90       |
| bootstrap   | 13            | 15M          | 4.4M         | 71       |
