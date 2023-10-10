local tlp = playdate.graphics.tilemap
local gfx = playdate.graphics

class('PlayerMSprite').extends(gfx.sprite)

function PlayerMSprite:init(x, y, image)
    local plrSpr = gfx.sprite.new()
    local pTable = gfx.imagetable.new(image)
    local pTmap = gfx.tilemap.new(pTable)
    self:setTilemap(pTmap)

    -- Define sprite states
    PlayerMSprite.states = {
        DOWN = 1,
        LEFT = 2,
        RIGHT = 3,
        UP = 4
    }
    PlayerMSprite.stateFrames = {
        [PlayerMSprite.states.DOWN] = {1,2}, 
        [PlayerMSprite.states.LEFT] = {7,8},
        [PlayerMSprite.states.RIGHT] = {3,4},
        [PlayerMSprite.states.UP] = {5,6}
    }

    self:moveTo(x, y)
    self:setZIndex(10)
    self.currentState = PlayerMSprite.states.DOWN
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
    
    currentPlrImage = map.mapChr
    print(currentPlrImage)
    local cX = map.chrX
    local cY = map.chrY
    PlayerMSprite(cX, cY, currentPlrImage)
end

function goMap(mapNumber) --command builds a map based on information from the table mapNumber
    mapInit(mapNumber)
    --clear all menus, portraits, text, etc
end
