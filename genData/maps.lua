--MAP FILE--

maps={

    mapNumberT = { --Test Map
    tileSet = "assets/images/tilemaps/testTile"
    ,tWidth = 16 -- tile sizes in pixels. May not be necessary
    ,tHeight = 16
    ,mapWidth = 16 -- map size in tiles
    ,mapHeight = 16
    ,mLayout = { -- table of values that represent what tile from the image file to draw where
        9,10,7,8,11,12,5,5,6,11,12,25,24,15,15,24,
        5,6,42,43,5,6,27,42,43,5,6,27,27,13,14,16,
        11,12,5,6,2,1,2,5,6,1,2,1,1,4,3,14,
        9,10,2,1,1,2,1,2,1,1,1,2,1,3,4,15,
        5,8,1,18,1,2,19,2,2,1,2,1,2,4,3,15,
        11,43,2,1,1,2,1,2,2,1,18,2,1,3,4,14,
        9,10,2,1,2,17,2,2,1,1,2,1,2,1,3,15,
        9,10,43,1,1,1,1,2,1,19,1,1,1,2,3,13,
        5,6,6,2,2,2,1,1,1,2,1,2,2,1,4,15,
        11,12,1,2,1,2,1,2,2,2,1,2,1,1,3,14,
        5,6,2,1,1,19,18,1,2,2,1,17,2,4,3,16,
        42,43,1,2,1,1,19,18,2,1,1,1,1,3,4,13,
        9,10,2,1,1,2,2,1,1,2,1,1,1,4,3,16,
        7,8,1,18,2,1,2,1,2,1,18,2,3,4,15,13,
        12,17,1,2,1,1,1,1,1,1,1,3,4,3,13,15,
        10,11,12,25,25,42,12,24,25,11,12,25,15,17,15,13
        }
    ,mObjectLayout = {
        --defines the location of certain kinds of objects
        --these objects are defined elsewhere in the program
        }
    ,mapChr = "assets/images/mapSpr/kidGoku"-- Selects the character that the player will be in the overworld.
    ,chrX = 10 --player sprite starting x pos
    ,chrY = 10 --player sprite starting y pos
    },
    map01 = {}
}