-- Class traits

defineTrait{
    name = "fighter",
    uiName = "Fighter",
    icon = 96,
    description = "As a fighter you are a master of close combat. You are trained to use a wide variety of weapons.",
    gameEffect = [[
    - Health 60 (+7 per level), Energy 30 (+3 per level)
    - Special attacks with melee weapons take half the time to build up and cost 25% less energy.]],
    onRecomputeStats = function(champion, level)
        if level > 0 then
            level = champion:getLevel()
            champion:addStatModifier("max_health", 60 + (level-1) * 7)
            champion:addStatModifier("max_energy", 30 + (level-1) * 3)
        end
    end,
}

defineTrait{
    name = "barbarian",
    uiName = "Barbarian",
    icon = 94,
    description = "As a barbarian you do not care about finesse in combat. Instead you rely on raw power and speed.",
    gameEffect = [[
    - Health 80 (+10 per level), Energy 30 (+3 per level)
    - Strength +1 per level.]],
    onRecomputeStats = function(champion, level)
        if level > 0 then
            level = champion:getLevel()
            champion:addStatModifier("strength", level)
            champion:addStatModifier("max_health", 80 + (level-1) * 10)
            champion:addStatModifier("max_energy", 30 + (level-1) * 3)
        end
    end,
}

defineTrait{
    name = "knight",
    uiName = "Knight",
    icon = 97,
    description = "As a knight you believe that good preparation is the key to triumph in combat. You are specialized in wielding armor and using the shield.",
    gameEffect = [[
    - Health 60 (+7 per level), Energy 30 (+3 per level)
    - Protection +1 per level.
    - Weight of equipped armor is reduced by 50%.
    - Evasion bonus of equipped shields is increased by 50%.]],
    onRecomputeStats = function(champion, level)
        if level > 0 then
            level = champion:getLevel()
            champion:addStatModifier("max_health", 60 + (level-1) * 7)
            champion:addStatModifier("max_energy", 30 + (level-1) * 3)
            champion:addStatModifier("protection", level)
        end
    end,
}

defineTrait{
    name = "rogue",
    uiName = "Rogue",
    icon = 95,
    description = "As a rogue you are a stealthy warrior who prefers to use ranged weapons or light melee weapons.",
    gameEffect = [[
    - Health 45 (+5 per level), Energy 40 (+5 per level)
    - When dual wielding you suffer only 25% penalty to weapon damage (normally 40%).
    - +1% chance per level to score a critical hit with missile or throwing weapons.]],
    onRecomputeStats = function(champion, level)
        if level > 0 then
            level = champion:getLevel()
            champion:addStatModifier("max_health", 45 + (level-1) * 5)
            champion:addStatModifier("max_energy", 40 + (level-1) * 5)
        end
    end,
    onComputeCritChance = function(champion, weapon, attack, attackType, level, monster, accuracy)
        if level > 0 and (attackType == "throw" or attackType == "missile") then return champion:getLevel() end
    end,
}

defineTrait{
    name = "wizard",
    uiName = "Wizard",
    icon = 33,
    description = "As a wizard you use enchanted staves and orbs to command great mystical powers that can be used to cause harm or to protect.",
    gameEffect = [[
    - Health 35 (+3 per level), Energy 50 (+7 per level)
    - Willpower +2
    - You can cast spells with bare hands.]],
    onRecomputeStats = function(champion, level)
        if level > 0 then
            level = champion:getLevel()
            champion:addStatModifier("willpower", 2)
            champion:addStatModifier("max_health", 35 + (level-1) * 3)
            champion:addStatModifier("max_energy", 50 + (level-1) * 7)
        end
    end,
}

defineTrait{
    name = "battle_mage",
    uiName = "Battle Mage",
    icon = 98,
    description = "As a battle mage you are comfortable with fighting in the front row as well as blasting with spells from the back row.",
    gameEffect = [[
    - Health 50 (+5 per level), Energy 50 (+5 per level)
    - Weight of equipped armor is reduced by 50%.
    - You can cast spells with bare hands.
    - You gain Protection +10 and Resist All +10 when equipped with a magical staff or an orb.]],
    onRecomputeStats = function(champion, level)
        if level > 0 then
            level = champion:getLevel()
            champion:addStatModifier("max_health", 50 + (level-1) * 5)
            champion:addStatModifier("max_energy", 50 + (level-1) * 5)
        end
    end,
}

defineTrait{
    name = "alchemist",
    uiName = "Alchemist",
    icon = 92,
    description = "As an alchemist you brew potions and defend yourself in combat by wielding firearms.",
    gameEffect = [[
    - Health 50 (+6 per level), Energy 50 (+4 per level)
    - Herbs in your inventory multiply. The growth rate is determined by the number of steps taken.
    - Firearms have 50% less chance to malfunction.]],
    onRecomputeStats = function(champion, level)
        if level > 0 then
            level = champion:getLevel()
            champion:addStatModifier("max_health", 50 + (level-1) * 6)
            champion:addStatModifier("max_energy", 50 + (level-1) * 4)
        end
    end,
}

defineTrait{
    name = "farmer",
    uiName = "Farmer",
    icon = 93,
    description = "As a farmer you do not command great powers and do not know how to wield a sword. Instead you are familiar with digging ditches for irrigation and the growth cycles of pitroot plants, basically everything a successful adventurer would never need.",
    gameEffect = [[
    - Health 30 (+5 per level), Energy 30 (+5 per level)
    - You receive no skillpoints at first level.
    - Instead of slaying monsters you gain experience points by eating food.]],
    onRecomputeStats = function(champion, level)
        if level > 0 then
            level = champion:getLevel()
            champion:addStatModifier("max_health", 30 + (level-1) * 5)
            champion:addStatModifier("max_energy", 30 + (level-1) * 5)
        end
    end,
}

-- Race traits

defineTrait{
	name = "human",
	uiName = "Human",
	icon = 37,
	description = "As a human you belong to the most populous sentient race in the known world. You are very adaptable and can excel in all professions.",
	gameEffect = "- You gain experience points 10% faster.",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("exp_rate", 10)
		end
	end,	
}

defineTrait{
	name = "minotaur",
	uiName = "Minotaur",
	icon = 38,
	description = "As a minotaur you are bulky, simple and quick to anger. Your incredible stubborness is tolerated by others only because of your incredible prowess in combat.",
	gameEffect = "- Strength +5, Dexterity -4, Vitality +4, Willpower -3.\n- Your food consumption rate is 25% higher than normal.",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("strength", 5)
			champion:addStatModifier("dexterity", -4)
			champion:addStatModifier("vitality", 4)
			champion:addStatModifier("willpower", -3)
			champion:addStatModifier("food_rate", 25)
		end
	end,
}

defineTrait{
	name = "lizardman",
	uiName = "Lizardman",
	icon = 40,
	description = "As a lizardman you are a social outcast and are mistrusted by other races because of your capricious and deceitful nature. What you lack in social skills you greatly make up for in stealth and dexterity.",
	gameEffect = "- Dexterity +2, Willpower -2.\n- Resist All +25%.",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("dexterity", 2)
			champion:addStatModifier("willpower", -2)
			champion:addStatModifier("resist_fire", 25)
			champion:addStatModifier("resist_cold", 25)
			champion:addStatModifier("resist_poison", 25)
			champion:addStatModifier("resist_shock", 25)
		end
	end,
}

defineTrait{
	name = "insectoid",
	uiName = "Insectoid",
	icon = 39,
	description = "As an insectoid, your thoughts are completely alien to other races. Your knowledge of the arcane is unrivaled. Insectoids come in many shapes and sizes but most often their bodies are covered with a thick shell.",
	gameEffect = "- Strength +1, Dexterity -2, Vitality -1, Willpower +2.\n- Your chance of getting body parts injured is reduced by 50%.",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("strength", 1)
			champion:addStatModifier("dexterity", -2)
			champion:addStatModifier("vitality", -1)
			champion:addStatModifier("willpower", 2)
		end
	end,
	onReceiveCondition = function(champion, cond, level)
		if level > 0 and string.match(cond, "_wound$") and math.random() <= 0.5 then
			return false
		end
	end,
}

defineTrait{
	name = "ratling",
	uiName = "Ratling",
	icon = 41,
	description = "As a ratling you may seem weak and disease ridden on the surface, but you are actually one of the most adaptable and hardy creatures in the world. You are a hoarder by nature and greatly enjoy fiddling with mechanical contraptions.",
	gameEffect = "- Strength -4, Dexterity +2.\n- Evasion +2.\n- Max Load +15kg.\n- You are immune to diseases.",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("strength", -4)
			champion:addStatModifier("dexterity", 2)
			champion:addStatModifier("evasion", 2)
			champion:addStatModifier("max_load", level * 15)
		end
	end,
	onReceiveCondition = function(champion, cond, level)
		if level > 0 and cond == "diseased" then
			return false
		end
	end,
}

-- Race-specific traits

defineTrait{
	name = "skilled",
	uiName = "Skilled",
	icon = 42,
	charGen = true,
	requiredRace = "human",
	description = "You gain 1 extra skill point at first level. It may only be used to raise a skill from level 0 to level 1.",
	-- hardcoded
}

defineTrait{
	name = "fast_learner",
	uiName = "Fast Learner",
	icon = 43,
	charGen = true,
	requiredRace = "human",
	description = "You gain experience points 10% faster. This bonus is in addition to the experience bonus granted by your race.",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("exp_rate", 10)
		end
	end,
}

defineTrait{
	name = "head_hunter",
	uiName = "Head Hunter",
	icon = 45,
	charGen = true,
	requiredRace = "minotaur",
	description = "Strength +1 for each skull carried.",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			-- count skulls
			local skulls = 0
			for i=1,ItemSlot.MaxSlots do
				local item = champion:getItem(i)
				if item then
					if item:hasTrait("skull") then
						skulls = skulls + 1
					else
						local container = item.go.containeritem
						if container then
							local capacity = container:getCapacity()
							for j=1,capacity do
								local item2 = container:getItem(j)
								if item2 and item2:hasTrait("skull") then
									skulls = skulls + 1
								end
							end
						end
					end
				end
			end
			champion:addStatModifier("strength", skulls)
		end
	end,
}

defineTrait{
	name = "rage",
	uiName = "Rage",
	icon = 46,
	charGen = true,
	requiredRace = "minotaur",
	description = "Your strength is temporarily increased by 10 when you have less than 20% health remaining.",
}

defineTrait{
	name = "fast_metabolism",
	uiName = "Fast Metabolism",
	icon = 54,
	charGen = true,
	requiredRace = "lizardman",
	description = "Your Health and Energy regenerates 30% faster while your food consumption rate increases by 20%. Additionally, healing potions are twice as effective for you.",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("food_rate", 20)
			champion:addStatModifier("health_regeneration_rate", 30)
			champion:addStatModifier("energy_regeneration_rate", 30)
		end
	end,
}

defineTrait{
	name = "endure_elements",
	uiName = "Endure Elements",
	icon = 55,
	charGen = true,
	requiredRace = "lizardman",
	description = "Years spent living in the wilderness have made you resistant to the forces of nature. Resist All +25%",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("resist_fire", 25)
			champion:addStatModifier("resist_cold", 25)
			champion:addStatModifier("resist_shock", 25)
			champion:addStatModifier("resist_poison", 25)
		end
	end,
}

defineTrait{
	name = "poison_immunity",
	uiName = "Poison Immunity",
	icon = 56,
	charGen = true,
	requiredRace = "lizardman",
	description = "You are immune to poison.",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("resist_poison", 100)
		end
	end,
}

defineTrait{
	name = "chitin_armor",
	uiName = "Chitin Armor",
	icon = 51,
	charGen = true,
	requiredRace = "insectoid",
	description = "Your body is covered by a thick chitin shell. You gain Protection +10.",
	onRecomputeStats = function(champion, level)
		if level > 0 then champion:addStatModifier("protection", 10) end
	end,
}

defineTrait{
	name = "quick",
	uiName = "Quick",
	icon = 52,
	charGen = true,
	requiredRace = "insectoid",
	description = "The cooldown period for all actions you perform is decreased by 10%.",
	onComputeCooldown = function(champion, weapon, attack, attackType, level)
		if level > 0 then return 0.9 end
	end,
}

defineTrait{
	name = "mutation",
	uiName = "Mutation",
	icon = 48,
	charGen = true,
	requiredRace = "ratling",
	description = "One of your attribute scores, chosen randomly, increases by 1 when you gain a new level.",
}

-- Generic traits

defineTrait{
	name = "athletic",
	uiName = "Muscular",
	icon = 12,
	charGen = true,
	description = "Your body is muscular. Strength +2",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("strength", 2)
		end
	end,
}

defineTrait{
	name = "agile",
	uiName = "Agile",
	icon = 81,
	charGen = true,
	description = "Your reflexes are exceptional. Dexterity +2",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("dexterity", 2)
		end
	end,
}

defineTrait{
	name = "healthy",
	uiName = "Healthy",
	icon = 77,
	charGen = true,
	description = "You are exceptionally healthy. Vitality +2",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("vitality", 2)
		end
	end,
}

defineTrait{
	name = "strong_mind",
	uiName = "Strong Mind",
	icon = 80,
	charGen = true,
	description = "Your mind is as sharp as a needle. Willpower +2",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("willpower", 2)
		end
	end,
}
	
defineTrait{
	name = "tough",
	uiName = "Tough",
	icon = 91,
	charGen = true,
	description = "You are resistant to physical punishment. Health +20",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("max_health", 20)
		end
	end,
}

defineTrait{
	name = "aura",
	uiName = "Aura",
	icon = 82,
	charGen = true,
	description = "You have a potent aura. Energy +20",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("max_energy", 20)
		end
	end,
}

defineTrait{
	name = "aggressive",
	uiName = "Aggressive",
	icon = 75,
	charGen = true,
	description = "You are full of rage. Damage +4",
	onComputeDamageModifier = function(champion, weapon, attack, attackType, level)
		if level > 0 then 
			return 4
		end
	end,
}

defineTrait{
	name = "evasive",
	uiName = "Evasive",
	icon = 9,
	charGen = true,
	description = "You know how best to stay away from harm. Evasion +5",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("evasion", 5)
		end
	end,
}

defineTrait{
	name = "fire_resistant",
	uiName = "Daemon Ancestor",
	icon = 76,
	charGen = true,
	description = "Your Great Grandfather had fiery eyes. Resist Fire +25",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("resist_fire", 25)
		end
	end,
}

defineTrait{
	name = "cold_resistant",
	uiName = "Cold-blooded",
	icon = 83,
	charGen = true,
	description = "You are naturally resistant to cold. Resist Cold +25",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("resist_cold", 25)
		end
	end,
}

defineTrait{
	name = "poison_resistant",
	uiName = "Poison Resistant",
	icon = 79,
	charGen = true,
	description = "You are naturally resistant to poisons. Resist Poison +25",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("resist_poison", 25)
		end
	end,
}

defineTrait{
	name = "natural_armor",
	uiName = "Natural Armor",
	icon = 78,
	charGen = true,
	description = "Your skin is very thick and armor-like. Protection +5",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("protection", 5)
		end
	end,
}

defineTrait{
	name = "endurance",
	uiName = "Endurance",
	icon = 11,
	charGen = true,
	description = "Max carrying capacity is increased by 25 kg and food consumption rate is decreased by 25%.",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("max_load", 25)
			champion:addStatModifier("food_rate", -25)
		end
	end,
}

defineTrait{
	name = "weapon_specialization",
	uiName = "Martial Training",
	icon = 0,
	charGen = true,
	description = "You are trained to use a wide variety of melee weapons. Melee attacks gain Accuracy +7.",
	onComputeAccuracy = function(champion, weapon, attack, attackType, level)
		if level > 0 and attackType == "melee" then return 7 end
	end,
}

-- Skill traits

defineTrait{
	name = "pack_mule",
	uiName = "Pack Mule",
	icon = 109,
	description = "Your max carrying capacity is increased by 15 kg.",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("max_load", 15)
		end
	end,
}

defineTrait{
	name = "meditation",
	uiName = "Meditation",
	icon = 110,
	description = "Your Energy regeneration rate is increased by 25% while resting.",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			if party.party:isResting() then
				champion:addStatModifier("energy_regeneration_rate", 25)
			end
		end
	end,
}

defineTrait{
	name = "two_handed_mastery",
	uiName = "Ogre's Grip",
	icon = 6,
	description = "You can wield two-handed weapons in one hand.",
	-- hardcoded trait
}

defineTrait{
	name = "light_armor_proficiency",
	uiName = "Light Armors",
	icon = 57,
	description = "You can wear Light Armor without penalties.",
	-- hardcoded trait
}

defineTrait{
	name = "heavy_armor_proficiency",
	uiName = "Heavy Armors",
	icon = 7,
	description = "You can wear Heavy Armor without penalties.",
	-- hardcoded trait
}

defineTrait{
	name = "armor_expert",
	uiName = "Armor Expert",
	icon = 7,
	description = "Weight of equipped armor is reduced by 50%.",
	onComputeItemWeight = function(champion, equipped, level)
		if level > 0 and equipped then
			return 1 - 0.5
		end
	end
}

defineTrait{
	name = "shield_expert",
	uiName = "Shield Expert",
	icon = 8,
	description = "Increases evasion bonus of equipped shields by 50%.",
	onComputeItemWeight = function(champion, equipped, level)
		if level > 0 and equipped then
			return 0.5
		end
	end
}

defineTrait{
	name = "staff_defence",
	uiName = "Staff Defence",
	icon = 34,
	description = "You gain Protection +10 and Resist All +10 when equipped with a staff or an orb.",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			local item1 = champion:getItem(ItemSlot.Weapon)
			local item2 = champion:getItem(ItemSlot.OffHand)
			if (item1 and item1.go.runepanel) or (item2 and item2.go.runepanel) then
				champion:addStatModifier("protection", 10)
				champion:addStatModifier("resist_fire", 10)
				champion:addStatModifier("resist_cold", 10)
				champion:addStatModifier("resist_shock", 10)
				champion:addStatModifier("resist_poison", 10)
			end
		end
	end,
}



defineTrait{
	name = "backstab",
	uiName = "Backstab",
	icon = 103,
	description = "You do triple damage when you successfully backstab an enemy with a dagger.",
	onCheckBackstab = function(monster, champion, weapon, attack, dmg, dmgType, crit, level)
		if level > 0 and weapon and weapon:hasTrait("dagger") then
			return 3
		end
	end	
}

defineTrait{
	name = "assassin",
	uiName = "Assassin",
	icon = 104,
	description = "You can backstab with any Light Weapon.",
	onCheckBackstab = function(monster, champion, weapon, attack, dmg, dmgType, crit, level)
		if level > 0 and weapon and weapon:hasTrait("light_weapon") then
			if weapon and weapon:hasTrait("dagger") then
				return 0 -- backstab is already 3 so we don't add both together
			else
				return 3 -- light weapon, not dagger
			end
		end
	end
}

defineTrait{
	name = "firearm_mastery",
	uiName = "Firearm Mastery",
	icon = 85,
	description = "Firearms never malfunction in your hands.",
	onComputeMalfunctionChance = function(champion, weapon, attack, attackType, level)
		if attackType == "firearm" then
			return 0
		end
	end,
}

defineTrait{
	name = "dual_wield",
	uiName = "Dual Wielding",
	icon = 19,
	description = "You can attack separately with Light Weapons in either hand. One of the weapons must be a dagger. Both weapons suffer a 40% penalty to the items' base damage when dual wielding.",
	onCheckDualWielding = function(champion, weapon1, weapon2, level)
		if level > 0 and weapon1 and weapon2 and weapon1:hasTrait("light_weapon") and weapon2:hasTrait("light_weapon") then
			if weapon1:hasTrait("dagger") or weapon2:hasTrait("dagger") then
				return true
			end
		end
	end
}

defineTrait{
	name = "improved_dual_wield",
	uiName = "Dual Wield Mastery",
	icon = 107,
	description = "You can dual wield any two Light Weapons. Both weapons still suffer a 40% penalty to the items' base damage when dual wielding.",
	onCheckDualWielding = function(champion, weapon1, weapon2, level)
		if level > 0 and weapon1 and weapon2 and weapon1:hasTrait("light_weapon") and weapon2:hasTrait("light_weapon") then
			return true
		end
	end
}

defineTrait{
	name = "piercing_arrows",
	uiName = "Piercing Arrows",
	icon = 23,
	description = "Your Missile Weapon attacks ignore 20 points of enemy's armor.",
	onComputePierce = function(monster, champion, weapon, attack, projectile, dmg, dmgType, attackType, crit, backstab, level)
		if level > 0 and (projectile.go.ammoitem:getAmmoType() == "arrow" or projectile.go.ammoitem:getAmmoType() == "quarrel") then
			return 20
		end
	end
}

defineTrait{
	name = "double_throw",
	uiName = "Double Throw",
	icon = 21,
	description = "You can throw weapons from both hands with one action.",
	-- hardcoded skill
}

defineTrait{
	name = "reach",
	uiName = "Reach",
	icon = 27,
	description = "You can perform melee attacks from the back row.",
	-- hardcoded skill
}

defineTrait{
	name = "uncanny_speed",
	uiName = "Uncanny Speed",
	icon = 108,
	description = "Cooldowns of all your actions are sped up by 10%.",
	onComputeCooldown = function(champion, weapon, attack, attackType, level)
		if level > 0 then return 0.9 end
	end,
}

defineTrait{
	name = "fire_mastery",
	uiName = "Fire Mastery",
	icon = 29,
	description = "You gain Resist Fire +50.",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("resist_fire", 50)
		end
	end,
}

defineTrait{
	name = "air_mastery",
	uiName = "Air Mastery",
	icon = 30,
	description = "You gain Resist Shock +50.",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("resist_shock", 50)
		end
	end,
}

defineTrait{
	name = "earth_mastery",
	uiName = "Earth Mastery",
	icon = 31,
	description = "You gain Resist Poison +50.",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("resist_poison", 50)
		end
	end,
}

defineTrait{
	name = "water_mastery",
	uiName = "Water Mastery",
	icon = 32,
	description = "You gain Resist Cold +50.",
	onRecomputeStats = function(champion, level)
		if level > 0 then
			champion:addStatModifier("resist_cold", 50)
		end
	end,
}

defineTrait{
	name = "rogue_dual_wield",
	uiName = "Rogue Dual Wield",
	icon = 95,
	description = "When dual wielding you suffer only 25% penalty to weapon damage (normally 40%).",
	onComputeDualWieldingModifier = function(champion, weapon, attack, attackType, level)
		if level > 0 then
			return 0.15
		end
	end,
}

defineTrait{
	name = "melee_specialist",
	uiName = "Melee Specialist",
	icon = 96,
	description = "Special attacks with melee weapons take half the time to build up and cost 25% less energy.",
	onComputeBuildupTime = function(champion, weapon, buildup, attackType, level)
		if level > 0 then
			if weapon and attackType == "melee" then
				return 0.5
			end
		end
	end,
	onComputePowerAttackCost = function(champion, weapon, cost, attackType, level)
		if level > 0 then
			if weapon and attackType == "melee" then
				return 0.75
			end
		end
	end,
}


defineTrait{
	name = "firearm_expert",
	uiName = "Firearms Expert",
	icon = 92,
	description = "Firearms have 50% less chance to malfunction.",
	onComputeMalfunctionChance = function(champion, weapon, attack, attackType, level)
		if attackType == "firearm" then
			return 0.5
		end
	end,
}

defineTrait{
	name = "herb_multiplication",
	uiName = "Herb Multiplication",
	icon = 0,
	hidden = true,
	description = "Enables herb multiplication",
}

-- Tome traits

defineTrait{
	name = "leadership",
	uiName = "Party Leader",
	icon = 13,
	description = "Other party members gain +1 bonus to all attributes as long as you are alive.",
	onRecomputeStats = function(champion, level)
		level = champion:getLevel()
		local leadership = 0
		for i=1,4 do
			local champ = party.party:getChampionByOrdinal(i)
			if champ:hasTrait("leadership") then
				leadership = 1
				break
			end
		end
		if leadership ~= 0 then
			champion:addStatModifier("strength", leadership)
			champion:addStatModifier("willpower", leadership)
			champion:addStatModifier("dexterity", leadership)
			champion:addStatModifier("vitality", leadership)
		end
	end,
}

defineTrait{
	name = "nightstalker",
	uiName = "Nightstalker",
	icon = 0,
	description = "",
	hidden = true,
	onRecomputeStats = function(champion, level)
		if level > 0 then
			local bonus = GameMode.getTimeOfDay() >= 1 and 5 or -5
			champion:addStatModifier("vitality", bonus)
		end
	end,
}