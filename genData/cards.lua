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
  }
  ,["Dummy Card"]=
  {
    cName = "Dummy Card"
    ,cNumber = 020
    ,cType = CEffect
    ,cPower = function() enduranceCalc(pDef) end 
    ,cAccuracy = 100 
    ,cCost = 7
    ,cEffect = "Dummy Effect."
    ,cDescription = "Just A Dummy Card."
    ,cPhases = PDefense
    ,cAbility = None
    ,cAllowed = AllChrs
  }
}

function cardRet(cardName) -- gets the card data from tthe above master table. Not for Save access.
  for i,v in pairs (cards) do
      if v.cName == cardName then
        return v
      end
  end
end

function cardInsert(location,mode,card,cardIndex) --card is a string and cardIndex is a number
  if location == "deck" then -- for inserting\removing from joint deck
    if mode == "insert" then -- insertion uses reference to card name string
      local cList = RAMSAVE[2]
      local dList = RAMSAVE[4]
      local cardDetail = nil
      for i,v in pairs(cList) do
        if type(v) == "table" then
          if card == v.cName then
            v.cAvailable = v.cAvailable - 1
            cardDetail = v.cName
          end
        end
      end
      dList[cardIndex] = cardDetail
      RAMSAVE[2] = cList
      RAMSAVE[4] = dList
    elseif mode == "remove" then -- removal uses reference to card name string "cName"
      local cList = RAMSAVE[2]
      local dList = RAMSAVE[4]
      local cCount = false
      for i,v in pairs(dList) do
        print(i.." "..v)
        if v == card and i == cardIndex then
          print(v)
          dList[i] = 0
        end
      end
      for j,k in pairs(cList) do
        if type(k) == "table" then
          if card == k.cName then
            k.cAvailable = k.cAvailable + 1
            cCount = true
          end
        end
      end
      RAMSAVE[2] = cList
      RAMSAVE[4] = dList
    end
  elseif location == "limit" then -- for inserting\removing from limit
    if mode == "insert" then
    elseif mode == "remove" then
    end
  end
end

--Card Calculations
function enduranceCalc(def)
  --takes the user's current defense and increases it by half
end