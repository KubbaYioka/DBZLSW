local tlp = playdate.graphics.tilemap
local gfx = playdate.graphics
local GRID_SIZE = 16 -- size of all grid tiles. 

class('Wall')

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
    local sX, sY = self:getSize()
    self:setCollideRect( 0, 0, self:getSize() )
    self:collisionsEnabled()
    self:changeState("down",true)
    self:setZIndex(100)
    --self:setCollideRect()
    self:add()
end

class('ObjectSprite').extends(AnimatedSprite)

function createMapObj(table)
    
    local obj = table.sprite
    print("table.sprite "..obj)
    local tempObj = ObjectSprite(obj)
    tempObj:moveTo(GRID_SIZE*table.x,GRID_SIZE*table.y)
end
function ObjectSprite:init(image)
    local oTable = gfx.imagetable.new(image)
    ObjectSprite.super.init(self,oTable)
    printTable(oTable)

    -- define sprite states
    local tileNum = oTable:getLength()
    print("number of tiles: ")
    if tileNum == 1 then
        print("1")
        self:addState("down",1)
    elseif tileNum == 2 then
        print("2")
    elseif tileNum == 3 then
        print("3")
    elseif tileNum == 4 then
        print("4")
    end
    self:playAnimation()
    --Other Properties
    self:changeState("down",true)
    self:setZIndex(100)
    self:setCollideRect( 0, 0, self:getSize() )
    self:collisionsEnabled()
    self:add()
end

function PlayerMSprite:handleInput(button)
    if gameMode == GameMode.MAP then
        local nextX = self.x
        local nextY = self.y
        print(self.x..self.y)

        if button == "left" then
            self.targetX = self.x - GRID_SIZE
            self.isMovingX = true
        elseif button == "right" then
            self.targetX = self.x + GRID_SIZE
            self.isMovingX = true
        elseif button == "up" then
            self.targetY = self.y - GRID_SIZE
            self.isMovingY = true
        elseif button == "down" then
            self.targetY = self.y + GRID_SIZE
            self.isMovingY = true
        end
        self:changeState(button)

        -- Check if the destination tile is passable
        local actualX, actualY, collisions, collisionsLen = self:moveWithCollisions(self.x,self.y)
        if collisionsLen ~= 0 then
            local pee = playdate.graphics.sprite.allOverlappingSprites()
            print(pee)
            printTable(pee)
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
    mapSprite.addWallSprites(currentMap,map.mEmptyIds)
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

