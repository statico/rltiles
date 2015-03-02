#!./node_modules/.bin/coffee

fs = require 'fs'
gm = require 'gm'
pathlib = require 'path'
readline = require 'linebyline'
commander = require 'commander'

argv = commander
  .usage('[options] <config.txt> <output.png> <output.json>')
  .parse(process.argv)

argv.help() unless argv.args.length is 3
[inputConfig, outputImage, outputJSON] = argv.args

TILE_SIZE = 32 # pixels
BGCOLOR = '#476c6c'

data = {}
tiles = []
pending = 0

parse = (filename, breadcrumbs) ->
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
          parse arg, breadcrumbs.concat [arg]
        when 'sdir'
          cwd = arg
        else
          console.error "Command %#{ cmd } not supported"
    else
      line = line.replace /\s*\/\*.*/g, ''
      path = pathlib.join(cwd, line + '.bmp')
      try
        fs.statSync path
      catch e
        throw new Error("File #{ path } not found, referenced from #{ breadcrumbs.join ' -> ' }")
      tiles.push [line, path]

parse inputConfig, [inputConfig]

finish = ->
  i = 0
  data.tiles = {}
  for [key, path] in tiles
    data.tiles[key] = i++
  fs.writeFileSync outputJSON, JSON.stringify(data, null, '  '), 'utf8'

  w = TILE_SIZE * data.width
  h = TILE_SIZE * Math.ceil(tiles.length / data.width)
  image = gm(w, h, 'transparent')
  for [key, path], i in tiles
    x = TILE_SIZE * (i - Math.floor(i / data.width) * data.width)
    y = TILE_SIZE * Math.floor(i / data.width)
    image = image.in('-page', "+#{x}+#{y}").in(path)
  image = image.mosaic().write outputImage, (err) ->
    throw new Error("Couldn't write to #{ outputImage }: #{ err }") if err
