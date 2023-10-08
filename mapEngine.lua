local tlp = playdate.graphics.tilemap
local gfx = playdate.graphics
---[[
--Example Map table 

--]]

local currentMapImage = nil
currentMap = nil

function mapInit(map)
    currentMapImage = gfx.imagetable.new(map.tileSet)
    currentMap = gfx.tilemap.new()
    currentMap:setImageTable(currentMapImage)
    currentMap:setSize(map.mapWidth,map.mapHeight) --size in tiles.
    currentMap:setTiles(map.mLayout, map.mapWidth)

    --creates new tilemap and image table from a mapTable containing all information for each map
    class('plrMapSpr').extends(gfx.sprite)
    local plrMapIma = gfx.image.new(map.mapChr)
    local cX = map.chrX
    local cY = map.chrY
    function plrMapSpr:init(cX,cY)
        plrMapSpr.super.init(self)
        self:setImage(plrMapIma)
        self:moveTo(cX,cY)
    end
    local pSprite = plrMapSpr(map.chrX,map.chrY)
    pSprite:add()
end



function goMap(mapNumber) --command builds a map based on information from the table mapNumber
    mapInit(mapNumber)
    --clear all menus, portraits, text, etc
end