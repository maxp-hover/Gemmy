### Gemmy gem

This is a general purpose gem which adds functionality to the ruby language
and defines some system tasks, such as generating a gem.

It is on RubyGems. Because there is an existing gem named `gemmy`, the name passed to `gem install` is `gemmyrb`. But `require 'gemmy'` is still used.

RubyGems hosts the YARD documentation at [http://www.rubydoc.info/gems/gemmyrb](http://www.rubydoc.info/gems/gemmyrb), but it's only updated when I push
a new gem version. So the version here on Github's master branch might contain
undocumented functionality. I'll try to keep the RubyGems version up-to-date though.

YARD is not the best for a birds-eye overview. For that, see the following
documents:

- _Loading the gem's code in different scopes_
  - [examples/01_using_as_refinement.rb](./examples/01_using_as_refinement.rb)
  - [examples/02_using_globally.rb](./examples/02_using_globally.rb)
- _List of methods intended for general Ruby use_
  - [examples/03_ruby_extensions_list.rb](./examples/03_ruby_extensions_list.rb)
- _Shell commands and other one-off processes_
  - [examples/04_shell_commands.rb](./04_shell_commands.rb)
