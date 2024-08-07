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
        ["placeholder"] = nil
    },
    ["dbKrillin"] = {
        ["image"] = "assets/images/battleGraphics/dbKrillin",
        ["normalStance"] = {x=0, y=0, width=41, height=69},
        ["flyBack"] = {x=42, y=0, width=50, height=72},
        ["flyForward"] = {x=92, y=0, width=62, height=69},
        ["armsWide"] = {x=154,y=0,width=64,height=70},
        ["blurForward"] = {x=218,y=0,width=52,height=70},
        ["endurance"] = {x=270,y=0,width=40,height=70},
        ["stageA"] = {x=310,y=0,width=62,height=70},
        ["stageB"] = {x=174,y=74,width=68,height=72},
        ["stageBack"] = {x=242,y=74,width=52,height=74},
        ["stageUp"] = {x=294,y=74,width=62,height=74},
        ["stageDown"] = {x=42,y=168,width=52,height=50},
        ["rapidKickOne"] = {x=0,y=74,width=68,height=64},
        ["rapidKickTwo"] = {x=68,y=74,width=66,height=64},
        ["blockTwo"] = {x=134,y=74,width=40,height=74},
        ["leap"] = {x=134,y=74,width=40,height=74},
        ["hammerUp"] = {x=0,y=152,width=42,height=70},
        ["damage"] = {x=96,y=160,width=46,height=70},
        ["damageUp"] = {x=142,y=159,width=44,height=68},
        ["heavyDamage"] = {x=186,y=164,width=58,height=52},
        ["dizzyOne"] = {x=250,y=152,width=46,height=92},
        ["dizzyTwo"] = {x=328,y=150,width=48,height=96},
        ["down"] = {x=402,y=210,width=76,height=32},
        ["leftKi"] = {x=2,y=225,width=62,height=68},
        ["rightKi"] = {x=69,y=234,width=60,height=68},
        ["chargeKi"] = {x=254,y=254,width=46,height=66},
        ["blastKi"] = {x=328,y=254,width=58,height=68},
        ["chargeKiTwo"] = {x=136,y=232,width=48,height=80},
        ["blastKiTwo"] = {x=328,y=254,width=58,height=68},
        ["taioken"] = {x=193,y=240,width=42,height=70},
        ["chargeKiThree"] = {x=2,y=311,width=56,height=64},
        ["blastKiThree"] = {x=72,y=313,width=70,height=64},
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