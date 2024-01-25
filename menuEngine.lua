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

nestedMode= {
    STATUS = "status"
    ,LIST = "list"
    ,TEAM = "team"
    ,DECK = "deck"
}

function createMenuIcon(icon)
    local iconMenu = MenuIcon('assets/images/background/menuIcon-table-96-80')
    iconMenu:changeState(icon)
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
        menuArt("typeOne")
        statusList:new()
        createMenuIcon(nestedMode.STATUS)
    end,
    ["nameHere"] = function()
        clearPauseMenu()
    end,
    ["Deck"] = function()
        debugMessage()
        createMenuIcon(nestedMode.DECK)
        menuArt("typeOne")
    end,
    ["Team"] = function()
        debugMessage()
        createMenuIcon(nestedMode.TEAM)
        menuArt("typeOne")
    end,
    ["List"] = function()
        cardList:new()
        createMenuIcon(nestedMode.LIST)
        menuArt("typeOne")
    end,
    ["Save"] = function()
        saveGame()
        print("Game Saved")
    end,
    ["Exit"] = function()
        clearPauseMenu()
    end,
    ["eof"] = 0
    -- Add more menu items and their corresponding functions here
}

function goMenu(item)
    -- Check if the selected item has a corresponding function and call it
    if item == nil then
        print("goMenu: item is nil.")
        return
    end
    if menuFunc[item] then
        menuFunc[item]()
    elseif not menuFunc[item] then
        if menuIndex[#menuIndex].menuType == "List" then --iterates through cards if menu is List
            local oFav = loadSavedCards("all")
            for i,v in pairs(oFav) do
                if type(v) == "table" then    
                    if v.cNumber == item then
                        cardData(v)
                    end
                end
            end
        end
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
    o:setScrollDuration(0)

    o.pauseRows = {"Status","Deck","List","Save","Exit"}
    o.saveRows = {"Yes", "No"}
    if gameMode == GameMode.BATTLE then
        print("Placeholder")
        o.pauseRows = {"Status","Deck","Team","List","Save","Exit"}
    end

    pauseView:setNumberOfColumns(1)
    pauseView:setNumberOfRows(#o.pauseRows)
    menuY = (#o.pauseRows * 25) + 10
    menuX = (120)
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
            gfx.fillTriangle(x,y+5,x,y+20,x+10,y+12)
        end
        menuText = o.pauseRows
        local fontHeight = gfx.getSystemFont():getHeight()
        local rCount = row
        for i,v in pairs(menuText) do
            if rCount == i then
                local rowCom = " "..v
                gfx.drawTextInRect(rowCom, x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, truncationString, kTextAlignment.left)
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

--statusList.backgroundImage = gfx.nineSlice.new("assets/images/textBorder",10,10,16,16)

function statusList:new()
    local o = playdate.ui.gridview.new(0,25)
    setmetatable(o,self)
    self.__index=self

    o:setCellPadding(0,0,1,3)
    o:setContentInset(5,5,7,7)
    o:setScrollDuration(0)
    o.scrollCellsToCenter = false

    o.menuType = "Status"

    o.bSpr = true
    local menuBSpr = MenuBackground(0,0,"menuTwo")
    menuBSpr:add()

    local menuX = 0 --size of background box and position to be set later
    local menuY = 0
    local yPos = 0
    local xPos = 0

    local oFat = loadSavedPlayers("all")
    o.listRows = {}
    o:setNumberOfColumns(1)
    o:setNumberOfRows(#oFat)
    o:removeHorizontalDividers()

    for i,v in pairs(oFat) do
        if type(v) == "table" and i == v.chrNum then
            o.listRows[v.chrNum] = v.chrName
        else
            o.listRows[i] = "   "
        end
    end

    xPos, yPos = menuPosition(menuPosEnum.menuPosvar)
    menuY = (155)
    menuX = (250)

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
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)


        gfx.fillRect(x, y+5, 30, 20)


        if selected then
            gfx.fillTriangle(x+35,y+8,x+35,y+23,x+45,y+15)
        end

        local fontHeight = gfx.getSystemFont():getHeight()
        local rowCom = o.listRows[row]
        local rowFin = tostring(row).."  "..rowCom

        gfx.setFont(sysFNT.smDBFont)

        local original_draw_mode = gfx.getImageDrawMode()
        local fontHeight = gfx.getFont():getHeight()

        gfx.setImageDrawMode(playdate.graphics.kDrawModeNXOR)
  
        gfx.drawTextInRect(tostring(row), x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, truncationString, kTextAlignment.left)
        gfx.setImageDrawMode(original_draw_mode)

        gfx.setFont(sysFNT.dbFont)

        gfx.drawTextInRect(o.listRows[row], x+50, y + (height/2 - fontHeight/2) + 2, width, height, nil, truncationString, kTextAlignment.left)
    end

    function o:menuControl(direction) 
        local rSelected = o:getSelectedRow()
        if direction == "up" then
            o:selectPreviousRow(true,true,false)
            rSelected = o:getSelectedRow()
        elseif direction == "down" then
            o:selectNextRow(true,true,false)
            rSelected = o:getSelectedRow()
        elseif direction == "right" then
            rSelected = rSelected + 5
            if rSelected >50 then
                rSelected = 1
            end
            o:setSelectedRow(rSelected)
            o:scrollToRow(rSelected)
        elseif direction == "left" then 
            rSelected = rSelected - 5
            if rSelected < 1 then
                rSelected = 50
            end
            o:setSelectedRow(rSelected)
            o:scrollToRow(rSelected)
        elseif direction == "a" then
            

        elseif direction == "b" then
            if o.bSpr == true then
                for i,v in pairs(otherIndex) do
                    if v.menuWhi then
                        otherIndex.v = nil
                        v:remove()
                    end
                end
            end
            if #numberBoxIndex > 0 then
                for i,v in pairs(numberBoxIndex) do
                    numberBoxIndex.v = nil
                    v:spriteKill()
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
        if #numberBoxIndex > 0 then
            for i,v in pairs(numberBoxIndex) do
                if i==#numberBoxIndex then
                    print(rSelected)
                    v:scroll(rSelected)
                end
            end
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

cardList = playdate.ui.gridview.new(0,25)

cardList.backgroundImage = gfx.nineSlice.new("assets/images/textBorder",10,10,16,16)

function cardList:new()
    local o = playdate.ui.gridview.new(0,25)
    setmetatable(o,self)
    self.__index=self

    o.menuType = "List"

    o:setCellPadding(0,0,1,3)
    o:setContentInset(5,5,7,7)
    o:setScrollDuration(0)

    o.bSpr = true
    local menuBSpr = MenuBackground(0,0,"menuTwo")
    menuBSpr:add()

    local menuX = 0 --size of background box and position to be set later
    local menuY = 0
    local yPos = 0
    local xPos = 0

    local oFat = loadSavedCards("all")
    o.listRows = {}
    o:setNumberOfColumns(1)
    o:setNumberOfRows(#oFat)

    for i,v in pairs(oFat) do
        if type(v) == "table" and i == v.cNumber then
            o.listRows[v.cNumber] = v.cName
        else
            o.listRows[i] = "  "..tostring(i)
        end
    end

    local xPos, yPos = menuPosition(menuPosEnum.menuPosvar)
    menuY = (155)
    menuX = (250)

    function o:getOption() -- item selection in menu
        local s = o:getSelectedRow()
        for i,v in pairs(o.listRows) do
            if s==i then
                return i
            end
        end
    end

    local cardListSprite = gfx.sprite.new()
    cardListSprite:setCenter(0,0)

    function o:spriteKill()
        cardListSprite:remove()
    end

    cardListSprite:add()

    function o:menuUpdate()
        if o.needsDisplay then
            local cardListImage = gfx.image.new(menuX,menuY,gfx.kColorWhite)
            cardListSprite:moveTo(xPos,yPos)
            
            local zInNew = 130
            zInNew = zInNew + #menuIndex -- newest menu will always be drawn on top
            cardListSprite:setZIndex(zInNew)

            gfx.pushContext(cardListImage)
                o:drawInRect(0,0,menuX,menuY)
            gfx.popContext()
            cardListSprite:setImage(cardListImage)
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)

        gfx.fillRect(x, y+5, 30, 20)


        if selected then
            gfx.fillTriangle(x+35,y+8,x+35,y+23,x+45,y+15)
        end

        local fontHeight = gfx.getSystemFont():getHeight()
        local rowCom = o.listRows[row]
        local rowFin = tostring(row).."  "..rowCom

        gfx.setFont(sysFNT.smDBFont)

        local original_draw_mode = gfx.getImageDrawMode()
        local fontHeight = gfx.getFont():getHeight()

        gfx.setImageDrawMode(playdate.graphics.kDrawModeNXOR)
  
        gfx.drawTextInRect(tostring(row), x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, truncationString, kTextAlignment.left)
        gfx.setImageDrawMode(original_draw_mode)

        gfx.setFont(sysFNT.dbFont)

        gfx.drawTextInRect(o.listRows[row], x+50, y + (height/2 - fontHeight/2) + 2, width, height, nil, truncationString, kTextAlignment.left)
    end

    function o:menuControl(direction) 
        local rSelected = o:getSelectedRow()
        if direction == "up" then
            o:selectPreviousRow(true,true,false)
            rSelected = o:getSelectedRow()
        elseif direction == "down" then
            o:selectNextRow(true,true,false)
            rSelected = o:getSelectedRow()
        elseif direction == "right" then
            rSelected = rSelected + 5
            if rSelected >150 then
                rSelected = 1
            end
            o:setSelectedRow(rSelected)
            o:scrollToRow(rSelected)
        elseif direction == "left" then 
            rSelected = rSelected - 5
            if rSelected < 1 then
                rSelected = 150
            end
            o:setSelectedRow(rSelected)
            o:scrollToRow(rSelected)
        elseif direction == "a" then
            local gSR = o:getSelectedRow()
            print("gSR is "..gSR)
            printTable(loadSavedCards(gSR))

        elseif direction == "b" then
            if o.bSpr == true then
                for i,v in pairs(otherIndex) do
                    if v.menuWhi then
                        otherIndex.v = nil
                        v:remove()
                    end
                end
            end

            if #numberBoxIndex > 0 then
                for i,v in pairs(numberBoxIndex) do
                    numberBoxIndex.v = nil
                    v:spriteKill()
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
        if #numberBoxIndex > 0 then
            for i,v in pairs(numberBoxIndex) do
                if i==#numberBoxIndex then
                    print(rSelected)
                    v:scroll(rSelected)
                end
            end
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

dataBox = playdate.ui.gridview.new(0,25)

function dataBox:new(xD,yD,wD,hD,dText,bgD,image,fntSize) -- where bgD is the background color

    local o = o or {}
    setmetatable(o,self)
    self.__index=self

    dataBox:setNumberOfColumns(1)
    dataBox:setNumberOfRows(1)
    dataBox:setCellPadding(0,0,0,0)
    dataBox:setContentInset(0,0,0,0)

    o.bgD = bgD
    o.dText = dText
    o.x = xD
    o.y = yD
    o.w = wD
    o.h = hD

    local dataBoxSprite = gfx.sprite.new()
    dataBoxSprite:setCenter(0, 0)

    function o:spriteKill()
        dataBoxSprite:remove()
    end
    if #dataBoxIndex == 0 then
        o.bSpr = true
        local menuBSpr = MenuBackground(0,0,"menuThree")
        menuBSpr:add()
    end

    dataBoxSprite:add()
  
    function o:menuControl(direction) 
        if direction == "b" then
            if o.bSpr == true then
                for i,v in pairs(otherIndex) do
                    if v.menuWhi == 2 then
                        otherIndex.v = nil
                        v:remove()
                    end
                end
            end 
            for i,v in pairs(dataBoxIndex) do
                v:spriteKill()
                dataBoxIndex[v.index] = nil
            end
        end
    end

    function o:menuUpdate()
        if o.needsDisplay then
            local boxImage = gfx.image.new(o.w,o.h,o.bgD)
            dataBoxSprite:moveTo(o.x, o.y)
            local zInd = #dataBoxIndex + 220
            dataBoxSprite:setZIndex(zInd)
            gfx.pushContext(boxImage)
                o:drawInRect(0,0,o.w,o.h)
            gfx.popContext()
            dataBoxSprite:setImage(boxImage)
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)

        local fontHeight = gfx.getSystemFont():getHeight()
        if o.x == 0 and o.y == 80 then -- text alignment for quantity of cards available
            o.align = kTextAlignment.right
        else
            o.align = kTextAlignment.left -- all other aligned left
        end
        if fntSize == "small" then
            gfx.setFont(sysFNT.smDBFont)
        end
        if o.bgD == 0 then
            local original_draw_mode = gfx.getImageDrawMode()
            gfx.setImageDrawMode( playdate.graphics.kDrawModeInverted )
            gfx.drawTextInRect(o.dText, x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, truncationString, o.align)
            gfx.setImageDrawMode( original_draw_mode )
        else
            gfx.drawTextInRect(o.dText, x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, truncationString, o.align)
        end
        if gfx.getFont() == sysFNT.smDBFont then
            gfx.setFont(sysFNT.dbFont)
        end
    end

    local countI = 0
    for _ in pairs(dataBoxIndex) do 
        countI = countI + 1 
    end

    o.index = countI + 1
    dataBoxIndex[o.index] = o
    return o
end

class('MenuBackground').extends(gfx.sprite) -- create menu backgrounds

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
    elseif back == "menuThree" then
        local menuImage = gfx.image.new('assets/images/background/400240.png')
        self:setImage(menuImage)
        self.menuWhi = 2
        self:setZIndex(160)
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
    self:moveTo(305, 0)
    self:setZIndex(140)
    
    local numberO = #otherIndex + 1
    otherIndex[numberO] = self
    self:add()
end

class('CardIcon').extends(AnimatedSprite)

function CardIcon:init(cardNum, change)

    local oTable = gfx.imagetable.new('assets/images/cardtemplates-96-80.png')
    CardIcon.super.init(self, oTable)

    -- Define sprite states
    self:addState("cardIcon",cardNum,cardNum)

    self:playAnimation()

    self.cardIcon = 1

    self.changeState("cardIcon")

    function changeIcon(cardNum)
        if change == true then
            self:addState("cardIcon",cardNum,cardNum)
            self.changeState("cardIcon")
        end
    end

    self:setCenter(0, 0)
    self:moveTo(0, 0)
    self:setZIndex(140)
    
    local numberO = #otherIndex + 1
    otherIndex[numberO] = self
    self:add()
end

function cardData(selCard) -- Render card info screen.
    if type(selCard) ~= "table" then
        print("cardData: Data not in correct format.")
    else
        for i,v in pairs(selCard) do
            if i == "cNumber" then
                local sRT = tostring(v)
                local sRTT = "No. "..sRT
                dataBox:new(180,0,250,20,sRTT,gfx.kColorBlack,nil)
            elseif i == "cName" then
                dataBox:new(180,40,200,20,v,gfx.kColorWhite,nil)
            elseif i == "cAccuracy" then
                local sRT = tostring(v)
                local sRTT = "Accuracy: "..sRT
                dataBox:new(60,140,200,20,sRTT,gfx.kColorWhite,nil)
            elseif i == "cCost" then
                local sRT = tostring(v)
                local sRTT = "CC: "..sRT
                dataBox:new(60,160,200,20,sRTT,gfx.kColorWhite,nil)
            elseif i == "cDescription" then
                dataBox:new(40,190,400,60,v,gfx.kColorWhite,nil)
            elseif i == "cQuantity" then
                local sRT = tostring(v)
                local sRTT = "Available: "..sRT
                dataBox:new(0,80,400,20,sRTT,gfx.kColorBlack,nil)
            elseif i == "cEffect" then
                dataBox:new(60,120,200,20,v,gfx.kColorWhite,nil)
            end
        end
    end
end

function chrData(chr, mode) -- render character info screen where mode specifies whether to pull pause parameters or in-battle status
    
    if mode == "battle" then
        debugMessage() -- pulls info from character in the battle at the time, not the parameters from RAMSAVE
    elseif mode == "pause" then
        print(chr)
        local chrTable = loadSavedPlayers(chr)        
        for i,v in pairs(chrTable) do
            if i == "chrNum" then
                local sRT = tostring(v)
                local sRTT = "No. "..sRT
                dataBox:new(180,0,250,20,sRTT,gfx.kColorBlack,nil)
            elseif i == "chrName" then
                dataBox:new(180,40,120,20,v,gfx.kColorWhite,nil)
            elseif i == "chrTrans" then
                if type(v) == "table" then
                    local sRT = v.trans1
                    dataBox:new(185,60,120,20,sRT,gfx.kColorWhite,nil,"small")
                end
            elseif i == "chrHp" then
                local sRT = tostring(v)
                local sRTT = "HP  "..sRT
                dataBox:new(60,100,120,20,sRTT,gfx.kColorWhite,nil)
            elseif i == "chrStr" then
                local sRT = tostring(v)
                local sRTT = "Str  "..sRT
                dataBox:new(60,120,120,20,sRTT,gfx.kColorWhite,nil)
            elseif i == "chrKi" then
                local sRT = tostring(v)
                local sRTT = "Ki  "..sRT
                dataBox:new(60,140,120,20,sRTT,gfx.kColorWhite,nil)
            elseif i == "chrDef" then
                local sRT = tostring(v)
                local sRTT = "Def  "..sRT
                dataBox:new(180,100,120,20,sRTT,gfx.kColorWhite,nil)
            elseif i == "chrSpd" then
                local sRT = tostring(v)
                local sRTT = "Spd  "..sRT
                dataBox:new(180,120,120,20,sRTT,gfx.kColorWhite,nil)
            elseif i == "chrExp" then
                local sRT = tostring(v)
                local sRTT = "Exp  "..sRT
                dataBox:new(180,160,120,20,sRTT,gfx.kColorWhite,nil)
            end
        end
    end
end

class('RectangleBox').extends(gfx.sprite)

function RectangleBox:init(bX,bY,bW,bH)
    RectangleBox.super.init(self)
    self:setCenter(0,0)
    self:moveTo(bX,bY)
    self:setZIndex(200)
    local rectanImage = gfx.image.new(bW,bH,gfx.kColorBlack)
    gfx.pushContext(rectanImage)
        gfx.fillRect(bX,bY,bW,bH)
    gfx.popContext()
    self:setImage(rectanImage)
    self.rectBox = true
    local selfIndex = #otherIndex + 1
    otherIndex[selfIndex] = self
end

class('TriangleBlock').extends(gfx.sprite)

function TriangleBlock:init(x1,y1,x2,y2,x3,y3,tW,tH) -- where tW and tH are the width and height of the 'image'
    TriangleBlock.super.init(self)
    self:setCenter(0,0)
    self:moveTo(x1,y1)
    self:setZIndex(200)
    local triImage = gfx.image.new(tW,tH,gfx.kColorBlack)
    gfx.pushContext(triImage)
        gfx.drawTriangle(x1,y1,x2,y2,x3,y3)
    gfx.popContext()
    self:setImage(triImage)
    self.rectBox = true
    local selfIndex = #otherIndex + 1
    otherIndex[selfIndex] = self
end

function menuArt(artType) -- function to draw all the boxes in the menu that are decorative
    if artType == "typeOne" then
       local midRect = RectangleBox(200,80,200,20)
       midRect:add()
       local midTri = TriangleBlock(180,80,200,110,200,80,20,20)
       midTri:add()
       local midLine = RectangleBox(0,80,200,5)
       midLine:add()

        --draw box at (190,85) with (220x20)
        --draw triangle at (190,85), (180,85), (190,105)
        --draw box at (200,0) with (400x20)

    end
end