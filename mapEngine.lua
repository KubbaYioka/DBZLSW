--[[
--Example Map table 
{
mapNumber = ## --set number that is called upon when mapmode is loaded
seriesNote = "string" -- values can be DB, DBZ, or DBS
mapSize = details the mapsize to use, eg. 20x20, 20x30, 40,20, etc
tileSet = Table -- calls on a tileSet Table to use, which will be defined in another section in another table
defaultChr = variable -- character graphic to load
mapLayout = {tileSet[x], tileSet[y], tileSet[z], etc} -- defines what tiles to use from the loaded tileSet
mapTriggers = {tileAppear(x,y), tileDisappear(x,y), chrAppear(x,y,chr), chrDisappear(x,y)} 
}

]]


function createMap(mapNumber) --command builds a map based on information from the table mapNumber
    local mapRef = mapNumber
    local tileset = Tileset.new()
    local tileWidth = tileset:tileWidth()
    local tileHeight = tileset:tileHeight()
end