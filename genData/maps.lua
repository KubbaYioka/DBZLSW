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
    ,mEmptyIds = {1,2,3,4,18,19}
    ,mTypeLayer = { -- table of values corresponding to the mLayout tiles. Establishes the type of tile (passthrough, impassable, etc) Tiles are defined elsewhere, but refer to this table.
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
    1,1,1,1,0,0,0,1,1,0,0,0,0,0,0,1,
    1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,1,0,0,0,1,0,0,0,0,0,0,0,0,0,1,
    1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,1,0,0,0,0,0,0,0,0,0,1,0,0,0,1,
    1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
    1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,
    1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,
    1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
    }
    ,mObjLayout = {
        --sampleObject(x,y,type,function,function2) where function is what the object does and function2 is the result of that action?
        --defines the location of certain kinds of objects
        --these objects are defined elsewhere in the program
        obj1 = {
            x = 4
            ,y = 5
            ,sprite = "assets/images/mapSpr/testObj-table-16-16"
            ,tag = "object"

            ,properties = {
                txtIter = 1
                ,text1 = {
                    function() dTag("left", "Goku") end
                    ,"This is a test object."
                    ,"This object will make the second jar appear."
                    ,function() dTag("clear") end
                    ,function() mNextText("jarOne",2) end
                    ,function() mObjAppear("obj2",true) end
                }
                ,text2 = {
                    function() dTag("left", "Goku") end
                    ,"Since the second jar has already appeared, the next text field is being used "
                    ,"in this object."
                    ,function() dTag("clear") end
                }
                ,name = "jarOne"
                ,oVisible = true
            }
        }
        ,obj2 = {
            x = 6
            ,y = 8
            ,sprite = "assets/images/mapSpr/testObj-table-16-16"
            ,tag = "object"

            ,properties = {
                txtIter = 1
                ,text1 = {
                    function() dTag("left", "Goku") end
                    ,"This is another test object."
                    , function() dTag("clear") end
                    --,-- command to say that this is the end of this dialogue session, and that the next won't begin until a flag is triggered.
                    ,function() dTag("left", "Goku") end
                    ,"This is more text and a card."
                    ,function() cCardAdd("3 Stage Attack") end
                    ,function() mNextText("jarTwo",2) end
                    , function() dTag("clear") end
                }
                ,text2 = {
                    function() dTag("left", "Goku") end
                    ,"And now the second object will be deleted."
                    ,"But first, here's a card."
                    ,function() cCardAdd("4 Stage Attack") end
                    ,function() mObjAppear("jarTwo",false) end
                    ,function() dTag("clear") end
                }
                ,name = "jarTwo"
                ,oVisible = false
            }
        }   
    }
    ,mapChr = "assets/images/mapSpr/kidGoku-table-16-16"-- Selects the character that the player will be in the overworld.
    ,chrX = 64 --player sprite starting x pos
    ,chrY = 64 --player sprite starting y pos
    },
    map01 = {}
}