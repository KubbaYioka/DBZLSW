--declarations
local leapCoords

-- enum

KiThrowType = {
    KIFORE = "fore",
    KIOVER = "overhand",
    KIUNDER = "underhand"

}

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
        ["verticalLines"] = {3,5},
        ["horizontalLines"] = {4,5},
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
        ["stageB"] = {4,2},
        ["stageBack"] = {5,2},
        ["stageUp"] = {6,2},
        ["stageDown"] = {3,1},
        ["rapidKickOne"] = {2,1},
        ["rapidKickTwo"] = {2,2},
        ["block"] = {3,2},
        ["leap"] = {7,2},
        ["hammerUp"] = {8,2},
        ["damage"] = {2,3},
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
        ["verticalLines"] = {1,5},
        ["horizontalLines"] = {2,5},
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
            [4] = {"normalStance",1}
        },
        ["a"] = {
            [1] = {"stageA",300,function(self, animation, frameIndex, trigFunction, effectTab) self:opponentHit("a", effectTab) end},
            [2] = {"normalStance",200}
        },
        ["b"] = {
            [1] = {"stageB",300,function(self, animation, frameIndex, trigFunction, effectTab) self:opponentHit("b", effectTab) end},
            [2] = {"normalStance",200}
        },
        ["back"] = {
            [1]= {"stageBack",1000,function(self, animation, frameIndex, trigFunction, effectTab) self:opponentHit("back", effectTab) end}
        },
        ["up"] = {
            [1] = {"stageUp",1000,function(self, animation, frameIndex, trigFunction, effectTab) self:opponentHit("up", effectTab) end}
        },
        ["down"] = {
            [1] = {"leap",50},
            [2] = {"hammerUp",300},
            [3] = {"stageDown",1000,function(self, animation, frameIndex, trigFunction, effectTab) self:opponentHit("down", effectTab) end}
        },
        ["normalHit"] = {
            [1] = {"damage",200}
        },
        ["upHit"] = {
            [1] = {"damageUp",200}
        },
        ["bigHit"] = {
            [1] = {"heavyDamage",200}
        },
        ["bigHitUp"] = {
            [1] = {
                "damageUp",
                {200,120},
                function(self, animation, frameIndex, trigFunction, effectTab)
                    local destX, destY = 200, 120
                    self:comeToStop(destX, destY, 30, function()
                        if effectTab and effectTab.controller then
                            effectTab.controller:getDefenseRecovery()
                        end
                    end)
                end
            }
        },
        ["bigHitBack"] = {
            [1] = {
                "heavyDamage",
                {200, 120},
                function(self, animation, frameIndex, trigFunction, effectTab)
                    local destX, destY = 200, 120
                    self:comeToStop(destX, destY, 30, function()
                        if effectTab and effectTab.controller then
                            effectTab.controller:getDefenseRecovery()
                        end
                    end)
                end
            }
        },
        ["bigHitDown"] = {
            [1] = {
            "heavyDamage",
            {200,120},
            function(self, animation, frameIndex, trigFunction, effectTab)
                local destX, destY = 200, 120
                self:comeToStop(destX, destY, 30, function()
                    if effectTab and effectTab.controller then
                        effectTab.controller:getDefenseRecovery()
                    end
                end)
            end
        }
    },
        ["knockBack"] = {
            [1] = {
                "heavyDamage",
                function() 
                    return getKnockBack("back")
                end,
                function(self)
                    local destTab = getKnockBack("back")
                    self:knockedBack(destTab, 25, "none")
                end
            }
        },
        ["knockBackDown"] = {
            [1] = {
                "heavyDamage",
                function() 
                    return getKnockBack("down")
                end,
                function(self)
                    local destTab = getKnockBack("down")
                    self:knockedBack(destTab, 30, "none")
                end
            }
        },
        ["knockBackUp"] = {
            [1] = {
                "damageUp",
                function() 
                    return getKnockBack("up")
                end,
                function(self)
                    local destTab = getKnockBack("up")
                    self:knockedBack(destTab, 30, "none")
                end
            }
        },
        ["stgParry"] = {
            [1] = {
                "stageUp",
                500,
            },
            [2] = {
                "normalStance",
                0
            }
        },
        ["stgCounter"] = {
            [1] = {
                "stageB",
                200
            },
            [2] = {
                "normalStance",
                0
            }
        },
        ["flyForward"] = {
            [1] = {"flyForward",0,function(self) self:moveInDirection(getTrajectory(), 10) end} -- placeholder
        },
        ["flyDown"] = {
            [1] = {"flyForward",0,function(self) self:moveInDirection(getTrajectory(), 10) end} -- placeholder
        },
        ["jumpForward"] = {
            [1] = {"leap",
            function(self)
                local destX, destY = getMovement(self, "jumpOut")
                return {destX, destY}
            end,
            function(self, animation, frameIndex, trigFunction, effectTab)
                local destX, destY, arcH, speed, arcD = getMovement(self, "jumpOut")
                self:moveInArc(destX, destY, arcH, speed, arcD,function() 
                    if effectTab and effectTab.controller then
                        effectTab.controller:getNextScrn()
                    end
                 end)
            end
            }
        },
        ["jumpUp"] = {
            [1] = {"leap",
            function(self)
                local destX, destY = getMovement(self, "jumpOut")
                return {destX, destY}
            end,
            function(self, animation, frameIndex, trigFunction, effectTab)
                local destX, destY, arcH, speed, arcD = getMovement(self, "jumpOut")
                self:moveInArc(destX, destY, arcH, speed, arcD, function()
                    -- Movement completed, proceed to the next animation frame
                    self:runAnimationSequence(animation, frameIndex + 1, trigFunction, effectTab)
                end)
            end
            }
        },
        ["jumpDown"] = {
            [1] = {"leap",
            function(self)
                local destX, destY = getMovement(self, "jumpOut")
                return {destX, destY}
            end,
            function(self, animation, frameIndex, trigFunction, effectTab)
                local destX, destY, arcH, speed, arcD = getMovement(self, "jumpOut")
                self:moveInArc(destX, destY, arcH, speed, arcD, function()
                    -- Movement completed, proceed to the next animation frame
                    self:runAnimationSequence(animation, frameIndex + 1, trigFunction, effectTab)
                end)
            end
            }
        },
        ["runForward"] = {
            [1] = {"flyForward",0,function(self) self:moveInDirection(getTrajectory(), 10) end}
        },
        ["dashRunForward"] = {
            [1] = {"flyForward",0,function(self) self:moveInDirection(getTrajectory(), 10) end} -- placeholder
        },
        ["flyForwardWithStop"] = {
            [1] = {"flyForward",500,function(self) self:moveInDirection(getTrajectory(), 10, "opponent") end} -- placeholder
        },
        ["flyDownWithStop"] = {
            [1] = {"flyForward",500,function(self) self:moveInDirection(getTrajectory(), 10, "opponent") end} -- placeholder
        },
        ["jumpForwardWithStop"] = {
            [1] = {"flyForward",500,function(self) self:moveInDirection(getTrajectory(), 10, "opponent") end} -- placeholder
        },
        ["jumpUpWithStop"] = {
            [1] = {"leap",1500,function(self) self:moveInDirection(getTrajectory(), 10, "opponent") end} -- placeholder
        },
        ["runForwardWithStop"] = {
            [1] = {"flyForward",500,function(self) self:moveInDirection(getTrajectory(), 10, "opponent") end}
        },
        ["dashRunForwardWithStop"] = {
            [1] = {"flyForward",500,function(self) self:moveInDirection(getTrajectory(), 10, "opponent") end} -- placeholder
        },
        ["jumpOver"] = {
            [1] = {"leap",
            function(self)
                local destX, destY = getMovement(self, "jumpIn")
                return {destX, destY}
            end,
            function(self, animation, frameIndex, trigFunction, effectTab)
                local destX, destY, arcH, speed, arcD = getMovement(self, "jumpIn")
                self:moveInArc(destX, destY, arcH, speed, arcD, function()
                    -- Movement completed, proceed to the next animation frame
                    self:runAnimationSequence(animation, frameIndex + 1, trigFunction, effectTab)
                end)
            end
            }
        },
        ["lowGraze"] = {
            [1] = {"leap", 
                   300, -- or function that does "waitForCollision" which would trigger a teleport/shockwave before the attack reaches or blocking animation before or right as the knockback/stun hit of the attack strikes.
                   function(self,animation,frameIndex,trigFunction,effectTab)
                        effectTab:getStunOrKnockBackForAtk(function()                        
                        end)
                   end
                }
        },
        ["medGraze"] = {
            [1] = {"leap", 
                    0,
                    function(self,animation,frameIndex,trigFunction,effectTab)
                        effectTab:getStunOrKnockBackForAtk(function()
                         
                        end)
                    end
                }
        },
        ["badGraze"] = {
            [1] = {"leap",            
                    0,
                    function(self,animation,frameIndex,trigFunction,effectTab)
                        effectTab:getStunOrKnockBackForAtk(function()
                       
                        end)
                    end
                }
        },
        ["genericAvoiding"] = {
            [1] = {"verticalLines",
                    150
                }
        },
        ["endurance"] = {
            [1] = {"endurance",
                    0,
                    function(self,animation,frameIndex,trigFunction,effectTab)
                        effectTab:getStunOrKnockBackForAtk(function ()
                    
                        end)
                    end
                }
        },
        ["fivePercentDamage"]={
            [1] = {"damage",
                0,
                function(self,animation,frameIndex,trigFunction,effectTab)
                    effectTab:getStunOrKnockBackForAtk(function ()

                    end)
                end

            }
        },
        ["Ki Blast"] = {
            [1] = {
                "rightKi",
                4000,
                function(self, animation, frameIndex, trigFunction, effectTab)
                    KiProjectile:new(self, KiThrowType.KIFORE, "Ki Blast", 16, 12, effectTab)
                end
            }
        },
        ["Ki Wave"] = {
            [1] = {
                "rightKi",
                4000,
                function(self, animation, frameIndex, trigFunction, effectTab)
                    KiWave:new(self, KiThrowType.KIFORE, "Ki Wave", 16, 14, effectTab)
                end
            }
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
            [13] = {"blurForward", 50},
            [14] = {"stageB",2000}
        },
        ["Cont. Kick"] = {
            [1] = {"rapidKickOne",50},
            [2] = {"rapidKickTwo",50},
            [3] = {"rapidKickOne",50},
            [4] = {"rapidKickTwo",50},
            [5] = {"rapidKickOne",50},
            [6] = {"rapidKickTwo",50},
            [7] = {"rapidKickOne",50},
            [8] = {"rapidKickTwo",50},
            [9] = {"rapidKickOne",50},
            [10] = {"rapidKickTwo",50},
            [11] = {"normalStance", 1500},
            [12] = {"blurForward", 50},
            [13] = {"rapidKickTwo",500},
            [14] = {"leap",300},
            [15] = {"normalStance", 0}
        },

        ["normalStance"] = {
            [1] = {"normalStance",0}
        },

        ["recoveryNormal"] = {
            [1] = {
                "normalStance",
                0,
                function(self, animation, frameIndex, trigFunction, effectTab)
                    if effectTab and effectTab.controller and (not effectTab.controller.attackOver) then

                        effectTab.controller:getAtkrMoveIn()
                    else
                        print("No controller in effectTab")
                    end
                end
            }
        },
        ["block"] = {
            [1] = {
                "block",
                200,
                function(self)
                    local oX, oY = self:getPosition()
                    self:hitBounce(oX-30, oY, 10, nil)
                end
            },
            [2] = {
                "normalStance",
                0
            }
        },
        ["knockAway"] = {
            [1] = {
                "damageUp",
                function()
                    getKnockAway("up")
                end,
                function(self)
                    local destTab = getKnockAway("up")
                    self:knockedBack(destTab, 30, "none")
                end
            }
        },
        ["forwardMove"] = {
            [1] = {
                "flyForward",                  -- image/frame to display
                0,                             -- time in ms to wait before next frame
                function(self, animation, frameIndex, trigFunction, effectTab)
                    local controller = effectTab and effectTab.controller
                    self:movementExec("forward", function()
                        if controller then
                            -- e.g. if your attacker is the one moving:
                            controller:stageAttackGo()
                        end
                    end)
                end
            }
        },
        
        ["backMove"] = {
            [1] = {
                "flyBack",
                0,
                function (self, animation, frameIndex, trigFunction, effectTab)
                    local controller = effectTab and effectTab.controller
                    self:movementExec("back", function()
                        if controller then
                            controller:stageAttackGo()
                        end
                    end)
                end
            }
        }
    },
    ["dbGoku"] = {

    },
    ["dbKrillin"] = {

    }
}

kiSprite16Table = {
    ["Ki Blast"] = 1,
    ["Ki Wave Base"] = 2,
    ["Ki Wave Edge"] = 3,
    ["Ki Wave Tail"] = 4,
    ["Finger Beam Base"] = 5,
    ["Finger Beam Edge"] = 6,
    ["One Arm Charge 1"] = 7,
    ["One Arm Charge 2"] = 8,
    ["One Arm Charge 3"] = 9
}

kiSpriteSegmentSmallTable = { -- width includes borders. There are no beams with width below 3.
    [3] = 1, -- so a segment with a visible width of 3 will be at location 1 in the spritesheet
    [4] = 2,
    [5] = 3,
    [6] = 4,
    [7] = 5,
    [8] = 6,
    [9] = 7,
    [10] = 8,
    [11] = 9,
    [12] = 10,
    [13] = 11,
    [14] = 12,
    [15] = 13,
    [16] = 14

}

kiSpriteSegmentLargeTable = {
    [18] = 0,
    [20] = 1,
    [22] = 2,
    [24] = 3,
    [26] = 4,
    [28] = 5,
    [30] = 6,
    [32] = 7
}

stageAttackAni = {
    ["a"] = {"stageA",300,"none"},
    ["b"] = {"stageB",300,"none"},
    ["back"] = {"stageBack",1000,"none"},
    ["up"] = {"stageUp",1000,"none"},
    ["down"] = {"stageDown",1000,"none"}
}

animLength = {--length for animations not otherwise specified.
    
}

function getAniLength(anim)
    if anim == "jumpUp" then
        return 400
    elseif anim == "jumpDown" then
        return 300
    elseif anim == "jumpForward" then
        return 500        
    end
end

function getMovementAni()
    -- will check to see if a character can fly or not. If so, they will glide. If not, they will run\leap.
    return "leap",600,"arc" -- for now, will simply return leaping in an arc
end

function getDistance() -- gets the locations of both the attacker and defender to see how much time the attacker has to enter a cmd
    return 2000 -- for now, this number will be 2 seconds
end

function leapCoords()
    if CurrentPhase == Phase.ATTACK then
        return {150,120}
    elseif CurrentPhase == Phase.DEFENSE then
        return {200,120}
    end
end

function getMovement(attk,jumpTo)
    local arcD = 1
    local arcH = 60
    local destiX = 1
    local destiY = 1
    if jumpTo == "jumpIn" then
        if attk.lastAnim == "up" then
            arcH = 10
            if CurrentPhase == Phase.ATTACK then
                attk:moveTo(50, 300)
                destiX = 170
                destiY = 120
            elseif CurrentPhase == Phase.DEFENSE then
                attk:moveTo(350,300)
                destiX = 240
                destiY = 120
            end
        elseif attk.lastAnim == "down" then
            arcH = 20
            arcD = 1 -- controls whether the arc has a positive or negative slope
            if CurrentPhase == Phase.ATTACK then
                attk:moveTo(170, -120)
                destiX = 170
                destiY = 120
            elseif CurrentPhase == Phase.DEFENSE then
                attk:moveTo(200,-120)
                destiX = 250
                destiY = 120
            end
        elseif attk.lastAnim == "back" then
            if CurrentPhase == Phase.ATTACK then
                attk:moveTo(-150, 120)
                destiX = 170
                destiY = 120
            elseif CurrentPhase == Phase.DEFENSE then
                attk:moveTo(450,120)
                destiX = 250
                destiY = 120
            end
        end
    elseif jumpTo == "jumpOut" then
        if attk.lastAnim == "up" then
            arcH = 10
            if CurrentPhase == Phase.ATTACK then
                destiX = 200
                destiY = -200
            elseif CurrentPhase == Phase.DEFENSE then
                destiX = 200
                destiY = -200
            end
        elseif attk.lastAnim == "down" then
            arcH = 20
            arcD = 1
            if CurrentPhase == Phase.ATTACK then
                destiX = 200
                destiY = 320
            elseif CurrentPhase == Phase.DEFENSE then
                destiX = 200
                destiY = 320
            end
        elseif attk.lastAnim == "back" then
            if CurrentPhase == Phase.ATTACK then
                destiX = 500
                destiY = 120
            elseif CurrentPhase == Phase.DEFENSE then
                destiX = -150
                destiY = 120
            end
        end
    end 
    return destiX,destiY,arcH,30,arcD
end

function getTrajectory()
    if CurrentPhase == Phase.ATTACK then
        return "right"
    elseif CurrentPhase == Phase.DEFENSE then
        return "left"
    end
end

function getKnockBack(dir)
    if CurrentPhase == Phase.ATTACK then
        if dir == "back" then
            return {450,120}
        elseif dir == "down" then
            return {300,230}
        elseif dir == "up" then
            return {300,-150}
        end
    elseif CurrentPhase == Phase.DEFENSE then
        if dir == "back" then
            return {-100,120}
        elseif dir == "down" then
            return {100,230}
        elseif dir == "up" then
            return {100,-150}
        end
    end
end

function getKnockAway(dir)
    if CurrentPhase == Phase.DEFENSE then
        if dir == "back" then
            return {450,120}
        elseif dir == "down" then
            return {300,230}
        elseif dir == "up" then
            return {300,-150}
        end
    elseif CurrentPhase == Phase.ATTACK then
        if dir == "back" then
            return {-100,120}
        elseif dir == "down" then
            return {100,230}
        elseif dir == "up" then
            return {100,-150}
        end
    end
end