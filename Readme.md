# Gitballs :8ball: :basketball: :soccer:

An investigation into storing package manager release tarballs in a space efficient way using git.

## Theory

Each release of a library to a package manager is usually a few line changes, but is stored as a complete copy of the changes, git is good at efficiently storing diffs so perhaps we can put each release in a git repo as a commit and see how much smaller the result will be.
