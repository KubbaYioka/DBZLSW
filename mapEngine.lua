---[[
--Example Map table 
mapNumberT = { --Test Map
tileSet = '/assets/tilemaps/testMap.png'
,tWidth = 16
,tHeight = 16
}

--]]


function goMap(mapNumber) --command builds a map based on information from the table mapNumber
    --clear all menus, portraits, text, etc
    local mapRef = mapNumber
    printTable(mapRef)
    local tileset = Tileset.new(mapRef[tileSet])
    local tileWidth = tileset:tileWidth(mapRef[tWidth])
    local tileHeight = tileset:tileHeight(mapRef[tHeight])

end