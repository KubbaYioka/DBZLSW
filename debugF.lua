--debug functions

local gfx = playdate.graphics

print("Message from debugF.lua:")
print("Next, add cards at the beginning of each turn.")

--view loaded file
function callRam()
    printTable(RAMSAVE)
end

regularBox = playdate.ui.gridview.new(0,20)
regularBox:setNumberOfColumns(1)

regularBox:setCellPadding(0,0,4,0)
regularBox:setContentInset(5,5,5,5)

regularBox.backgroundImage = gfx.nineSlice.new("assets/images/textBorder",10,10,16,16)

function regularBox:new(optionsTable) -- pass a table to this menu to get those options drawn
    local o = o or {}
    setmetatable(o,self)
    self.__index=self

    local menuX, menuY = 150, 80 --size of background box
    local xPos, yPos = menuPosition(menuPosEnum.menuPosStart)
    o:setScrollDuration(0)

    o.optionsRow = optionsTable
    regularBox:setNumberOfRows(#o.optionsRow)

    function o:getOption() -- item selection in menu
        local s = o:getSelectedRow()
        for i,v in pairs(o.optionsRow) do
            if s==i then
                return v
            end
        end
    end

    local regSprite = gfx.sprite.new()
    regSprite:setCenter(0,0)
    function o:spriteKill()
        regSprite:remove()
    end
    
    regSprite:add()

    function o:menuUpdate()
        if o.needsDisplay then
            local regImage = gfx.image.new(menuX,menuY,gfx.kColorWhite)
            regSprite:moveTo(xPos,yPos)
            regSprite:setZIndex(130)
            gfx.pushContext(regImage)
                o:drawInRect(0,0,menuX,menuY)
            gfx.popContext()
            regSprite:setImage(regImage)
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)
        local menuText = {}
        if selected then
            gfx.fillTriangle(x,y+5,x,y+20,x+10,y+12)
        end
        menuText = o.optionsRow
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
            regSprite:remove()
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

function loadTestBattle()
    clearAll()
    battleInit(battles["battleTest"])
end


titleMenu = playdate.ui.gridview.new(0,20) -- initial gridview object 

titleMenu.backgroundImage = gfx.nineSlice.new("assets/images/textBorder",10,10,16,16)

function titleMenu:new(gType,name)
    local o = o or {}
    setmetatable(o,self)
    self.__index=self
    o.type = gType
    local menuX, menuY, xPos, yPos = 0,0,0,0 

    o.options = {}
    o.options = name

    titleMenu:setCellPadding(0,0,4,0)
    titleMenu:setContentInset(5,5,5,5)
    titleMenu:setNumberOfColumns(1)
    titleMenu:setNumberOfRows(#o.options)

    menuY = (#o.options * 25) + 10
    menuX = (130)

    xPos, yPos = menuPosition(name)
    
    function o:getOption() -- item selection in menu
        local s = o:getSelectedRow()
        for i,v in pairs(o.options) do
            if s==i then
                return v
            end
        end
    end

    local titleMenuSprite = gfx.sprite.new()
    titleMenuSprite:setCenter(0, 0)

    function o:spriteKill()
        titleMenuSprite:remove()
    end

    titleMenuSprite:add()

    function o:menuUpdate()
        if o.needsDisplay then
            local gridviewImage = gfx.image.new(menuX,menuY,gfx.kColorWhite)
            titleMenuSprite:moveTo(xPos, yPos) -- same location as where the grid is drawn
            titleMenuSprite:setZIndex(130)
            gfx.pushContext(gridviewImage)
                o:drawInRect(0,0,menuX,menuY)
            gfx.popContext()
            titleMenuSprite:setImage(gridviewImage)
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)
        local menuText={}
        local nN = nil
        if selected then
            gfx.fillTriangle(x,y+5,x,y+20,x+10,y+12)
        end
        menuText = o.options
        local fontHeight = gfx.getSystemFont():getHeight()
        for i,v in pairs(menuText) do
            if row == i then
                nN = " "..v
                gfx.drawTextInRect(nN, x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, truncationString, kTextAlignment.left)
            end
        end
    end

    function o:menuControl(direction) 
        if direction == "up" then
            o:selectPreviousRow(true,true,false)
        elseif direction == "down" then
            o:selectNextRow(true,true,false)
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