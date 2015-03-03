# GitHub clone of [RL Tiles](http://rltiles.sourceforge.net/) + extra work!

I wanted tiles for a roguelike game. The RL tiles are great, but I wanted a few more things:

- Transparent background
- All the 2D tiles from both its NetHack set and its Dungeon Crawl set
- Metadata of (name → index) in JSON format
- Deduplication
- Decent ordering in the map (all monsters, all items, all dungeon features)

[View the interactive tileset explorer here](http://statico.github.io/rltiles/) and then check out `rltiles-2d.json` and `rltiles-2d.png`.

![](https://raw.githubusercontent.com/statico/rltiles/master/rltiles-2d.png)

### Developiing

The .txt files seemed simple enough, and I couldn't figure out tools in tools/, so I wrote a small tool to do what I want.

### Requirements

1. GraphicsMagick (`brew install graphicsmagick` or `apt-get install graphicsmagick`)
1. Node 0.10 or later

### Building the tiles

1. `npm install`
1. `./build.coffee rltiles-2d.txt rltiles-2d.png rltiles-2d.json`

## License

    Part of (or All) the graphic tiles used in this program is the public 
    domain roguelike tileset "RLTiles".

    You can find the original tileset at:
    http://rltiles.sf.net

See http://rltiles.sourceforge.net/ for more information about RL Tiles.
