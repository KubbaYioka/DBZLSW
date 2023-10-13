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
    printTable(self)

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
            pMapSprite:changeState("left")

        elseif button == "right" then
            pMapSprite:changeState("right")

        elseif button == "up" then
            pMapSprite:changeState("up")

        elseif button == "down" then
            pMapSprite:changeState("down")
        elseif button == "a" then
            --checkObject() --checks the tile immediately in front of the player
        end
        if not pMapSprite.isMoving then

            if button == "up" then
                pMapSprite.targetY = pMapSprite.y - GRID_SIZE
            elseif button == "down" then
                pMapSprite.targetY = pMapSprite.y + GRID_SIZE
            elseif button == "left" then
                pMapSprite.targetX = pMapSprite.x - GRID_SIZE
            elseif button == "right" then
                pMapSprite.targetX = pMapSprite.x + GRID_SIZE
            end
            pMapSprite.isMoving = true
        end
        if pMapSprite.isMoving then
            local moveSpeed = GRID_SIZE -- This can be adjusted based on desired movement speed        
            -- Move in the X direction
            if pMapSprite.x < pMapSprite.targetX then
                pMapSprite.x = pMapSprite.x + moveSpeed
                if pMapSprite.x > pMapSprite.targetX then
                    pMapSprite.x = pMapSprite.targetX
                end
            elseif pMapSprite.x > pMapSprite.targetX then
                pMapSprite.x = pMapSprite.x - moveSpeed
                if pMapSprite.x < pMapSprite.targetX then
                    pMapSprite.x = pMapSprite.targetX
                end
            end
            -- Move in the Y direction
            if pMapSprite.y < pMapSprite.targetY then
                pMapSprite.y = pMapSprite.y + moveSpeed
                if pMapSprite.y > pMapSprite.targetY then
                    pMapSprite.y = pMapSprite.targetY
                end
            elseif pMapSprite.y > pMapSprite.targetY then
                pMapSprite.y = pMapSprite.y - moveSpeed
                if pMapSprite.y < pMapSprite.targetY then
                    pMapSprite.y = pMapSprite.targetY
                end
            end
            -- Check if sprite reached target position
            if pMapSprite.x == pMapSprite.targetX and pMapSprite.y == pMapSprite.targetY then
                pMapSprite.isMoving = false
            end
        end
    end
end

function PlayerMSprite:update()
    self:updateAnimation()
end

local currentMapImage = nil
currentMap = nil
currentPlrSprite = nil
function mapInit(map)
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
    pMapSprite.targetX = map.chrX
    pMapSprite.targetY = map.chrY
end

function goMap(mapNumber) --command builds a map based on information from the table mapNumber
    mapInit(mapNumber)
    --clear all menus, portraits, text, etc
end