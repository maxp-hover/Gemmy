### Gemmy gem

This is a general purpose gem which adds functionality to the ruby language
and defines some system tasks, such as generating a gem.

It is on RubyGems. Because there is an existing gem named `gemmy`, the name passed to `gem install` is `gemmyrb`. But `require 'gemmy'` is still used.

RubyGems hosts the YARD documentation at [http://www.rubydoc.info/gems/gemmyrb](http://www.rubydoc.info/gems/gemmyrb), but it's only updated when I push
a new gem version. So the version on Github's master branch might contain
undocumented functionality. I'll try to keep the RubyGems version up-to-date though.

YARD is not the best for a birds-eye overview. For that, see the following
documents:

**Note! The following links won't work if you're reading this on rubydoc.info**

**Follow the links from http://github.com/maxpleaner/gemmy instead**

- _Loading the gem's code in different scopes_
  - [examples/01_using_as_refinement.rb](./examples/01_using_as_refinement.rb)
  - [examples/02_using_globally.rb](./examples/02_using_globally.rb)
- _Shell commands and other one-off processes_
  - [examples/03_shell_commands.rb](./examples/03_shell_commands.rb)

**To see a full list of the patched methods (there are a lot since I've
included many from facets), see the [rubydoc](http://www.rubydoc.info/gems/gemmyrb)**

Specifically, look at the constants defined on Gemmy::Patches. There is one
module for each of the core classes being patched. Each individual method
is also contained in its own module (to make modular inclusion possible)
