--MENU MASTER LIST
startMenu={"New Game","Options"}

intermMenu={"New Game","Continue","Options"}

fullMenuMain={"New Game", "Continue", "Battle", "Options"}

menuBattle={"Characters","Team","Deck","List","Save","Exit"} --all will read and write from save and data files

menuPause={"Characters","Deck","List","Save","Exit"} --all will read and write from save and data files


menuPosEnum = {
    menuPosChr = "chr"
    ,menuPosvar = "varMenu"
    ,menuPosBattle = "battle"
    ,menuPosPause = "pause"
    ,menuPosStart = "start"
    ,menuPosInterim = "interim"
    ,menuPosFullMenu = "fullmenu"
}

function menuPosition(menuName)
    if menuName == startMenu or menuName == intermMenu or menuName == fullMenuMain then
        return 80, 120
    elseif menuName == menuBattle or menuName == menuPause then
        return 0,0
    elseif menuName == menuPosEnum.menuPosvar then
        return 2,85
    elseif menuName == menuPosEnum.numberBox then
        return 0,60
    elseif menuName == menuPosEnum.menuPosChr then
        return 40,40
    else
        print("menuName not recognized in menuPosition - menuCat.lua")
        return 100,100
    end
end


