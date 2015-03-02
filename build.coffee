#!./node_modules/.bin/coffee

fs = require 'fs'
gm = require 'gm'
pathlib = require 'path'
commander = require 'commander'

argv = commander
  .usage('[options] <config.txt> <output.png> <output.json>')
  .parse(process.argv)

argv.help() unless argv.args.length is 3
[inputConfig, outputImage, outputJSON] = argv.args

TILE_SIZE = 32 # pixels
BGCOLOR = '#476c6c'

data = {
  tileSize: TILE_SIZE
}
tiles = []
seen = {}
srcdirs = ['.']

parse = (filename, breadcrumbs) ->
  indent = new Array(breadcrumbs.length).join('  ')
  console.error indent, '>>', filename
  contents = fs.readFileSync filename, 'utf8'
  lineno = 0
  for line in contents.split /\n/m
    lineno++
    line = line.replace /\s+$/m, ''
    continue if /^\s*#/.test line
    continue unless /\S/.test line
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
          srcdirs.push arg if srcdirs.indexOf arg is -1
        else
          console.error indent, "  Line #{ lineno } - ignoring: #{ line }"
    else
      args = line.split /\s+/
      filename = args[0].replace /\s*\/\*.*/g, ''
      key = pathlib.basename filename
      continue if key of seen
      seen[key] = true
      path = do ->
      for dir in srcdirs
        path = pathlib.join(dir, filename + '.bmp')
        try
          fs.statSync path
        catch e
          path = null
        break if path
      if not path
        throw new Error("Couldn't find #{ key } in #{ srcdirs } via #{ breadcrumbs }")

      tiles.push [key, path]

  console.error indent, '<<', filename
  return

parse inputConfig, [inputConfig]

i = 0
data.tiles = new Array(tiles)
for [key, path], i in tiles
  data.tiles[i] = key
fs.writeFileSync outputJSON, JSON.stringify(data, null, '  '), 'utf8'

w = TILE_SIZE * data.width
h = TILE_SIZE * Math.ceil(tiles.length / data.width)
image = gm(w, h, 'transparent')
for [key, path], i in tiles
  x = TILE_SIZE * (i - Math.floor(i / data.width) * data.width)
  y = TILE_SIZE * Math.floor(i / data.width)
  image = image.in('-page', "+#{x}+#{y}").in(path)
image = image.mosaic().transparent(BGCOLOR).write outputImage, (err) ->
  throw new Error("Couldn't write to #{ outputImage }: #{ err }") if err
