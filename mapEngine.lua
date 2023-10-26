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
    self:setZIndex(100)
    self:add()
end

class('ObjectSprite').extends(AnimatedSprite)

function createMapObj(table)
    
    local obj = table.sprite
    
    local tempObj = ObjectSprite(obj)
    tempObj.tag = table.tag
    if table.text then
        tempObj.text = table.text
    end
    tempObj:moveTo(GRID_SIZE*table.x,GRID_SIZE*table.y)
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

    function killObj(self)
        gfx.sprite.removeSprite(self)
    end

    --Other Properties
    self:changeState("down",true)
    self:setZIndex(100)
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
                    print("Tag is Object.")
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
--[[
mapDiag = playdate.ui.gridview.new(0,20)
function mapDiag:new(gType,name) -- creates grid object based on parameters passed to it
    -- types can be: dialogue, twoChoices, menu
        local o = o or {}
        setmetatable(o,self)
        self.__index=self
        o.type = gType
    
        local menuX = 0 -- controls width of background box
        local menuY = 0 -- controls height of background box
        local xPos = 0
        local yPos = 0
    
        if o.type == "menu" or o.type == "twoChoices" then
            --options in menu list and menu orientation dependent on name variable
            -- so like if name == y then o.options = option table 1, etc
            o.options = {}
            o.options = name
    
            gridview:setNumberOfColumns(1)
            gridview:setNumberOfRows(#o.options)
            menuY = (#o.options * 25) + 10
            menuX = (100)
            xPos, yPos = menuPosition(name)
            --display menu
            
            function o:getOption() -- item selection in menu
                local s = o:getSelectedRow()
                for i,v in pairs(o.options) do
                    if s==i then
                        return v
                    end
                end
            end
    
        elseif o.type == "dialogue" or o.type == "mapDialogue" then
            menuY = (80)
            menuX = (400)
            o:setNumberOfRows(rows or 1)
            o:setNumberOfColumns(columns or 1)
            
            o.location = name
            o.key = 1
            o.cText = "none"
    
            function o:text()
                local qryText = nil
                if o.type == "mapDialogue" then
                    for i,v in pairs(o.location) do
                        if v then
                            for j,w in pairs(v) do
                                if j=="text" then
                                    qryText=w
                                end
                            end
                        end
                    end
                    if #qryText >= o.key then
                        print("trigOne")
                        while type(qryText[o.key]) ~= "string" do
                            if type(qryText[o.key]) == "function" then
                                qryText[o.key]()
                            end
                            o.key = o.key + 1
                        end
                        o.cText = qryText[o.key]
                        o.key = o.key + 1
                    elseif #qryText < o.key then
                        o:spriteKill()
                        menuIndex = {}
                        clearMenus()
                        ctrlConSwi("off")
                        return
                    end
                
                elseif o.type == "dialogue" then
                    for i,v in pairs(stories) do
                        if o.location == i then
                            while type(v[o.key]) ~= "string" do -- do something else with other triggers that might be for graphics or changes in scenery\characters
                                if type(v[o.key]) == "function" then
                                    v[o.key]()
                                end
                                o.key = o.key + 1
                            end
                            o.cText = v[o.key]
                            o.key = o.key + 1
                        end
                    end
                end
            end
        else
            print("Error in o.type")
        end
    
        local gridviewSprite = gfx.sprite.new()
        gridviewSprite:setCenter(0, 0)
    
        function o:spriteKill()
            gridviewSprite:remove()
        end
    
        gridviewSprite:add()
    
        function o:menuUpdate()
            if o.needsDisplay then
                local gridviewImage = gfx.image.new(menuX,menuY,gfx.kColorWhite)
                if o.type == "menu" or o.type == "twoChoices" then
                    if o.type == "menu" then
                        gridviewSprite:moveTo(xPos, yPos) -- same location as where the grid is drawn
                        gridviewSprite:setZIndex(130)
                    elseif o.type == "twoChoices" then
                        gridviewSprite:moveTo(100, 100)
                    end
                elseif o.type == "dialogue" or o.type == "mapDialogue" then
    
                    gridviewSprite:setZIndex(130)
                    gridviewSprite:moveTo(0,160)
                    o:setContentInset(5,20,0,0)
                    o:setCellSize(380, 50)
                end
    
                gfx.pushContext(gridviewImage)
                if o.type=="mapDialogue" then 
                    print("trigTwo")
                    print(gridviewImage)
                end
                o:drawInRect(0,0,menuX,menuY)
                gfx.popContext()
                gridviewSprite:setImage(gridviewImage)
            end
        end
    
        function o:drawCell(section,row,column,selected,x,y,width,height)
            local menuText={}
            if o.type == "menu" then
                if selected then
                    gfx.drawRect(x,y,width+2,height+2)
                    gfx.drawRect(x,y,width,height)
                else
                    gfx.drawRect(x,y,width,height)
                end
                menuText = o.options
    
            else-- for dialogue, etc
                menuText[1] = o.cText
            end
    
            local fontHeight = gfx.getSystemFont():getHeight()
            local rCount = row
    
            for i,v in pairs(menuText) do
                if rCount == i then
                    gfx.drawTextInRect(v, x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, nil, kTextAlignment.left)
                end
            end
        end
    
        function o:menuControl(direction) 
            if o.type == "menu" or o.type == "twoChoices" then
                if direction == "up" then
                    o:selectPreviousRow(true)
                elseif direction == "down" then
                    o:selectNextRow(true)
                end
            elseif o.type == "dialogue" or o.type == "mapDialogue" then -- Iterates through all line items in a story.
                if direction == "a" then
                    o:text()
                    o:selectNextRow(true)
                end
            end
        end]]--