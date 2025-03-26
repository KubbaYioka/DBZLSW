--battleUIMenu
--For controlling all UI elements and the BattleUIMenu class

local gfx = playdate.graphics

function drawUI(phase)
    local pName, eName = playerChr.chrName, enemyChr.chrName
    local pUI = topUI:new("left",pName)
    local eUI = topUI:new("right",eName)
    local bottomBox = RectangleBox(0,200,400,80)
        bottomBox:add()
    local vsEmb = VsEmblem()
    local enSprite = BattleMiniSpr("enemy")
    local plrSprite = BattleMiniSpr("player")
    fillGauge()
    --compare speeds to see who attacks first.
    local battleSMenu = battleUIMenu:new(phase) --also spawns battleInfoBox

    SubMode = SubEnum.MENU
end

function fillGauge()
    local enLife = LifeBar("enemy",enemyChr.chrHp)
    local plLife = LifeBar("player",playerChr.chrHp)
    --do animation to fill life gauges, possibly by incrementing the width of a rectangle until a max width is reached
end

function getNextBMenu(selOption,phase) --gets the selected option and creates the next menu level based on that.
    if selOption ~= nil then
        --print("selOption in getNextBMenu: "..selOption)
    end
    --Limit
    if selOption == "Limit" then

    --Joint
    elseif selOption == "Joint Deck" then
        local jD = jointDeck:new()
    --Basic Commands
    elseif selOption == "Basic Command" then
        local bC = batCom:new()
    --Character
    elseif selOption == "Character" then
        chrData(playerTeam,"battle")
    elseif selOption == "Guard" then
        goOption(selOption,"player")
    elseif selOption == "Movement" then
        SubMode = SubEnum.MOVE
        local gC = moveField:new(playerChr.ability[1])
    elseif selOption == "Focus" then
    elseif selOption == "Power Up" then
    elseif selOption and selOption ~= nil and selOption ~= "notAvailable" then
        if #menuIndex < 3 and menuIndex[#menuIndex].tag ~= "tossMenu" then -- prevents the optionSelect currently in place from being overwritten
            local lp = 0
            local oS = optionSelect:new(selOption)
        elseif menuIndex[#menuIndex].tag == "tossMenu" then
            local oS = tossSelect:new(selOption)
        end
    end
end

function changeUIInfo(tableOne,tableTwo)
    local tebN = {}
    if tableOne == nil then
        if limitQuery("player") == true then
            tebN = BattleInfoStrings.HasLimit
        else
            tebN = BattleInfoStrings.NoLimit
        end
    else
        tebN = tableOne
    end
    if UIIndex ~= nil then
        for i,v in pairs(UIIndex) do
            if v.tag == "UIInfo" then
                if tableTwo then
                    v:newTable(tebN,tableTwo)
                else
                    v:newTable(tebN)
                end
            end
        end
    end
end

function getDeck(deck) -- get icons to appear for each item in the deck.
    local iconTable = {}
    local nameTable = {}
    local portTable = {}
    local costTable = {}
    local phaseTable = {}
    local characterTable = {}
    local notAllowedForms = {}
    local ccAmountTable = {}
    for i,v in pairs(deck) do
        for k,c in pairs(cards) do
            if v == c.cNumber then
                if c.cPhases ~= CurrentPhase then
                    --do something to sorta grey out the icons that can't be used
                end
                iconTable[i] = c.mIcon
                nameTable[i] = c.cName
                portTable[i] = c.cPortrait
                costTable[i] = c.cCost
                phaseTable[i] = c.cPhases
                characterTable[i] = c.cAllowed
                notAllowedForms[i] = c.cNForms
                ccAmountTable[i] = c.cCost 
            end
        end
    end
    local availability = {phaseTable,characterTable,notAllowedForms,ccAmountTable}
    return iconTable,nameTable,portTable,costTable,availability
end

class('LifeBar').extends(gfx.sprite) -- the HP meter for combatants

function LifeBar:init(position, HP)
    LifeBar.super.init(self)
    self.max = HP
    self.currentHP = HP
    self.position = position  -- Store the position for reuse

    if position == "enemy" then
        self:moveTo(320, 20)
        local bg = RectangleBox(319, 19, 102, 22) -- supposed to be white
        self.tag = "enemyHP"
    elseif position == "player" then
        self:moveTo(80, 20)
        local bg = RectangleBox(79, 19, 102, 22)
        self.tag = "playerHP"
    end

    self.initL = false
    self.intHP = 0

    self:updateHP(self.currentHP)

    local numberO = #otherIndex
    self.index = numberO + 1
    lifeBarIndex[self.tag] = self

    self:add()
end

function LifeBar:updateHP(newHP)
    local maxWidth = 100
    local height = 10
    local lifeBarWidth = (newHP / self.max) * maxWidth  -- Scale HP to bar width
    local lifeBarImage = gfx.image.new(maxWidth, height)
    gfx.pushContext(lifeBarImage)
    gfx.setColor(gfx.kColorWhite)
    gfx.fillRect(0, 0, lifeBarWidth, height)
    gfx.popContext()
    self:setZIndex(251)
    self:setImage(lifeBarImage)
end

function LifeBar:damage(damageAmount, completionFunc)
    local startHP = self.currentHP
    local targetHP = self.currentHP - damageAmount
    if targetHP < 0 then
        targetHP = 0
    end
    if damageAmount == 0 then
        completionFunc()
    end

    local step = (startHP - targetHP) / 20 
    local duration = 100 
    local interval = duration / 20  

    local function animateStep()
        if math.abs(self.currentHP - targetHP) < step then
            self.currentHP = targetHP
            self:updateHP(self.currentHP)
            if completionFunc then
                completionFunc()
            end
            return
        end
        self.currentHP = self.currentHP - step
        if self.currentHP < targetHP then
            self.currentHP = targetHP
        end
        self:updateHP(self.currentHP)
        playdate.timer.performAfterDelay(interval, animateStep)
    end
    
    animateStep()
end

topUI = playdate.ui.gridview.new(0, 25)
topUI.__index = topUI

function topUI:new(side, cName) -- sprite text for character names.
    local o = setmetatable({}, topUI)

    o.text = cName

    o.w = 200 -- width is constant
    o.h = 30  -- height is constant

    if side == "left" then
        o.x = 0
    elseif side == "right" then
        o.x = 200
    else
        error("Invalid side: " .. tostring(side))
    end
    o.y = 0 -- y is constant

    o:setNumberOfColumns(1)
    o:setNumberOfRows(1)
    o:setCellPadding(0, 0, 0, 0)
    o:setContentInset(0, 0, 0, 0)

    o.sprite = gfx.sprite.new()
    o.sprite:setCenter(0, 0)
    o.sprite:setZIndex(#UIIndex + 250)
    o.sprite:add()

    o.needsDisplay = true

    local countI = 0
    for _ in pairs(UIIndex) do 
        countI = countI + 1 
    end

    o.index = countI + 1
    UIIndex[o.index] = o

    return o
end

function topUI:spriteKill()
    self.sprite:remove()
end

function topUI:menuUpdate()
    if self.needsDisplay then
        local UIImage = gfx.image.new(self.w, self.h, gfx.kColorBlack)
        self.sprite:moveTo(self.x, self.y)

        gfx.pushContext(UIImage)
            self:drawInRect(0, 0, self.w, self.h)
        gfx.popContext()
        self.sprite:setImage(UIImage)

        self.needsDisplay = false
    end
end

function topUI:drawCell(section, row, column, selected, x, y, width, height)
    gfx.setFont(sysFNT.smDBFont)
    local original_draw_mode = gfx.getImageDrawMode()
    gfx.setImageDrawMode(gfx.kDrawModeInverted)
    gfx.drawTextInRect(self.text, x, y - 2, width, height, nil, truncationString, kTextAlignment.center)
    gfx.setImageDrawMode(original_draw_mode)
    gfx.setFont(sysFNT.dbFont)
end

class('VsEmblem').extends(gfx.sprite) -- the dividing emblem at the top-center of the arena\battle menu

function VsEmblem:init()
    VsEmblem.super.init(self)

    local vsImage = gfx.image.new('/assets/images/background/vsEmblemw90h45.png')

    local vsSprite = gfx.sprite.new()
    vsSprite:setCenter(0,0)
    vsSprite:moveTo(155,0)

    local zInd = #otherIndex + 260
    vsSprite:setZIndex(zInd)
    vsSprite:setImage(vsImage)
    function self:spriteKill()
        for i,v in pairs(otherIndex) do
            if v.vs then
                vsSprite:remove()
                otherIndex[i] = nil
            end
        end
    end

    vsSprite:add()

    self.vs = true

    local numberO = #otherIndex + 1
        
    self.index = numberO
    otherIndex[numberO] = self
end

battleUIMenu = playdate.ui.gridview.new(0, 25)
battleUIMenu.__index = battleUIMenu

function battleUIMenu:new(phase)
    local o = playdate.ui.gridview.new(20, 20)
    setmetatable(o, self)
    
    o.phase = phase
    o:initOptions()
    o:initGridView()
    
    o.bInfoSpr = gfx.sprite.new()
    o.bInfoSpr:setCenter(0, 0)
    o.bInfoSpr:setZIndex(105 + #menuIndex)
    o.bInfoSpr:add()
    
    o.tag = "battleUI"
    o.index = #menuIndex + 1
    menuIndex[o.index] = o

    local STable = o:initBattleInfoStrings()
    local bNfoBx = battleInfoBox:new(STable)
    
    return o
end

function battleUIMenu:initOptions()
    if limitQuery("player") == true then
        self.options = {
            [1] = 1,
            [2] = 1,
            [3] = 9,
            [4] = 13
        }
        self.STable = BattleInfoStrings.HasLimit
    else
        self.options = {
            [1] = 1,
            [2] = 9,
            [3] = 13
        }
        self.STable = BattleInfoStrings.NoLimit
    end
end

function battleUIMenu:initGridView()
    self:setNumberOfColumns(#self.options)
    self:setNumberOfRows(1)
    self:setCellPadding(10, 10, 0, 0)
    self:setContentInset(0, 0, 0, 0)
    self.scrollCellsToCenter = false
    self:removeHorizontalDividers()
    self:setScrollDuration(0)
end

function battleUIMenu:spriteKill()
    self.bInfoSpr:remove()
end

function battleUIMenu:getOption()
    local itemS = nil
    for _, k in pairs(UIIndex) do
        if k.tag == "UIInfo" then
            itemS = k.sTable[k:getSelectedRow()]
        end
    end
    return itemS, self.phase
end

function battleUIMenu:menuUpdate()
    if self.needsDisplay then
        local UIImage = gfx.image.new(304, 20, gfx.kColorBlack)
        self.bInfoSpr:moveTo(96, 200)

        gfx.pushContext(UIImage)
            self:drawInRect(0, 0, 304, 20)
        gfx.popContext()
        self.bInfoSpr:setImage(UIImage)
    end
end

function battleUIMenu:drawCell(section, row, column, selected, x, y, width, height)
    gfx.setColor(gfx.kColorWhite)

    if selected then
        gfx.fillRect(x + 2, y, 24, 16)
        gfx.fillTriangle(x + 25, y, x + 36, y + 16, x + 25, y + 16)
    end

    local fontHeight = gfx.getFont():getHeight()
    for i, v in pairs(self.options) do
        if i == column then
            gfx.setImageDrawMode(gfx.kDrawModeNXOR)
            miniIcons:drawImage(v, x + 5, y)
        end
    end
end

function battleUIMenu:initBattleInfoStrings() --checks to see if the player is able to use limit decks.
    if limitQuery("player") then
        return BattleInfoStrings.HasLimit
    else
        return BattleInfoStrings.NoLimit
    end
end

battleInfoBox = playdate.ui.gridview.new(0, 40) -- this is the little window that tells the player what each item does.
battleInfoBox.__index = battleInfoBox

function battleInfoBox:new(selTable)
    local o = playdate.ui.gridview.new(0, 40)
    setmetatable(o, self)
    
    o.sTable = selTable
    o.oldTable = {}
    o.available = {} -- for availability of a selection in joint deck based on current phase
    o:setNumberOfColumns(1)
    o:setNumberOfRows(#o.sTable)
    o:setCellPadding(0, 0, 0, 0)
    o:setContentInset(0, 0, 0, 0)

    o.bBottomM = gfx.sprite.new()
    o.bBottomM:setCenter(0, 0)
    o.bBottomM:setZIndex(110)
    o.bBottomM:add()

    o.tag = "UIInfo"
    o.index = #UIIndex + 1
    UIIndex[o.index] = o

    return o
end

function battleInfoBox:newTable(newTable, phaseTable)
    self.oldTable = self.sTable
    self.sTable = newTable
    if phaseTable then
        self.available = phaseTable
    end
    self:updateSelection()
end

function battleInfoBox:updateSelection()
    local sS, sR, sC = 0, 0, 0
    for i, v in pairs(menuIndex) do
        if i == #menuIndex then
            sS, sR, sC = v:getSelection()
        end
    end
    self:setNumberOfRows(#self.sTable)
    self:setSelectedRow(sC)
    self:selectNextRow(true, true, false)
    self:selectPreviousRow(true, true, false) -- to update screen
end

function battleInfoBox:restorePrevTab()
    self.sTable = self.oldTable
    self:updateSelection()
end

function battleInfoBox:spriteKill()
    self.bBottomM:remove()
end

function battleInfoBox:menuUpdate()
    if self.needsDisplay then
        local bottUIImg = gfx.image.new(304, 40, gfx.kColorWhite)
        self.bBottomM:moveTo(96, 215)
        gfx.pushContext(bottUIImg)
            self:drawInRect(0, 0, 304, 40)
        gfx.popContext()
        self.bBottomM:setImage(bottUIImg)
    end
end

function battleInfoBox:drawCell(section, row, column, selected, x, y, width, height)
    local fontHeight = gfx.getFont():getHeight()
    for i, v in pairs(self.sTable) do
        if i == row then
            gfx.drawTextInRect(self.sTable[i], x + 5, y + 5, width, height, nil, truncationString, kTextAlignment.left)
        end
    end
end

jointDeck = playdate.ui.gridview.new(20, 20)
jointDeck.__index = jointDeck

function jointDeck:new() -- This is created when the player selects the Joint Deck in the battle menu
    local o = playdate.ui.gridview.new(20, 20)
    setmetatable(o, self)
    
    o.icons, o.names, o.ports, o.costs, o.conditions = getDeck(playerDeck)
    o.selectable = {}

    o:initGridView()
    o:initSprite()

    o.tag = "jointDeck"
    o.index = #menuIndex + 1
    menuIndex[o.index] = o

    changeUIInfo(o.names, o.conditions)
    
    return o
end

function jointDeck:initGridView()
    self:setNumberOfColumns(#self.icons)
    self:setNumberOfRows(1)
    self:setCellPadding(5, 5, 0, 0)
    self:setContentInset(0, 0, 0, 0)
    self:setScrollDuration(0)
end

function jointDeck:initSprite()
    self.jointSpr = gfx.sprite.new()
    self.jointSpr:setCenter(0, 0)
    self.jointSpr:setZIndex(107 + #menuIndex)
    self.jointSpr:add()
end

function jointDeck:spriteKill()
    self.jointSpr:remove()
    menuIndex[self.index] = nil
    changeUIInfo()
end

function jointDeck:getOption()
    for _, v in pairs(UIIndex) do
        if v.tag == "UIInfo" then
            local selectedRow = v:getSelectedRow()
            if self.selectable[selectedRow] then
                return v.sTable[selectedRow]
            else
                return "notAvailable"
            end
        end
    end
    return nil
end

function jointDeck:menuUpdate()
    if self.needsDisplay then
        local JDImage = gfx.image.new(304, 20, gfx.kColorBlack)
        self.jointSpr:moveTo(96, 200)
        gfx.pushContext(JDImage)
            self:drawInRect(0, 0, 304, 20)
        gfx.popContext()
        self.jointSpr:setImage(JDImage)
    end
end

function jointDeck:drawCell(section, row, column, selected, x, y, width, height)
    gfx.setColor(gfx.kColorWhite)
    if selected then
        gfx.fillRect(x + 2, y, 24, 16)
        gfx.fillTriangle(x + 25, y, x + 36, y + 16, x + 25, y + 16)
    end

    local fontHeight = gfx.getFont():getHeight()
    for i, v in pairs(self.icons) do
        if i == column then
            local cardAvailable = availabilityCheck(i, self.conditions)
            self.selectable[i] = cardAvailable
            if cardAvailable then
                gfx.setImageDrawMode(gfx.kDrawModeNXOR)
            else
                gfx.setImageDrawMode(gfx.kDrawModeBlackTransparent)
            end
            miniIcons:drawImage(v, x + 5, y)
        end
    end
end

batCom = playdate.ui.gridview.new(0, 0)
batCom.__index = batCom

function batCom:new() -- This is created when the player selects basic commands
    local o = playdate.ui.gridview.new(20, 20)
    setmetatable(o, self)
    
    o.icons, o.names, o.ports = abilityGet()
    o:initGridView()
    o:initSprite()
    
    o.tag = "batCom"
    o.index = #menuIndex + 1
    menuIndex[o.index] = o
    
    changeUIInfo(o.names)
    
    return o
end

function batCom:initGridView()
    self:setNumberOfColumns(#self.icons)
    self:setNumberOfRows(1)
    self:setCellPadding(5, 5, 0, 0)
    self:setContentInset(0, 0, 0, 0)
    self:setScrollDuration(0)
end

function batCom:initSprite()
    self.batSpr = gfx.sprite.new()
    self.batSpr:setCenter(0, 0)
    self.batSpr:setZIndex(107 + #menuIndex)
    self.batSpr:add()
end

function batCom:spriteKill()
    self.batSpr:remove()
    menuIndex[self.index] = nil
    changeUIInfo()
end

function batCom:getOption()
    for _, v in pairs(UIIndex) do
        if v.tag == "UIInfo" then
            return v.sTable[v:getSelectedRow()]
        end
    end
    return nil
end

function batCom:menuUpdate()
    if self.needsDisplay then
        local JDImage = gfx.image.new(304, 20, gfx.kColorBlack)
        self.batSpr:moveTo(96, 200)

        gfx.pushContext(JDImage)
            self:drawInRect(0, 0, 304, 20)
        gfx.popContext()
        self.batSpr:setImage(JDImage)
    end
end

function batCom:drawCell(section, row, column, selected, x, y, width, height)
    gfx.setColor(gfx.kColorWhite)

    if selected then
        gfx.fillRect(x + 2, y, 24, 16)
        gfx.fillTriangle(x + 25, y, x + 36, y + 16, x + 25, y + 16)
    end

    local fontHeight = gfx.getFont():getHeight()

    for i, v in pairs(self.icons) do
        if i == column then
            gfx.setImageDrawMode(gfx.kDrawModeNXOR)
            miniIcons:drawImage(v, x + 5, y)
        end
    end
end

optionSelect = playdate.ui.gridview.new(0, 0)
optionSelect.__index = optionSelect

optionSelect.backgroundImage = gfx.nineSlice.new("assets/images/textBorder", 10, 10, 16, 16)

function optionSelect:new(selItem)
    local o = setmetatable(playdate.ui.gridview.new(50, 30), self)
    
    o:initOptions(selItem)
    o:initSprite()
    
    o.tag = "optionSelect"
    o.index = #menuIndex + 1
    menuIndex[o.index] = o
    
    return o
end

function optionSelect:initOptions(selItem)
    self.parentItem = selItem
    self.menuTable = {"Details", "Use"}
    
    self:setNumberOfRows(1)
    self:setNumberOfColumns(#self.menuTable)
    self:setCellPadding(0, 30, 0, 0)
    self:setContentInset(0, 0, 0, 0)
    self.scrollCellsToCenter = false
    self:setScrollDuration(0)
    
    self.selectionType = menuIndex[#menuIndex].tag
end

function optionSelect:initSprite()
    self.menuSprite = gfx.sprite.new()
    self.menuSprite:setCenter(0, 0)
    self.menuSprite:setZIndex(#menuIndex + 170)
    self.menuSprite:add()
end

function optionSelect:spriteKill()
    self.menuSprite:remove()
    menuIndex[self.index] = nil
end

function optionSelect:getOption()
    local sS, sR, sC = self:getSelection()
    if self.menuTable[sC] == "Details" then
        bShowCard(self.parentItem)
    elseif self.menuTable[sC] == "Use" then
        PlayerSelection = self.selectionType
        if not deckCheck() or PlayerSelection == "jointDeck" or PlayerSelection == "limit" then
            goOption(self.parentItem, "player")
        else
            fullHand(self.parentItem)
        end
    end
end

function optionSelect:menuUpdate()
    if self.needsDisplay then
        local menuImage = gfx.image.new(150, 30, gfx.kColorWhite)
        self.menuSprite:moveTo(120, 180)

        gfx.pushContext(menuImage)
            self:drawInRect(0, 0, 150, 30)
        gfx.popContext()
        
        self.menuSprite:setImage(menuImage)
    end
end

function optionSelect:drawCell(section, row, column, selected, x, y, width, height)
    if selected then
        gfx.fillTriangle(x + 15, y + 8, x + 15, y + 23, x + 25, y + 15)
    end

    gfx.drawTextInRect(self.menuTable[column], x + 26, y + 10, width, height, nil, truncationString, kTextAlignment.left)
end

moveUIInfo = playdate.ui.gridview.new(0,0) --information for the slot selected in the moveField

function moveUIInfo:new(selTable1,selTable2)
    local o = playdate.ui.gridview.new(0,40)
    setmetatable(o,self)
    self.__index=self

    print("selTable1 has "..tostring(#selTable1).."elements of:")
    for i,v in pairs(selTable1) do
        print(tostring(i)..") "..selTable1[i])
    end

    o.gTable = movDesc(selTable1)
    if selTable2 ~= nil then
        o.aTable = movDesc(selTable2)
        o.rowTrig = true
        o:setNumberOfColumns(2)
    else
        o.rowTrig = false
        o:setNumberOfColumns(1)
    end

    o:setNumberOfRows(#o.gTable)
    o:setCellPadding(0,0,0,0)
    o:setContentInset(0,0,0,0)
    o:setScrollDuration(0)

    o.current = nil

    local bBottomM = gfx.sprite.new()
    bBottomM:setCenter(0,0)
    local zInd = 120
    bBottomM:setZIndex(zInd)
    
    function o:spriteKill()
        bBottomM:remove()
        UIIndex[o.index] = nil
    end

    bBottomM:add()

    function o:menuUpdate()
        if o.needsDisplay then
            local bottUIImg = gfx.image.new(304,40,gfx.kColorWhite)
            bBottomM:moveTo(96,215)
            gfx.pushContext(bottUIImg)
                o:drawInRect(0,0,304,40)
            gfx.popContext()
            bBottomM:setImage(bottUIImg)
        end
    end

    function o:drawCell(section, row, column, selected, x, y, width, height)
        if column == 1 then
            local text = o.gTable[row] or ""
            gfx.drawTextInRect(text, x + 5, y + 5, width - 10, height - 10, nil, truncationString, kTextAlignment.left)
            o.current = text
        elseif o.rowTrig and column == 2 then
            local text = o.aTable[row] or ""
            gfx.drawTextInRect(text, x + 5, y + 5, width - 10, height - 10, nil, truncationString, kTextAlignment.left)
            o.current = text
        end
    end

    o.tag = "movementUIInfo"

    o.index = #UIIndex + 1
    UIIndex[o.index] = o
end

--Generic battle dialogue box

batDialogue = playdate.ui.gridview.new(0, 20)
batDialogue.__index = batDialogue

batDialogue:setNumberOfColumns(1)
batDialogue:setCellPadding(0, 0, 4, 0)
batDialogue:setContentInset(5, 5, 5, 5)
batDialogue.backgroundImage = gfx.nineSlice.new("assets/images/textBorder", 10, 10, 16, 16)

function batDialogue:new(diTable) -- indicate which dialogue from dialogueTable to be rendered.
    local o = setmetatable({}, self)
    
    o:initOptions(diTable)
    o:initSprite()
    
    o.tag = "batDialogue"
    o.index = #menuIndex + 1
    menuIndex[o.index] = o
    
    return o
end

function batDialogue:initOptions(diTable)
    local menuX, menuY = 200, 50 -- size of background box
    local xPos, yPos = 10, 200
    self:setScrollDuration(0)

    if dialogueTable[diTable] then
        self.optionsRow = dialogueTable[diTable]
        self.type = "diTable"
    else
        self.optionsRow = {diTable}
        self.type = "msg"
    end
    if self.type == "msg" then
        menuX, menuY = 400,50
        xPos, yPos = 0, 200
    end

    self:setNumberOfRows(#self.optionsRow)
    self.menuX = menuX
    self.menuY = menuY
    self.xPos = xPos
    self.yPos = yPos
end

function batDialogue:initSprite()
    self.batDSprite = gfx.sprite.new()
    self.batDSprite:setCenter(0, 0)
    self.batDSprite:setZIndex(480)
    self.batDSprite:add()
end

function batDialogue:spriteKill()
    self.batDSprite:remove()
    table.remove(menuIndex,self.index)
end

function batDialogue:menuUpdate()
    if self.needsDisplay then
        local batDImage = gfx.image.new(self.menuX, self.menuY, gfx.kColorWhite)
        self.batDSprite:moveTo(self.xPos, self.yPos)
        
        gfx.pushContext(batDImage)
            self:drawInRect(0, 0, self.menuX, self.menuY)
        gfx.popContext()
        
        self.batDSprite:setImage(batDImage)
    end
end

function batDialogue:drawCell(section, row, column, selected, x, y, width, height)
    local menuText = self.optionsRow
    local fontHeight = gfx.getSystemFont():getHeight()

    for i, v in pairs(menuText) do
        if row == i then
            local rowCom = " " .. v
            gfx.drawTextInRect(rowCom, x + 2, y + (height / 2 - fontHeight / 2) + 2, width, height, nil, truncationString, kTextAlignment.left)
        end
    end
end
function batDialogue:menuControl(direction)
    if direction == "a" and self.type == "diTable" then
        self:spriteKill()
        for i, v in ipairs(menuIndex) do
            if v == self then
                table.remove(menuIndex, i)
                break
            end
        end
        tossMenuInit()
    end
end


function batDialogue:killTimer(duration)
    local kTimer = playdate.timer.new(duration, function() self:spriteKill() end)
end

dialogueTable = {
    ["fullHand"] = {"Your hand is full."},
    ["cardToss"] = {"Select a card to toss."}
}

function tossMenuInit()
    for i,v in pairs(menuIndex) do
        if v.tag == "batDialogue" then
            v:spriteKill()
            menuIndex[i] = nil
        end
        if v.tag == "optionSelect" then
            v:spriteKill()
            menuIndex[i] = nil
        end
    end
    tossMenu:new()
    SubMode = SubEnum.MENU
end



tossMenu = playdate.ui.gridview.new(20, 20)
tossMenu.__index = tossMenu

function tossMenu:new() -- This is created when the player must discard an item from their hand.
    local o = playdate.ui.gridview.new(20, 20)
    setmetatable(o, self)
    
    o.icons, o.names, o.ports, o.costs = getDeck(playerDeck) -- returns no conditions. Any card can be tossed.
    o.selectable = {}

    o:initGridView()
    o:initSprite()

    o.tag = "tossMenu"
    o.index = #menuIndex + 1
    menuIndex[o.index] = o

    changeUIInfo(o.names)
    
    return o
end

function tossMenu:initGridView()
    self:setNumberOfColumns(#self.icons)
    self:setNumberOfRows(1)
    self:setCellPadding(5, 5, 0, 0)
    self:setContentInset(0, 0, 0, 0)
    self:setScrollDuration(0)
end

function tossMenu:initSprite()
    self.jointSpr = gfx.sprite.new()
    self.jointSpr:setCenter(0, 0)
    self.jointSpr:setZIndex(107 + #menuIndex)
    self.jointSpr:add()
end

function tossMenu:spriteKill()
    self.jointSpr:remove()
    table.remove(menuIndex,self.index)
    changeUIInfo()
end

function tossMenu:getOption()
    for _, v in pairs(UIIndex) do
        if v.tag == "UIInfo" then
            local selectedRow = v:getSelectedRow()
            return v.sTable[selectedRow]
        end
    end
    return nil
end

function tossMenu:menuUpdate()
    if self.needsDisplay then
        local JDImage = gfx.image.new(304, 20, gfx.kColorBlack)
        self.jointSpr:moveTo(96, 200)

        gfx.pushContext(JDImage)
            self:drawInRect(0, 0, 304, 20)
        gfx.popContext()
        self.jointSpr:setImage(JDImage)
    end
end

function tossMenu:drawCell(section, row, column, selected, x, y, width, height)
    gfx.setColor(gfx.kColorWhite)
    if selected then
        gfx.fillRect(x + 2, y, 24, 16)
        gfx.fillTriangle(x + 25, y, x + 36, y + 16, x + 25, y + 16)
    end

    local fontHeight = gfx.getFont():getHeight()
    for i, v in pairs(self.icons) do
        if i == column then
            gfx.setImageDrawMode(gfx.kDrawModeNXOR)
            miniIcons:drawImage(v, x + 5, y)
        end
    end
end


tossSelect = playdate.ui.gridview.new(0, 0)
tossSelect.__index = tossSelect

tossSelect.backgroundImage = gfx.nineSlice.new("assets/images/textBorder", 10, 10, 16, 16)

function tossSelect:new(selItem)
    local o = setmetatable(playdate.ui.gridview.new(50, 30), self)
    
    o:initOptions(selItem)
    o:initSprite()
    
    o.tag = "tossSelect"
    o.index = #menuIndex + 1
    menuIndex[o.index] = o
    
    return o
end

function tossSelect:initOptions(selItem)
    self.parentItem = selItem
    self.menuTable = {"Details", "Toss"}
    
    self:setNumberOfRows(1)
    self:setNumberOfColumns(#self.menuTable)
    self:setCellPadding(0, 30, 0, 0)
    self:setContentInset(0, 0, 0, 0)
    self.scrollCellsToCenter = false
    self:setScrollDuration(0)
    
    self.selectionType = menuIndex[#menuIndex].tag
end

function tossSelect:initSprite()
    self.menuSprite = gfx.sprite.new()
    self.menuSprite:setCenter(0, 0)
    self.menuSprite:setZIndex(#menuIndex + 170)
    self.menuSprite:add()
end

function tossSelect:spriteKill()
    self.menuSprite:remove()
    menuIndex[self.index] = nil
end

function tossSelect:getOption()
    local sS, sR, sC = self:getSelection()
    if self.menuTable[sC] == "Details" then
        bShowCard(self.parentItem)
    elseif self.menuTable[sC] == "Toss" then
        tossCard(self.parentItem)
    end
end

function tossSelect:menuUpdate()
    if self.needsDisplay then
        local menuImage = gfx.image.new(150, 30, gfx.kColorWhite)
        self.menuSprite:moveTo(120, 180)

        gfx.pushContext(menuImage)
            self:drawInRect(0, 0, 150, 30)
        gfx.popContext()
        
        self.menuSprite:setImage(menuImage)
    end
end

function tossSelect:drawCell(section, row, column, selected, x, y, width, height)
    if selected then
        gfx.fillTriangle(x + 15, y + 8, x + 15, y + 23, x + 25, y + 15)
    end

    gfx.drawTextInRect(self.menuTable[column], x + 26, y + 10, width, height, nil, truncationString, kTextAlignment.left)
end