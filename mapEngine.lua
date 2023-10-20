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

class('ObjectSprite').extends(AnimatedSprite)

function createMapObj(table)
    
    local obj = table.sprite
    print("table.sprite "..obj)
    ObjectSprite(obj)
end
function ObjectSprite:init(image)
    local oTable = gfx.imagetable.new(image)
    ObjectSprite.super.init(self,oTable)
    printTable(oTable)

    -- define sprite states
    local tileNum = gfx.imagetable:getLength(oTable)
    print("number of tiles: ")
    if tileNum == 1 then
        print("1")
    elseif tileNum == 2 then
        print("2")
    elseif tileNum == 3 then
        print("3")
    elseif tileNum == 4 then
        print("4")
    end
    --Other Properties
    --self:changeState("down",true)
    self:setZIndex(100)
    self:setCollideRect(0,0,self:getSize())
    self:add()
end

function PlayerMSprite:handleInput(button)
    if gameMode == GameMode.MAP then
        local nextX = self.x
        local nextY = self.y

        if button == "left" then
            nextX = self.x - GRID_SIZE
        elseif button == "right" then
            nextX = self.x + GRID_SIZE
        elseif button == "up" then
            nextY = self.y - GRID_SIZE
        elseif button == "down" then
            nextY = self.y + GRID_SIZE
        end

        -- Convert the pixel coordinates to tile coordinates
        local tileX = math.floor(nextX / GRID_SIZE) + 1
        local tileY = math.floor(nextY / GRID_SIZE) + 1

        -- Check if the destination tile is passable
        local tileIndex = (tileY - 1) * maps.mapNumberT.mapWidth + tileX
        if maps.mapNumberT.mTypeLayer[tileIndex] ~= 1 and self.isMovingX == false and self.isMovingY == false then
            -- If the tile is passable, update the target coordinates
            if button == "left" or button == "right" then
                self.targetX = nextX
                self.isMovingX = true
            else
                self.targetY = nextY
                self.isMovingY = true
            end
            -- Update the sprite's facing direction and animation state
            self:changeState(button)
        elseif self.isMovingX == false and self.isMovingY == false then
            -- Update the sprite's facing direction and animation state
            self:changeState(button)
        end
    end
end

function PlayerMSprite:updatePosition()
    if self.isMovingX then
        if self.x < self.targetX then
            local inc = self.x + 1
            self:moveTo(inc, self.y)
            self.x = inc
        elseif self.x > self.targetX then
            local inc = self.x - 1
            self:moveTo(inc, self.y)
            self.x = inc
        end
        if self.x == self.targetX then
            self.isMovingX = false
        end
    end

    if self.isMovingY then
        if self.y < self.targetY then
            local inc = self.y + 1
            self:moveTo(self.x, inc)
            self.y = inc
        elseif self.y > self.targetY then
            local inc = self.y - 1
            self:moveTo(self.x, inc)
            self.y = inc
        end
        if self.y == self.targetY then
            self.isMovingY = false
        end
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
    
    -- begin creating new player sprite
    currentPlrImage = map.mapChr
    pMapSprite = PlayerMSprite(currentPlrImage)
    pMapSprite:moveTo(map.chrX,map.chrY)
    pMapSprite.targetX = pMapSprite.x
    pMapSprite.targetY = pMapSprite.y
    pMapSprite.isMovingX = false
    pMapSprite.isMovingY = false
    pMapSprite.hasContext = true
    pMapSprite.facing = "down"

    for i,v in pairs(map.mObjLayout) do
        createMapObj(v)
    end
end

function goMap(mapNumber) --command builds a map based on information from the table mapNumber
    mapInit(mapNumber)
    --clear all menus, portraits, text, etc
end

--Object Functions

