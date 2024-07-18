    
--Master Cards List

--Type and SubType Enumeration--

--types--
CCommand = "command"
CPhysical = "physical"
CKi = "ki"
CEffect = "effect"
CTrans = "transformation"
CReady = "ready"
CPower = "powerup"
CGuard = "guard"

--Phase Enumeration

PBoth = "both"
PAttack = "attack"
PDefense = "defense"

--Ability Funtions
function PDefUp(side,card) --raise Def for user
  print("Define code for PDefUp in cards.lua")
end

function ODefDn(side,card) --lower enemy defense
  local stat = nil
  local num = nil
  print("Define code for ODefDn in cards.lua")
  local tab = {stat,num}
  return tab
end

function PKiUp(side,card) --raise Ki for user 
  print("Define code for PKiUp in cards.lua")
end

function OKiDn(side,card) --lower ki for opponent
  print("Define code for OKiDn in cards.lua")
end

function PStrUp(side,card) --raise strength for user"
  print("Define code for PStrUp in cards.lua")
end

function OStrDn(side,card) -- lower opponent strength
  print("Define code for OStrDn in cards.lua")
end

function PSpdUp(side,card)--raise user's speed
  print("Define code for PSpdUp in cards.lua")
end

function OSpdDn(side,card) --lower opponent's speed
  print("Define code for OSpdDn in cards.lua")
end

function HpReg(side,card) -- regenerate HP
  print("Define code for HpReg in cards.lua")
end

function PEvaUp(side,card)-- raise user's evasion (note that this should be a greater increase than something that raises speed alone)
  print("Define code for PEvaUp in cards.lua")
end

function OEvaDn(side,card)-- lower opponent's evasion
  print("Define code for OEvaDn in cards.lua")
end

function PAccUp(side,card)-- raise user's accuracy
  print("Define code for PAccUp in cards.lua")
end

function OAccDn(side,card) -- lower opponent's accuracy
  print("Define code for OAccDn in cards.lua")
end

function CCAdd(side,card) -- add CC to the user
  print("Define code for CCAdd in cards.lua")
end

function AfterImage(side,card) -- apply afterimage to user
  print("Define code for AfterImage in cards.lua")
end

function breakBlock(side,card) -- breaks through avoiding cards
  side.breakBlock = true
  return side
end

function DefBoost(side,card) -- raises defense for a single turn, used with Endurance, for instance
  local tempTab = {}
  tempTab.def =  side.def
  side.def = side.def + (side.def * card.cPower)
  side.prevStats = tempTab
  return side
end

function PhysBlock(side,card) -- Blocks physical type moves completely
  side.willBlock = "phys"
  return side
end

function KiAvoid(side,card) -- Dodges most Ki-based attacks
  side.willBlock = "ki"
  return side
end

function CDGuard(side,card) -- basic guard command
  print("Define code for CDGuard in cards.lua")
  return side
end

function ChrMove(side,card) -- basic movement, carries slight penalty
  print("Define code for ChrMove in cards.lua")
end

function CommandBlock(side,card)
  side.willBlock = "com"
  return side
end

function NoAbility(side,card)
  return side
end

AbilityTableSelf ={ -- abilities applied to the self
  PDefUp
  ,PKiUp
  ,PStrUp
  ,PSpdUp
  ,HpReg
  ,PEvaUp
  ,PAccUp
  ,CCAdd
  ,AfterImage
  ,breakBlock
  ,DefBoost
  ,PhysBlock
  ,KiAvoid
  ,CDGuard
  ,ChrMove
  ,CommandBlock
  ,NoAbility
}

OffensiveAbilities = {
  ODefDn
  ,OKiDn
  ,OStrDn
  ,OSpdDn
  ,OEvaDn
  ,OAccDn
  ,NoAbility
}

--Other Enumeration
AllChrs = "all" -- all characters allowed to use card.

cards = {
["3 Stage Attack"] =
  {
    cName = "3 Stage Attack"
    ,cNumber = 001
    ,cType = CCommand
    ,cPower = .5 -- percentage of base power to add to attack
    ,cAccuracy = 100 
    ,cCost = 0
    ,cCostGain = 3
    ,cEffect = "Basic Attack."
    ,cDescription = "Gains 3 CC on successful attack."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {1,1}
    ,mIcon = 2
  }
,["4 Stage Attack"] =
  {
    cName = "4 Stage Attack"
    ,cNumber = 002
    ,cType = CCommand
    ,cPower = .5 
    ,cAccuracy = 100 
    ,cCost = 0
    ,cCostGain = 4
    ,cEffect = "Basic Attack."
    ,cDescription = "Gains 4 CC on successful attack."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {1,2}
    ,mIcon = 2
  }
,["5 Stage Attack"] =
  {
    cName = "5 Stage Attack"
    ,cNumber = 003
    ,cType = CCommand
    ,cPower = .5
    ,cAccuracy = 100 
    ,cCost = 0
    ,cCostGain = 5
    ,cEffect = "Basic Attack."
    ,cDescription = "Gains 5 CC on successful attack."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {1,3}
    ,mIcon = 2
  }
,["6 Stage Attack"] =
  {
    cName = "6 Stage Attack"
    ,cNumber = 004
    ,cType = CCommand
    ,cPower = .5
    ,cAccuracy = 100 
    ,cCost = 0
    ,cCostGain = 6
    ,cEffect = "Basic Attack."
    ,cDescription = "Gains 6 CC on successful attack."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {1,4}
    ,mIcon = 2
  }
,["7 Stage Attack"] =
  {
    cName = "7 Stage Attack"
    ,cNumber = 005
    ,cType = CCommand
    ,cPower = .5
    ,cAccuracy = 100 
    ,cCost = 0
    ,cCostGain = 7
    ,cEffect = "Basic Attack."
    ,cDescription = "Gains 7 CC on successful attack."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {1,5}
    ,mIcon = 2
  }
,["Cont. Punch"]=
  {
    cName = "Cont. Punch"
    ,cNumber = 006
    ,cType = CPhysical
    ,cPower = 2
    ,cAccuracy = 90 
    ,cCost = 10
    ,cEffect = "Rapid Punches."
    ,cDescription = "A basic series of punches."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {1,6}
    ,mIcon = 3
  }
,["Cont. Kick"]=
  {
    cName = "Cont. Kick"
    ,cNumber = 007
    ,cType = CPhysical
    ,cPower = 4
    ,cAccuracy = 80 
    ,cCost = 15
    ,cEffect = "Rapid Kicks."
    ,cDescription = "A basic series of kicks."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {1,7}
    ,mIcon = 3
  }
,["Energy Blast"]=
  {
    cName = "Energy Blast"
    ,cNumber = 008
    ,cType = CKi
    ,cPower = 10
    ,cAccuracy = 80 
    ,cCost = 8
    ,cEffect = "Basic energy ball."
    ,cDescription = "A simple blast of energy from within."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {1,8}
    ,mIcon = 4
  }
,["Energy Wave"]=
  {
    cName = "Energy Wave"
    ,cNumber = 009
    ,cType = CKi
    ,cPower = 15
    ,cAccuracy = 90 
    ,cCost = 12
    ,cEffect = "Basic energy wave"
    ,cDescription = "A sustained wave of energy."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {1,9}
    ,mIcon = 4
  }
,["Endurance"]=
  {
    cName = "Endurance"
    ,cNumber = 010
    ,cType = CEffect
    ,cPower = 0.5 -- to increase player defense by 50%
    ,cAccuracy = 100 
    ,cCost = 7
    ,cEffect = "Raise Defense."
    ,cDescription = "Defends against attacks using whole body."
    ,cPhases = PDefense
    ,cAbility = DefBoost
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {1,10}
    ,mIcon = 10
  }
,["Sword Slash"]=
  {
    cName = "Sword Slash"
    ,cNumber = 011
    ,cType = CPhysical
    ,cPower = 5
    ,cAccuracy = 80
    ,cCost = 5
    ,cEffect = "Attack with a Sword."
    ,cDescription = "Simple swing of the sword."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = {"dbzFTrunks","dbYamcha","dbBearThief","dbzKidGohan","dbzTeenGohan","dbzDabura","dbMurasaki","dbTao"}
    ,cNForms = None
    ,cPortrait = {2,1}
    ,mIcon = 20
  }
,["Pole Strike"]=
  {
    cName = "Pole Strike"
    ,cNumber = 012
    ,cType = CPhysical
    ,cPower = 5
    ,cAccuracy = 80
    ,cCost = 5
    ,cEffect = "Strike with Pole Weapon."
    ,cDescription = "Simple strike with a pole"
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = {"dbGoku","dbKorin","dbRoshi"}
    ,cNForms = None
    ,cPortrait = {2,2}
    ,mIcon = 20
  }
,["Pistol Shot"]=
  {
    cName = "Pistol Shot"
    ,cNumber = 013
    ,cType = CPhysical
    ,cPower = 6
    ,cAccuracy = 60
    ,cCost = 5
    ,cEffect = "Shot from a handgun."
    ,cDescription = "Strong, but inaccurate."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = {"dbBulma"}
    ,cNForms = None
    ,cPortrait = {2,3}
    ,mIcon = 20
  }
  ,["Card 14"]=
  {
    cName = "Card 14"
    ,cNumber = 014
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 14's Effect."
    ,cDescription = "Description for Card 14."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {2,4}
    ,mIcon = 6
  }
  ,["Card 15"]=
  {
    cName = "Card 15"
    ,cNumber = 015
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 15's Effect."
    ,cDescription = "Description for Card 15."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {2,5}
    ,mIcon = 6
  }
  ,["Card 16"]=
  {
    cName = "Card 16"
    ,cNumber = 016
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 16's Effect."
    ,cDescription = "Description for Card 16."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {2,6}
    ,mIcon = 6
  }
  ,["Card 17"]=
  {
    cName = "Card 17"
    ,cNumber = 017
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 17's Effect."
    ,cDescription = "Description for Card 17."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {2,7}
    ,mIcon = 6
  }
  ,["Card 18"]=
  {
    cName = "Card 18"
    ,cNumber = 018
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 18's Effect."
    ,cDescription = "Description for Card 18."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {2,8}
    ,mIcon = 6
  }
  ,["Card 19"]=
  {
    cName = "Card 19"
    ,cNumber = 019
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 19's Effect."
    ,cDescription = "Description for Card 19."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {2,9}
    ,mIcon = 6
  }
  ,["Card 20"]=
  {
    cName = "Card 20"
    ,cNumber = 020
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 20's Effect."
    ,cDescription = "Description for Card 20."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {2,10}
    ,mIcon = 6
  }
  ,["Card 21"]=
  {
    cName = "Card 21"
    ,cNumber = 021
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 21's Effect."
    ,cDescription = "Description for Card 21."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {3,1}
    ,mIcon = 6
  }
  ,["Card 22"]=
  {
    cName = "Card 22"
    ,cNumber = 022
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 22's Effect."
    ,cDescription = "Description for Card 22."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {3,2}
    ,mIcon = 6
  }
  ,["Card 23"]=
  {
    cName = "Card 23"
    ,cNumber = 023
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 23's Effect."
    ,cDescription = "Description for Card 23."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {3,3}
    ,mIcon = 6
  }
  ,["Card 24"]=
  {
    cName = "Card 24"
    ,cNumber = 024
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 24's Effect."
    ,cDescription = "Description for Card 24."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {3,4}
    ,mIcon = 6
  }
  ,["Card 25"]=
  {
    cName = "Card 25"
    ,cNumber = 025
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 25's Effect."
    ,cDescription = "Description for Card 25."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {3,5}
    ,mIcon = 6
  }
  ,["Card 26"]=
  {
    cName = "Card 26"
    ,cNumber = 026
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 26's Effect."
    ,cDescription = "Description for Card 26."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {3,6}
    ,mIcon = 6
  }
  ,["Card 27"]=
  {
    cName = "Card 27"
    ,cNumber = 027
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 27's Effect."
    ,cDescription = "Description for Card 27."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {3,7}
    ,mIcon = 6
  }
  ,["Card 28"]=
  {
    cName = "Card 28"
    ,cNumber = 028
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 28's Effect."
    ,cDescription = "Description for Card 28."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {3,8}
    ,mIcon = 6
  }
  ,["Card 29"]=
  {
    cName = "Card 29"
    ,cNumber = 029
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 29's Effect."
    ,cDescription = "Description for Card 29."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {3,9}
    ,mIcon = 6
  }
  ,["Card 30"]=
  {
    cName = "Card 30"
    ,cNumber = 030
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 30's Effect."
    ,cDescription = "Description for Card 30."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
    ,cPortrait = {3,10}
    ,mIcon = 6
  }
  ,["2 Stage Attack"]=
  {
  cName = "2 Stage Attack"
  ,cNumber = 031
  ,cType = CCommand
  ,cPower = .5
  ,cAccuracy = 100 
  ,cCost = 0
  ,cEffect = "Basic Attack"
  ,cDescription = "Gain 2 CCs on successful attack."
  ,cPhases = PDefense
  ,cAbility = None
  ,cAllowed = AllChrs
  ,cNForms = None
  ,cPortrait = {4,1}
  ,mIcon = 6
  }

}

--[[
  ,["Avoiding"]=
  {
  cName = "Avoiding"
  ,cNumber = ###
  ,cType = CEffect
  ,cPower = 0
  ,cAccuracy = 100 
  ,cCost = 12
  ,cEffect = "Avoid Beam"
  ,cDescription = "A moment of foresight allows beam dodge."
  ,cPhases = PDefense
  ,cAbility = KiAvoid
  ,cAllowed = AllChrs
  ,cPortrait = {#,#}
  ,mIcon = #
  }

]]

BasicOther = { -- for all other actions that are not cards. 
  ["Guard"] = {
    cName = "Guard"
    ,cType = CGuard
    ,cPower = 0
    ,cAccuracy = 100
    ,cCost = 0
    ,cEffect = "Square Off"
    ,cDescription = "A simple defensive stance."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cNForms = None
  }
}

function cardRet(cardName) -- gets the card data from tthe above master table. Not for Save access.
  for i,v in pairs(BasicOther) do
    if v.cName == cardName then
      return v
    end
  end
  for i,v in pairs (cards) do
      if v.cName == cardName then
        return v
      end
  end

end

function cardPort(cardName)
  for i,v in pairs (otherIndex) do
    if type(v) =="table" and v.cardIcon then
      v:spriteKill{}
    end
  end
  if cardName ~= "  " then
    local cardPort = CardIcon(cardName)
  end
end

function cardInsert(location,mode,selected,selIndex,chrIndex,chrN) --selected is a string and selIndex is a number. lmtIndex is used to populate the limit slot
  if location == "deck" then -- for inserting\removing from joint deck
    if mode == "insert" then -- insertion uses reference to selected name string
      local cList = RAMSAVE[2]
      local dList = RAMSAVE[4]
      local cardDetail = nil
      for i,v in pairs(cList) do
        if type(v) == "table" then
          if selected == v.cName then
            v.cAvailable = v.cAvailable - 1
            cardDetail = v.cName
          end
        end
      end
      dList[selIndex] = cardDetail
      RAMSAVE[2] = cList
      RAMSAVE[4] = dList
    elseif mode == "remove" then -- removal uses reference to selected name string "cName"
      local cList = RAMSAVE[2]
      local dList = RAMSAVE[4]
      local cCount = false
      for i,v in pairs(dList) do
        if v == selected and i == selIndex then
          dList[i] = 0
        end
      end
      for j,k in pairs(cList) do
        if type(k) == "table" then
          if selected == k.cName then
            k.cAvailable = k.cAvailable + 1
            cCount = true
          end
        end
      end
      RAMSAVE[2] = cList
      RAMSAVE[4] = dList
    end
  elseif location == "limit" then -- for inserting\removing from limit
    local cList = RAMSAVE[2]
    local tempList = RAMSAVE[1]
    local limList = nil
    local cardDetail = nil
    if mode == "insert" then
      for i,v in pairs(tempList) do
        if type(v) == "table" then
          if v.chrNum == chrIndex and v.chrName == chrN then 
            limList = v.limit
            limList[selIndex] = selected
            v.limit = limList
          end
        end
      end
      
      for i,v in pairs(cList) do
        if type(v) == "table" then
          if selected == v.cName then
            v.cAvailable = v.cAvailable - 1
            cardDetail = v.cName
          end
        end
      end

    elseif mode == "remove" then
      for i,v in pairs(tempList) do
        if type(v) == "table" then
          if v.chrNum == chrIndex and v.chrName == chrN then
            limList = v.limit
            limList[selIndex] = nil
            v.limit = limList
          end
        end
      end
      
      for i,v in pairs(cList) do
        if type(v) == "table" then
          if selected == v.cName then
            v.cAvailable = v.cAvailable + 1
          end
        end
      end
    end

    RAMSAVE[1] = tempList
    RAMSAVE[2] = cList
  end
end

--Card Calculations
function enduranceCalc(def)
  --takes the user's current defense and increases it by half
end