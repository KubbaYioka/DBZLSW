--battle data

--Win condition enum

local winCond = {
    health75 = 75 -- percentage of health left for win\lose
    ,health50 = 50
    ,health25 = 25
    ,healthZero = 0
    --perhaps add functions for special win conditions
}

local arenaList = {
    tenkaichi = "bgTourn" -- reference to the .png in the background folder
    ,noko = nil
}
local turnBGList = {
    tenkaichi = "bgTournAni"
    ,noko = nil
}

battles = {

    ["battleTest"] = {
        ["name"] = "Test Battle"

        ,["oppoParam"] = {
            oppoTeam = {"dbKrillin"}
            ,opponentLvl = {10}
            ,opponentDeck = {1,2,1,2,1,2,1,2,1,3,4,5,6,7,1,2,3,4,5,6}
            ,opponentLimit = {
                [1] = {"Energy Blast","Cont. Kick"}
            }
            ,opponentAppearance = {"normal"} -- first index in table is for the first index in oppoTeam, aka first chr
            ,opponentTrans = {"none"}
            ,opponentAIType = {AI.NORMAL}
            ,opponentTransformations = { -- only for initial state. Available transformations should be calculated based on level tables in another function.
                [1] = "normal"
            }

            }
        ,["arenaParam"] = {
            bField = arenaList.tenkaichi,
            turnField = turnBGList.tenkaichi
        }
        ,["eventParam"] = {
            winCondition = healthZero
            ,secretWin = nil -- conditions in which a secret is unlocked. Could be the use of a chr or attack or winning with a certain amount of health
            ,winCards = {4,5,6} -- cards that can be collected upon win
            ,secWinCards = {} -- cards that can be collected if a condition is met
        }
    }
}