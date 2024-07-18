--debug functions

local gfx = playdate.graphics

print("Message from debugF.lua:")

--view loaded file
function callRam()
    printTable(RAMSAVE)
end

local gfx = playdate.graphics -- Assuming gfx is used from playdate.graphics

regularBox = playdate.ui.gridview.new(0, 20)
regularBox:setNumberOfColumns(1)
regularBox:setCellPadding(0, 0, 4, 0)
regularBox:setContentInset(5, 5, 5, 5)
regularBox.backgroundImage = gfx.nineSlice.new("assets/images/textBorder", 10, 10, 16, 16)

function regularBox:new(optionsTable)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    local menuX, menuY = 150, 80
    local xPos, yPos = menuPosition(menuPosEnum.menuPosStart)
    o:setScrollDuration(0)

    o.optionsRow = optionsTable
    o:setNumberOfRows(#o.optionsRow)

    o.regSprite = gfx.sprite.new()
    o.regSprite:setCenter(0, 0)
    o.regSprite:add()

    function o:getOption()
        local s = self:getSelectedRow()
        for i, v in pairs(self.optionsRow) do
            if s == i then
                return v
            end
        end
    end

    function o:spriteKill()
        self.regSprite:remove()
    end

    function o:menuUpdate()
        if self.needsDisplay then
            local regImage = gfx.image.new(menuX, menuY, gfx.kColorWhite)
            self.regSprite:moveTo(xPos, yPos)
            self.regSprite:setZIndex(130)
            gfx.pushContext(regImage)
                self:drawInRect(0, 0, menuX, menuY)
            gfx.popContext()
            self.regSprite:setImage(regImage)
        end
    end

    function o:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.fillTriangle(x, y + 5, x, y + 20, x + 10, y + 12)
        end
        local fontHeight = gfx.getSystemFont():getHeight()
        local text = " " .. self.optionsRow[row]
        gfx.drawTextInRect(text, x + 2, y + (height / 2 - fontHeight / 2) + 2, width, height, nil, truncationString, kTextAlignment.left)
    end

    function o:menuControl(direction)
        if direction == "up" then
            self:selectPreviousRow(true)
        elseif direction == "down" then
            self:selectNextRow(true)
        elseif direction == "b" then
            self.regSprite:remove()
            menuIndex[self.index] = nil
        end
    end

    o.index = #menuIndex + 1
    menuIndex[o.index] = o

    return o
end


function loadTestBattle()
    clearAll()
    battleInit(battles["battleTest"])
end


titleMenu = playdate.ui.gridview.new(0, 20) -- initial gridview object 
titleMenu.backgroundImage = gfx.nineSlice.new("assets/images/textBorder", 10, 10, 16, 16)

function titleMenu:new(gType, name)
    local o = {}
    setmetatable(o, self)
    self.__index = self

    o.type = gType
    o.options = name
    o:setCellPadding(0, 0, 4, 0)
    o:setContentInset(5, 5, 5, 5)
    o:setNumberOfColumns(1)
    o:setNumberOfRows(#o.options)

    o.menuY = (#o.options * 25) + 10
    o.menuX = 130
    o.xPos, o.yPos = menuPosition(name)

    o.titleMenuSprite = gfx.sprite.new()
    o.titleMenuSprite:setCenter(0, 0)
    o.titleMenuSprite:add()

    function o:getOption()
        local s = self:getSelectedRow()
        for i, v in pairs(self.options) do
            if s == i then
                return v
            end
        end
    end

    function o:spriteKill()
        self.titleMenuSprite:remove()
    end

    function o:menuUpdate()
        if self.needsDisplay then
            local gridviewImage = gfx.image.new(self.menuX, self.menuY, gfx.kColorWhite)
            self.titleMenuSprite:moveTo(self.xPos, self.yPos)
            self.titleMenuSprite:setZIndex(130)
            gfx.pushContext(gridviewImage)
                self:drawInRect(0, 0, self.menuX, self.menuY)
            gfx.popContext()
            self.titleMenuSprite:setImage(gridviewImage)
        end
    end

    function o:drawCell(section, row, column, selected, x, y, width, height)
        if selected then
            gfx.fillTriangle(x, y + 5, x, y + 20, x + 10, y + 12)
        end
        local fontHeight = gfx.getSystemFont():getHeight()
        local text = " " .. self.options[row]
        gfx.drawTextInRect(text, x + 2, y + (height / 2 - fontHeight / 2) + 2, width, height, nil, truncationString, kTextAlignment.left)
    end

    function o:menuControl(direction)
        if direction == "up" then
            self:selectPreviousRow(true, true, false)
        elseif direction == "down" then
            self:selectNextRow(true, true, false)
        end
    end

    o.index = #menuIndex + 1
    menuIndex[o.index] = o

    return o
end