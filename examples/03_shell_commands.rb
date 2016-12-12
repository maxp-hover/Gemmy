# One-off tasks

# There is one system executable, 'gemmy'.

# Type that by itself to see a list of commands

# Here is the command reference:

# -------------
# make_gem <name>
# -------------

# This generates a gem with some basic structure added.
# It's only a few files; don't be intimidated.
# See the comments in lib/gemmy/tasks/make_gem.rb

# It's probably a good idea to check on RubyGems if the name is taken, because
# it's a little bit of a drag to have to change the name.

# The reinstall script should take care of the development process for the gem.
# It uninstalls, rebuilds the gem executable, then installs it.
# It also creates a skeleton executable using Thor.

# Note that this will prompt you for additional input via gets

# I have manually tested this; it should work.

# -------------
# test
# -------------

# Runs a test suite which is the lib/gemmy/tests/ directory.
# More unit than integration tests. Ensures that the patches are loaded
# in a refinement-based approach and that the methods work as basically
# intended.

# Doesn't yet test the one-off system jobs i.e. make_gem
