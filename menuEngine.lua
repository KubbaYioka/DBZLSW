--Contains functions for menu rendering and modes
local gfx = playdate.graphics

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
        statusList:new()
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

statusList = playdate.ui.gridview.new(0,25)

statusList.backgroundImage = gfx.nineSlice.new("assets/images/textBorder",10,10,16,16)

function statusList:new()
    local o = o or {}
    setmetatable(o,self)
    self.__index=self

    o:setCellPadding(0,0,0,0)
    o:setContentInset(5,5,7,7)

    o.bSpr = true
    local menuBSpr = MenuBackground(0,0,"menuTwo")
    menuBSpr:add()

    local menuX = 0 --size of background box and position to be set later
    local menuY = 0
    local yPos = 0
    local xPos = 0

    local oFat = loadSavedPlayers("all")
    o.listRows = {}
    o.menuNumberBox = {}
    o:setNumberOfColumns(1)
    o:setNumberOfRows(#oFat)

    for i,v in pairs(oFat) do
        if type(v) == "table" and i == v.chrNum then
            o.listRows[v.chrNum] = v.chrName
        else
            o.listRows[i] = "None "..tostring(i)
        end
        o.menuNumberBox[i] = tostring(i)
    end

    xPos, yPos = menuPosition(menuPosEnum.menuPosDyna)
    menuY = (140)
    menuX = (100)

    function o:getOption() -- item selection in menu
        local s = o:getSelectedRow()
        for i,v in pairs(o.listRows) do
            if s==i then
                return v
            end
        end
    end

    function o:createNumberBox(nX,nY,numberIndex)
        local numberIndexStr = tostring(numberIndex)
        numberBox:new(nX,nY,numberIndexStr)
    end

    function o:clearNumberBox()
        if #numberBoxIndex > 0 then
            for i,v in pairs(numberBoxIndex) do
                v.spriteKill()
                numberBoxIndex[i] = nil
            end
        end  
    end

    local statusListSprite = gfx.sprite.new()
    statusListSprite:setCenter(0,0)

    function o:spriteKill()
        statusListSprite:remove()
    end


    
    statusListSprite:add()
    

    function o:menuUpdate()
        if o.needsDisplay then
            local statusListImage = gfx.image.new(menuX,menuY,gfx.kColorWhite)
            statusListSprite:moveTo(xPos,yPos)
            
            local zInNew = 130
            zInNew = zInNew + #menuIndex -- newest menu will always be drawn on top
            statusListSprite:setZIndex(zInNew)

            gfx.pushContext(statusListImage)
                o:drawInRect(0,0,menuX,menuY)
            gfx.popContext()
            statusListSprite:setImage(statusListImage)
            print("drawing Menu")
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)
        if selected then
            gfx.drawRect(x,y,width+2,height+2)
            gfx.drawRect(x,y,width,height)
        else
            gfx.drawRect(x,y,width,height)
        end

        local fontHeight = gfx.getSystemFont():getHeight()

        gfx.drawTextInRect(o.listRows[row], x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, truncationString, kTextAlignment.left)
        --o:createNumberBox(x,y,i)

    end

    function o:menuControl(direction) 
        if direction == "up" then
            o:selectPreviousRow(true,true,true)

        elseif direction == "down" then
            o:selectNextRow(true,true,true)

        elseif direction == "right" then
            printTable(o.menuText)
        elseif direction == "left" then 
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

dynaList = playdate.ui.gridview.new(0,25)

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

    local menuX = 0 --size of background box and position to be set later
    local menuY = 0
    local yPos = 0
    local xPos = 0

    o:setCellPadding(0,0,0,0)
    o:setContentInset(5,5,7,7)

    o.listRows = {}
    if mode == nestedMode.STATUS then
    local oFat = loadSavedPlayers("all")
    o.menuNumberBox = {} -- table for chr numbers according to their place in the table for the numberbox object
    o:setNumberOfColumns(1) 
    o:setNumberOfRows(#oFat)

    for i,v in pairs(oFat) do
        if type(v) == "table" and i == v.chrNum then
            o.listRows[v.chrNum] = v.chrName
        else
            o.listRows[i] = "None "..tostring(i)
        end
        o.menuNumberBox[i] = tostring(i)
    end
    
    xPos, yPos = menuPosition(menuPosEnum.menuPosDyna)
    menuY = (140)
    menuX = (100)

    elseif mode == nestedMode.LIST then
        -- display all cards in inventory
        o.hasColumns = true
        xPos, yPos = menuPosition(menuPosEnum.menuPosDyna)
        menuY = (6 * 25) + 10
        menuX = (100)
    elseif mode == nestedMode.DECK then
        -- display all cards in the deck
        o.hasColumns = true
        xPos, yPos = menuPosition(menuPosEnum.menuPosDyna)
        menuY = (6 * 25) + 10
        menuX = (100)
    elseif mode == nestedMode.TEAM then
        -- display all characters in the team
        xPos, yPos = menuPosition(menuPosEnum.menuPosDyna)
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

    function o:createNumberBox(nX,nY,numberIndex)
        local numberIndexStr = tostring(numberIndex)
        numberBox:new(nX,nY,numberIndexStr)
    end

    function o:clearNumberBox()
        if #numberBoxIndex > 0 then
            for i,v in pairs(numberBoxIndex) do
                v.spriteKill()
                numberBoxIndex[i] = nil
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
        if selected then
            gfx.drawRect(x,y,width+2,height+2)
            gfx.drawRect(x,y,width,height)
        else
            gfx.drawRect(x,y,width,height)
        end

        local fontHeight = gfx.getSystemFont():getHeight()

        if mode == nestedMode.STATUS then
            gfx.drawTextInRect(o.listRows[row], x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, truncationString, kTextAlignment.left)
            --o:createNumberBox(x,y,i)

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
            o:selectPreviousRow(true,true,true)
        elseif direction == "down" then
            o:selectNextRow(true,true,true)
        elseif direction == "right" then
            printTable(o.menuText)
        elseif direction == "left" then 
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

numberBox = playdate.ui.gridview.new(0,0)

function numberBox:new(bX,bY,listNum)
    local o = o or {}
    setmetatable(o,self)
    self.__index=self
    numberBox:setNumberOfColumns(1)
    numberBox:setNumberOfRows(5)
    numberBox:setCellPadding(0,0,0,0)
    numberBox:setContentInset(0,0,0,0)

    o.numBoxSprite = gfx.sprite.new()
    o.numBoxSprite:setCenter(0, 0)
    o.rowNum = listNum -- is a string
    o.xPos = bX
    o.yPos = bY
    --print(o.rowNum.." at: ("..bX..", "..bY..")")
    function o:spriteKill()
        o.numBoxSprite:remove()
    end
    
    o.numBoxSprite:setZIndex(145)
    o.numBoxSprite:moveTo(bX, bY)
    o.numBoxSprite:add()

    function o:menuUpdate()
        if o.needsDisplay then
            local boxImage = gfx.image.new(20,20,gfx.kColorBlack)
            o:setCellSize(20, 20)
            gfx.pushContext(boxImage)
            o:drawInRect(0,0,20,20)
            gfx.popContext()
            o.numBoxSprite:setImage(boxImage)
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)
        gfx.drawRect(o.xPos,o.yPos,width,height)
        local fontHeight = gfx.getSystemFont():getHeight()
        gfx.drawTextInRect(o.rowNum, o.xPos+2, o.yPos + (height/2 - fontHeight/2) + 2, width, height, nil, truncationString, kTextAlignment.left)
    end

    local countI = 0
    for _ in pairs(numberBoxIndex) do 
        countI = countI + 1 
    end

    o.index = countI + 1
    numberBoxIndex[o.index] = o
    return o
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