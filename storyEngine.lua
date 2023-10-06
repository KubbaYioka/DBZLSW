--character portrait object

local gfx = playdate.graphics

local ChrPort = gfx.sprite.new()

--nameTag object 
local nameTag = playdate.ui.gridview.new(0,20)
nameTag:setNumberOfColumns(1)
nameTag:setNumberOfRows(1)
nameTag:setCellPadding(0,0,4,0)
nameTag:setContentInset(5,5,5,5)
nameTag.backgroundImage = gfx.nineSlice.new("assets/images/textBorder",10,10,16,16)

function nameTag:new(pos, name) -- create nametag at designated position

    local o = o or {}
    setmetatable(o,self)
    self.__index=self
    local sizeY = (25)
    local sizeX = (100)
    local tagSprite = gfx.sprite.new()
    tagSprite:setCenter(0,0)
    function o:spriteKill()
        tagSprite:remove()
    end
    tagSprite:add()

    function o:tagUpdate()
        if o.needsDisplay then
            local tagImage = gfx.image.new(sizeX,sizeY,gfx.kColorWhite)
            tagSprite:setZIndex(4)
            nameTag:setContentInset(0,0,0,0)
            nameTag:setCellSize(100, 25)
            if pos == "left" then
                tagSprite:moveTo(0,160)
            elseif pos == "right" then
                tagSprite:moveTo(300,160)
            end
            gfx.pushContext(tagImage)
            o:drawInRect(0,0,sizeX,sizeY)
            gfx.popContext()
            tagSprite:setImage(tagImage)
        end
    end
    function o:drawCell(section,row,column,selected,x,y,width,height)
        local fontHeight = gfx.getSystemFont():getHeight()
        gfx.drawTextInRect(name, x+2, y + (height/2 - fontHeight/2) + 2, width, height, nil, nil, kTextAlignment.center)
    end
    tagIndex[pos] = o
    return o
end

function ChrPort:new(image, pos)
    print("portrait created")
    local o=o or {}
    setmetatable(o, self)
    self.__index=self

    o.image = gfx.image.new('/assets/images/portraits/'..image..'.png')

    o.pos = pos or "left"
    o.currrent = image

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

    local chrPortSprite = gfx.sprite.new()
    chrPortSprite:moveTo(o.xPos, o.yPos)
    chrPortSprite:add()
  
    function o:spriteKill()
        chrPortSprite:remove()
    end

    function o:portUpdate()
        gfx.pushContext(o.image)
        o.image:draw(o.xPos, o.yPos)
        gfx.popContext()
        chrPortSprite:setImage(o.image)
    end

    function o:changeImage(newImage)
        o.image = gfx.image.new('/assets/images/portraits/'..newImage..'.png')
        o.image:scaledImage(2)
    end

    portIndex[o.pos] = o
    return o
end

function portChange(image, pos)
    if image == "clear" and pos == nil then -- kill all portraits
        for i,v in pairs(portIndex) do
            v:spriteKill()
            portIndex[i]=nil
        end
        return

    elseif image == "clear" and pos ~= nil then -- selectively kill portrait
        for i,v in pairs(portIndex) do
            if v.pos == pos then
                v:spriteKill()
                portIndex[i]=nil
            end
        end
        return
    end

    for i, v in pairs(portIndex) do
        if v.pos == pos then
            v:changeImage(image) --changes image rather than deleting sprite
            return
        end
    end

    if image ~= "clear" then
        local sptOne = ChrPort:new(image, pos)
    end
end

function dTag(pos, name)
    for i, v in pairs(tagIndex) do -- automatically replaces the existing tag if another is called in the same position
        if v.type == "left" or v.type == "right" then
            v:spriteKill()
            table.remove(tagIndex[i]) --remove tag at index 'i'
        end
    end

    if pos == "clear" then
        for i, v in pairs(tagIndex) do -- erases all tags 
            v:spriteKill()
            table.remove(tagIndex[i]) --remove tag at index 'i'
        end
        return
    end

    nameTag:new(pos, name)

end