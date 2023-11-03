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

function gameModeChange(mode, location, index)
    if mode == GameMode.BATTLE then
        controlContext = GameMode.BATTLE
        --display vs and transition
    elseif mode == GameMode.MENU then
        controlContext = GameMode.MENU
        -- gridview etc etc
        -- load appropriate menu
    elseif mode == GameMode.MAP then
        controlContext = GameMode.MAP
        clearAll()
        gfx.clear()
        goMap(location) -- loads map from appropriate dataset
    elseif mode == GameMode.STORY then
        controlContext = GameMode.STORY
       -- gridview:new(name, rows, columns, options, index, mType)
        gridview:new(mode, location)
        -- load appropriate story
    end
    gameMode = mode
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
        local mode, loc = gameContinue()
        gameModeChange(mode, loc)
    end,
    ["New Game"] = function()
        clearMenus()
        local mode, loc = gameContinue()
        gameModeChange(mode, loc) 
    end,
    ["Options"] = function()
        debugMessage()
    end,
    ["Battle"] = function()
        debugMessage()
    end,
    ["Status"] = function()
        dynaList:new(nestedMode.STATUS)
    end,
        ["nameHere"] = function()
            clearPauseMenu()
        end,
    ["Deck"] = function()
        debugMessage()
    end,
    ["Team"] = function()
        debugMessage()
    end,
    ["List"] = function()
        debugMessage()
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
            if v.chrName == item then
                chrStat(v)
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
    pauseView:new()
end

dynaList = playdate.ui.gridview.new(0,20)
dynaList:setNumberOfColumns(1)
dynaList:setNumberOfRows(5)
dynaList:setCellPadding(0,0,5,5)
dynaList:setContentInset(5,5,5,5)

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

    local menuX = 0 --size of background box
    local menuY = 0
    local yPos = 0
    local xPos = 0
    o.listRows = {}
    if mode == nestedMode.STATUS then
        dynaList:setNumberOfSections(10)
        local oFat = loadSavedPlayers("all")
        for i,v in pairs(oFat) do
            if type(v) == "table" then
                o.listRows[i] = v.chrName
            else
                o.listRows[i] = " "
            end
        end
        menuY = (6 * 25) + 10
        menuX = (100)
        dynaList:setNumberOfColumns(1)
        dynaList:setNumberOfRows(#o.listRows)
    elseif mode == nestedMode.LIST then
        -- display all cards in inventory
        menuY = (6 * 25) + 10
        menuX = (100)
    elseif mode == nestedMode.DECK then
        -- display all cards in the deck
        menuY = (6 * 25) + 10
        menuX = (100)
    elseif mode == nestedMode.TEAM then
        -- display all characters in the team
        menuY = (6 * 25) + 10
        menuX = (100)
    elseif mode == nestedMode.CHAR then
        -- display character info from save

        for i,v in pairs(tableData) do
            if i == "chrHp" then
                o.listRows["HP"] = v
            end
            if i == "chrStr" then
                o.listRows["Strength"] = v
            end
            if i == "chrKi" then
                o.listRows["Ki"] = v                
            end
            if i == "chrDef" then
                o.listRows["Defense"] = v
            end
            if i == "chrSpd" then
                o.listRows["Speed"] = v
            end
            if i == "chrExp" then
                o.listRows["EXP"] = v
            end
            if i == "chrTrans" then
                if v[1] == "none" then
                    o.listRows["Transformations"] = "none"
                else
                    o.listRows["Transformations"] = v
                end
            end
            
        end

        printTable(o.listRows)
        print(#o.listRows)

        o.category = {"HP","Strength","KI","Defense","Speed","EXP","Transformations"}
        menuY = (#o.listRows) + 10
        menuX = (100)
        dynaList:setNumberOfColumns(1)

        local count = 0
        for _ in pairs(o.listRows) do
            count = count + 1
        end
        dynaList:setNumberOfRows(count)
            
    elseif mode == nestedMode.CARD then
        --display card info from save
        menuY = (6 * 25) + 10
        menuX = (100)
    else
        print("Mode not recognized in menuEngine, dynaList.")
        return
    end

    xPos, yPos = menuPosition(menuPause)

    function o:getOption() -- item selection in menu
        local s = o:getSelectedRow()
        for i,v in pairs(o.listRows) do
            if s==i then
                return v
            end
        end
    end

    local dynaListSprite = gfx.sprite.new()
    dynaListSprite:setCenter(0,0)
    function o:spriteKill()
        dynaListSprite:remove()
    end

    dynaListSprite:add()

    function o:menuUpdate()
        if o.needsDisplay then
            local zInNew = 100
            local dynaListImage = gfx.image.new(menuX,menuY,gfx.kColorWhite)
            dynaListSprite:moveTo(xPos,yPos)
            for i,v in pairs(menuIndex) do
                if i == #menuIndex then
                    zInNew = v:getZIndex()
                end
            end
            dynaListSprite:setZIndex(zInNew)
            gfx.pushContext(dynaListImage)
            o:drawInRect(0,0,menuX,menuY)
            gfx.popContext()
            dynaListSprite:setImage(dynaListImage)
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
        menuText = o.listRows
        local fontHeight = gfx.getSystemFont():getHeight()
        local rCount = row
        if mode == nestedMode.STATUS then
            for i,v in pairs(o.listRows) do
                local cNum = i
                local cNam = " "
                local cName = nil
                if rCount == i then
                    if type(v) == "string" then
                        cNam = v
                    end
                    cName = cNum..": "..cNam
                    gfx.drawTextInRect(cName, x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, truncationString, kTextAlignment.left)
                end
            end
        elseif mode == nestedMode.CHAR then
            for i,v in pairs(o.listRows) do
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

function chrStat(chr)
    dynaList:new(nestedMode.CHAR,chr)
end