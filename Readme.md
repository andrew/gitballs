# Gitballs :8ball: :basketball: :soccer:

An investigation into storing package manager release tarballs in a space efficient way using git.

## Theory

Each release of a library to a package manager is usually a few line changes, but is stored as a complete copy of the changes, git is good at efficiently storing diffs so perhaps we can put each release in a git repo as a commit and see how much smaller the result will be.

## Results

#### Rubygems

| gem name           | # of releases | tarball size | gitball size | % saving | saving |
| ------------------ | ------------- | ------------ | ------------ | -------- | ------ |
| split              | 48            | 2.5M         | 380K         | 85       | 2.12MB |
| redis              | 52            | 1.7M         | 400K         | 76       | 1.3MB  |
| capistrano         | 82            | 7.0M         | 772K         | 89       | 6.23MB |
| rake               | 71            | 7.0M         | 624K         | 91       | 6.38MB |
| bundler            | 225           | 42M          | 1.9M         | 95       | 40MB   |
| rails              | 288           | 159M         | 7.4M         | 95       | 152MB  |
| nokogiri           | 94            | 275M         | 33M          | 88       | 242MB  |
| sass               | 309           | 74M          | 2.0M         | 97       | 72MB   |
| font-awesome-rails | 34            | 55M          | 16M          | 70       | 39MB   |
| i18n-active_record | 4             | 52K          | 360K         | -590     | -308KB |

#### NPM

| module name | # of releases | tarball size | gitball size | % saving | saving |
| ----------- | ------------- | ------------ | ------------ | -------- | ------ |
| base62      | 6             | 36K          | 100K         | -277     | -64KB  |
| express     | 274           | 23M          | 9.8M         | 57       | 13.2MB |
| mocha       | 118           | 10M          | 1.1M         | 89       | 8.9MB  |
| node-sass   | 94            | 111M         | 22M          | 80       | 89MB   |
| request     | 111           | 6.7M         | 844K         | 87       | 5.86MB |
| left-pad    | 11            | 52K          | 348K         | -569     | -296KB |
| react       | 87            | 40M          | 4.8M         | 88       | 35.2MB |
| chai        | 64            | 3.4M         | 780K         | 77       | 2.62MB |
| lodash      | 88            | 79M          | 8.1M         | 90       | 70.9MB |
| bootstrap   | 13            | 15M          | 4.4M         | 71       | 10.6MB |

## Installation

```
gem install gitballs
```

## CLI

```
gitballs init <purl>     # Download and compress package versions into git repo
gitballs stats <path>    # Show stats for an existing gitballs repo
gitballs version         # Show version
```

Options:
- `-o, --output DIR` - Output directory (default: ./gitballs/<package>)
- `-q, --quiet` - Suppress progress output

Examples:

```
gitballs init pkg:gem/rails
gitballs init pkg:npm/lodash --output ./lodash-repo
gitballs init pkg:gem/nokogiri --quiet
gitballs stats ./gitballs/rails
```
