#!./node_modules/.bin/coffee

fs = require 'fs'
pathlib = require 'path'
readline = require 'linebyline'
commander = require 'commander'

argv = commander
  .usage('[options] <config.txt> <output.png> <output.json>')
  .parse(process.argv)

argv.help() unless argv.args.length is 3
[inputConfig, outputImage, outputJSON] = argv.args

data = {}
tiles = []
pending = 0

parse = (filename) ->
  pending++
  rl = readline filename
  cwd = '.'
  rl.on 'error', (err) -> throw new Error(err)
  rl.on 'end', ->
    pending--
    finish() unless pending
  rl.on 'line', (line) ->
    match = line.match /^%(\w+)\s+(.*)/
    if match
      [_, cmd, arg] = match
      switch cmd
        when 'width'
          data.width = parseInt arg, 10
        when 'name'
          data.name = arg
        when 'include'
          parse arg
        when 'sdir'
          cwd = arg
        else
          console.error "Command %#{ cmd } not supported"
    else
      tiles.push [line, pathlib.join(cwd, line)]

parse inputConfig

finish = ->
  i = 0
  data.tiles = {}
  for [key, path] in tiles
    data.tiles[key] = i++

  console.log JSON.stringify data, null, '  '
