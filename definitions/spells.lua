defineSpell{
    name = "shield",
    uiName = "Shield",
    gesture = 456,
    manaCost = 35,
    duration = 30,
    durationScaling = 10, -- multiplies skill level
    power = 25, -- protection amount
    onCast = "shield",
    skill = "concentration",
    requirements = { "concentration", 1 },
    icon = 102,
    spellIcon = 19,
    description = "Creates a magical shield around you. The shield protects from physical damage by increasing your Protection by 25. Every point in concentration skill increases spell's duration by 10 seconds.",
}

defineSpell{
    name = "light",
    uiName = "Light",
    gesture = 25,
    manaCost = 35,
    duration = 600, 
    onCast = "light",
    skill = "concentration",
    requirements = { "concentration", 2 },
    icon = 58,
    spellIcon = 18,
    description = "Conjures a dancing ball of light that illuminates your path.",
}

defineSpell{
    name = "darkness",
    uiName = "Darkness",
    gesture = 85,
    manaCost = 25,
    duration = 300,
    onCast = "darkness",
    skill = "concentration",
    requirements = { "concentration", 2 },
    icon = 59,
    spellIcon = 11,
    description = "Negates all magical and non-magical light sources carried by your party.",
}

defineSpell{
    name = "darkbolt",
    uiName = "Darkbolt",
    gesture = 854,
    manaCost = 25,
    power = 9,
    powerScaling = 2,
    onCast = "darkbolt",
    skill = "concentration",
    requirements = { "concentration", 3 },
    icon = 100,
    spellIcon = 20,
    description = "Shoots a ray that engulfs the target in magical darkness.",
}

defineSpell{
    name = "force_field",
    uiName = "Force Field",
    gesture = 123698741,
    manaCost = 35,
    duration = 0,
    durationScaling = 5,
    onCast = "forceField",
    skill = "concentration",
    requirements = { "concentration", 2 },
    icon = 101,
    spellIcon = 5,
    description = "Creates a magical barrier that blocks all movement. Every point in Concentration increases spell's duration by 2 seconds.",
}

-- fire magic

defineSpell{ 
    name = "fireburst",
    uiName = "Fireburst",
    gesture = 1,
    manaCost = 25,
    duration = 0.4, -- used for burn chance
    power = 22,
    onCast = "fireburst",
    skill = "fire_magic",
    requirements = { "fire_magic", 1 },
    icon = 60,
    spellIcon = 1,
    description = "Conjures a blast of fire that deals fire damage to all foes directly in front of you.",
}

defineSpell{
    name = "fireball",
    uiName = "Fireball",
    gesture = 1236,
    manaCost = 43,
    power = 30,
    onCast = "fireball",
    skill = "fire_magic",
    requirements = { "fire_magic", 3, "air_magic", 1 },
    icon = 61,
    spellIcon = 7,
    description = "A flaming ball of fire shoots from your fingertips causing devastating damage to your foes.",
}

defineSpell{
    name = "meteor_storm",
    uiName = "Meteor Storm",
    gesture = 14563,
    manaCost = 80,
    power = 15,
    onCast = "meteorStorm",
    skill = "fire_magic",
    requirements = { "fire_magic", 5, "air_magic", 3 },
    icon = 99,
    spellIcon = 8,
    description = "Unleashes a devastating storm of meteors on your foes.",
}

defineSpell{
    name = "fire_shield",
    uiName = "Fire Shield",
    gesture = 52145,
    manaCost = 50,
    power = 35, -- resist amount
    duration = 50,
    onCast = "fireShield",
    skill = "fire_magic",
    requirements = { "fire_magic", 3, "concentration", 3 },
    icon = 66,
    spellIcon = 12,
    description = "Creates a magical shield reducing fire damage against the party.",
}

-- ice magic

defineSpell{
    name = "ice_shards",
    uiName = "Ice Shards",
    gesture = 789,
    manaCost = 30,
    power = 18,
    duration = 2, -- used for base range
    durationScaling = 1, -- used for range scaling
    onCast = "iceShards",
    skill = "water_magic",
    requirements = { "water_magic", 1, "earth_magic", 1 },
    icon = 70,
    spellIcon = 3,
    description = "Deathly sharp spikes of ice thrust from the ground hitting your opponents in a line. Every point in Water Magic increases the spell's range by one.",
}

defineSpell{
    name = "dispel",
    uiName = "Dispel",
    gesture = 123654789,
    manaCost = 42,
    power = 25,
    onCast = "dispel",
    skill = "water_magic",
    requirements = { "water_magic", 1, "concentration", 1 },
    icon = 72,
    spellIcon = 13,
    description = "Shoots a ray that damages elementals.",
}

defineSpell{
    name = "frostbolt",
    uiName = "Frostbolt",
    gesture = 369,
    manaCost = 37,
    power = 15,
    onCast = "frostbolt",
    skill = "water_magic",
    requirements = { "water_magic", 3, "air_magic", 1 },
    icon = 71,
    spellIcon = 4,
    description = "You hurl a bolt of icy death dealing ranged damage and freezing your opponents. Every point in Water Magic increases the probability and duration of the freezing effect.",
}

defineSpell{
    name = "frost_shield",
    uiName = "Frost Shield",
    gesture = 58965,
    manaCost = 50,
    power = 35, -- resist amount
    duration = 50,
    onCast = "frostShield",
    skill = "water_magic",
    requirements = { "water_magic", 3, "concentration", 3 },
    icon = 68,
    spellIcon = 14,
    description = "Creates a magical shield reducing cold damage against the party.",
}

-- air magic		

defineSpell{
    name = "shock",
    uiName = "Shock",
    gesture = 3,
    manaCost = 25,
    power = 22,
    onCast = "shock",
    skill = "air_magic",
    requirements = { "air_magic", 1 },
    icon = 64,
    spellIcon = 6,
    description = "Conjures a blast of electricity that deals shock damage to all foes directly in front of you.",
}

defineSpell{
    name = "invisibility",
    uiName = "Invisibility",
    gesture = 3658,
    manaCost = 45,
    duration = 40,
    onCast = "invisibility",
    skill = "air_magic",
    requirements = { "air_magic", 3, "concentration", 2 },
    icon = 74,
    spellIcon = 15,
    description = "Turns yourself and your friends invisible.",
}

defineSpell{
    name = "lightning_bolt",
    uiName = "Lightning Bolt",
    gesture = 4523,
    manaCost = 50,
    power = 30,
    onCast = "lightningBolt",
    skill = "air_magic",
    requirements = { "air_magic", 4 },	
    icon = 65,
    spellIcon = 9,
    description = "You channel the power of storms through your hands.",
}

defineSpell{
    name = "shock_shield",
    uiName = "Shock Shield",
    gesture = 52365,
    manaCost = 50,
    power = 35, -- resist amount
    duration = 50,
    onCast = "shockShield",
    skill = "air_magic",
    requirements = { "air_magic", 3, "concentration", 3 },
    icon = 69,
    spellIcon = 16,
    description = "Creates a magical shield reducing shock damage against the party.",
}

-- earth magic

defineSpell{
    name = "poison_cloud",
    uiName = "Poison Cloud",
    gesture = 7,
    manaCost = 27,
    power = 5,
    onCast = "poisonCloud",
    skill = "earth_magic",
    requirements = { "earth_magic", 1 },	
    icon = 62,
    spellIcon = 2,
    description = "Summon a toxic cloud of poison that deals damage over time.",
}

defineSpell{
    name = "poison_bolt",
    uiName = "Poison Bolt",
    gesture = 78963,
    manaCost = 32,
    power = 15,
    onCast = "poisonBolt",
    skill = "earth_magic",
    requirements = { "earth_magic", 2 },	
    icon = 63,
    spellIcon = 10,
    description = "A sizzling venomous bolt of poison shoots from your hands.",
}

defineSpell{
    name = "poison_shield",
    uiName = "Poison Shield",
    gesture = 58745,
    manaCost = 50,
    power = 35, -- resist amount
    duration = 50,
    onCast = "poisonShield",
    skill = "earth_magic",
    requirements = { "earth_magic", 3, "concentration", 3 },
    icon = 67,
    spellIcon = 17,
    description = "Creates a magical shield reducing poison damage against the party.",
}

-- hidden spells

defineSpell{
    name = "open_serpent_door",
    uiName = "Open Door",
    gesture = 0,
    manaCost = 25,
    onCast = "openDoor",
    skill = "concentration",
    requirements = { "concentration", 1 },
    icon = 59,
    spellIcon = 0,
    description = "",
    hidden = true,
}

defineSpell{
    name = "disintegrate",
    uiName = "Disintegrate",
    gesture = 0,
    manaCost = 0,
    onCast = "disintegrate",
    skill = "concentration",
    requirements = { "concentration", 5 },
    icon = 59,
    spellIcon = 0,
    description = "",
    hidden = true,
}

defineSpell{
    name = "balance",
    uiName = "Balance",
    gesture = 5,
    manaCost = 10,
    onCast = "balance",
    skill = "concentration",
    requirements = {},
    icon = 59,
    spellIcon = 0,
    description = "",
    hidden = true,
}

defineSpell{
    name = "cause_fear",
    uiName = "Cause Fear",
    gesture = 0,
    manaCost = 25,
    power = 0, -- increases chance to fear, up to 100
    onCast = "causeFear",
    skill = "concentration",
    requirements = { "concentration", 3 },
    icon = 33,
    spellIcon = 0,
    description = "",
    hidden = true,
}

defineSpell{
    name = "heal",
    uiName = "Heal",
    gesture = 0,
    manaCost = 50,
    power = 100, -- heal amount
    onCast = "heal",
    skill = "concentration",
    requirements = { "concentration", 3 },
    icon = 33,
    spellIcon = 0,
    description = "",
    hidden = true,
}