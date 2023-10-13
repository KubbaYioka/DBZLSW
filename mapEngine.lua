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
        if not self.isMovingX and not self.isMovingY then

            if button == "up" then
                self.targetY = self.y - GRID_SIZE
                self.isMovingY = true
            elseif button == "down" then
                self.targetY = self.y + GRID_SIZE
                self.isMovingY = true
            elseif button == "left" then
                self.targetX = self.x - GRID_SIZE
                self.isMovingX = true
            elseif button == "right" then
                self.targetX = self.x + GRID_SIZE
                self.isMovingX = true
            end
        end
    end
end

function PlayerMSprite:updatePosition()
    -- Grid-based movement logic
    if self.isMovingX then
        local moveSpeed = 1  -- Adjust for desired movement speed

        -- Move in the X direction
        if self.x < self.targetX then
            self.x = self.x + moveSpeed
            if self.x > self.targetX then
                self.x = self.targetX
            end
        elseif self.x > self.targetX then
            self.x = self.x - moveSpeed
            if self.x < self.targetX then
                self.x = self.targetX
            end
        end
    end
    if self.isMovingY then
        local moveSpeed = 1  -- Adjust for desired movement speed

        -- Move in the Y direction
        if self.y < self.targetY then
            self.y = self.y + moveSpeed
            if self.y > self.targetY then
                self.y = self.targetY
            end
        elseif self.y > self.targetY then
            self.y = self.y - moveSpeed
            if self.y < self.targetY then
                self.y = self.targetY
            end
        end
    end

    -- Check if sprite reached target position
    if self.x == self.targetX and self.y == self.targetY then
        self.isMovingX = false
        self.isMovingY = false
    end
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
    pMapSprite.hasContext = true
    pMapSprite.isMovingX = false
    pMapSprite.isMovingY = false
end

function goMap(mapNumber) --command builds a map based on information from the table mapNumber
    mapInit(mapNumber)
    --clear all menus, portraits, text, etc
end

--[[The movement speed is set to GRID_SIZE, which means the sprite will move the entire grid size in one frame. This will make the movement instantaneous, and you won't see the sprite transitioning smoothly from one grid cell to another. To achieve smooth movement, you should reduce the moveSpeed value. For example, setting it to 1 or 2 will make the sprite move 1 or 2 pixels per frame, respectively.]]