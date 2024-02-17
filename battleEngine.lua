--battleEngine
local gfx = playdate.graphics

function bTabInit()
    PositionEnum = {
        GroundFore = "groundfore"
        ,GroundAft = "groundaft"
        ,AirFore = "airfore"
        ,AirAft = "airaft"
    }
    sprBIndex = {}

    ---------------
    --Player Info--
    ---------------

    playerChr={}
    playerTeam={}
    pDeckCopy={} -- copy of RAMSAVE[4]
    playerDeck={}
    playerCC = 3
    playerSprTab = {
        sprRange = {}
        ,current = 0
        ,position = PositionEnum.GroundAft
    }

    bFaster = {} -- will compare speeds of combatants to see who will go first. Evaluated every turn change.

    enemyChr={}
    enemyTeam={}
    eDeckCopy={} -- copy from battle data in the battle database
    enemyDeck={}
    enemyCC = 3
    enemySprTab = {
        sprRange = {}
        ,current = 0
        ,position = PositionEnum.GroundAft
    }

    Phase = {
        ATTACK = "attack"
        ,DEFENSE = "defense"
    }

    CurrentPhase = nil

    ---------------------
    --Menu Enum----------
    ---------------------

    BattleInfoStrings = {
        NoJoint = {
            [1] = "Joint Deck"
            ,[2] = "Basic Command"
            ,[3] = "Character"
        },
        HasJoint = {
            [1] = "Limit Deck"
            ,[2] = "Joint Deck"
            ,[3] = "Basic Command"
            ,[4] = "Character"
        },
        noEntryD = {}
    }

    ---------------------
    --Joint Deck Info ---
    ---------------------

    playerHand = {}
    enemyHand = {}

    UIIndex = {} -- for graphical and gridview objects related to the battle screen

    miniIcons = gfx.imagetable.new('assets/images/background/cardMiniIcon-table-16-16.png')

    BattleRef = {} -- contains all battle data and parameters for later reference. Cleared at the end of every battle.
end

function battleInit(battleTable) -- copy values from tables and player save to create battle-only data
    bTabInit()
    if type(battleTable) ~= "table" then
        print("battle table is not in correct format")
    end
    BattleRef = battleTable
    local initPTeam = {"dbGoku"} -- will eventually pull from table RAMSAVE[5]
    --pDeckCopy = RAMSAVE[4]
    pDeckCopy = {1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10} -- will eventually pull from table RAMSAVE[4]
    playerDeck[1],playerDeck[2],playerDeck[3],pDeckCopy = cardShuffle(pDeckCopy,true)
    local initChr = initPTeam[1] -- simply uses the first player in the team

    local oppTab = battleTable["oppoParam"]
    local initETeam = oppTab.oppoTeam
    local initEChr = initETeam[1]
    eDeckCopy = oppTab.enemyDeck
    --enemyDeck = cardShuffle(eDeckCopy,true)
    enemyDeck = oppTab.enemyDeck

    CurrentPhase = phaseChange(playerChr,enemyChr)

    for i,v in pairs(initPTeam) do -- copy current players in team to battle ram
        local mTab = RAMSAVE[1]
        for j,k in pairs(mTab) do
            if type(k) == "table" then
                if k.chrCode == v then
                    playerTeam[i] = k
                    playerTeam[i].ability = unlockCheck(v,k.chrExp)
                    local lmtChk = playerTeam[i].ability
                    if lmtChk[2] == true then
                        playerTeam[i].limit = k.limit
                    end
                end
            end
        end
    end

    for i,v in pairs(initETeam) do
        for j,k in pairs(characters) do
            if v == j then
                enemyTeam[i] = characters[j]
                local chrLvlT = oppTab.opponentLvl
                enemyTeam[i].ability = unlockCheck(characters[j].chrCode,chrLvlT[i])
                local lmtChk = enemyTeam[i].ability
                if lmtChk[2] == true then
                    enemyTeam[i].limit = oppTab.opponentLimit[i]
                end
                --Next, do calculations to set stats according to [oppoParam].opponentLvl and insert .opponentLimit, .hasFly, hasLimit, transformation etc
            end
        end
    end
    playerChr = playerTeam[1]
    enemyChr = enemyTeam[1]

    gameModeChange(GameMode.BATTLE)
    SubMode = SubEnum.NONE
    --Battle start screen
    battleIntro(playerChr.chrCode,#playerTeam,enemyChr.chrCode,#enemyTeam)
    battleSpriteSet(BattleRef)
    drawUI()

end

function phaseChange(playerChr,enemyChr)
    return Phase.ATTACK
end

function cardShuffle(deck,initial)
    local cSelect = nil
    local cCount = 1
    local cOne, cTwo, cThree
    local tempTab = {cOne, cTwo, cThree}
    local emptyTest = 0 -- if this number reaches 20, then the deck is empty and no card is drawn.
    if initial == true then
        cCount = 3
    end
    for i=1,cCount,1 do
        cSelect = nil
        while cSelect == nil do
            cSelect  = deck[math.random(1, #deck)] 
            if cSelect ~= nil then
                local spec = false
                for k,c in pairs(deck) do
                    if spec == false then
                        if c == cSelect then
                            deck[k]=nil -- card is no longer in the deck and is either discarded or in the hand
                            spec = true -- since cards are removed one at a time, this eliminates the first card found.
                        end
                    end
                end
                tempTab[i] = cSelect
            end
            emptyTest = emptyTest + 1
            if emptyTest >= #deck then
                return "No Cards Remaining"
            end
        end
    end
    
    if initial == true then
        return tempTab[1],tempTab[2],tempTab[3],deck
    else
        return tempTab[1],deck
    end
end

function battleIntro(chr1,T1,chr2,T2)
    -- create battle start screen.
    -- chr1 and chr2 are the portraits and names to be displayed
    --T1 and T2 are the number of team members for the icon that shows up on the battle screen for 2+ team members.

    --ba da ba da ba ba baa ba da da baaaaaaaaa
    --when done, return
    return 0
end

---------------------
-- BATTLE GRAPHICS --
---------------------
function battleSpriteSet(bTable)
    bgChange(bTable["arenaParam"].bField)
    enemySprTab.sprRange = arenaSpriteSelect(enemyChr)
    playerSprTab.sprRange = arenaSpriteSelect(playerChr)
    arenaSpriteMode("player","normal")
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

function drawChr(chr)
    if chr == "player" then
    elseif chr == "enemy" then
    end
end

function drawArena()
-- Draw players in the different positions. 
--draw UI and lifebars
--Do top UI turn animations and Defense\attack animations
--create gridview after animations that have options based on above characteristics

end

function drawUI()
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
    local bMenu = battleUIMenu:new(Phase.ATTACK) --also spawns battleInfoBox

    SubMode = SubEnum.MENU
end

function fillGauge()
    local enLife = LifeBar("enemy",enemyChr.chrHp)
    local plLife = LifeBar("player",playerChr.chrHp)
    --do animation to fill life gauges, possibly by incrementing the width of a rectangle until a max width is reached
    
end

-------------------
--ARENA FUNCTIONS--
-------------------

function chrPlacement(chr,position)--where chr is enemyChr or playerChr and position is PositionEnum entry
    -- changes the position variable for chr to position. 
end

----------------------
--SELECTION FUNCTION--
----------------------

function getNextBMenu(selOption,phase) --gets the selected option and creates the next menu level based on that.
    --Limit
    if selOption == "Limit" then

    --Joint
    elseif selOption == "Joint Deck" then
        local jD = jointDeck:new()
    --Basic Commands
    elseif selOption == "Basic Commands" then

    --Character
    elseif selOption == "Character" then
        chrData(playerTeam,"battle")
    end
end

--[[
local cardStats = {
    Type = "Attack", -- or "Defense" or "Support"
    AttackRating = 10,
    DefenseRating = 5,
    Effect = nil,
    AccuracyRating = 90
}

local positionalBonuses = {
    --["Position"] = {DefBonus, StrBonus, KiBonus}
    ["Ground Aft"] =0-- Bonus Def, Ki Defense, Phys Penalty
    ,["Ground Fore"] =0-- STR Bonus, KI Defense, Phys Penalty
    ,["Air Aft"] =0-- DEF Bonus, Ki Penalty, Phys Defense
    ,["Air Fore"] =0-- KI Bonus, Ki Penalty, Phys Defense
}
-- Functions
local function calculateDerivedStats(character, phaseType) --pass character name and the phase they are in for appropriate stats
    if phaseType == attack then
        local calcOFF = character.STR + character.KI
        local calcEVA = character.SPD + character.DEF
        return calcOFF, calcEVA
    elseif phaseType == defense then
        local calcMAS = character.STR + character.DEF
        local calcACC = character.SPD + character.KI -- Modify as needed
        return calcMAS, calcACC 
    else
        print("error in battleEngine calculateDerivedStats")
    end
end

local function calculateEvasion(defender)
    return math.sqrt(defender.SPD + defender.DEF)
end

local function determineAttackOutcome(attacker, defender, card) --only if an attacker uses an attack card and the defender uses Guard
    local hitChance = attacker.ACCURACY - calculateEvasion(defender)
    local isCritical = false

    if hitChance > 100 then
        local critChance = math.min(hitChance - 100, 50)
        isCritical = math.random(100) <= critChance
        hitChance = 100
    end

    local doesHit = math.random(100) <= hitChance

    return doesHit, isCritical
end

local function calculateDamage(attacker, defender, isCritical)
    local damage = defender.DEF - (attacker.STR or attacker.KI) -- Depending on the type of attack
    if isCritical then
        damage = damage * 1.5 -- Assuming critical hits do 1.5x damage, adjust as needed
    end
    return damage
end

local function calculateKnockback(attacker, defender)
    local knockbackChance = (attacker.OFFENSE / defender.MASS) * 100
    -- Use the table you provided to determine the final knockback percentage
    -- Example: if knockbackChance is between 200% and 190%, set it to 100%
    return knockbackChance
end

local function applyDamage(defender, damage)
    defender.HP = defender.HP - damage
end

local function postAttackChecks(player, opponent)
    if player.HP < 1 then
        -- Check for more characters in the player's team
        -- If none, opponent wins
    end
    if opponent.HP < 1 then
        -- Check for more characters in the opponent's team
        -- If none, player wins
    end
    -- Swap roles for next phase
    player, opponent = opponent, player
end

-- Game Loop (simplified for demonstration)
while true do
    -- Initialization, Turn Sequence, End Conditions
    -- This is a placeholder; the actual game loop would be more complex and involve user input, UI updates, etc.
end
]]--

---------------------------
--Battle Gridview Objects--
---------------------------
topUI = playdate.ui.gridview.new(0,25)

function topUI:new(side,cName) -- where bgD is the background color

    local o = o or {}
    setmetatable(o,self)
    self.__index=self

    o.text = cName

    o.w = 200 -- w and h are constant
    o.h = 30

    if side == "left" then
        o.x = 0
    elseif side == "right" then
        o.x = 200
    end
    o.y = 0 -- y is constant

    topUI:setNumberOfColumns(1)
    topUI:setNumberOfRows(1)
    topUI:setCellPadding(0,0,0,0)
    topUI:setContentInset(0,0,0,0)

    local topUISprite = gfx.sprite.new()
    topUISprite:setCenter(0, 0)

    function o:spriteKill()
        topUISprite:remove()
    end

    topUISprite:add()

    function o:menuUpdate()
        if o.needsDisplay then
            local UIImage = gfx.image.new(o.w,o.h,gfx.kColorBlack)
            topUISprite:moveTo(o.x, o.y)
            local zInd = #UIIndex + 50
            topUISprite:setZIndex(zInd)
            gfx.pushContext(UIImage)
                o:drawInRect(0,0,o.w,o.h)
            gfx.popContext()
            topUISprite:setImage(UIImage)
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)
        gfx.setFont(sysFNT.smDBFont)
        local original_draw_mode = gfx.getImageDrawMode()
        gfx.setImageDrawMode( playdate.graphics.kDrawModeInverted )
        o.align = kTextAlignment.center
        gfx.drawTextInRect(o.text, x, y-2 , width, height, nil, truncationString, o.align)
        gfx.setImageDrawMode( original_draw_mode )
        gfx.setFont(sysFNT.dbFont)
    end

    local countI = 0
    for _ in pairs(UIIndex) do 
        countI = countI + 1 
    end

    o.index = countI + 1
    UIIndex[o.index] = o
    return o
end

class('BattleMiniSpr').extends(gfx.sprite)

function BattleMiniSpr:init(tag)
    BattleMiniSpr.super.init(self)

    local oTable = gfx.imagetable.new('assets/images/battleSprites-table-16-16.png')

    local mSpr = gfx.sprite.new()

    mSpr:setCenter(0,0)
    mSpr:moveTo(areaPosition(tag))

    local zInd = #sprBIndex + 105
    mSpr:setZIndex(zInd)

    local selImage = nil
    if tag == "player" then
        selImage = (oTable:getImage(playerSprTab.current))
        mSpr:setImage(selImage,gfx.kImageUnflipped,2)
    elseif tag == "enemy" then
        selImage = (oTable:getImage(enemySprTab.current))
        mSpr:setImage(selImage,gfx.kImageFlippedX,2)
    end

    self.tag = tag

    function self:spriteKill()
        mSpr:remove()
        for i,v in pairs(sprBIndex) do
            if v.tag == "enemy" or v.tag == "player" then
                sprBIndex[i] = nil
            end
        end
    end

    mSpr:add()

    local numberO = #sprBIndex + 1
    self.index = numberO
    sprBIndex[numberO] = self
end

class('VsEmblem').extends(gfx.sprite)

function VsEmblem:init()
    VsEmblem.super.init(self)

    local vsImage = gfx.image.new('/assets/images/background/vsEmblemw90h45.png')

    local vsSprite = gfx.sprite.new()
    vsSprite:setCenter(0,0)
    vsSprite:moveTo(155,0)

    local zInd = #otherIndex + 105
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


class('LifeBar').extends(gfx.sprite)

function LifeBar:init(position,HP)
    LifeBar.super.init(self)
    self.max = HP
    self.currentHP = HP

    if position == "enemy" then
        self:moveTo(320,20)
        local bg = RectangleBox(319,19,102,22) -- supposed to be white
        self.tag = "enemyHP"
    elseif position == "player" then
        self:moveTo(80,20)
        local bg = RectangleBox(79,19,102,22)
        self.tag = "playerHP"
    end

    self.initL = false
    self.intHP = 0

    self:updateHP(position,HP)

    local numberO = #otherIndex
    self.index = numberO + 1
    otherIndex[self.index] = self

    self:add()
end

function LifeBar:updateHP(position,nHP)
    local maxWidth = 100
    local height = 10
    local lifeBarWidth = (nHP / self.max) * maxWidth -- ensure maxWidth is not the same as self.max (max HP from chr table)
    local lifeBarImage = gfx.image.new(maxWidth,height)
    gfx.pushContext(lifeBarImage)
    gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0,0,lifeBarWidth,height)
    gfx.popContext()
    self:setZIndex(#otherIndex + 107)
    self:setImage(lifeBarImage)
end

function LifeBar:damage(position,damage)
    self.currentHP -= damage
    if self.currentHP <= 0 then
        self.currentHP = 0
    end
    self:updateHP(position,self.HP)
end

battleUIMenu = playdate.ui.gridview.new(0,25)

function battleUIMenu:new(phase)
    local o = playdate.ui.gridview.new(20,20)
    setmetatable(o,self)
    self.__index=self

    o.phase = phase

    --establish contents of the entire gridview before continuing
    local STable = nil
    if limitQuery() == true then
        o.options = {
            [1] = 1
            ,[2] = 1
            ,[3] = 9
            ,[4] = 13
        }
        STable = BattleInfoStrings.HasJoint
    else
        o.options = {            
            [1] = 1
            ,[2] = 9
            ,[3] = 13
        }
        STable = BattleInfoStrings.NoJoint
    end

    o:setNumberOfColumns(#o.options)
    o:setNumberOfRows(1)
    o:setCellPadding(10,10,0,0)
    o:setContentInset(0,0,0,0)
    o.scrollCellsToCenter = false
    o:removeHorizontalDividers()
    o:setScrollDuration(0)

    local bInfoSpr = gfx.sprite.new()
    bInfoSpr:setCenter(0,0)
    
    function o:spriteKill()
        bInfoSpr:remove()
    end
    
    bInfoSpr:add()

    function o:getOption() -- item selection in menu
        local itemS = nil
        for j,k in pairs(UIIndex) do
            if k.tag == "UIInfo" then
                itemS = k.sTable[k:getSelectedRow()]
            end
        end
        return itemS,o.phase
    end

    function o:menuUpdate()
        if o.needsDisplay then
            local UIImage = gfx.image.new(304,20,gfx.kColorBlack)
            bInfoSpr:moveTo(96,200)

            local zInd = 105 + #menuIndex
            bInfoSpr:setZIndex(zInd)

            gfx.pushContext(UIImage)
                o:drawInRect(0,0,304,20)
            gfx.popContext()
            bInfoSpr:setImage(UIImage)
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)
        gfx.setColor(gfx.kColorWhite)

        if selected then
            gfx.fillRect(x+2,y,24,16)
            gfx.fillTriangle(x+25,y,x+36,y+16,x+25,y+16)
        end

        local fontHeight = gfx.getFont():getHeight()
        for i,v in pairs(o.options) do
            if i == column then
                gfx.setImageDrawMode(gfx.kDrawModeNXOR)
                miniIcons:drawImage(v,x+5,y)
            end
        end
    end

    o.tag = "battleUI"

    o.index = #menuIndex + 1
    menuIndex[o.index] = o
    local bNfoBx = battleInfoBox:new(STable)
end

function limitQuery() -- check to see if the player has limit deck unlocked and return deck if true
    if #playerChr.limit ~= 0 then
        return true
    else
        return false
    end
end

battleInfoBox = playdate.ui.gridview.new(0,40)

function battleInfoBox:new(selTable)
    local o = playdate.ui.gridview.new(0,40)
    setmetatable(o,self)
    self.__index=self

    o.sTable = selTable
    o.oldTable = {}

    o:setNumberOfColumns(1)
    o:setNumberOfRows(#o.sTable)
    o:setCellPadding(0,0,0,0)
    o:setContentInset(0,0,0,0)

    function o:newTable(newTable)
        local tempT = o.sTable
        o.oldTable = tempT
        o.sTable = newTable
        local sS,sR,sC = 0,0,0
        for i,v in pairs(menuIndex) do
            if i==#menuIndex then
               sS,sR,sC = v:getSelection()
            end
        end
        o:setSelectedRow(sC)
    end

    function o:restorePrevTab()
        o.sTable = o.oldTable
        local sS,sR,sC = 0,0,0
        for i,v in pairs(menuIndex) do
            if i==#menuIndex then
               sS,sR,sC = v:getSelection()
            end
        end
        o:setSelectedRow(sC)
        o:selectNextRow(true,true,false)
        o:selectPreviousRow(true,true,false) -- to update screen
    end

    local bBottomM = gfx.sprite.new()
    bBottomM:setCenter(0,0)

    function o:spriteKill()
        bBottomM:remove()
    end

    bBottomM:add()

    function o:menuUpdate()
        if o.needsDisplay then
            local bottUIImg = gfx.image.new(304,40,gfx.kColorWhite)
            bBottomM:moveTo(96,215)

            local zInd = 110
            bBottomM:setZIndex(zInd)

            gfx.pushContext(bottUIImg)
                o:drawInRect(0,0,304,40)
            gfx.popContext()
            bBottomM:setImage(bottUIImg)
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)
        local fontHeight = gfx.getFont():getHeight()
        for i,v in pairs(o.sTable) do
            if i == row then
                gfx.drawTextInRect(o.sTable[i], x+5, y+5, width, height, nil, truncationString, kTextAlignment.left)
            end
        end
    end

    o.tag = "UIInfo"

    o.index = #UIIndex + 1
    UIIndex[o.index] = o
    return o
end

function changeUIInfo(tableOne)
    local tebN = {}
    if tableOne == nil then
        if limitQuery() == true then
            tebN = BattleInfoStrings.HasJoint
        else
            tebN = BattleInfoStrings.NoJoint
        end
    else
        tebN = tableOne
    end

    for i,v in pairs(UIIndex) do
        if v.tag == "UIInfo" then
            v:newTable(tebN)
        end
    end
end

jointDeck = playdate.ui.gridview.new(20,20)

function jointDeck:new()
    o = playdate.ui.gridview.new(20,20)
    setmetatable(o,self)
    self.__index=self

    o.icons,o.names,o.ports,o.costs = getDeck(playerDeck)
    changeUIInfo(o.names)

    o:setNumberOfColumns(#o.icons)
    o:setNumberOfRows(1)
    o:setCellPadding(5,5,0,0)
    o:setContentInset(0,0,0,0)
    o.scrollCellsToCenter = false
    o:removeHorizontalDividers()
    o:setScrollDuration(0)

    local jointSpr = gfx.sprite.new()
    jointSpr:setCenter(0,0)

    function o:spriteKill()
        jointSpr:remove()
        menuIndex[o.index] = nil
        changeUIInfo()
    end

    jointSpr:add()

    function o:getOption()

    end

    function o:menuUpdate()
        if o.needsDisplay then
            local JDImage = gfx.image.new(304,20,gfx.kColorBlack)
            jointSpr:moveTo(96,200)

            local zInd = 107 + #menuIndex
            jointSpr:setZIndex(zInd)

            gfx.pushContext(JDImage)
                o:drawInRect(0,0,304,20)
            gfx.popContext()
            jointSpr:setImage(JDImage)
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)
        gfx.setColor(gfx.kColorWhite)

        if selected then
            gfx.fillRect(x+2,y,24,16)
            gfx.fillTriangle(x+25,y,x+36,y+16,x+25,y+16)
        end

        local fontHeight = gfx.getFont():getHeight()

        for i,v in pairs(o.icons) do
            if i == column then
                gfx.setImageDrawMode(gfx.kDrawModeNXOR)
                miniIcons:drawImage(v,x+5,y)
            end
        end

    end

    o.tag = "jointDeck"

    o.index = #menuIndex + 1
    menuIndex[o.index] = o

end

function getDeck(deck) -- get icons to appear for each item in the deck.
    local iconTable = {}
    local nameTable = {}
    local portTable = {}
    local costTable = {}
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
            end
        end
    end
    return iconTable,nameTable,portTable,costTable
end

basicCommands = playdate.ui.gridview:new(20,20)

function basicCommands:new()
    o = playdate.ui.gridview:new(20,20)
    setmetatable(o,self)
    self.__index=self

    o.abTable = commandGet()
    

end

function commandGet()
    --[1] is fly, 2 is limit, 3 is focus, 4 is powerup)
    local pPhase = CurrentPhase
    local pTab = playerChr.ability
    local retTable = {}
    
    for i,v in pairs(pTab) do
        if pTab[1] == true then
            retTable[1] = "canFly"
        elseif pTab[1] == false then
            retTable[1] = "noFly"
        end 
        if pTab[3] == true then
            retTable[3] = "canFocus"
        elseif pTab[3] == false then
            retTable[3] = "noFocus"
        end 
        if pTab[4] == true then
            retTable[4] = "canPowerUp"
        elseif pTab[4] == false then
            retTable[4] = "noPowerUp"
        end 
    end

    if pPhase == Phase.ATTACK then
        return retTable
    else
        return reTable[1]
    end 
end