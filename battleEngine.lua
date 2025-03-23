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
    playerTemp = nil -- to hold card data temporarily.
    playerPoweredUp = false
    playerStandReady = false
    playerBattleDamaged = false
    playerSprTab = {
        sprRange = {}
        ,current = 0
        ,position = PositionEnum.GroundFore--PositionEnum.GroundAft -- override for debugging
    }

    bFaster = {} -- will compare speeds of combatants to see who will go first. Evaluated every turn change.

    enemyChr={}
    enemyTeam={}
    enemyTeamRO = {} -- for read-only copy of team for reference. 
    eDeckCopy={} -- copy from battle data in the battle database
    enemyDeck={}
    enemyCC = 3
    enemyAtkCounter = 1 -- enemy keeps track of how long it has been since the player has used a special attack
    enemyPoweredUp = false
    enemyStandReady = false
    enemyBattleDamaged = false
    enemySprTab = {
        sprRange = {}
        ,current = 0
        ,position = PositionEnum.GroundAft
    }

    currentAI = nil

    Phase = {
        ATTACK = "attack"
        ,DEFENSE = "defense"
    }

    CurrentTurn = 0
    PhaseTrig = false
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

    PlayerSelection = "None"
    EnemySelection = "None"

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

    --CARD SETUP--

    --pDeckCopy = RAMSAVE[4]
    pDeckCopy = {1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10} -- will eventually pull from table RAMSAVE[4]
    playerDeck[1],playerDeck[2],playerDeck[3],pDeckCopy = cardShuffle(pDeckCopy,true)
    eDeckCopy = oppTab.opponentDeck -- pulls from where the enemy deck info is for this battle
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

                enemyTeam[i].aiType = oppTab.opponentAIType[i]
                
                --Next, do calculations to set stats according to [oppoParam].opponentLvl and insert .opponentLimit, .hasFly, hasLimit, transformation etc
                enemyTeamRO = enemyTeam
            end
        end
    end
    playerChr = playerTeam[1]
    enemyChr = enemyTeam[1]
    currentAI = oppTab.opponentAIType[1]

    gameModeChange(GameMode.BATTLE)
    SubMode = SubEnum.NONE
    CurrentPhase = initTurn(playerChr,enemyChr)
    --Battle start screen
    battleIntro(playerChr.chrCode,#playerTeam,enemyChr.chrCode,#enemyTeam)
    battleSpriteSet(BattleRef)
    drawUI(CurrentPhase)
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
    print("Player Speed = "..playerChr.chrSpd)
    print("Enemy Speed = "..enemyChr.chrSpd)
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
    PhaseTrig = false
end

function phaseCheck()
    if PhaseTrig == false then
        PhaseTrig = true
        return 0
    elseif PhaseTrig == true then
        turnInc()
        PhaseTrig = false
        drawCard()
        return 0
    end
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

function drawCard()
    local enCardNum = #enemyDeck + 1
    local plCardNum = #playerDeck + 1
    enemyDeck[enCardNum], eDeckCopy = cardShuffle(eDeckCopy,false)
    playerDeck[plCardNum], pDeckCopy = cardShuffle(pDeckCopy,false)
end

function turnTableClear()
    enemyTurnTable = nil
    playerTurnTable = nil
    attacker = nil
    defender = nil
end

function nextPhase()
    turnTableClear()
    clearField()
    local enSprite = BattleMiniSpr("enemy")
    local plrSprite = BattleMiniSpr("player")
    bgChange(BattleRef["arenaParam"].bField)
    phaseCheck() -- check to see if a new turn begins and draw one card if available
    CurrentPhase = phaseChange()

    --if new turn, then do the speed check again
    for i,v in pairs(menuIndex) do
        v:spriteKill()
        menuIndex[i] = nil
        if v.tag == "optionSelect" then
            v:spriteKill()
        end
    end
    for i,v in pairs(UIIndex) do
        if v.tag == "UIInfo" then
            v:spriteKill()
            UIIndex[i] = nil
        end
    end

    local battleSMenu battleUIMenu:new(phase)

    SubMode = SubEnum.MENU

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

function getPositionDistance(savBtn)
    local playerDist = playerSprTab.position
    local enemyDist = enemySprTab.position
    local attackerTime = 2000
    local att = 1
    local def = 1
    local attSpeed = 1
    local defSpeed = 2
    local res = 0
    if CurrentPhase == Phase.ATTACK then
        att = playerDist
        def = enemyDist
        attSpeed, defSpeed = getSpeeds("player")
        res = (attSpeed/defSpeed) * 100

    elseif CurrentPhase == Phase.DEFENSE then
        def = playerDist
        att = enemyDist
        attSpeed, defSpeed = getSpeeds("enemy")
        res = (attSpeed/defSpeed) * 100
    end
    if att == "groundfore" then
        if def == "groundfore" then
            attackerTime = attackerTime + 500
        elseif def == "groundaft" then
            attackerTime = attackerTime - 200
        elseif def == "airfore" then
            attackerTime = attackerTime + 300
        elseif def == "airaft" then
            attackerTime = attackerTime - 400
        end
    elseif att == "groundaft" then
        if def == "groundfore" then
            attackerTime = attackerTime - 200
        elseif def == "groundaft" then
            attackerTime = attackerTime - 700
        elseif def == "airfore" then
            attackerTime = attackerTime - 300
        elseif def == "airaft" then
            attackerTime = attackerTime - 800
        end
    elseif att == "airfore" then
        if def == "groundfore" then
            attackerTime = attackerTime + 300
        elseif def == "groundaft" then
            attackerTime = attackerTime - 400
        elseif def == "airfore" then
            attackerTime = attackerTime + 500
        elseif def == "airaft" then
            attackerTime = attackerTime - 200
        end
    elseif att == "airaft" then
        if def == "groundfore" then
            attackerTime = attackerTime - 300
        elseif def == "groundaft" then
            attackerTime = attackerTime - 800
        elseif def == "airfore" then
            attackerTime = attackerTime - 200
        elseif def == "airaft" then
            attackerTime = attackerTime - 700
        end
    end

    if savBtn == nil then
        local spdFactor = getSpdFactor(res)
        attackerTime = attackerTime + spdFactor
    elseif savBtn == "btn" then
        attackerTime = getSpdFactorForSavBtn(res)
        
    end
    return attackerTime
end

function getSpdFactorForSavBtn(num) -- this returns the number of frames a player has to enter a command to continue an attack
    if num < 50 then
        return 5
    elseif num >= 51 and num <= 60 then
        return 6
    elseif num >= 61 and num <= 75 then
        return 7
    elseif num >= 76 and num <= 90 then
        return 8
    elseif num >= 91 and num <= 110 then
        return 15
    elseif num >= 111 and num <= 120 then
        return 17
    elseif num >= 121 and num <= 130 then
        return 20
    elseif num >= 131 and num <= 145 then
        return 30
    elseif num >= 146 and num <= 160 then
        return 40
    elseif num > 161 then
        return 50
    else
        return 0
    end
end

function getSpeeds(attackerS)
    if attackerS == "player" then
        local sp = playerChr["chrSpd"]
        local ds = enemyChr["chrSpd"]
        return playerChr["chrSpd"], enemyChr["chrSpd"]
    elseif attackerS == "enemy" then
        return enemyChr["chrSpd"], playerChr["chrSpd"]
    end
end

function getSpdFactor(num)
    if num < 50 then
        return -500
    elseif num >= 51 and num <= 60 then
        return -400
    elseif num >= 61 and num <= 75 then
        return -200
    elseif num >= 76 and num <= 90 then
        return -100
    elseif num >= 91 and num <= 110 then
        return 0
    elseif num >= 111 and num <= 120 then
        return 200
    elseif num >= 121 and num <= 130 then
        return 300
    elseif num >= 131 and num <= 145 then
        return 400
    elseif num >= 146 and num <= 160 then
        return 500
    elseif num > 161 then
        return 700
    else
        return 0
    end
end

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

-- Functions
function calculateDerivedStats(character, phaseType) --pass character name and the phase they are in for appropriate stats
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

function getHitTables()
    local plr = {}
    local ene = {}
    plr["def"] = playerChr["chrDef"]
    plr["str"] = playerChr["chrStr"]
    ene["def"] = enemyChr["chrDef"]
    ene["str"] = enemyChr["chrStr"]

    plr["off"] = playerChr["chrStr"] + playerChr["chrKi"]
    plr["eva"] = playerChr["chrSpd"] + playerChr["chrDef"]
    plr["mas"] = playerChr["chrStr"] + playerChr["chrDef"]
    plr["acc"] = playerChr["chrSpd"] + playerChr["chrKi"]

    ene["off"] = enemyChr["chrStr"] + enemyChr["chrKi"]
    ene["eva"] = enemyChr["chrSpd"] + enemyChr["chrDef"]
    ene["mas"] = enemyChr["chrStr"] + enemyChr["chrDef"]
    ene["acc"] = enemyChr["chrSpd"] + enemyChr["chrKi"]
    if CurrentPhase == Phase.ATTACK then
        return plr, ene        
    elseif CurrentPhase == Phase.DEFENSE then
        return ene, plr
    end
end

function getPercentageAndFunc(atk, def)
    local more = math.max(atk, def)
    local least = math.min(atk, def)
    local prc = (least / more) * 100

    if prc < 20 then
        -- No visible effect from strikes
        return "normal", {["a"]={"normalHit",20},["b"]={"bigHit",35},["back"]={"bigHit"},["up"]={"upHit"},["down"]={"bigHit"}}
        --placeholder
    elseif prc >= 20 and prc < 40 then
        -- only a slight nudge from strikes
        return "normal", {["a"]={"normalHit",20},["b"]={"bigHit",35},["back"]={"bigHit"},["up"]={"upHit"},["down"]={"bigHit"}}
        --placeholder
    elseif prc >= 40 and prc < 50 then
        -- sprite reaction and slight nudge
        return "normal", {["a"]={"normalHit",20},["b"]={"bigHit",35},["back"]={"bigHit"},["up"]={"upHit"},["down"]={"bigHit"}}
        --placeholder
    elseif prc >= 50 and prc < 80 then
        -- sprite reaction and small shake
        return "normal", {["a"]={"normalHit",20},["b"]={"bigHit",35},["back"]={"bigHit"},["up"]={"upHit"},["down"]={"bigHit"}}
        --placeholder
    elseif prc >= 80 and prc < 120 then
        -- sprite reaction and normal shake
        return "normal", {["a"]={"normalHit",20},["b"]={"bigHit",35},["back"]={"bigHit"},["up"]={"upHit"},["down"]={"bigHit"}}
    elseif prc >= 120 and prc < 150 then
        -- sprite reaction and big shake
        return "normal", {["a"]={"normalHit",20},["b"]={"bigHit",35},["back"]={"bigHit"},["up"]={"upHit"},["down"]={"bigHit"}}
        --placeholder
    elseif prc >= 150 and prc < 170 then
        -- sprite slight knockback, shake, and reaction
        return "normal", {["a"]={"normalHit",20},["b"]={"bigHit",35},["back"]={"bigHit"},["up"]={"upHit"},["down"]={"bigHit"}}
        --placeholder
    elseif prc >= 170 then
        -- each hit knocks the sprite back
        return "normal", {["a"]={"normalHit",20},["b"]={"bigHit",35},["back"]={"bigHit"},["up"]={"upHit"},["down"]={"bigHit"}}
        --placeholder
    end
end

local function calculateEvasion(spd,def)
    return math.sqrt(spd + def)
end
---------------------------
--Battle Gridview Objects--
---------------------------
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

class('BattleMiniSpr').extends(gfx.sprite)

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

class('VsEmblem').extends(gfx.sprite)

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


class('LifeBar').extends(gfx.sprite)

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

function battleUIMenu:initBattleInfoStrings()
    if limitQuery("player") then
        return BattleInfoStrings.HasLimit
    else
        return BattleInfoStrings.NoLimit
    end
end

function limitQuery(side) -- check to see if the player has limit deck unlocked and return deck if true
    if side == "player" then
        if playerChr.limit ~= nil and #playerChr.limit ~= 0 then
            return true
        else
            return false
        end
    elseif side == "enemy" then
        if enemyChr.limit ~= nil and #enemyChr.limit ~= 0 then
            return true
        else
            return false
        end
    end
end

battleInfoBox = playdate.ui.gridview.new(0, 40)
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

function availabilityCheck(cardNumber,conditionTable) -- will need to revisit for attacks that require 2 chrs
    local phaseTable = conditionTable[1]
    local chrTable = conditionTable[2]
    local formTable = conditionTable[3]
    local ccTable = conditionTable[4]


    -- phase compatibility block
    if phaseTable[cardNumber] ~= CurrentPhase and phaseTable[cardNumber] ~= "both" then
        print("Card not available in current phase")
        return false
    end

    --chr compatibility block
    local chrFlag = false
    for i,v in pairs(chrTable) do
        if v == playerChr.chrCode then
            chrFlag = true
        end
    end
    if chrFlag == true then
        print("Card not compatible with current character")
        return false
    end

    --form compatibility block
    --[[
    for i,v in pairs(formTable) do
        if v == playerChr.trans then
            print("Transformations not yet implemented. Must be implemented in save file, battle init, and functions need to be made for determining available transformations based on level")
        end
    ]]
    
    --cc Amount Check
    for i,v in pairs(ccTable) do
        if ccTable[cardNumber] > playerCC then
            return false
        end
    end

    return true
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

function deckCheck()
    if #playerDeck >= 6 then
        return true
    else
        return false
    end
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
    print("Enemy Position Reported as: "..enemySprTab.position)
    print("Player Position Reported as: "..playerSprTab.position)
    if enemySprTab.position == PositionEnum.AirAft or enemySprTab.position == PositionEnum.GroundAft then
        if playerSprTab.position == PositionEnum.AirFore or playerSprTab.position == PositionEnum.GroundFore then
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
    print("Warning: compMove() did not find a matching condition. Returning defaults.")
    return 50, 50, 1, 1  -- Ensures it always returns valid numbers
end

moveUIInfo = playdate.ui.gridview.new(0,0)

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
    print("side: "..side)
    local sidePos = "string"
    print("playerSprTab.position or enemySprTab.position should be changed at this time.")
    --[[    PositionEnum = {
        GroundFore = "groundfore"
        ,GroundAft = "groundaft"
        ,AirFore = "airfore"
        ,AirAft = "airaft"]]
    local selectedMovement = "nil" -- Note that there should be multiple options here that take into account whether the chr can fly and where they are in the arena so that there are more animations contingent on movement abilities
    if newPos == "Defense Up. Phys Defense." then
        selectedMovement = "backMove"
        sidePos = PositionEnum.AirAft
    elseif newPos == "Attack Up. Phys Defense." then
        selectedMovement = "forwardMove"
        sidePos = PositionEnum.AirFore
    elseif newPos == "Defense Up. Ki Defense." then
        selectedMovement = "backMove"
        sidePos = PositionEnum.GroundAft
    elseif newPos == "Attack Up. Ki Defense." then
        selectedMovement = "forwardMove"
        sidePos = PositionEnum.GroundFore
    end
    if side == "enemy" then
        enemySprTab.position = sidePos
    elseif side == "player" then
        playerSprTab.position = sidePos
    end
    goOption(selectedMovement, side)
end

function goOption(selOption,side) -- execute selected battle menu command
    battleCardConfirm(selOption,side)
    aiGo() -- perform AI's turn. returns battleCardConfirm
    if CurrentPhase == Phase.ATTACK then
        --printTable(playerTurnTable)
        --printTable(enemyTurnTable)
        execTurn(playerTurnTable,enemyTurnTable)
    elseif CurrentPhase == Phase.DEFENSE then
        execTurn(enemyTurnTable,playerTurnTable)
    end
end

function battleCardConfirm(selOption,side)
    --print("selOption for "..side.." is "..selOption)
    --print("Here is where selOption (a card name string) is compared with a table containing card names that can trigger the command input screen and can be expanded with other tables for other actions")
    if side == "enemy" then
        if #enemyDeck >= 6 then
            enemyDiscard()
        end
        -- Do enemy calcs for move
        enemyTurnTable = {}
        enemyTurnTable.card = cardRet(selOption)
        enemyTurnTable.mStats = turnStat(enemyChr,enemyTurnTable.card,"enemy")
        local cardRemove = enemyTurnTable.card
        for i,v in pairs(enemyDeck) do
            if cardRemove.cNumber == v then
                table.remove(enemyDeck,i)
            end
        end
    elseif side == "player" then
        --printTable(playerDeck)
        --print(selOption)

        playerTurnTable = {}
        playerTurnTable.card = cardRet(selOption)
        playerTurnTable.mStats = turnStat(playerChr,playerTurnTable.card,"player")
        local cardRemove = playerTurnTable.card
        if PlayerSelection == "jointDeck" then
            for i,v in pairs(playerDeck) do
                if cardRemove.cNumber == v then
                    table.remove(playerDeck,i)
                end
            end
        end
    end
end

function enemyDiscard()
    local discard = math.random(1,6)
    table.remove(enemyDeck,discard)
end

function turnStat(stat,card,side)
    local tempTab = {}

    local pBonus = {}
    if side == "player" then
       pBonus = getPositionBonus("player")
    elseif side == "enemy" then
       pBonus = getPositionBonus("enemy")
    end

    tempTab.hp = stat.chrHp
    tempTab.def = stat.chrDef
    tempTab.spd = stat.chrSpd
    tempTab.str = stat.chrStr
    tempTab.ki = stat.chrKi
    
    --apply positional bonuses
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
    
    --apply any defense bonus from position
    if pBonus["KiDef"] then
        --print("pBonus KiDef")
        tempTab.kiDef = true
    elseif pBonus["PhysDef"] then
        --print("pBonus PhysDef")
        tempTab.physDef = true
    end

    --calculate hidden stats
    tempTab.off = tempTab.str + tempTab.ki
    tempTab.eva = calculateEvasion(tempTab.def,tempTab.spd)
    tempTab.mas = tempTab.str + tempTab.def
    if type(card) == "table" then
        tempTab.acc = card.cAccuracy
        tempTab.abi = card.cAbility
        --examine ability
       --[[ local cType = card.cType
        if cType == CPhysical then
            tempTab.str = tempTab.str + card.cPower
        elseif cType == CKi then
            tempTab.ki = tempTab.ki + card.cPower
        elseif cType == CCommand then
            tempTab.str = tempTab.str + (tempTab.str*card.cPower) -- attacks with a command card are always a percentage of the base strength
        elseif cType == CEffect then
            --tempTab = examineEffect(side,tempTab,card)
        elseif cType == CTrans then
            --function applyTrans(trans)
        elseif cType == CReady then
            --function becomeReady(chr)
        elseif cType == cPower then
            --tempTab = powerUp(tempTab)
        end--]]
    end

    --/ofzg```````

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

function examineEffect(side,chrTab,card)
    chrTab = card.cAbility(side,chrTab,card.cPower)
    return chrTab
end

function execTurn(attacker,defender)
    local defType = defender.card
    local attType = attacker.card
    local knockbackDamage = nil
    animationGo(attacker,defender)

end

function turnFunctionsDuringAnimation(attacker, defender)
    attacker = attWillDamage(attacker) -- for determining hits and effects as well as applying them
    defender = defKind(defender) -- for determining defense type and effects as well as applying them

    if attacker.damageApply ~= nil then
        attacker.cardHitMiss = moveCompare(attacker,defender) -- checks if cards cause hit or miss due to avoiding, block, etc
        attacker.statHitMiss = statCompare(attacker,defender) -- gets a table with damage, if an attack will land, and if knockback happens
    end

    if attacker.offensiveEffect ~= nil or defender.offensiveEffect ~= nil then
        attacker, defender = effectCompare(attacker,defender) -- returns a table with an offensive effect and its number
        -- conditionals for all other moves possible other than attacks. Effects, powerup, ready, partner switch, etc
        attacker, defender = effectHit(attacker, defender) -- returns booleans for if the attack hits. If a card is supposed to be a command card, the player must enter the commands for this to process.
    end

    --cardHitMiss[1] is a boolean for whether or not the card landed a hit or if the opponent's card blocked it
    --cardHitMiss[2] is the stat that is affected by the hit.
    --where atDamage (statusHitMiss[1]) is the numeric value for hp the defender loses
    --attHit (statHitMiss[2]) is a boolean signaling if the attack lands at all
    --and isKnockback (statHitMiss[3]) is a boolean for whether or not this is critical
    --finally, knockbackMulti (statHitMiss[4]) is the amount of damage to add for a crit
    attacker, defender = moveProcessing(attacker, defender)

    -- do any partner switches
end

function endOfTurn()
    local attacker = battleSpriteIndex["attacker"]
    local defender = battleSpriteIndex["defender"]
    ccChange(attacker,defender)
    postTurn(attacker, defender)
end

function ccChange(attacker, defender)
    if CurrentPhase == Phase.ATTACK then
        if attacker.ccAdd ~= nil then
            playerCC = playerCC + attacker.ccAdd
        end
        if defender.ccAdd ~= nil then
            enemyCC = enemyCC + defender.ccAdd
        end
    elseif CurrentPhase == Phase.DEFENSE then
        if attacker.ccAdd ~= nil then
            enemyCC = enemyCC + attacker.ccAdd
        end
        if defender.ccAdd ~= nil then
            playerCC = playerCC + defender.ccAdd
        end
    end
end

function attWillDamage(attacker)
    local card = attacker.card
    local attType = card.cType
    local damageApply = nil
    local willEffect = nil

    if attType == CCommand or attType == CKi or attType == CPhysical then
        damageApply = true
    end
    if attType == CEffect then
        willEffect = true
    end

    attacker.damageApply = damageApply

    attacker.effectApply = willEffect

    attacker = effectProcessing(attacker) --apply effects of card to user, or load them to see if they hit later

    return attacker 
end

function defKind(defender) 
    local card = defender.card
    local defType = card.cType
    local defAbility = card.cAbility
    local willEffect = nil

    if defType == CEffect then
        willEffect = true
    end

    defender.effectApply = willEffect
    defender = effectProcessing(defender)

    return defender
end

function effectProcessing(side)
    local card = side.card
    local cardEffect = card.cType
    local cardAbility = card.cAbility

    if cardEffect == CEffect then
        for i,v in pairs(AbilityTableSelf) do
            if cardEffect == v then
                side = cardAbility(side,card)
                side.selfEffect = true
            end
        end
        for i,v in pairs(OffensiveAbilities) do
            if cardEffect == v then
                side.offensiveEffect = true
            end
        end
    elseif cardEffect == CTrans or cardEffect == CReady or cardEffect == CPower then
        print(tostring(cardEffect).." not yet implemented. side.selfEffect = true")
        side.selfEffect = true
    end
    return side
end

function moveCompare(attacker,defender) -- compare cards to determine hit or miss because of avoiding, block, etc
    local caCard = attacker.card
    local cdCard = defender.card
    local atCardType = caCard.cType
    local deCardType = cdCard.cType

    local wOutCome = nil
    local kindOfHit = nil
    local retTable = {}
    if attacker.damageApply then 
        if atCardType == CKi then
            kindOfHit = "ki"
        elseif atCardType == CPhysical then
            kindOfHit = "phys"
        elseif atCardType == CCommand then
            kindOfHit = "com"
        end
        if defender.willBlock ~= nil then
            if attacker.breakBlock then
                -- breakBlock. Ignore all willBlock
                wOutCome = true
            else
                if defender.willBlock == "ki" then
                    if atCardType == CKi then
                        wOutCome = false
                    else
                        wOutCome = true
                    end
                elseif defender.willBlock == "phys" then
                    if atCardType == CPhysical then
                        wOutCome = false
                    else
                        wOutCome = true
                    end
                elseif defender.willBlock == "com" then
                    if atCardType == CCommand then
                        wOutCome = false
                    else
                        wOutCome = true
                    end
                end
            end
        else 
            wOutCome = true
        end
    end
    
    retTable = {wOutCome, kindOfHit}

    return retTable
end

function effectCompare(attacker,defender) -- compare cards to determine hit or miss because of avoiding, block, etc
    local caCard = attacker.card
    local cdCard = defender.card
    local attackerEffOffense = {}
    local defenderEffOffense = {}

    if attacker.offensiveEffect == true then
        attackerEffOffense = card.cAbility(defender,card) -- will return stat and how much to change it by
    else
        attackerEffOffense = nil
    end
    if defender.offensiveEffect == true then
        defenderEffOffense = card.cAbility(attacker,card)
    else
        defenderEffOffense = nil
    end

    attacker.EffOffense = attackerEffOffense
    defender.EffOffense = defenderEffOffense

    return attacker, defender

end

function statCompare(attacker,defender)
    local atStat = attacker.mStats
    local deStat = defender.mStats
    local cacKind = attacker.card
    local atKind = cacKind.cType
    local attackKind = nil
    local retTable = {}
    if atKind == CKi then
        attackKind = atStat.ki + cacKind.cPower
    elseif atKind == CPhysical then
        attackKind = atStat.str + cacKind.cPower
    elseif atKind == CCommand then
        local ccPwr = atStat.str * cacKind.cPower
        attackKind = atStat.str + ccPwr
    end
    local atDamage = attackKind - deStat.def

    local hitToEvasionChance = calculateHitChance(atStat.acc, deStat.eva)

    local attHit = attackHits(hitToEvasionChance) -- boolean for if the attack has landed
    local knockbackChance = calcKnockback(atStat.off,deStat.mas)
    local isKnockback = attackHits(knockbackChance)

    local knockbackMulti = nil
    if isKnockback == true then
        knockbackMulti = calculateKnockDamage(atKind, atStat, knockbackChance)
    end

    --debug print statements--
    --print("Raw Attack Power: "..attackKind)
    --print("Enemy's Defense: "..deStat.def)
    local debug1state = "Attack Will Land"
    local debug2state = "Opponent is not knocked back."

    if attHit == false then
        debug1State = "Attack Misses"
    end
    if isKnockback == false then
        debug2State = "Opponent is knocked back!" 
    end

    --print("Chance to Hit: "..hitToEvasionChance)
    --print(debug1state)
   -- print("Chance of Knockback: "..knockbackChance)
    --print(debug2state)

    -- at this point, we have determined the amount of damage an attack will cause
    -- whether or not the attack will hit, and if it will cause knockback and if so, how much damage

    

    retTable = {atDamage,attHit,isKnockback,knockbackMulti}
    --print("statCompare retTable")
    --printTable(retTable)

    return retTable

end

function effectHit(attacker, defender)
    local atStat = attacker.mStats
    local deStat = defender.mStats
    local cacKind = attacker.card
    local cdcKind = defender.card

    if attacker.EffOffense ~= nil then
        local atHitToEvasionChance = calculateHitChange(atStat.acc, deStat.eva)
        local attHit = attackHits(atHitToEvasionChance)
        if attHit == true then
            --print("Attacker's Effect Has Hit!")
            attacker.effecthits = true
        else
            --print("Attacker's Effect Has Missed!")
            attacker.effectHits = false
        end
    end

    if defender.EffOffense ~= nil then
        local deHitToEvasionChance = calculateHitChange(deStat.acc, atStat.eva)
        local deHit = attackHits(atHitToEvasionChance)
        if deHit == true then
            --print("Defender's Effect Has Hit!")
            defender.effectHits = true
        else
            --print("Defender's Effect Has Missed!")
            defender.effectHits = false
        end
    end

    return attacker, defender
end



function calculateHitChance(accuracy, evasion)
    local minimumHitChance = 1
    local maximumHitChance = 100

    local evasionImpact = evasion > accuracy and (accuracy / evasion) * evasion or evasion
    local hitChance = accuracy - evasionImpact

    hitChance = math.max(minimumHitChance, hitChance)
    hitChance = math.min(maximumHitChance, hitChance)

    return hitChance
end

function attackHits(hitChance)
    local rndChance = math.random(1, 100)
    
    if rndChance <= hitChance then
        return true  -- Attack hits
    else
        return false  -- Attack misses
    end
end

function calcKnockback(offense, mass)
    local percentage = (offense / mass) * 100
    --print("offense of "..offense.." is "..percentage.." percent of mass "..mass)

    if percentage >= 200 then
        return 100
    elseif percentage >= 160 and percentage <= 189 then
        return 80
    elseif percentage >= 130 and percentage <= 159 then
        return 60
    elseif percentage >= 80 and percentage <= 129 then
        return 40
    elseif percentage >= 60 and percentage <= 79 then
        return 20
    elseif percentage >= 50 and percentage <= 59 then
        return 10
    else
        return 0
    end
end

function calculateKnockDamage(atType, stats, scale) -- criticals scale with difference in power
    local stt = nil
    if atType == "command" or atType == "physical" then
        stt = stats.str
    elseif atType == "ki" then
        stt = stats.ki
    end
    local per = scale * .01
    local critDamage = stt * per
    return critDamage
end

function moveProcessing(atta, defe)
    --[[
    print("Move Processing")
    print("atta table: ")
    printTable(atta)
    print("------------")
    print(" ")
    print("defe table: ")
    printTable(defe)
    print("------------")
    print(" ")
    --]]
    local attackerMovement = false
    local defenderMovement = false
    if atta.card[cType] == DMove then
        attackerMovement = true
    end
    if defe.card[cType] == DMove then
        defenderMovement = true
    end

    local cardHitTable = atta.cardHitMiss
    local statHitTable = atta.statHitMiss
    local attackerEffect = atta.EffOffense
    local defenderEffect = defe.EffOffense -- check correctness
    local deStat = defe.mStats
    local atStat = atta.mStats

    --[[
    print(tostring(statHitTable.attHit))
    print("----------------------")
    print("cardHitTable. Generated by moveCompare. Should have {wOutCome, kindOfHit}")
    for i,v in pairs(cardHitTable) do
        print("index: "..i.." value: "..tostring(v))
    end
    
    print("----------------------")
    print("statHitTable. Generated by statCompare. Should have {atDamage,attHit,isKnockback,knockbackMulti}")
    
    for i,v in pairs(statHitTable) do
        print("index: "..i.." value: "..tostring(v))
    end
    print("----------------------")
    ]]

    local cardHit = cardHitTable[1] -- boolean for if the attack lands
    local hitType = cardHitTable[2] -- string for stat that is affected by the hit
    local damageAmount = statHitTable[1] --number
    local statHit = statHitTable[2] -- boolean
    local knockbackHit = statHitTable[3] --boolean
    local knockbackDamage = statHitTable[4] -- amount

    if cardHit == true and statHit == true then
        --print("attack hit in eval")
        if knockbackHit == true then
            damageAmount = damageAmount + knockbackDamage
        end

        deStat.hp = deStat.hp - damageAmount

    elseif cardHit == false and statHit == true then
        -- Attack dodged
    elseif cardHit == true and statHit == false then
        -- Enemy dodges attack
    else
        -- complete miss (critical miss?)
    end
    
    if atta.offensiveEffect == true then -- apply changes to defender's stats if true
        for i,v in pairs (deStats) do
            if v == attackerEffect.stat then
                v = v - attackerEffect.num
            end
        end
    end

    defe.mStats = deStat

    if defe.offensiveEffect == true then -- apply changes to attacker's stats if true
        for i,v in pairs (atStats) do
            if v == defenderrEffect.stat then
                v = v - defenderEffect.num
            end
        end
    end

    atta.mStats = atStat

    return atta, defe
end

function newHPStats(original,turnStats)
    original.chrHp = turnStats.hp
    return original
end

function postTurn(attacker,defender)    
    local timerPT = playdate.timer.new(1000, function() 
        nextPhase()
    end)
    -- if it is a new turn, set any temporary changes in stats back to normal using the table in side.prevStats
    -- apply any transformation changes
    -- apply powerup changes
    -- check to see if anyone is dead
    -- change to new partner if someone is dead and a partner is available
    -- if not, give victory or defeat
    --
end

function fullHand(execItem) --where execItem is the o.parentItem to be used after a card is discarded
    SubMode = SubEnum.DIAG
    local tossCheck = false

    batDialogue:new("fullHand")

    playerTemp = execItem

end

function tallyDamage()
    local crd = {}
    local attacker = {}
    local defender = {}
    if CurrentPhase == Phase.ATTACK then
        crd = playerTurnTable.card
        attacker = playerTurnTable
        defender = enemyTurnTable
    elseif CurrentPhase == Phase.DEFENSE then
        crd = enemyTurnTable.card
        attacker = enemyTurnTable 
        defender = playerTurnTable
    end

    local damage = crd.cPower * attacker["mStats"]["str"]
    if battleSpriteIndex["attacker"].damageApplied == nil then
        battleSpriteIndex["attacker"].damageApplied = 0
    end
    battleSpriteIndex["attacker"].damageApplied = battleSpriteIndex["attacker"].damageApplied + damage
end


function applyDamage(attackerTable, defenderTable, nFunc)
    if attackerTable.damageApplied == nil then
        attackerTable.damageApplied = 0 -- this occurs when the attacker fails to execute any stg attacks. Due to foresight or error on their part.
    end
    --print("atkrDamage: "..attackerTable.damageApplied)
    local defLife = {}
    if CurrentPhase == Phase.ATTACK then
        defLife = lifeBarIndex["enemyHP"]
    else 
        defLife = lifeBarIndex["playerHP"]
    end
    if attackerTable.damageApplied ~= 0 then
        defLife:damage(attackerTable.damageApplied,nFunc)
    else
        defLife:damage(0,nFunc)
    end
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

function tossCard(item)
    local remCard = cardRet(item)
    for i,v in pairs(playerDeck) do
        if remCard.cNumber == v then -- will remove the first card with the same cNumber in playerDeck. This means that if there are two identical cards, the first one found will be removed.
            table.remove(playerDeck,i)
        end
    end
    for i,v in pairs(menuIndex) do
        if v.tag == "tossSelect" then
            v:spriteKill()
            menuIndex[i] = nil
        end
    end
    goOption(playerTemp, "player")
    playerTemp = nil
    return 0
end