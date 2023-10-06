--[[

MASTER MAP TABLE

]]--

maps = {

    testMap ={
        mapWidth -- map width in tiles. All tiles are 16x16.
        ,mapHeight -- map height by tiles. All tiles are 16x16.
        ,tilemaps -- set of graphics to use as the background
        ,objectFile -- a file containing image assets for tiles. Pass as sprite sheet
        ,objectDef = {} -- a table containing attributes for all objects on the map, such as what happens if a player presses 'A' while facing them.

    },

}