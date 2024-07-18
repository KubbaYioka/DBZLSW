import 'CoreLibs/graphics'
import 'CoreLibs/sprites'

local tlp = playdate.graphics.tilemap
local gfx = playdate.graphics
local GRID_SIZE = 16 -- size of all grid tiles.

-- Wall Class (if needed)
Wall = {}
Wall.__index = Wall

-- PlayerMSprite Class
class('PlayerMSprite').extends(AnimatedSprite)

function PlayerMSprite:init(image)
    local pTable = gfx.imagetable.new(image)
    PlayerMSprite.super.init(self, pTable)
    self:setCenter(0, 0)

    -- Define sprite states
    self:addState("down", 1, 2, {tickStep = 12})
    self:addState("up", 5, 6, {tickStep = 12})
    self:addState("left", 7, 8, {tickStep = 12})
    self:addState("right", 3, 4, {tickStep = 12})
    self:playAnimation()

    -- Properties
    self:setCollideRect(0, 0, self:getSize())
    self:collisionsEnabled()
    self:changeState("down", true)
    self:setZIndex(50)
    self:add()
end

-- ObjectSprite Class
class('ObjectSprite').extends(AnimatedSprite)

function ObjectSprite:init(image)
    local oTable = gfx.imagetable.new(image)
    ObjectSprite.super.init(self, oTable)
    self:setCenter(0, 0)

    -- Define sprite states based on the number of tiles
    local tileNum = oTable:getLength()
    if tileNum == 1 then
        self:addState("down", 1)
    elseif tileNum == 2 then
        self:addState("down", 1, 2, {tickStep = 12})
    elseif tileNum == 3 then
        self:addState("down", 1, 3, {tickStep = 12})
    elseif tileNum == 4 then
        self:addState("down", 1, 4, {tickStep = 12})
    end
    self:playAnimation()

    -- Properties
    self:setCollideRect(0, 0, self:getSize())
    self:collisionsEnabled()
    self:setZIndex(50)
    self:add()
end

function createMapObj(table, visSkip)
    local visCheck = nil
    for k, w in pairs(table.properties or {}) do
        if k == "oVisible" then
            visCheck = w
        end
    end
    if visCheck == true or visSkip == true then
        local obj = table.sprite
        local tempObj = ObjectSprite(obj)
        tempObj.properties = table.properties
        tempObj.tag = table.tag

        tempObj:moveTo(GRID_SIZE * table.x, GRID_SIZE * table.y)
        local tempIndexNum = table.properties.name or "none"
        mapObjIndex[tempIndexNum] = tempObj
    end
end

function PlayerMSprite:handleInput(button)
    if gameMode == GameMode.MAP then
        if not self.isMovingY and not self.isMovingX then
            if button == "left" and sprObjChk("left", self.x, self.y) == 0 then
                self.targetX = self.x - GRID_SIZE
                self.isMovingX = true
            elseif button == "right" and sprObjChk("right", self.x, self.y) == 0 then
                self.targetX = self.x + GRID_SIZE
                self.isMovingX = true
            elseif button == "up" and sprObjChk("up", self.x, self.y) == 0 then
                self.targetY = self.y - GRID_SIZE
                self.isMovingY = true
            elseif button == "down" and sprObjChk("down", self.x, self.y) == 0 then
                self.targetY = self.y + GRID_SIZE
                self.isMovingY = true
            elseif button == "a" then
                local dirChk = self.currentState
                sprObjChk(dirChk, self.x, self.y, true)
            end

            if button ~= "a" then
                self:changeState(button)
            end
        end

        -- Move with collisions
        local actualX, actualY, collisions, collisionsLen = self:moveWithCollisions(self.x, self.y)
        if collisionsLen ~= 0 then
            local overlappingSprites = gfx.sprite.allOverlappingSprites()
            -- Handle collisions if needed
        end
    end
end

function sprObjChk(direction, xOrig, yOrig, obj)
    local xDir, yDir
    if direction == "down" then
        xDir = xOrig + 8
        yDir = yOrig + 24
    elseif direction == "up" then
        xDir = xOrig + 8
        yDir = yOrig - 8
    elseif direction == "right" then
        xDir = xOrig + 24
        yDir = yOrig + 8
    elseif direction == "left" then
        xDir = xOrig - 8
        yDir = yOrig + 8
    end
    local query = gfx.sprite.querySpritesAtPoint(xDir, yDir)
    if obj then
        queryObject(xDir, yDir, query)
    else
        return #query
    end
end

function queryObject(xPos, yPos, qryObj)
    local qryTag
    for _, sprite in ipairs(qryObj) do
        if sprite.tag == "object" then
            ctrlConSwi("story")
            dialogueBox:new("mapDialogue", qryObj)
            return
        end
    end
end

function PlayerMSprite:updatePosition()
    if self.isMovingX then
        if self.x < self.targetX then
            self:moveTo(self.x + 1, self.y)
        elseif self.x > self.targetX then
            self:moveTo(self.x - 1, self.y)
        end
        if self.x == self.targetX then
            self.isMovingX = false
        end
    end

    if self.isMovingY then
        if self.y < self.targetY then
            self:moveTo(self.x, self.y + 1)
        elseif self.y > self.targetY then
            self:moveTo(self.x, self.y - 1)
        end
        if self.y == self.targetY then
            self.isMovingY = false
        end
    end
end

-- Map Initialization and Management
local currentMapImage = nil
local currentMap = nil
local currentPlrSprite = nil
GlobalCurrentMapRef = nil

function mapInit(map)
    GlobalCurrentMapRef = map
    currentMapImage = gfx.imagetable.new(map.tileSet)
    currentMap = gfx.tilemap.new()
    currentMap:setImageTable(currentMapImage)
    currentMap:setSize(map.mapWidth, map.mapHeight) -- size in tiles
    currentMap:setTiles(map.mLayout, map.mapWidth)
    
    local mapSprite = gfx.sprite.new()
    mapSprite:setTilemap(currentMap)
    mapSprite.addWallSprites(currentMap, map.mEmptyIds)
    mapSprite:moveTo(0, 0)
    mapSprite:setCenter(0, 0)
    mapSprite:setZIndex(1)
    mapSprite:add()

    -- Create player sprite
    pMapSprite = PlayerMSprite(map.mapChr)
    pMapSprite:moveTo(map.chrX, map.chrY)
    pMapSprite.targetX = pMapSprite.x
    pMapSprite.targetY = pMapSprite.y
    pMapSprite.isMovingX = false
    pMapSprite.isMovingY = false
    pMapSprite.hasContext = true
    pMapSprite.facing = "down"

    for _, v in pairs(map.mObjLayout) do
        createMapObj(v)
    end
end

function goMap(mapNumber)
    mapInit(mapNumber)
end

-- Object Functions
function mObjAppear(objName, task)
    if task then
        for i, v in pairs(GlobalCurrentMapRef.mObjLayout) do
            if i == objName then
                createMapObj(v, true)
                return
            end
        end
    else
        for i, v in pairs(mapObjIndex) do
            if i == objName then
                v:remove()
                mapObjIndex[i] = nil
                return
            end
        end
    end
end

function mNextText(objName, iterNum)
    for _, v in pairs(mapObjIndex) do
        if v.tag == "object" and v.properties.name == objName then
            v.properties.txtIter = iterNum
            return
        end
    end
end

function cCardAdd(addCard)
    local cNA = cardRet(addCard)
    local cCTable = RAMSAVE[2]
    if cCTable[cNA.cNumber] == 0 then
        cNA.cQuantity = 1
        cNA.cAvailable = 1
        cCTable[cNA.cNumber] = cNA
    else
        cCTable[cNA.cNumber].cQuantity = cCTable[cNA.cNumber].cQuantity + 1
        cCTable[cNA.cNumber].cAvailable = cCTable[cNA.cNumber].cAvailable + 1
    end
    RAMSAVE[2] = cCTable
end
