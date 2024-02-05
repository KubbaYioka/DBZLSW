--debug functions

--view loaded file
function callRam()
    printTable(RAMSAVE)
end

regularBox = playdate.ui.gridview.new(0,20)
regularBox:setNumberOfColumns(1)
regularBox:setNumberOfRows(1)
regularBox:setCellPadding(0,0,4,0)
regularBox:setContentInset(5,5,5,5)

regularBox.backgroundImage = gfx.nineSlice.new("assets/images/textBorder",10,10,16,16)

function regularBox:new(optionsTable) -- pass a table to this menu to get those options drawn
    local o = o or {}
    setmetatable(o,self)
    self.__index=self

    local menuX, menuY = 80, 80 --size of background box
    local xPos, yPos = 0 menuPosition(menuPosEnum.menuPosStart)
    o:setScrollDuration(0)

    o.optionsRow = optionsTable
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