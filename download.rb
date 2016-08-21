# for a given library (rubygem/node module etc)

# download a list of every release number

# download each release tarball into /tarballs/:name

# calculate the size of the folder of tarballs (du -sh .)

# create a new git repository in /gitballs/:name

# sort releases by semver

# for each release
  # delete the contents of the directory

  # untar the release into the directory

  # add and commit all files and folders with the release number as the message

# calculate the size of the git repository (git count-objects -vH)

# output comparison

# Extra - make a branch for each major semver number
