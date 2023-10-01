--Story Data File

--Contains all story data, strings, flags, and triggers that the game uses. 

storyBattles = {

    story1 = {
        allowedPlrFighters = {"dbGoku"},
        eneFighters = {"dbKrillin"},
        progDefeat = false, -- can the player progress without defeat

        prizeCards = {nil}, --cards the player can pick from for winning
        chrAdd = false,     --boolean for whether or not a new character is added at the end of this fight
        addToRoster = {nil},--table containing references to characters to add from characterMaster{}

    }


}