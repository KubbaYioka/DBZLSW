--battleEngine


playerChr={}
playerTeam={}
playerDeck={}

enemyChr={}
enemyTeam={}
enemyDeck={}

function battleInit(battleTable) -- copy values from tables and player save to create battle-only data
    if type(battleTable) ~= "table" then
        print("battle table is not in correct format")
    end
    local initPTeam = {"dbGoku"} -- will eventually pull from table RAMSAVE[5]
    local initPDeck = {1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10} -- will eventually pull from table RAMSAVE[4]
    local initChr = initPTeam[1] -- simply uses the first player in the team

    local oppTab = battleTable[oppoParam]
    local initETeam = oppTab[oppoTeam]
    local initEChr = initETeam[1]
    local initeDeck = oppTab[enemyDeck]

    for i,v in pairs(initPTeam) do
        -- make copies of all players from RAMSAVE into playerTeam
    end
end


local cardStats = {
    Type = "Attack", -- or "Defense" or "Support"
    AttackRating = 10,
    DefenseRating = 5,
    Effect = nil,
    AccuracyRating = 90
}

local positionalBonuses = {
    --["Position"] = {DefBonus, StrBonus, KiBonus}
    ["Ground Aft"] -- Bonus Def, Ki Defense, Phys Penalty
    ["Ground Fore"] -- STR Bonus, KI Defense, Phys Penalty
    ["Air Aft"] -- DEF Bonus, Ki Penalty, Phys Defense
    ["Air Fore"] -- KI Bonus, Ki Penalty, Phys Defense
}
-- Functions
local function calculateDerivedStats(character, phaseType) --pass character name and the phase they are in for appropriate stats
    if phaseType == attack then
        local calcOFF = character.STR + character.KI
        local calcEVA = character.SPD + character.DEF
        return calcOFF, calcEVA
    elseif phaseType == defense then
        local calcMAS = character.STR + character.DEF
        local calcACC = character.SPD + character.KI -- Modify as needed
        return calcMAS, calcACC 
    else
        print("error in battleEngine calculateDerivedStats")
    end
end

local function calculateEvasion(defender)
    return math.sqrt(defender.SPD + defender.DEF)
end

local function determineAttackOutcome(attacker, defender, card) --only if an attacker uses an attack card and the defender uses Guard
    local hitChance = attacker.ACCURACY - calculateEvasion(defender)
    local isCritical = false

    if hitChance > 100 then
        local critChance = math.min(hitChance - 100, 50)
        isCritical = math.random(100) <= critChance
        hitChance = 100
    end

    local doesHit = math.random(100) <= hitChance

    return doesHit, isCritical
end

local function calculateDamage(attacker, defender, isCritical)
    local damage = defender.DEF - (attacker.STR or attacker.KI) -- Depending on the type of attack
    if isCritical then
        damage = damage * 1.5 -- Assuming critical hits do 1.5x damage, adjust as needed
    end
    return damage
end

local function calculateKnockback(attacker, defender)
    local knockbackChance = (attacker.OFFENSE / defender.MASS) * 100
    -- Use the table you provided to determine the final knockback percentage
    -- Example: if knockbackChance is between 200% and 190%, set it to 100%
    return knockbackChance
end

local function applyDamage(defender, damage)
    defender.HP = defender.HP - damage
end

local function postAttackChecks(player, opponent)
    if player.HP < 1 then
        -- Check for more characters in the player's team
        -- If none, opponent wins
    end
    if opponent.HP < 1 then
        -- Check for more characters in the opponent's team
        -- If none, player wins
    end
    -- Swap roles for next phase
    player, opponent = opponent, player
end

-- Game Loop (simplified for demonstration)
while true do
    -- Initialization, Turn Sequence, End Conditions
    -- This is a placeholder; the actual game loop would be more complex and involve user input, UI updates, etc.
end