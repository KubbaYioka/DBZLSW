--Contains functions for menu rendering and modes
local gfx = playdate.graphics

function gridSprite(spriteType) -- sprite gen for menu\story
    local gridviewSprite = gfx.sprite.new()
    gridviewSprite:setCenter(0, 0)
    if spriteType == "menu" then
        gridviewSprite:moveTo(40, 40) -- same location as where the grid is drawn
    elseif spriteType == "story" then
        gridviewSprite:moveTo(0,180)
        gridview:setCellSize(240, 40)
    end
    gridviewSprite:add()
    return gridviewSprite
end

function gridviewRend()
    gridview = playdate.ui.gridview.new(0,20) -- initial gridview object 
    gridview:setNumberOfColumns(1)
    gridview:setNumberOfRows(1)
    gridview:setCellPadding(0,0,4,0)
    --Set Menu\Text Border 

    gridview.backgroundImage = gfx.nineSlice.new("assets/images/textBorder",10,10,16,16)
    gridview:setContentInset(5,5,5,5)
    return gridview
end

function gameModeChange(gMode, location, index)
    if gMode == GameMode.BATTLE then
        controlContext = GameMode.BATTLE
        --display vs and transition
    elseif gMode == GameMode.MENU then
        controlContext = GameMode.MENU
        -- gridview etc etc
        -- load appropriate menu
    elseif gMode == GameMode.MAP then
        controlContext = GameMode.MAP
        clearAll()
        gfx.clear()
        goMap(location) -- loads map from appropriate dataset
    elseif gMode == GameMode.STORY then
        controlContext = GameMode.STORY
       -- gridview:new(name, rows, columns, options, index, mType)
        gridview:new(gMode, location)
        -- load appropriate story
    end
    gameMode = gMode
end

function clearMenus(typ)
    for k,v in pairs(menuIndex) do
        menuIndex[k] = nil
    end
    menuIndex = {}
    gfx.sprite.removeAll()
    gfx.setDrawOffset(0, 0)
end

function clearPauseMenu()
    for i,v in pairs(menuIndex) do
        v.spriteKill()
        menuIndex[i]=nil
        ctrlConSwi("off")
        bounceProtectSwi("on")
    end
    for i,v in pairs(otherIndex) do
        if v.menuObj then
            otherIndex.v = nil
            v:remove()
        end
    end
end

function clearSprites()
    spriteIndex = {}
    gfx.sprite.removeAll()
    gfx.setDrawOffset(0, 0)
end

function clearPorts()

    for k,v in pairs(portIndex) do
        portIndex[k] = nil
    end
    portIndex = {}
    gfx.sprite.removeAll()
    gfx.setDrawOffset(0, 0)
end

function clearTags()

    for k,v in pairs(tagIndex) do
        tagIndex[k] = nil
    end
    tagIndex = {}
    gfx.sprite.removeAll()
    gfx.setDrawOffset(0, 0)
end

function clearAll()
    clearTags()
    clearPorts()
    clearMenus()
    clearSprites()
end

function debugMessage()
    print("Function not yet implemented.")
end

local menuFunc = {
    ["Continue"] = function()
        clearMenus()
        local nMode, loc = gameContinue()
        gameModeChange(nMode, loc)
    end,
    ["New Game"] = function()
        clearMenus()
        local nMode, loc = gameContinue()
        gameModeChange(nMode, loc) 
    end,
    ["Options"] = function()
        debugMessage()
    end,
    ["Battle"] = function()
        debugMessage()
    end,
    ["Status"] = function()
        dynaList:new(nestedMode.STATUS)
        createMenuIcon(nestedMode.STATUS)
    end,
        ["nameHere"] = function()
            clearPauseMenu()
        end,
    ["Deck"] = function()
        debugMessage()
        createMenuIcon(nestedMode.DECK)
    end,
    ["Team"] = function()
        debugMessage()
        createMenuIcon(nestedMode.TEAM)
    end,
    ["List"] = function()
        debugMessage()
        createMenuIcon(nestedMode.LIST)
    end,
    ["Save"] = function()
        debugMessage()
    end,
    ["Exit"] = function()
        clearPauseMenu()
    end,
    ["eof"] = 0
    -- Add more menu items and their corresponding functions here
}

function goMenu(item)
    -- Check if the selected item has a corresponding function and call it
    if menuFunc[item] then
        menuFunc[item]()
    elseif not menuFunc[item] then
        local oFat = loadSavedPlayers("all")
        for i,v in pairs(oFat) do
            for k,c in pairs(v) do

                if c.chrName == item then
                    chrStat(c)
                end
            end
        end
        --do it again for cards
    else
        print("No action defined for menu item:", item)
    end
end

-- PAUSE MENU --

local dbFont = playdate.graphics.font.new('assets/fonts/DBLSW2')
playdate.graphics.setFont(dbFont) 

pauseView = playdate.ui.gridview.new(0,20)
pauseView:setNumberOfColumns(1)
pauseView:setNumberOfRows(1)
pauseView:setCellPadding(0,0,4,0)
pauseView:setContentInset(5,5,5,5)

--Set Menu\Text Border

pauseView.backgroundImage = gfx.nineSlice.new("assets/images/textBorder",10,10,16,16)

function pauseView:new()
    local o = o or {}
    setmetatable(o,self)
    self.__index=self

    local menuX = 0 --size of background box
    local menuY = 0
    local yPos = 0
    local xPos = 0

    o.pauseRows = {"Status","Deck","List","Save","Exit"}
    o.saveRows = {"Yes", "No"}
    if gameMode == GameMode.BATTLE then
        print("Placeholder")
        o.pauseRows = {"Status","Deck","Team","List","Save","Exit"}
    end

    pauseView:setNumberOfColumns(1)
    pauseView:setNumberOfRows(#o.pauseRows)
    menuY = (#o.pauseRows * 25) + 10
    menuX = (100)
    xPos, yPos = menuPosition(menuPause)

    function o:getOption() -- item selection in menu
        local s = o:getSelectedRow()
        for i,v in pairs(o.pauseRows) do
            if s==i then
                return v
            end
        end
    end

    local pauseViewSprite = gfx.sprite.new()
    pauseViewSprite:setCenter(0,0)
    function o:spriteKill()
        pauseViewSprite:remove()
    end

    pauseViewSprite:add()

    function o:menuUpdate()
        if o.needsDisplay then
            local pauseViewImage = gfx.image.new(menuX,menuY,gfx.kColorWhite)
            pauseViewSprite:moveTo(xPos,yPos)
            pauseViewSprite:setZIndex(130)
            gfx.pushContext(pauseViewImage)
            o:drawInRect(0,0,menuX,menuY)
            gfx.popContext()
            pauseViewSprite:setImage(pauseViewImage)
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)
        local menuText = {}
        if selected then
            gfx.drawRect(x,y,width+2,height+2)
            gfx.drawRect(x,y,width,height)
        else
            gfx.drawRect(x,y,width,height)
        end
        menuText = o.pauseRows
        local fontHeight = gfx.getSystemFont():getHeight()
        local rCount = row
        for i,v in pairs(menuText) do
            if rCount == i then
                gfx.drawTextInRect(v, x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, truncationString, kTextAlignment.left)
            end
        end
    end

    function o:menuControl(direction) 

        if direction == "up" then
            o:selectPreviousRow(true)
        elseif direction == "down" then
            o:selectNextRow(true)
        elseif direction == "b" then
            o:spriteKill()
            menuIndex[o.index] = nil
            clearPauseMenu()
        end
    end

    local countI = 0
    for _ in pairs(menuIndex) do 
        countI = countI + 1 
    end

    o.index = countI + 1
    menuIndex[o.index] = o
    return o
end
  
function pauseMenu()
    ctrlConSwi("pause")
    local menuBSpr = MenuBackground(0,0,"menuOne")
    menuBSpr:add()
    pauseView:new()
end

dynaList = playdate.ui.gridview.new(0,20)

dynaList.backgroundImage = gfx.nineSlice.new("assets/images/textBorder",10,10,16,16)

nestedMode = {
    STATUS = "status"
    ,LIST = "list"
    ,DECK = "deck"
    ,TEAM = "team"
    ,CHAR = "character"
    ,CARD = "card"
}

function dynaList:new(mode,tableData)
    local o = o or {}
    setmetatable(o,self)
    self.__index=self

    o.mMode = mode

    if mode == nestedMode.STATUS or mode == nestedMode.DECK or mode == nestedMode.LIST or mode == nestedMode.TEAM then
        o.bSpr = true
        local menuBSpr = MenuBackground(0,0,"menuTwo")
        menuBSpr:add()
    end

    local menuX = 0 --size of background box
    local menuY = 0
    local yPos = 0
    local xPos = 0

    o:setCellPadding(0,0,5,5)
    o:setContentInset(5,5,5,5)

    o.listRows = {}
    if mode == nestedMode.STATUS then
        
    local oFat = loadSavedPlayers("all")
    o.chrRefNum = {} -- table for chr numbers according to their place in the table
    o:setNumberOfColumns(1)
    for i,v in pairs(oFat) do
        if type(v) == "table" and i == v.chrNum then
            o.listRows[v.chrNum] = v.chrName
        else
            o.listRows[i] = "None"
        end
        o.chrRefNum[i] = tostring(i)
    end
    
    xPos, yPos = menuPosition(menuPosEnum.menuPosDyna)
    menuY = (6 * 25) + 10
    menuX = (100)
   
    o:setNumberOfRows(5,5,5,5,5,5,5,5,5,5)
    o:setNumberOfSections(#o.listRows / 5)

    elseif mode == nestedMode.LIST then
        -- display all cards in inventory
        o.hasColumns = true
        xPos, yPos = menuPosition(menuPause)
        menuY = (6 * 25) + 10
        menuX = (100)
    elseif mode == nestedMode.DECK then
        -- display all cards in the deck
        o.hasColumns = true
        xPos, yPos = menuPosition(menuPause)
        menuY = (6 * 25) + 10
        menuX = (100)
    elseif mode == nestedMode.TEAM then
        -- display all characters in the team
        xPos, yPos = menuPosition(menuPause)
        menuY = (6 * 25) + 10
        menuX = (100)
    elseif mode == nestedMode.CHAR then
        -- display character info from save
        local hp = nil
        local str = nil
        local ki = nil
        local def = nil
        local spd = nil
        local exp = nil
        local trans = {}
        for i,v in pairs(tableData) do
            if i == "chrHp" then
                hp = tostring(v)
            end
            if i == "chrStr" then
                str = tostring(v)
            end
            if i == "chrKi" then
                ki = tostring(v)                
            end
            if i == "chrDef" then
                def = tostring(v)
            end
            if i == "chrSpd" then
                spd = tostring(v)
            end
            if i == "chrExp" then
                exp = tostring(v)
            end
            if i == "chrTrans" then
                if v[1] == "none" then
                    trans = "none"
                else
                    trans = v
                end
            end
        end
        o.listRows = {hp,str,ki,def,spd,exp,trans}
        o.category = {"HP","Strength","KI","Defense","Speed","EXP","Transformations"}
        xPos, yPos = menuPosition(menuPosEnum.menuPosChr)
        menuY = (#o.listRows * 25) + 10
        menuX = (200)
        o:setNumberOfColumns(1)
        o:setNumberOfRows(#o.listRows)
            
    elseif mode == nestedMode.CARD then
        --display card info from save
        menuY = (6 * 25) + 10
        menuX = (100)
    else
        print("Mode not recognized in menuEngine, dynaList.")
        return
    end

    function o:getOption() -- item selection in menu
        local s = o:getSelectedRow()
        for i,v in pairs(o.listRows) do
            if s==i then
                return v
            end
        end
    end

    function o:selSection(dir)
        local gSec, gRow, gCol = o:getSelection()
        gSec, gRow, gCol = o:getSelection()
        print("row: ",gRow)
        if mode == nestedMode.STATUS then
            if dir == "next" or dir =="prev" then
                print("Leaving Section: ",gSec)
                if dir == "next" then
                    if gSec == 10 then
                        gSec = 1
                        print("gSec round to 1")
                    else
                        gSec = gSec + 1

                    end
                elseif dir == "prev" then
                    if gSec == 1 then
                        gSec = 10

                    else
                        gSec = gSec - 1

                    end
                end
                print("Section: ",gSec)
                o:setSelection(gSec, 1, 1)
                o:scrollToCell(gSec, 1, 1, false)
                
                print("Entering Section: ",gSec)
            elseif dir == "rowNext" or dir == "rowPrev" then
                if dir == "rowNext" then
                    if o:getSelectedRow() == 5 then
                        gSec = gSec + 1
                        if gSec > 10 then
                            gSec = 1
                        end
                        gRow = 1
                        o:setSelection(gSec, gRow, 1)
                        o:scrollToCell(gSec, gRow, 1, false)
                    else
                        o:selectNextRow(false, false, false)
                        
                        return
                    end
                elseif dir == "rowPrev" then
                    if gRow == 1 then
                        gSec = gSec - 1
                        if gSec < 1 then
                            gSec = 10
                        end
                        gRow = 5
                        o:setSelection(gSec, gRow, 1)
                        o:scrollToCell(gSec, gRow, 1, false)
                    else
                        o:selectPreviousRow(false, false, false)
                        return
                    end
                end
                print("row scrolling")
                
                
            end
        else
            if dir == "rowNext" then
                o:selectNextRow(true)
            elseif dir == "rowPrev" then
                o:selectPreviousRow(true)
            end
        end

    end

    local dynaListSprite = gfx.sprite.new()
    dynaListSprite:setCenter(0,0)
    function o:spriteKill()
        dynaListSprite:remove()
    end

    local zInNew = 130
    zInNew = zInNew + #menuIndex -- newest menu will always be drawn on top
    dynaListSprite:setZIndex(zInNew)
    dynaListSprite:add()

    function o:menuUpdate()
        if o.needsDisplay then
            local dynaListImage = gfx.image.new(menuX,menuY,gfx.kColorWhite)
            dynaListSprite:moveTo(xPos,yPos)
            gfx.pushContext(dynaListImage)
            o:drawInRect(0,0,menuX,menuY)
            gfx.popContext()
            dynaListSprite:setImage(dynaListImage)
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)
        o.menuText = {}
        if selected then
            gfx.drawRect(x,y,width+2,height+2)
            gfx.drawRect(x,y,width,height)
        else
            gfx.drawRect(x,y,width,height)
        end
        local fontHeight = gfx.getSystemFont():getHeight()

        if mode == nestedMode.STATUS then

            o.menuText = {}
            local sect = section -- variable that will be between 1 and 10
            
            -- Calculate the starting and ending indices for the slice of o.listRows
            local startIndex = (sect - 1) * 5 + 1
            local endIndex = sect * 5
            
            -- Iterate over o.listRows and insert the relevant slice into o.menuText
            for i = startIndex, endIndex do
                if o.listRows[i] then  -- Check if the element exists
                    table.insert(o.menuText, o.listRows[i])
                end
            end

            for i,v in pairs(o.menuText) do
                if i == row then
                    gfx.drawTextInRect(v, x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, truncationString, kTextAlignment.left)
                end
            end

        elseif mode == nestedMode.CHAR then
            o.menuText = o.listRows
            local fEnum = nil
            local cb = nil
            for i,v in pairs(o.listRows) do
                if i==rCount then
                    if type(v) == "table" then
                        cb = tostring(#v)
                    end
                    for k,b in pairs (o.category) do
                        if k==rCount then
                            fEnum = b..": "..v
                        end
                    end
                    gfx.drawTextInRect(fEnum, x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, truncationString, kTextAlignment.left)
                end
            end
        end
    end

    function o:menuControl(direction) 
        if direction == "up" then
            o:selSection("rowPrev")
        elseif direction == "down" then
            o:selSection("rowNext")
        elseif direction == "right" then
            o:selSection("next")
            printTable(o.menuText)
        elseif direction == "left" then 
            o:selSection("prev")
            printTable(o.menuText)
        elseif direction == "b" then
            if o.bSpr == true then
                for i,v in pairs(otherIndex) do
                    if v.menuWhi then
                        otherIndex.v = nil
                        v:remove()
                    end
                end
            end
            for k, c in pairs(otherIndex) do
                if c.menuIcon then
                    otherIndex.c = nil
                    c:remove()
                end
            end
            o:spriteKill()
            menuIndex[o.index] = nil
        end
    end

    local countI = 0
    for _ in pairs(menuIndex) do 
        countI = countI + 1 
    end

    o.index = countI + 1
    menuIndex[o.index] = o
    return o
end

specialBox = playdate.ui.gridview.new(0,20)
specialBox:setNumberOfColumns(1)
specialBox:setNumberOfRows(1)
specialBox:setCellPadding(0,0,0,0)
specialBox:setContentInset(0,0,0,0)

-- A basic and configurable black box with text inside. 
function specialBox:new(x,y,w,h,text) -- text will be the result of a function
    local o = o or {}
    setmetatable(o,self)
    self.__index=self

end

class('MenuBackground').extends(gfx.sprite)

function MenuBackground:init(x,y,back)
    MenuBackground.super.init(self)
    if back == "menuOne" then
        local menuImage = gfx.image.new('assets/images/background/menu.png')
        self:setImage(menuImage)
        self.menuObj = 1
        self:setZIndex(60)
    elseif back == "menuTwo" then
        local menuImage = gfx.image.new('assets/images/background/400240.png')
        self:setImage(menuImage)
        self.menuWhi = 1
        self:setZIndex(131)
    end

    -- Properties
    self:setCenter(0,0)
    self:moveTo(x, y)
    local numberO = #otherIndex + 1
    otherIndex[numberO] = self
end

class('MenuIcon').extends(AnimatedSprite)

function MenuIcon:init(image)

    local oTable = gfx.imagetable.new(image)
    MenuIcon.super.init(self, oTable)

    -- Define sprite states
    self:addState("status",1,1)
    self:addState("team",2,2)
    self:addState("list",3,3)
    self:addState("deck",4,4)
    self:playAnimation()

    self.menuIcon = 1

    self.changeState("character")

    self:setCenter(0, 0)
    self:moveTo(320, 0)
    self:setZIndex(190)
    
    local numberO = #otherIndex + 1
    otherIndex[numberO] = self
    self:add()
end


function createMenuIcon(icon)
    local iconMenu = MenuIcon('assets/images/background/menuIcon-table-48-40')
    iconMenu:changeState(icon)
end

function chrStat(chr) -- Render character stat screen.
    dynaList:new(nestedMode.CHAR,chr)
end