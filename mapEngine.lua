<<<<<<< HEAD
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
=======
--Basic graphics setup

local gfx = playdate.graphics

local setMap = gfx.tilemap.new()

function setMap:new()
    local o = o or {}
    setmetatable(o,self)
    self.__index=self

    local loadedMap = maps.map
    printTable(loadedMap)

end

function goMap(mapNumber) --command builds a map based on information from the table mapNumber
    --clear all menus, portraits, text, etc
    local mapRef = mapNumber
    printTable(mapRef)
    local tileset = setMap:new(mapRef[tileSet])
    local tileWidth = setMap:tileWidth(mapRef[tWidth])
    local tileHeight = setMap:tileHeight(mapRef[tHeight])

end

--Interactive Object Class

--

--
>>>>>>> b6c9b08f6ed1a16bd95fe4951176d895684a67ea
