--character portrait object

local gfx = playdate.graphics

ChrPort = gfx.sprite.new()

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

function dTag(pos, name, change)
    for i, v in pairs(menuIndex) do
        if v.mType == "tag" then
            v:spriteKill()
            table.remove(menuIndex["tag"])
        end
    end

    if pos == "clear" then
        return
    end

    local tag = gridview:new(name, 1, 1, pos, "tag", "tag")

end