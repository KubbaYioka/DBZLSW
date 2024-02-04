--[[
    
Master Cards List

desig = {"number","desig","name","cc","type","stat","ability","allowedChrs"}

     number= Sequential number in the card list
      desig= designator name
       name= Name of the card
         cc= CC cost of using the card
       type= Type can be things like Def, Att, or Both (remember that the effect may be different based on phase)
       stat= what stat the card alters
    ability= Visible ability the card triggers (afterimage)
   hAbility= Invisible ability the card triggers
allowedChrs= list of characters the card can be used by. chrAll for all characters
--]]

--Type Enumeration
CCommand = "command"
CPhysical = "physical"
CKi = "ki"
CEffect = "effect"
CTrans = "transformation"
CFocus = "focus"
CAI = "afterimage"
CPower = "powerup"


--Phase Enumeration

PBoth = "both"
PAttack = "attack"
PDefense = "defense"

--Ability Enumeration
PDefUp = "P Defense Up"
ODefDn = "O Defense Down"
PKiUp =  "P Ki Up"
OKiDn =  "O Ki Down"
PStrUp = "P Strength Up"
PStrDn = "O Strength Down"
PSpdUp = "P Speed Up"
OSpdDn = "O Speed Down"
HpReg = "HP Regen"
PEvaUp = "P Evasion Up"
OEvaDn = "O Evasion Down"
PAccUp = "P Accuracy Up"
OAccDn = "O Accuracy Down"
None = "none"

--Other Enumeration
AllChrs = "all" -- all characters allowed to use card.

cards = {
["3 Stage Attack"] =
  {
    cName = "3 Stage Attack"
    ,cNumber = 001
    ,cType = CCommand
    ,cPower = 1
    ,cAccuracy = 100 
    ,cCost = 0
    ,cEffect = "Basic Attack."
    ,cDescription = "Gains 3 CC on successful attack."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cPortrait = {1,1}
  }
,["4 Stage Attack"] =
  {
    cName = "4 Stage Attack"
    ,cNumber = 002
    ,cType = CCommand
    ,cPower = 1
    ,cAccuracy = 100 
    ,cCost = 0
    ,cEffect = "Basic Attack."
    ,cDescription = "Gains 4 CC on successful attack."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cPortrait = {1,2}
  }
,["5 Stage Attack"] =
  {
    cName = "5 Stage Attack"
    ,cNumber = 003
    ,cType = CCommand
    ,cPower = 1
    ,cAccuracy = 100 
    ,cCost = 0
    ,cEffect = "Basic Attack."
    ,cDescription = "Gains 5 CC on successful attack."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cPortrait = {1,3}
  }
,["6 Stage Attack"] =
  {
    cName = "6 Stage Attack"
    ,cNumber = 004
    ,cType = CCommand
    ,cPower = 1
    ,cAccuracy = 100 
    ,cCost = 0
    ,cEffect = "Basic Attack."
    ,cDescription = "Gains 6 CC on successful attack."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cPortrait = {1,4}
  }
,["7 Stage Attack"] =
  {
    cName = "7 Stage Attack"
    ,cNumber = 005
    ,cType = CCommand
    ,cPower = 1
    ,cAccuracy = 100 
    ,cCost = 0
    ,cEffect = "Basic Attack."
    ,cDescription = "Gains 7 CC on successful attack."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cPortrait = {1,5}
  }
,["Cont. Punch"]=
  {
    cName = "Cont. Punch"
    ,cNumber = 006
    ,cType = CPhysical
    ,cPower = 1
    ,cAccuracy = 90 
    ,cCost = 10
    ,cEffect = "Rapid Punches."
    ,cDescription = "A basic series of punches."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cPortrait = {1,6}
  }
,["Cont. Kick"]=
  {
    cName = "Cont. Kick"
    ,cNumber = 007
    ,cType = CPhysical
    ,cPower = 20
    ,cAccuracy = 80 
    ,cCost = 15
    ,cEffect = "Rapid Kicks."
    ,cDescription = "A basic series of kicks."
    ,cPhases = PAttack
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cPortrait = {1,7}
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
    ,cPortrait = {1,8}
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
    ,cPortrait = {1,9}
  }
,["Endurance"]=
  {
    cName = "Endurance"
    ,cNumber = 010
    ,cType = CEffect
    ,cPower = function() enduranceCalc(pDef) end 
    ,cAccuracy = 100 
    ,cCost = 7
    ,cEffect = "Raise Defense."
    ,cDescription = "Defends against attacks using whole body."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cPortrait = {1,10}
  }
  ,["Card 11"]=
  {
    cName = "Card 11"
    ,cNumber = 011
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 11's Effect."
    ,cDescription = "Description for Card 11."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cPortrait = {2,1}
  }
  ,["Card 12"]=
  {
    cName = "Card 12"
    ,cNumber = 012
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 12's Effect."
    ,cDescription = "Description for Card 12."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cPortrait = {2,2}
  }
  ,["Card 13"]=
  {
    cName = "Card 13"
    ,cNumber = 013
    ,cType = CEffect
    ,cPower = CEffect
    ,cAccuracy = 100 
    ,cCost = 1
    ,cEffect = "Card 13's Effect."
    ,cDescription = "Description for Card 13."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
    ,cPortrait = {2,3}
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
    ,cPortrait = {2,4}
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
    ,cPortrait = {2,5}
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
    ,cPortrait = {2,6}
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
    ,cPortrait = {2,7}
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
    ,cPortrait = {2,8}
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
    ,cPortrait = {2,9}
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
    ,cPortrait = {2,10}
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
    ,cPortrait = {3,1}
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
    ,cPortrait = {3,2}
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
    ,cPortrait = {3,3}
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
    ,cPortrait = {3,4}
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
    ,cPortrait = {3,5}
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
    ,cPortrait = {3,6}
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
    ,cPortrait = {3,7}
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
    ,cPortrait = {3,8}
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
    ,cPortrait = {3,9}
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
    ,cPortrait = {3,10}
  }

}

function cardRet(cardName) -- gets the card data from tthe above master table. Not for Save access.
  for i,v in pairs (cards) do
      if v.cName == cardName then
        return v
      end
  end
end

function cardPort(cardName)
  if cardName ~= "  " then
    for i,v in pairs (otherIndex) do
      if type(v) =="table" and v.cardIcon then
        v:spriteKill{}
      end
    end
    local cardPort = CardIcon:new(cardName)
    cardPort:changeState(cardName)
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
        print(i.." "..v)
        if v == selected and i == selIndex then
          print(v)
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
    RAMSAVE[4] = dList
  end
end

--Card Calculations
function enduranceCalc(def)
  --takes the user's current defense and increases it by half
end