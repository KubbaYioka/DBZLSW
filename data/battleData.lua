--Contains all battle data for each story fight. 
--Read Only

--[[
    nnStory## = {                     --denoted by either db, dbz, or dbs. Must Match story data file names

        allowedFighters = {           --fighters the player is allowed. ignored if game has been beaten, except for # in array
            "chrName",
            "chrName"
        },
        enemyFighters = {             --fighters that the computer will use
            "chrName",
            "chrName"
        },   
        enemyCardList = {             --cards that the computer will have
            "nil"
        }
        enemyLevels = {               --level modifiers for the enemy fighers. Changes stats
            0,
            n,
        },

        progressIfDead = False,       --decides if the story progresses if the player loses

        bgGfx = "nil",                --background graphics
        bgMusic = "nil",              --background music

        victoryCards = {              --cards the player chooses from if they win
            "nil1",
            "nil2",
            "nil3"
        },
]]--

local storyFighters = {

    dbStory00 = {

        allowedFighters = {
            "dbGoku"
        },
        enemyFighters = {
            "dbKrillin"
        },
        enemyCardList = {
            "nil",
            "nil"
        },
        enemyLevels = {
            0
        },
        progressIfDead = false,
        bgGfx = "nil",
        bgMusic = "nil",
        victoryCards = {
            "nil1",
            "nil2",
            "nil3"
        },
    },

    dbStory02 = {

    }
}