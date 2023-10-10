local tlp = playdate.graphics.tilemap
local gfx = playdate.graphics

class('PlayerMSprite').extends(gfx.sprite)

function PlayerMSprite:init(x, y, sprite)
    local plrSpr = gfx.sprite.new()
    self:setImage(currentPlrSprite)
    self:moveTo(x, y)
    self:setZIndex(10)
    self:add()
end

local currentMapImage = nil
currentMap = nil
currentPlrSprite = nil
function mapInit(map)
    currentMapImage = gfx.imagetable.new(map.tileSet)
    currentMap = gfx.tilemap.new()
    currentMap:setImageTable(currentMapImage)
    currentMap:setSize(map.mapWidth,map.mapHeight) --size in tiles.
    currentMap:setTiles(map.mLayout, map.mapWidth)
    local mapSprite = gfx.sprite.new()
    mapSprite:setTilemap(currentMap)
    mapSprite:moveTo(0,0)
    mapSprite:setCenter(0,0)
    mapSprite:setZIndex(1)
    mapSprite:add()

    --creates new tilemap and image table from a mapTable containing all information for each map
    
    currentPlrSprite = gfx.image.new(map.mapChr)
    local cX = map.chrX
    local cY = map.chrY
    print(cX.." "..cY)
    PlayerMSprite(cX, cY, currentPlrSprite)
end

function goMap(mapNumber) --command builds a map based on information from the table mapNumber
    mapInit(mapNumber)
    --clear all menus, portraits, text, etc
end
