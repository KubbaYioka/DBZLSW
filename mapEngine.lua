local tlp = playdate.graphics.tilemap
local gfx = playdate.graphics
local GRID_SIZE = 16 -- size of all grid tiles. 

class('Wall')

class('PlayerMSprite').extends(AnimatedSprite)

function PlayerMSprite:init(image)
    local pTable = gfx.imagetable.new(image)
    PlayerMSprite.super.init(self, pTable)
    self:setCenter(0, 0)

    -- Define sprite states
    self:addState("down",1,2,{tickStep = 12})
    self:addState("up",5,6,{tickStep = 12})
    self:addState("left",7,8,{tickStep = 12})
    self:addState("right",3,4,{tickStep = 12})
    self:playAnimation()

    -- Properties
    local sX, sY = self:getSize()
    self:setCollideRect( 0, 0, self:getSize())
    self:collisionsEnabled()
    self:changeState("down",true)
    self:setZIndex(50)
    self:add()
end

class('ObjectSprite').extends(AnimatedSprite)

function createMapObj(table,visSkip)
    local visCheck = nil
    for i,v in pairs(table) do
        if i == "properties" then
            for k,w in pairs(v) do
                if k == "oVisible" then
                    visCheck = w
                end
            end
        end
    end
    if visCheck == true or visSkip == true then
        local obj = table.sprite
        local tempObj = ObjectSprite(obj)
        tempObj.properties = table.properties
        tempObj.tag = table.tag

        tempObj:moveTo(GRID_SIZE*table.x,GRID_SIZE*table.y)
        local tempIndexNum = "none"
        for i,v in pairs(tempObj.properties) do
            if i == "name" then
                tempIndexNum = v
            end
        end
        mapObjIndex[tempIndexNum] = tempObj
    end
end

function ObjectSprite:init(image)
    local oTable = gfx.imagetable.new(image)
    ObjectSprite.super.init(self,oTable)
    self:setCenter(0, 0)

    -- define sprite states
    local tileNum = oTable:getLength()
    if tileNum == 1 then
        self:addState("down",1)
    elseif tileNum == 2 then
        self:addState("down",1)
    elseif tileNum == 3 then
        self:addState("down",1)
    elseif tileNum == 4 then
        self:addState("down",1)
    end
    self:playAnimation()

    function killObj()
        gfx.sprite.removeSprite(self)
    end
    
    --Other Properties
    self:changeState("down",true)
    self:setZIndex(50)
    self:setCollideRect( 0, 0, self:getSize() )
    self:collisionsEnabled()
    self:add()
end

function PlayerMSprite:handleInput(button)
    if gameMode == GameMode.MAP then


        if self.isMovingY == false and self.isMovingX == false then
            if button == "left" then
                if sprObjChk("left",self.x,self.y) == 0 then
                    self.targetX = self.x - GRID_SIZE
                    self.isMovingX = true
                end
            elseif button == "right" then
                if sprObjChk("right",self.x,self.y) == 0 then
                    self.targetX = self.x + GRID_SIZE
                    self.isMovingX = true
                end
            elseif button == "up" then
                if sprObjChk("up",self.x,self.y) == 0 then
                    self.targetY = self.y - GRID_SIZE
                    self.isMovingY = true
                end
            elseif button == "down" then
                if sprObjChk("down",self.x,self.y) == 0 then
                    self.targetY = self.y + GRID_SIZE
                    self.isMovingY = true
                end
            elseif button == "a" then
                local dirChk = self.currentState
                sprObjChk(dirChk,self.x,self.y,true)

            end
            if button ~= "a" then
                self:changeState(button)
            end
        end       

        -- Check if the destination tile is passable
        local actualX, actualY, collisions, collisionsLen = self:moveWithCollisions(self.x,self.y)
            if collisionsLen ~= 0 then
            local spriCol = playdate.graphics.sprite.allOverlappingSprites()
        end
    end
end

function sprObjChk(direction,xOrig,yOrig,obj)
    local xDir = 0
    local yDir = 0
    if direction == "down" then
        xDir = xOrig+8
        yDir = yOrig+24
    elseif direction == "up" then
        xDir = xOrig+8
        yDir = yOrig-8
    elseif direction == "right" then
        xDir = xOrig+24
        yDir = yOrig+8
    elseif direction == "left" then
        xDir = xOrig-8
        yDir = yOrig+8
    end
    local query = playdate.graphics.sprite.querySpritesAtPoint(xDir,yDir)
    if obj == true then
        queryObject(xDir,yDir,query)
    else
        local queryResult = #query
        return queryResult
    end
end

function queryObject(xPos,yPos,qryObj)
    local qryTag = nil
    for i,v in ipairs(qryObj) do
        if v then
            for j,w in pairs(v) do
                if j=="tag" then
                    qryTag=w
                end
            end
        end
    end
    if qryTag == "object" then
        ctrlConSwi("story")
        gridview:new("mapDialogue",qryObj)
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
local currentMap = nil
local currentPlrSprite = nil
GlobalCurrentMapRef = nil
function mapInit(map)
    GlobalCurrentMapRef = map
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
end

--Object Functions
function mObjAppear(objName,task) -- causes an object to be drawn and have a collision rect created or be removed.
    local tempTableO
    if task == true then
        for i,v in pairs(GlobalCurrentMapRef.mObjLayout) do
            if i == objName then
                tempTableO = GlobalCurrentMapRef.mObjLayout[objName]
                createMapObj(tempTableO,true)
            end
        end
    end
    if task == false then
        for i,v in pairs(mapObjIndex) do
            if objName == i then
                for j,k in pairs(gfx.sprite.getAllSprites()) do
                    if k.tag == "object" then
                        for l,m in pairs(k) do
                            if l == "properties" then
                                for n,p in pairs(m) do
                                    if p == objName then
                                        gfx.sprite:removeSprite(k)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function mNextText(objName,iterNum) -- causes an object's next text field to be read by o:text by iterating its text number or changing it entirely.
    local nameFound = false
    for i,v in pairs(mapObjIndex) do
        if v.tag == "object" then
            for j,k in pairs(v.properties) do
                if k == objName then
                    nameFound = true
                end
            end
            if nameFound == true then
                for h,l in pairs(v.properties) do
                    if h == "txtIter" then
                        v.properties[h] = iterNum
                    end
                end
            end
        end
    end
end

function cCardAdd(addCard) -- function to add a card to the player's list
    local cNA = cardRet(addCard)
    local cCTable = RAMSAVE[2]
    if cCTable[cNA.cNumber] == 0 then -- adds a card to the slot and populates card info
        cNA.cQuantity = 1
        cCTable[cNA.cNumber] = cNA
    else --if the player already has one or more cards of this type, an additional card is added to the available quantity
        cCTable[cNA.cNumber].cQuantity = cCTable[cNA.cNumber].cQuantity + 1
    end
    RAMSAVE[2] = cCTable
end