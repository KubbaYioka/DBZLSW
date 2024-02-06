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
    tenkaichi = 'assets/images/background/fields.png'
}

battles = {

    battleTest = {
        name = "Test Battle"

        ,[oppoParam] = {
            ,oppoTeam = {"dbKrillin"}
            ,opponentLvl = {0}
            ,opponentDeck = {1,2,1,2,1,2,1,2,1,3,4,5,6,7,1,2,3,4,5,6}
            ,opponentLimit = {1,2,3}
            ,opponentAppearance = {"normal"}
            ,opponentTrans = {"none"}
            ,hasFly = [false] -- corresponds to the first index of each table in this groun (except deck and limit)
            ,hasLimit = [false]
            }
        ,[arenaParam] = {
            bField = arenaList.tenkaichi
        }
        ,[eventParam] = {
            winCondition = healthZero
            ,secretWin = nil -- conditions in which a secret is unlocked. Could be the use of a chr or attack or winning with a certain amount of health
            ,winCards = {4,5,6} -- cards that can be collected upon win
            ,secWinCards - {} -- cards that can be collected if a condition is met
        }
    }





}