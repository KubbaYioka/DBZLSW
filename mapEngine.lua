local tlp = playdate.graphics.tilemap
local gfx = playdate.graphics
local GRID_SIZE = 16 -- size of all grid tiles. 

class('PlayerMSprite').extends(AnimatedSprite)

function PlayerMSprite:init(image)
    local pTable = gfx.imagetable.new(image)
    PlayerMSprite.super.init(self, pTable)

    -- Define sprite states
    self:addState("down",1,2,{tickStep = 12})
    self:addState("up",5,6,{tickStep = 12})
    self:addState("left",7,8,{tickStep = 12})
    self:addState("right",3,4,{tickStep = 12})
    self:playAnimation()

    -- Properties
    self:changeState("down",true)
    self:setZIndex(100)
    --self:setCollideRect()
    self:add()
end

--[[ Possible alternate way to load player sprite info for maps. local config would need to go in maps.lua
local config = {
    imagetable = currentPlrImage,
    states = someStates,
    animate = someAnimateValue,
    startX = maps.mapNumberT.chrX,
    startY = maps.mapNumberT.chrY
}
pMapSprite = PlayerMSprite(config)]]

function PlayerMSprite:handleInput(button)
    if gameMode == GameMode.MAP then
        if button == "left" then
            if pMapSprite.currentState == "left" then
            end
            pMapSprite:changeState("left")

        elseif button == "right" then
            if pMapSprite.currentState == "right" then
            end
            pMapSprite:changeState("right")

        elseif button == "up" then
            if pMapSprite.currentState == "up" then
            end
            pMapSprite:changeState("up")

        elseif button == "down" then
            if pMapSprite.currentState == "down" then
                
            end
            pMapSprite:changeState("down")
        elseif button == "a" then
            --checkObject(pMapSprite.currentState) --checks the tile immediately in front of the player
        end
    end
end

function PlayerMSprite:updatePosition()

end

local currentMapImage = nil
currentMap = nil
currentPlrSprite = nil
function mapInit(map)
    print("mapInit")
    --creates new tilemap and image table from a mapTable containing all information for each map
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
    
    -- begin creating nes player sprite
    currentPlrImage = map.mapChr
    print(currentPlrImage)

    pMapSprite = PlayerMSprite(currentPlrImage)
    pMapSprite:moveTo(map.chrX,map.chrY)

    pMapSprite.hasContext = true
    pMapSprite.facing

end

function goMap(mapNumber) --command builds a map based on information from the table mapNumber
    mapInit(mapNumber)
    --clear all menus, portraits, text, etc
end

--[[The movement speed is set to GRID_SIZE, which means the sprite will move the entire grid size in one frame. This will make the movement instantaneous, and you won't see the sprite transitioning smoothly from one grid cell to another. To achieve smooth movement, you should reduce the moveSpeed value. For example, setting it to 1 or 2 will make the sprite move 1 or 2 pixels per frame, respectively.]]