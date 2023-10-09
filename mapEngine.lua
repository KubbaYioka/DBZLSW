local tlp = playdate.graphics.tilemap
local gfx = playdate.graphics

function plrSprInit(x,y,image)
    local plrSpr = gfx.sprite.new()
    function plrSpr:draw()
    end
    plrSpr:add()
end

local currentMapImage = nil
currentMap = nil

function mapInit(map)
    currentMapImage = gfx.imagetable.new(map.tileSet)
    currentMap = gfx.tilemap.new()
    currentMap:setImageTable(currentMapImage)
    currentMap:setSize(map.mapWidth,map.mapHeight) --size in tiles.
    currentMap:setTiles(map.mLayout, map.mapWidth)

    --creates new tilemap and image table from a mapTable containing all information for each map
    
    local plrMapIma = gfx.image.new(map.mapChr)
    local cX = map.chrX
    local cY = map.chrY
    print(cX.." "..cY)
    plrSprInit(cX,xY,plrMapIma)
end



function goMap(mapNumber) --command builds a map based on information from the table mapNumber
    mapInit(mapNumber)
    --clear all menus, portraits, text, etc
end
