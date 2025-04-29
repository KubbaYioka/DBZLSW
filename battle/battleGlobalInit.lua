--battleGlobalInit
--Initializes globals for battleEngine

local gfx = playdate.graphics

function bTabInit()
    print("Message from battleGlobalInit.lua: ")
    print("Player's CC hardcoded to 15. Line ~25.")
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
    playerTeamRO = {}
    pDeckCopy={} -- copy of RAMSAVE[4]
    playerDeck={}
    playerCC = 15
    playerTemp = nil -- to hold card data temporarily.
    playerPoweredUp = false
    playerStandReady = false
    playerBattleDamaged = false
    playerSprTab = {
        sprRange = {}
        ,current = 0
        ,position = PositionEnum.GroundAft
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