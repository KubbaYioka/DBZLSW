--battleSprites
--contains functions for arena sprites

local gfx = playdate.graphics

function battleSpriteSet(bTable)
    bgChange(bTable["arenaParam"].bField)
    enemySprTab.sprRange = arenaSpriteSelect(enemyChr)
    playerSprTab.sprRange = arenaSpriteSelect(playerChr)
    arenaSpriteMode("player","normal") -- "normal" is a stand-in and may change to a playerChr element that can change based on certain battle or player conditions.
    arenaSpriteMode("enemy","normal")
end

function arenaSpriteSelect(chr) -- selects minisprite to appear in the field
    local sprTab = {}                -- returns coordinates for a 16x16 sprite from battleSprites.png
    for i,v in pairs(battleSprites) do
        if i == chr.chrCode then
            return battleSprites[i]
        end
    end
end

function arenaSpriteMode(player,mode) -- for deciding if the sprite is normal, standready, or powerup
    if player == "player" then
        playerSprTab.current = playerSprTab.sprRange[mode]
    elseif player == "enemy" then
        enemySprTab.current = enemySprTab.sprRange[mode]
    end
end

function areaPosition(tag)
    --get the enemy position enumeration or player enumeration from enemySprTab
    local pos = nil
    if tag == "player" then
        pos = playerSprTab.position
        if pos == PositionEnum.GroundFore then
            return 150,160
        elseif pos == PositionEnum.GroundAft then
            return 60,160
        elseif pos == PositionEnum.AirFore then
            return 150, 70
        elseif pos == PositionEnum.AirAft then
            return 60, 70
        end
    elseif tag == "enemy" then
        pos = enemySprTab.position
        if pos == PositionEnum.GroundFore then
            return 220,160
        elseif pos == PositionEnum.GroundAft then
            return 340,160
        elseif pos == PositionEnum.AirFore then
            return 220, 70
        elseif pos == PositionEnum.AirAft then
            return 340, 70
        end
    end

end 


class('BattleMiniSpr').extends(gfx.sprite) -- the little sprite representing a character on the arena

function BattleMiniSpr:init(tag)
    BattleMiniSpr.super.init(self)

    self.oTable = gfx.imagetable.new('assets/images/battleSprites-table-16-16.png')
    self:setCenter(0, 0)

    self.x, self.y = areaPosition(tag)
    self:moveTo(self.x, self.y)

    self:setZIndex(#sprBIndex + 90)
    self.tag = tag

    self:selectImage(tag)

    local numberO = #sprBIndex + 1
    self.index = numberO
    sprBIndex[numberO] = self

    self:add()
end

function BattleMiniSpr:selectImage(tag)
    local selImage = nil
    if tag == "player" then
        selImage = self.oTable:getImage(playerSprTab.current)
        self:setImage(selImage, gfx.kImageUnflipped, 2)
    elseif tag == "enemy" then
        selImage = self.oTable:getImage(enemySprTab.current)
        self:setImage(selImage, gfx.kImageFlippedX, 2)
    end
end

function BattleMiniSpr:spriteKill()
    self:remove()
end

function BattleMiniSpr:changePosition(tag) -- change depiction of position in arena.
    self.x,self.y = areaPosition(tag)
    mSpr:moveTo(self.x,self.y)
end

moveField = playdate.ui.gridview.new(0,0) -- technically part of the UI, but dictates where the available arena slots 
-- to which a character can move

function moveField:new(flyParam)
    local o = playdate.ui.gridview.new(20,20)
    setmetatable(o,self)
    self.__index=self

    o.canFly = flyParam

    for i,v in pairs (sprBIndex) do
        if v.tag == "player" then
            o.currentPosition = playerSprTab.position
        end
    end

    o.cX,o.cY = movTabConfig(o.currentPosition)

    o.extraSpace = enTest()
    print("extraSpace is "..tostring(o.extraSpace))

    o.drawX,o.drawY,o.dRow,o.dCol = compMove(o.cX,o.cY,o.extraSpace,o.currentPosition,o.canFly)    
    if not o.dRow or o.dRow < 1 then
        print("Warning: dRow is nil or invalid. Setting to 1.")
        o.dRow = 1
    end

    if not o.dCol or o.dCol < 1 then
        print("Warning: dCol is nil or invalid. Setting to 1.")
        o.dCol = 1
    end

    o:setNumberOfRows(o.dRow)
    o:setNumberOfColumns(o.dCol)

    print(o.drawX,o.drawY,o.dRow,o.dCol)

        -- Now that grid is properly set, lock scrolling
    if o.dRow > 0 and o.dCol > 0 then
        print("row and col > 0")
        --o:scrollToCell(1, 1)  -- Only if rows exist
    end
    o.scrollCellsToCenter = false
    o:setScrollDuration(0)
    o:setCellPadding(0,90,0,90)
    o:setContentInset(0,0,0,0)


    --o:setScrollPosition(0, 0) -- no unintended moving
    o.scrollCellsToCenter = false -- no centering of field positions.

    local movementSpr = gfx.sprite.new()
    movementSpr:setCenter(0,0)
    local zInd = #menuIndex + 171
    movementSpr:setZIndex(zInd)
    movementSpr:add()

    function o:getOption()
        local itemS = nil
        for i,v in pairs(UIIndex) do
            if v.tag == "movementUIInfo" then
                itemS = v.current
            end
        end
        return itemS
    end

    function o:spriteKill()
        movementSpr:remove()
        menuIndex[o.index] = nil
    end

    function o:menuUpdate()
        if o.needsDisplay then

            local mGridCursor = gfx.image.new(90*o.dCol,90*o.dRow,gfx.kColorClear)
            movementSpr:moveTo(o.drawX,o.drawY)

            gfx.pushContext(mGridCursor)
                print(o.dCol, o.dRow)
                o:drawInRect(0,0,90*o.dCol,90*o.dRow) 
            gfx.popContext()
            movementSpr:setImage(mGridCursor)
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)
            -- Debug Rectangle
            gfx.setColor(gfx.kColorBlack)
            gfx.drawRect(x, y, width, height)
        if selected then
            gfx.fillTriangle(x,y,x+32,y,x+16,y+16)
        end
    end

    o.tag = "moveGrid"

    local countI = 0
    for _ in pairs(menuIndex) do 
        countI = countI + 1 
    end

    o.index = countI + 1
    menuIndex[o.index] = o

end