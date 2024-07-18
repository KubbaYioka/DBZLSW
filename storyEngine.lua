local gfx = playdate.graphics

-- Character Portrait Object
ChrPort = {}
ChrPort.__index = ChrPort

function ChrPort:new(image, pos)
    local o = setmetatable({}, ChrPort)
    o.image = gfx.image.new('/assets/images/portraits/' .. image .. '.png')
    o.pos = pos or "left"
    o.current = image

    if o.pos == "left" then
        o.xPos = 70
        o.yPos = 100
    elseif o.pos == "center" then
        o.xPos = 200
        o.yPos = 100
    elseif o.pos == "right" then
        o.xPos = 350
        o.yPos = 100
    else
        o.xPos = 0
        o.yPos = 0
    end

    o.chrPortSprite = gfx.sprite.new()
    o.chrPortSprite:moveTo(o.xPos, o.yPos)
    o.chrPortSprite:add()

    return o
end

function ChrPort:spriteKill()
    self.chrPortSprite:remove()
end

function ChrPort:portUpdate()
    gfx.pushContext(self.image)
    self.image:draw(self.xPos, self.yPos)
    gfx.popContext()
    self.chrPortSprite:setImage(self.image)
end

function ChrPort:changeImage(newImage)
    self.image = gfx.image.new('/assets/images/portraits/' .. newImage .. '.png')
    self.image:scaledImage(2)
end

-- Name Tag Object
local nameTag = playdate.ui.gridview.new(0, 20)
nameTag:setNumberOfColumns(1)
nameTag:setNumberOfRows(1)
nameTag:setCellPadding(0, 0, 4, 0)
nameTag:setContentInset(0, 0, 0, 0)
nameTag.backgroundImage = gfx.nineSlice.new("assets/images/textBorder", 10, 10, 16, 16)
nameTag.__index = nameTag

function nameTag:new(pos, name)
    local o = setmetatable({}, nameTag)
    local sizeX, sizeY = 100, 25

    o.tagSprite = gfx.sprite.new()
    o.tagSprite:setCenter(0, 0)
    o.tagSprite:add()

    function o:spriteKill()
        self.tagSprite:remove()
    end

    function o:tagUpdate()
        if self.needsDisplay then
            local tagImage = gfx.image.new(sizeX, sizeY, gfx.kColorWhite)
            self.tagSprite:setZIndex(140)
            self:setContentInset(0, 0, 0, 0)
            self:setCellSize(100, 25)
            if pos == "left" then
                self.tagSprite:moveTo(0, 160)
            elseif pos == "right" then
                self.tagSprite:moveTo(300, 160)
            end
            gfx.pushContext(tagImage)
            self:drawInRect(0, 0, sizeX, sizeY)
            gfx.popContext()
            self.tagSprite:setImage(tagImage)
        end
    end

    function o:drawCell(section, row, column, selected, x, y, width, height)
        local fontHeight = gfx.getSystemFont():getHeight()
        gfx.drawTextInRect(name, x + 2, y + (height / 2 - fontHeight / 2) + 2, width, height, nil, nil, kTextAlignment.center)
    end

    tagIndex[pos] = o
    return o
end

-- Dialogue Box Object
dialogueBox = playdate.ui.gridview.new(0, 0)
dialogueBox.backgroundImage = gfx.nineSlice.new("assets/images/textBorder", 10, 10, 16, 16)
dialogueBox.__index = dialogueBox

function dialogueBox:new(gType, name)
    local o = setmetatable({}, dialogueBox)
    o.type = gType

    o:setNumberOfColumns(1)
    o:setNumberOfRows(1)
    o:setCellPadding(0, 0, 4, 0)
    o:setContentInset(5, 5, 5, 5)

    local menuX, menuY = 400, 80
    o:setNumberOfRows(1)
    o:setNumberOfColumns(1)

    o.location = name
    o.key = 1
    o.cText = "none"

    function o:text()
        local qryText, textRef
        if self.type == "mapDialogue" then
            for _, v in pairs(self.location) do
                for g, q in pairs(v) do
                    if g == "properties" then
                        for j, w in pairs(q) do
                            if j == "txtIter" then
                                textRef = "text" .. w
                            end
                        end
                        for j, w in pairs(q) do
                            if j == textRef then
                                qryText = w
                                break
                            end
                        end
                        if not qryText then
                            print("Error. Properties Not Found in Object.")
                            return
                        end
                    end
                end
            end
            if #qryText >= self.key then
                while type(qryText[self.key]) ~= "string" and self.key <= #qryText do
                    if type(qryText[self.key]) == "function" then
                        qryText[self.key]()
                    end
                    self.key = self.key + 1
                end
                if self.key <= #qryText then
                    self.cText = qryText[self.key]
                    self.key = self.key + 1
                end
            end
            if self.key > #qryText then
                self:spriteKill()
                menuIndex = {}
                ctrlConSwi("off")
            end
        elseif self.type == "dialogue" then
            for i, v in pairs(stories) do
                if self.location == i then
                    while type(v[self.key]) ~= "string" do
                        if type(v[self.key]) == "function" then
                            v[self.key]()
                        end
                        self.key = self.key + 1
                    end
                    self.cText = v[self.key]
                    self.key = self.key + 1
                end
            end
        end
    end

    o.gridviewSprite = gfx.sprite.new()
    o.gridviewSprite:setCenter(0, 0)
    o.gridviewSprite:add()

    function o:spriteKill()
        self.gridviewSprite:remove()
    end

    function o:menuUpdate()
        if self.needsDisplay then
            local gridviewImage = gfx.image.new(menuX, menuY, gfx.kColorWhite)
            self.gridviewSprite:setZIndex(130)
            self.gridviewSprite:moveTo(0, 160)
            self:setContentInset(5, 20, 10, 0)
            self:setCellSize(380, 50)
            gfx.pushContext(gridviewImage)
            self:drawInRect(0, 0, menuX, menuY)
            gfx.popContext()
            self.gridviewSprite:setImage(gridviewImage)
        end
    end

    function o:drawCell(section, row, column, selected, x, y, width, height)
        local fontHeight = gfx.getSystemFont():getHeight()
        local text = self.cText
        gfx.drawTextInRect(text, x + 2, y + (height / 2 - fontHeight / 2) + 2, width, height, nil, truncationString, kTextAlignment.left)
    end

    function o:menuControl(direction)
        if direction == "a" then
            self:text()
            self:selectNextRow(true, true, false)
        end
    end

    o.index = #menuIndex + 1
    menuIndex[o.index] = o
    return o
end

-- Helper functions for managing ports and tags

function portChange(image, pos)
    if image == "clear" and pos == nil then -- kill all portraits
        for _, v in pairs(portIndex) do
            v:spriteKill()
        end
        portIndex = {}
        return
    elseif image == "clear" and pos ~= nil then -- selectively kill portrait
        if portIndex[pos] then
            portIndex[pos]:spriteKill()
            portIndex[pos] = nil
        end
        return
    end

    if portIndex[pos] then
        portIndex[pos]:changeImage(image)
    else
        portIndex[pos] = ChrPort:new(image, pos)
    end
end

function dTag(pos, name)
    if pos == "clear" then
        for _, v in pairs(tagIndex) do
            v:spriteKill()
        end
        tagIndex = {}
        return
    end

    if tagIndex[pos] then
        tagIndex[pos]:spriteKill()
    end

    tagIndex[pos] = nameTag:new(pos, name)
end
