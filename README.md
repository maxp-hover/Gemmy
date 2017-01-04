### Gemmy gem

This is a general purpose gem which adds functionality to the ruby language
and defines some system tasks, such as generating a gem.

It is on RubyGems. Because there is an existing gem named `gemmy`, the name passed to `gem install` is `gemmyrb`. But `require 'gemmy'` is still used.

RubyGems hosts the YARD documentation at [http://www.rubydoc.info/gems/gemmyrb](http://www.rubydoc.info/gems/gemmyrb), but it's only updated when I remember to run `yard`. 

**Follow the links from http://github.com/maxpleaner/gemmy, not rubydoc**

- _Loading the gem's code in different scopes_
  - [examples/01_using_as_refinement.rb](./examples/01_using_as_refinement.rb)
  - [examples/02_using_globally.rb](./examples/02_using_globally.rb)
- _Shell commands and other one-off processes_
  - [examples/03_shell_commands.rb](./examples/03_shell_commands.rb)
- _Natural language utilities_
  - [examples/04_language_stuff.rb](./examples/04_language_stuff.rb)


**To see a full list of the patched methods, see the [rubydoc](http://www.rubydoc.info/gems/gemmyrb)**

Specifically, look at the constants defined on Gemmy::Patches. There is one
module for each of the core classes being patched. Each individual method
is also contained in its own module.
