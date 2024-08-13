spriteMetadata = {

    ["dbGoku"] = {
        ["image"] = "assets/images/battleGraphics/dbGoku",
        ["normalStance"] = {1,1},
        ["flyBack"] = {2,1},
        ["flyForward"] = {3,1},
        ["armsWide"] = {4,1},
        ["blurForward"] = {5,1},
        ["endurance"] = {6,1},
        ["stageA"] = {7,1},
        ["stageB"] = {1,2},
        ["stageBack"] = {5, 2},
        ["stageUp"] = {6, 2},
        ["stageDown"] = {1, 3},
        ["rapidKickOne"] = {2, 2},
        ["rapidKickTwo"] = {3, 2},
        ["contPunch"] = {8, 1},
        ["block"] = {4, 2},
        ["leap"] = {7, 2},
        ["hammerUp"] = {8, 2},
        ["damage"] = {2, 3},
        ["damageUp"] = {3, 3},
        ["heavyDamage"] = {4, 3},
        ["dizzyOne"] = {5, 3},
        ["dizzyTwo"] = {6, 3},
        ["down"] = {7, 3},
        ["leftKi"] = {1, 4},
        ["rightKi"] = {2, 4},
        ["chargeKiTwo"] = {3, 4},
        ["kiBlastTwo"] = {4, 4},
        ["chargeKi"] = {7, 4},
        ["blastKi"] = {8, 4},
        ["taioken"] = {8, 3},
        ["RunOne"] = {3,1},
        ["RunTwo"] = {3,1},
        ["RunThree"] = {3,1},
        ["RunFour"] = {3,1},
        ["placeholder"] = nil
    },
    ["dbKrillin"] = {
        ["image"] = "assets/images/battleGraphics/dbKrillin",
        ["normalStance"] = {1,1},
        ["flyBack"] = {2,1},
        ["flyForward"] = {3,1},
        ["armsWide"] = {4,1},
        ["blurForward"] = {5,1},
        ["endurance"] = {6,1},
        ["stageA"] = {7,1},
        ["stageB"] = {8,1},
        ["stageBack"] = {5,2},
        ["stageUp"] = {6,2},
        ["stageDown"] = {3,1},
        ["rapidKickOne"] = {2,1},
        ["rapidKickTwo"] = {2,2},
        ["block"] = {3,2},
        ["leap"] = {7,2},
        ["hammerUp"] = {8,2},
        ["damage"] = {3,2},
        ["damageUp"] = {3,3},
        ["heavyDamage"] = {4,3},
        ["dizzyOne"] = {5,3},
        ["dizzyTwo"] = {6,3},
        ["down"] = {7,3},
        ["leftKi"] = {1,4},
        ["rightKi"] = {2,4},
        ["chargeKi"] = {4,4},
        ["blastKi"] = {5,4},
        ["chargeKiTwo"] = {6,4},
        ["blastKiTwo"] = {7,4},
        ["taioken"] = {8,3},
        ["chargeKiThree"] = {3,4},
        ["blastKiThree"] = {},
        ["placeholder"] = nil
    },

    ["placeholder"] = {}
}

characterAnimationTables = {
    ["generic"] = {
        ["stgPrepare"] = {
            [1] = {"armsWide",100},
            [2] = {"blurForward",50},
            [3] = {"endurance",800},
            [4] = {"normalStance",0}
        },
        ["flyForward"] = {
            [1] = {"flyForward",0,function(self) btlSprite:moveInDirection("right", 10) end} -- placeholder
        },
        ["flyDown"] = {
            [1] = {"flyForward",0,function(self) btlSprite:moveInDirection("right", 10) end} -- placeholder
        },
        ["jumpForward"] = {
            [1] = {"flyForward",0,function(self) btlSprite:moveInDirection("right", 10) end} -- placeholder
        },
        ["jumpUp"] = {
            [1] = {"flyForward",0,function(self) btlSprite:moveInDirection("right", 10) end} -- placeholder
        },
        ["runForward"] = {
            [1] = {"flyForward",0,function(self) btlSprite:moveInDirection("right", 10) end}
        },
        ["dashRunForward"] = {
            [1] = {"flyForward",0,function(self) self:moveInDirection("right", 10) end} -- placeholder
        },
        ["Ki Blast"] = {
            [1] = {"rightKi",4000}
        },
        ["Ki Wave"] = {
            [1] = {"rightKi",4000}
        },
        ["Cont. Punch"] = {
            [1] = {"stageA",500},
            [2] = {"stageB",500},
            [3] = {"stageA",500},
            [4] = {"stageB",500},
            [5] = {"stageA",500},
            [6] = {"stageB",500},
            [7] = {"stageA",500},
            [8] = {"stageB",500},
            [9] = {"stageA",500},
            [10] = {"stageB",500},
            [11] = {"normalStance", 1500},
            [12] = {"chargeKiOne",300},
            [13] = {"blurForward", 200},
            [14] = {"stageB",2000}
        },
        ["Cont. Kick"] = {
            [1] = {"rapidKickOne",500},
            [2] = {"rapidKickTwo",500},
            [3] = {"rapidKickOne",500},
            [4] = {"rapidKickTwo",500},
            [5] = {"rapidKickOne",500},
            [6] = {"rapidKickTwo",500},
            [7] = {"rapidKickOne",500},
            [8] = {"rapidKickTwo",500},
            [9] = {"rapidKickOne",500},
            [10] = {"rapidKickTwo",500},
            [11] = {"normalStance", 1500},
            [12] = {"blurForward", 200},
            [13] = {"rapidKickTwo",500},
            [14] = {"leap",300},
            [15] = {"normalStance", 2000}
        }


    },
    ["dbGoku"] = {

    },
    ["dbKrillin"] = {

    }

}

stageAttackAni = {
    ["a"] = {"stageA",300,"none"},
    ["b"] = {"stageB",300,"none"},
    ["back"] = {"stageBack",1000,"none"},
    ["up"] = {"stageUp",1000,"none"},
    ["down"] = {"stageDown",1000,"none"}
}

function getMovementAni()
    -- will check to see if a character can fly or not. If so, they will glide. If not, they will run\leap.
    return "leap",600,"arc" -- for now, will simply return leaping in an arc
end

function getDistance() -- gets the locations of both the attacker and defender to see how much time the attacker has to enter a cmd
    return 2000 -- for now, this number will be 2 seconds
end