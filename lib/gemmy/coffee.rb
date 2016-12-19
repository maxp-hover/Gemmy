Gemmy::Coffee = <<-COFFEE

#!/usr/bin/env coffee
puts = console.log

# Gemmy.init reads from argv and starts command
Gemmy =
  validCommands: (key) ->
    {
      'pos': this.partOfSpeech
    }[key]

  init: ->
    [cmd, args...] = process.argv.slice -2
    component = this.validCommands(cmd)
    unless component
      throw('missing or invalid argv command')
    component.run(args...).then component.callback

# Part of speech detector
pos = Gemmy.partOfSpeech = {}
pos.run = (sentence) ->
  WordPos = require 'wordpos'
  wordpos = new WordPos(profile: true)
  new Promise (resolve, reject) ->
    wordpos.getPOS sentence, resolve
pos.callback = (result) ->
  puts JSON.stringify result

Gemmy.init()

COFFEE

