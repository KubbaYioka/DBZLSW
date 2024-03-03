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

    CurrentTurn = 0
    CurrentPhase = nil

    ---------------------
    --Menu Enum----------
    ---------------------

    BattleInfoStrings = {
        NoLimit = {
            [1] = "Joint Deck"
            ,[2] = "Basic Command"
            ,[3] = "Character"
        },
        HasLimit = {
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
    local initChr = initPTeam[1] -- simply uses the first player in the team
    local oppTab = battleTable["oppoParam"]
    local initETeam = oppTab.oppoTeam
    local initEChr = initETeam[1]

    printTable(oppTab)
    --CARD SETUP--

    --pDeckCopy = RAMSAVE[4]
    pDeckCopy = {1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10} -- will eventually pull from table RAMSAVE[4]
    playerDeck[1],playerDeck[2],playerDeck[3],pDeckCopy = cardShuffle(pDeckCopy,true)
    eDeckCopy = oppTab.opponentDeck -- pulls from where the enemy deck info is for this battle
    print(oppTab.opponentDeck)
    enemyDeck[1],enemyDeck[2],enemyDeck[3],eDeckCopy = cardShuffle(eDeckCopy,true)

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
    CurrentPhase = initTurn(playerChr,enemyChr)
    --Battle start screen
    battleIntro(playerChr.chrCode,#playerTeam,enemyChr.chrCode,#enemyTeam)
    battleSpriteSet(BattleRef)
    drawUI()
end

function initTurn(playerChr,enemyChr)
    local chrGo = nil
    if playerChr.chrSpd > enemyChr.chrSpd then
        chrGo = "player"
    elseif playerChr.chrSpd < enemyChr.chrSpd then
        chrGo = "enemy"
    elseif playerChr.chrSpd == enemyChr.chrSpd then
        if playerChr.chrKi >= enemyChr.chrKi then
            chrGo = "player"
        else
            chrGo = "enemy"
        end
    end
    if chrGo == "player" then
        turnInc()
        return Phase.ATTACK
    elseif chrGo == "enemy" then
        turnInc()
        return Phase.DEFENSE
    end
end

function turnInc()
    CurrentTurn = CurrentTurn + 1
end

function phaseChange()
    local cPhase = CurrentPhase
    if cPhase == Phase.ATTACK then
        cPhase = Phase.DEFENSE
    elseif cPhase == Phase.DEFENSE then
        cPhase = Phase.ATTACK
    end
    return cPhase
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
            cSelect = deck[math.random(1, #deck)] 
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
    local battleSMenu = battleUIMenu:new(Phase.ATTACK) --also spawns battleInfoBox

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
    elseif selOption == "Basic Command" then
        local bC = batCom:new()
    --Character
    elseif selOption == "Character" then
        chrData(playerTeam,"battle")
    elseif selOption == "Guard" then
    elseif selOption == "Movement" then
        SubMode = SubEnum.MOVE
        local gC = moveField:new(playerChr.ability[1])
    elseif selOption == "Focus" then
    elseif selOption == "Power Up" then
    else
        local oS = optionSelect:new(selOption)
    end
end


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

local function calculateEvasion(spd,def)
    return math.sqrt(spd + def)
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
    self.x,self.y = areaPosition(tag)
    mSpr:moveTo(self.x,self.y)

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
        STable = BattleInfoStrings.HasLimit
    else
        o.options = {            
            [1] = 1
            ,[2] = 9
            ,[3] = 13
        }
        STable = BattleInfoStrings.NoLimit
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
    if playerChr.limit ~= nil and #playerChr.limit ~= 0 then
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
        o:updateSelection()
    end

    function o:updateSelection()
        local sS,sR,sC = 0,0,0
        for i,v in pairs(menuIndex) do
            if i == #menuIndex then
                sS,sR,sC = v:getSelection()
            end
        end
        o:setNumberOfRows(#o.sTable)
        o:setSelectedRow(sC)
        o:selectNextRow(true,true,false)
        o:selectPreviousRow(true,true,false) -- to update screen
    end

    function o:restorePrevTab()
        o.sTable = o.oldTable
        o:updateSelection()
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

end

function changeUIInfo(tableOne)
    local tebN = {}
    if tableOne == nil then
        if limitQuery() == true then
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
                v:newTable(tebN)
            end
        end
    end
end

jointDeck = playdate.ui.gridview.new(20,20)

function jointDeck:new()

    o = playdate.ui.gridview.new(20,20)
    setmetatable(o,self)
    self.__index=self

    o.icons,o.names,o.ports,o.costs = getDeck(playerDeck)
    

    o:setNumberOfColumns(#o.icons)
    o:setNumberOfRows(1)
    o:setCellPadding(5,5,0,0)
    o:setContentInset(0,0,0,0)
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
        local itemS = nil
        for i,v in pairs(UIIndex) do
            if v.tag == "UIInfo" then
                itemS = v.sTable[v:getSelectedRow()]
            end
        end
        return itemS
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
    changeUIInfo(o.names)
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

batCom = playdate.ui.gridview.new(0,0)

function batCom:new()
    o = playdate.ui.gridview.new(20,20)
    setmetatable(o,self)
    self.__index=self

    o.icons,o.names,o.ports = abilityGet()

    o:setNumberOfColumns(#o.icons)
    o:setNumberOfRows(1)
    o:setCellPadding(5,5,0,0)
    o:setContentInset(0,0,0,0)
    o:setScrollDuration(0)

    local batSpr = gfx.sprite.new()
    batSpr:setCenter(0,0)

    function o:spriteKill()
        batSpr:remove()
        menuIndex[o.index] = nil
        changeUIInfo()
    end

    batSpr:add()

    function o:getOption()
        local itemS = nil
        for i,v in pairs(UIIndex) do
            if v.tag == "UIInfo" then
                itemS = v.sTable[v:getSelectedRow()]
            end
        end
        return itemS
    end

    function o:menuUpdate()
        if o.needsDisplay then
            local JDImage = gfx.image.new(304,20,gfx.kColorBlack)
            batSpr:moveTo(96,200)

            local zInd = 107 + #menuIndex
            batSpr:setZIndex(zInd)

            gfx.pushContext(JDImage)
                o:drawInRect(0,0,304,20)
            gfx.popContext()
            batSpr:setImage(JDImage)
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

    o.tag = "batCom"

    o.index = #menuIndex + 1
    menuIndex[o.index] = o
    changeUIInfo(o.names)
end

function abilityGet()
    local retuTable = {}
    local nameTable = {}
    local portTable = {}
    local pPhase = CurrentPhase
    local pTab = playerChr.ability

    if pPhase == Phase.ATTACK then
        retuTable[1] = 2 -- player will always be able to move. Check for fly later.
        nameTable[1] = "2 Stage Attack" 
        retuTable[2] = 18
        nameTable[2] = "Movement"
        for i,v in pairs(pTab) do
            if pTab[3] == true then
                retuTable[3] = 17
                nameTable[3] = "Focus"
            elseif pTab[4] == true then
                retuTable[3] = 5
                nameTable[3] = "Power Up"
            else
                retuTable[3] = nil
                nameTable[3] = nil
            end
        end
    else
        retuTable[1] = 19 -- guard
        nameTable[1] = "Guard"
        retuTable[2] = 18
        nameTable[2] = "Movement"
    end 
    return retuTable,nameTable,portTable
end

optionSelect = playdate.ui.gridview.new(0,0)

optionSelect.backgroundImage = gfx.nineSlice.new("assets/images/textBorder",10,10,16,16)

function optionSelect:new(item) -- where item is the selected card
    local o = playdate.ui.gridview.new(50,30)
    setmetatable(o,self)
    self.__index=self

    o.item = item

    o.menuTable = {"Details","Use"}

    o:setNumberOfRows(1)
    o:setNumberOfColumns(#o.menuTable)
    o:setCellPadding(0,30,0,0)
    o:setContentInset(0,0,0,0)
    o.scrollCellsToCenter = false
    o:setScrollDuration(0)

    function o:getOption()
        
        local sS,sR,sC = o:getSelection()
        if o.menuTable[sC] == "Details" then
            bShowCard(o.item)
        elseif o.menuTable[sC] == "Use" then
            goOption(o.item,"player")
        end
        o:spriteKill() -- bounce is making the object reappear after initial kill
    end

    local menuSprite = gfx.sprite.new()
    menuSprite:setCenter(0, 0)

    function o:spriteKill()
        menuSprite:remove()
        menuIndex[o.index] = nil
    end

    menuSprite:add()

    function o:menuUpdate()
        if o.needsDisplay then
            local menuImage = gfx.image.new(150,30,gfx.kColorWhite)
            menuSprite:moveTo(120, 180)
            local zInd = #menuIndex + 170
            menuSprite:setZIndex(zInd)
            gfx.pushContext(menuImage)
                o:drawInRect(0,0,150,30)
            gfx.popContext()
            menuSprite:setImage(menuImage)
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)

        if selected then
            gfx.fillTriangle(x+15,y+8,x+15,y+23,x+25,y+15)
        end
        local fontHeight = gfx.getFont():getHeight()
        gfx.drawTextInRect(o.menuTable[column], x+26, y+10, width, height, nil, truncationString, kTextAlignment.left)
    end

    o.tag = "optionSelect"

    local countI = 0
    for _ in pairs(menuIndex) do 
        countI = countI + 1 
    end

    o.index = countI + 1
    menuIndex[o.index] = o
    return o
end

function bShowCard(card)
    local retCard = cardRet(card)
    cardData(retCard)
    SubMode = SubEnum.STAT
end

moveField = playdate.ui.gridview.new(0,0)

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

    o.drawX,o.drawY,o.dRow,o.dCol = compMove(o.cX,o.cY,o.extraSpace,o.currentPosition,o.canFly)    

    o:setNumberOfRows(o.dRow)
    o:setNumberOfColumns(o.dCol)
    o.scrollCellsToCenter = false
    o:setScrollDuration(0)
    o:setCellPadding(0,90,0,90)
    o:setContentInset(0,0,0,0)

    local movementSpr = gfx.sprite.new()
    movementSpr:setCenter(0,0)
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
            local mGrid = gfx.image.new(90*o.dCol,90*o.dRow,gfx.kColorClear)
            movementSpr:moveTo(o.drawX,o.drawY)
            local zInd = #menuIndex + 171
            movementSpr:setZIndex(zInd)
            gfx.pushContext(mGrid)
                o:drawInRect(0,0,90*o.dCol,90*o.dRow) 
            gfx.popContext()
            movementSpr:setImage(mGrid)
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)
        if selected then
            gfx.fillTriangle(x+35,y+13,x+35,y+28,x+45,y+20)
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

function movTabConfig(cPos)
    if cPos == PositionEnum.GroundFore then
        return 150,160
    elseif cPos == PositionEnum.GroundAft then
        return 60,160
    elseif cPos == PositionEnum.AirFore then
        return 150, 70
    elseif cPos == PositionEnum.AirAft then
        return 60, 70
    end
end

function enTest()
    if enemySprTab.Position == PositionEnum.AirAft or enemySprTab.Position == PositionEnum.GroundAft then
        if playerSprTab.Position == PositionEnum.AirFore or playerSprTab.Position == PositionEnum.GroundFore then
            return true
        end
    else 
        return false
    end
end

function compMove(oX,oY,xtra,cPos,cFly)
    if cPos == PositionEnum.GroundAft then
        if  cFly == true then
            moveUIInfo:new({"AAft","AFore"},{"GAft","GFore"})
            return  50,50,2,2
        else
            moveUIInfo:new({"GAft","GFore"})
            return 50,140,1,2
        end
    elseif cPos == PositionEnum.AirAft then
        moveUIInfo:new({"AAft","AFore"},{"GAft","GFore"})
        return 50,50,2,2
    elseif cPos == PositionEnum.GroundFore then
        if  cFly == true and xtra == true then
            moveUIInfo:new({"AAft","AFore","AXtra"},{"GAft","GFore","GXtra"})
            return  50,50,2,3
        elseif cFly == true and xtra == false then
            moveUIInfo:new({"AAft","AFore"},{"GAft","GFore"})
            return 50,50,2,2
        elseif cFly == false and xtra == true then
            moveUIInfo:new({"GAft","GFore","GXtra"})
            return 50,140,1,3
        elseif cFly == false and xtra == false then
            moveUIInfo:new({"GAft","GFore"})
            return 50,140,1,2
        end
    elseif cPos == PositionEnum.AirFore then
        if  xtra == true then
            moveUIInfo:new({"AAft","AFore","AXtra"},{"GAft","GFore","GXtra"})
            return  50,50,2,3
        elseif xtra == false then
            moveUIInfo:new({"AAft","AFore"},{"GAft","GFore"})
            return 50,50,2,2
        end
    end
end

moveUIInfo = playdate.ui.gridview.new(0,0)

function moveUIInfo:new(selTable1,selTable2)
    local o = playdate.ui.gridview.new(0,40)
    setmetatable(o,self)
    self.__index=self

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

    function o:spriteKill()
        bBottomM:remove()
        UIIndex[o.index] = nil
    end

    bBottomM:add()

    function o:menuUpdate()
        if o.needsDisplay then
            local bottUIImg = gfx.image.new(304,40,gfx.kColorWhite)
            bBottomM:moveTo(96,215)

            local zInd = 120
            bBottomM:setZIndex(zInd)

            gfx.pushContext(bottUIImg)
                o:drawInRect(0,0,304,40)
            gfx.popContext()
            bBottomM:setImage(bottUIImg)
        end
    end

    function o:drawCell(section,row,column,selected,x,y,width,height)
        local fontHeight = gfx.getFont():getHeight()
        for i,v in pairs(o.gTable) do
            if i == row and column == 1 then
                gfx.drawTextInRect(v, x+5, y+5, width, height, nil, truncationString, kTextAlignment.left)
                o.current = v
            end
        end
        if o.rowTrig == true then
            for i,v in pairs(o.aTable) do
                if i == row and column == 2 then
                    gfx.drawTextInRect(v, x+5, y+5, width, height, nil, truncationString, kTextAlignment.left)
                    o.current = v
                end
            end
        end
    end

    o.tag = "movementUIInfo"

    o.index = #UIIndex + 1
    UIIndex[o.index] = o
end

function movDesc(newPos)
    local retTable = {}
    if newPos[1] == "AAft" then
        retTable[1] = "Defense Up. Phys Defense."
        retTable[2] = "Attack Up. Phys Defense."
        if newPos[3] ~= nil and newPos[3 ]== "AXtra" then
            retTable[3] = "Attack Up. Phys Defense"
        end
    elseif newPos[1] == "GAft" then
        retTable[1] = "Defense Up. Ki Defense."
        retTable[2] = "Attack Up. Ki Defense."
        if newPos[3] ~= nil and newPos[3 ]== "GXtra" then
            retTable[3] = "Attack Up. Ki Defense"
        end
    end
    return retTable
end

------------------
--Action Confirm--
------------------

function movementConfirm(newPos,side)
    print(newPos)
end

function goOption(selOption,side)
    battleCardConfirm(selOption,side)
    --enemy card select based on AI type--
    
    execTurn()
end

function battleCardConfirm(selOption,side)
    if side == "enemy" then
        -- Do enemy calcs for move
        enemyTurnTable = {}
        enemyTurnTable.card = cardRet(selOption)
        enemyTurnTable.mStats = turnStat(enemyChr,cardRet(selOption))
    elseif side == "player" then
        playerTurnTable = {}
        playerTurnTable.card = cardRet(selOption)
        playerTurnTable.mStats = turnStat(playerChr,cardRet(selOption))
    end
end

function turnStat(stat,card,mod)
    local tempTab = {}

    local pBonus = {}
    if stat == playerChr then
       pBonus = getPositionBonus("player")
    elseif stat == enemyChr then
       pBonus = getPositionBonus("enemy")
    end

    tempTab.hp = stat.chrHp
    tempTab.def = stat.chrDef
    tempTab.spd = stat.chrSpd
    tempTab.str = stat.chrStr
    tempTab.ki = stat.chrKi
    
    if pBonus["Def"] then
        --print("pBonus Def")
        tempTab.def = tempTab.def + (tempTab.def * pBonus["Def"])
    elseif pBonus["Str"] then
        --print("pBonus Str")
        tempTab.str = tempTab.str + (tempTab.str * pBonus["Str"])
    elseif pBonus["Ki"] then
        --print("pBonus Ki")
        tempTab.ki = tempTab.ki + (tempTab.ki * pBonus["Ki"])
    end
    if pBonus["KiDef"] then
        --print("pBonus KiDef")
        tempTab.kiDef = true
    elseif pBonus["PhysDef"] then
        --print("pBonus PhysDef")
        tempTab.physDef = true
    end
    tempTab.off = tempTab.str + tempTab.ki
    tempTab.eva = calculateEvasion(tempTab.def,tempTab.spd)
    tempTab.mas = tempTab.str + tempTab.def
    if type(card) == "table" then
        tempTab.acc = card.cAccuracy
        tempTab.abi = card.cAbility
    end

    --/ofzg```````                       

    --apply position bonuses. Calculate positional changes first.

    return tempTab

end

function getPositionBonus(side)
    local pTab = nil
    if side == "enemy" then
        pTab = enemySprTab.position
    elseif side == "player" then
        pTab = playerSprTab.position
    end
    local reTab = {}
    if pTab == PositionEnum.GroundAft then
        reTab["Def"] = 0.10
        reTab["KiDef"] = true
    elseif pTab == PositionEnum.GroundFore then
        reTab["Str"] = 0.10
        reTab["KiDef"] = true
    elseif pTab == PositionEnum.AirAft then
        reTab["Def"] = 0.10
        reTab["PhyDef"] = true
    elseif pTab == PositionEnum.AirFore then
        reTab["Ki"] = 0.10
        reTab["PhyDef"] = true
    end

    return reTab
end

function execTurn()
    print("ExecTurn")
    if CurrentPhase == Phase.ATTACK then
        -- in this routine, we need to compare enemy and player tables to get phase results.
        printTable(playerTurnTable)
        printTable(enemyTurnTable)

    elseif CurrentPhase == Phase.DEFENSE then

    end
end

--[[
    {
	[ability] = {
		false,
		false,
		false,
		false,
	},
	[chrCode] = dbGoku,
	[chrDef] = 2,
	[chrExp] = 0,
	[chrHp] = 80,
	[chrKi] = 0,
	[chrName] = Goku,
	[chrNum] = 1,
	[chrSpd] = 3,
	[chrStr] = 2,
	[chrTrans] = {
		[trans1] = Base,
		[trans2] = Oozaru,
	},
	[limit] = {
	},
}

]]
