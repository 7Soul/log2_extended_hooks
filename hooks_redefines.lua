function Dungeon:redefineTraits()
-------------------------------------------------------------------------------------------------------
-- Redefining vanilla classes                                                                        --
-------------------------------------------------------------------------------------------------------

	defineCharClass{
		name = "alchemist",	
		uiName = "Alchemist",
		traits = { "herb_multiplication", "firearm_expert" },
		optionalTraits = 2,
	}
	
	defineCharClass{
		name = "barbarian",
		uiName = "Barbarian",
		optionalTraits = 2,
	}
	
	defineCharClass{
		name = "battle_mage",	
		uiName = "Battle Mage",
		traits = { "hand_caster", "armor_expert", "staff_defence" },
		optionalTraits = 2,
	}
	
	defineCharClass{
		name = "farmer",
		uiName = "Farmer",
		skillPoints = 0,
		optionalTraits = 2,
	}
	
	defineCharClass{
		name = "fighter",
		uiName = "Fighter",
		traits = { "melee_specialist" },
		optionalTraits = 2,
	}
	
	defineCharClass{
		name = "knight",
		uiName = "Knight",
		traits = { "armor_expert", "shield_expert" },
		optionalTraits = 2,
	}
	
	defineCharClass{
		name = "rogue",
		uiName = "Rogue",
		traits = { "rogue_dual_wield" },
		optionalTraits = 2,
	}
	
	defineCharClass{
		name = "wizard",
		uiName = "Wizard",
		traits = { "hand_caster" },
		optionalTraits = 2,
	}

-------------------------------------------------------------------------------------------------------
-- Redefining vanilla traits                                                                         --    
-------------------------------------------------------------------------------------------------------

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
	onUseItem = function(champion, item, level)
		if level > 0 and food:getNutritionValue() then
			local food = item.go.usableitem
			-- compute exp for farmer from eating food
			local level = champion:getLevel()
			local levelFactor = 0.3 + math.pow(level, 1.1) * 0.19
			if level >= 13 then
				levelFactor = levelFactor + 1.5
			elseif level >= 11 then
				levelFactor = levelFactor + 0.5
			end
			local nutrition = food:getNutritionValue() * 0.5 + 500 * 0.5
			local exp = math.floor(nutrition * levelFactor)
			print(exp)

			champion:gainExp(exp)
		end
	end
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
		onLevelUp = function(champion, level)
			if level > 0 then
				local stats = { "strength", "dexterity", "vitality", "willpower" }
				champion:upgradeBaseStat(stats[champion:randomNumber(1) % 4 + 1], 1)
			end
		end
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
		name = "improved_alchemy",
		uiName = "Improved Alchemy",
		icon = 107,
		description = "You brew stronger healing and energy potions.",
		onBrewPotion = function(champion, potion, count, recipe, level)
			if level > 0 then
				if potion == "potion_healing" then potion = "potion_greater_healing" end
				if potion == "potion_energy"  then potion = "potion_greater_energy"  end
				return true, potion, count
			end
		end 
	}
	
	defineTrait{
		name = "bomb_expert",
		uiName = "Bomb Expert",
		icon = 108,
		description = "When you craft bombs you get three bombs instead of one.",
		onBrewPotion = function(champion, potion, count, recipe, level)
			if level > 0 then
				if string.match(potion, "_bomb$") then count = 3 end
				return true, potion, count
			end
		end 
	}

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
			if level > 0 and attackType == "ranged" and (projectile.go.ammoitem:getAmmoType() == "arrow" or projectile.go.ammoitem:getAmmoType() == "quarrel") then
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
		onComputeBuildupTime = function(champion, weapon,attack, buildup, attackType, level)
			if level > 0 then
				if weapon and attackType == "melee" then
					return 0.5
				end
			end
		end,
		onComputePowerAttackCost = function(champion, weapon, attack, cost, attackType, level)
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

end

-------------------------------------------------------------------------------------------------------
-- Redefining vanilla skills                                                                         --    
-------------------------------------------------------------------------------------------------------

function Dungeon:redefineSkills()
	defineSkill{
		name = "alchemy",
		uiName = "Alchemy",
		priority = 10,
		icon = 20,
		description = "A higher skill level in Alchemy allows you to brew a wider range of potions. To craft potions you also need herbs and a Mortar and Pestle.",
		skillTraits = { 
			[4] = "You brew stronger healing and energy potions.",
			[5] = "When you craft bombs you get three bombs instead of one."
		},
		traits = { [4] = "improved_alchemy", [5] = "bomb_expert" },
	}

	defineSkill{
		name = "athletics",
		uiName = "Athletics",
		priority = 20,
		icon = 12,
		description = "Increases your health by 20 for each skill point.",
		skillTraits = { 
			[3] = "Your carrying capacity is increased by 15 kg.",
		},
		traits = { [3] = "pack_mule" },
		onRecomputeStats = function(champion, level)
			champion:addStatModifier("max_health", level*20)
		end,
	}

	defineSkill{
		name = "concentration",
		uiName = "Concentration",
		priority = 30,
		icon = 26,
		description = "Increases your energy by 20 for each skill point.",
		skillTraits = { 
			[3] = "Your Energy regeneration rate is increased by 25% while resting.",
		},
		traits = { [3] = "meditation" },
		onRecomputeStats = function(champion, level)
			champion:addStatModifier("max_energy", level*20)
		end,
	}

	defineSkill{
		name = "light_weapons",
		uiName = "Light Weapons",
		priority = 40,
		icon = 106,
		description = "Increases damage of Light Weapons by 20% for each skill point.",
		skillTraits = { 
			[3] = "You can dual wield* Light Weapons as long one of them is a dagger.",
			[5] = "You can dual wield* any Light Weapons.",
			[6] = "When dual wielding you suffer a 40% penalty to weapon damage.",
		},
		traits = { [3] = "dual_wield", [5] = "improved_dual_wield" },
		onComputeDamageMultiplier = function(champion, weapon, attack, attackType, level)
			if level > 0 and weapon and weapon:hasTrait("light_weapon") and attackType == "melee" then
				return 1 + level * 0.2
			end
		end,
	}

	defineSkill{
		name = "heavy_weapons",
		uiName = "Heavy Weapons",
		priority = 50,
		icon = 105,
		description = "Increases damage of Heavy Weapons by 20% for each skill point.",
		skillTraits = { 
			[5] = "You can wield two-handed weapons in one hand.",
		},
		traits = { [5] = "two_handed_mastery" },
		onComputeDamageMultiplier = function(champion, weapon, attack, attackType, level)
			if level > 0 and weapon and weapon:hasTrait("heavy_weapon") and attackType == "melee" then
				return 1 + level * 0.2
			end
		end,
	}

	defineSkill{
		name = "missile_weapons",
		uiName = "Missile Weapons",
		priority = 60,
		icon = 17,
		description = "Increases damage of Missile Weapons by 20% for each skill point.",
		skillTraits = { 
			[4] = "Your Missile Weapon attacks ignore 20 points of an enemy's armor.",
		},
		traits = { [4] = "piercing_arrows" },
		onComputeDamageMultiplier = function(champion, weapon, attack, attackType, level)
			if level > 0 and weapon and weapon:hasTrait("missile_weapon") and attackType == "missile" then
				return 1 + level * 0.2
			end
		end,
	}

	defineSkill{
		name = "throwing",
		uiName = "Throwing",
		priority = 70,
		icon = 16,
		description = "Increases damage of Throwing Weapons by 20% for each skill point.",
		skillTraits = { 
			[5] = "You can throw weapons from both hands with one action.",
		},
		traits = { [5] = "double_throw" },
		onComputeDamageMultiplier = function(champion, weapon, attack, attackType, level)
			if level > 0 and weapon and weapon:hasTrait("throwing_weapon") and attackType == "throw" then
				return 1 + level * 0.2
			end
		end,
	}

	defineSkill{
		name = "firearms",
		uiName = "Firearms",
		priority = 80,
		icon = 90,
		description = "Increases range of firearm attacks by 1 square for each skill point.", -- idk why the original said it decreases malfunctioning chance, as it only the trait does that
		skillTraits = { 
			[5] = "Firearms never malfunction in your hands.",
		},
		traits = { [5] = "firearm_mastery" },
		onComputeRange = function(champion, weapon, attack, attackType, level)
			if attackType == "firearm" then
				return level
			end
		end,
	}

	defineSkill{
		name = "accuracy",
		uiName = "Accuracy",
		priority = 90,
		icon = 86,
		description = "Increases your Accuracy by 10 for each skill point.",
		skillTraits = { 
			[2] = "You can perform melee attacks from the back row.",
		},
		traits = { [2] = "reach" },
		onComputeAccuracy = function(champion, weapon, attack, attackType, level, monster)
			return level * 10
		end,
	}

	defineSkill{
		name = "critical",
		uiName = "Critical",
		priority = 100,
		icon = 10,
		description = "Improves your chance of scoring a critical hit with physical attacks by 3%.",
		skillTraits = { 
			[3] = "You can backstab an enemy with a dagger and deal triple damage.",
			[5] = "You can backstab with any Light Weapon.",
		},
		traits = { [3] = "backstab", [5] = "assassin" },
		onComputeCritChance = function(champion, weapon, attack, attackType, level, monster, accuracy)
			return level * 3
		end,
	}

	defineSkill{
		name = "armors",
		uiName = "Armor",
		priority = 110,
		icon = 7,
		description = "Increases protection of armor pieces equipped by 5% for each skill point.",
		skillTraits = { 
			[2] = "You are proficient with Light Armor and can wear it without penalties.",
			[4] = "You can wear Heavy Armor without penalties.",
		},
		traits = { [2] = "light_armor_proficiency", [4] = "heavy_armor_proficiency" },
		onComputeItemStats = function(equipmentitem, champion, slot, statName, statValue, level)
			local item = equipmentitem.go.item
			if statName == "protection" then
				return statValue + (statValue * level * 0.05)
			end
			-- if equipmentitem:getProtection() and slot ~= ItemSlot.Weapon and slot ~= ItemSlot.OffHand then
			--     champion:addStatModifier("protection", equipmentitem:getProtection() * level * 0.05)
			-- end
		end,
	}

	defineSkill{
		name = "dodge",
		uiName = "Dodge",
		priority = 120,
		icon = 9,
		description = "Increases evasion by 3 for each skill point.",
		skillTraits = { 
			[3] = "The cooldown period for all of your actions is decreased by 10%.",
		},
		onRecomputeStats = function(champion, level)
			champion:addStatModifier("evasion", level * 3)
		end,
		traits = { [3] = "uncanny_speed" },
	}

	defineSkill{
		name = "fire_magic",
		uiName = "Fire Magic",
		priority = 130,
		icon = 29,
		description = "Increases damage of fire spells by 20% for each skill point.",
		skillTraits = { 
			[5] = "You gain Resist Fire +50.",
		},
		traits = { [5] = "fire_mastery" },
		onComputeSpellDamage = function(champion, spell, name, cost, skill, level)
			if level > 0 and spell and skill == "fire_magic" then
				spell:setAttackPower(spell:getAttackPower() * (1 + 0.2 * level))
				return { true, spell }
			end
		end
	}

	defineSkill{
		name = "air_magic",
		uiName = "Air Magic",
		priority = 140,
		icon = 30,
		description = "Increases damage of air spells by 20% for each skill point.",
		skillTraits = { 
			[5] = "You gain Resist Shock +50.",
		},
		traits = { [5] = "air_mastery" },
		onComputeSpellDamage = function(champion, spell, name, cost, skill, level)
			if level > 0 and spell and skill == "air_magic" then
				spell:setAttackPower(spell:getAttackPower() * (1 + 0.2 * level))
				return { true, spell }
			end
		end
	}

	defineSkill{
		name = "earth_magic",
		uiName = "Earth Magic",
		priority = 150,
		icon = 31,
		description = "Increases damage of earth spells by 20% for each skill point.",
		skillTraits = { 
			[5] = "You gain Resist Poison +50.",
		},
		traits = { [5] = "earth_mastery" },
		onComputeSpellDamage = function(champion, spell, name, cost, skill, level)
			if level > 0 and spell and skill == "earth_magic" then
				spell:setAttackPower(spell:getAttackPower() * (1 + 0.2 * level))
				return { true, spell }
			end
		end
	}

	defineSkill{
		name = "water_magic",
		uiName = "Water Magic",
		priority = 160,
		icon = 32,
		description = "Increases damage of water spells by 20% for each skill point.",
		skillTraits = { 
			[5] = "You gain Resist Cold +50.",
		},
		traits = { [5] = "water_mastery" },
		onComputeSpellDamage = function(champion, spell, name, cost, skill, level)
			if level > 0 and spell and skill == "water_magic" then
				spell:setAttackPower(spell:getAttackPower() * (1 + 0.2 * level))
				return { true, spell }
			end
		end
	}
end

-------------------------------------------------------------------------------------------------------
-- Redefining items                                                                             --    
-------------------------------------------------------------------------------------------------------
function Dungeon:redefineItems()
	defineObject{
		name = "crystal_shard_protection",
		baseObject = "base_item",
		components = {
			{
				class = "Model",
				model = "assets/models/items/crystal_shard_protection.fbx",
			},
			{
				class = "Item",
				uiName = "Crystal Shard of Protection",
				gfxIndex = 439,
				weight = 0.3,
				stackable = true,
				gameEffect = "Protects the party against physical damage. Protection +25 for 40 seconds.",
			},
			{
				class = "Light",
				offset = vec(0, 0.02, 0),
				range = 0.5,
				color = vec(0,2.55, 0),
				brightness = 10,
				castShadow = false,
				fillLight = true,
			},
			{
				class = "UsableItem",
				sound = "heal_party",
				onUseItem = function(self, champion)
					for i=1,4 do
						local champion = party.party:getChampion(i)
						champion:setConditionValue("protective_shield", 40, 25)
					end
				end,
			},
		},
	}

	defineObject{
		name = "fire_gauntlets",
		baseObject = "base_item",
		components = {
			{
				class = "Model",
				model = "assets/models/items/fire_gauntlets.fbx",
			},
			{
				class = "Item",
				uiName = "Gauntlets of Fire",
				description = "These gauntlets will slowly burn a hole into anything that they touch. Strangely enough, their wearer is always left unharmed.",
				gfxIndex = 327,
				weight = 0.4,
				traits = { "gloves", "fire_gauntlets" },
				gameEffect = "Turns damage type of melee attacks to fire damage."
			},
			{
				class = "EquipmentItem",
				protection = 5,
				resistFire = 15,
				onPerformAddedDamage = function(self, champion, weapon, attack, attackType, damageType)
					if attackType == "melee" and damageType == "fire" then
						return attack:getAttackPower()
					end
				end,
				onComputeChampionAttackDamage = function(self, monster, champion, weapon, attack, dmg, damageType, crit, backstab)
					if (weapon and weapon.go.meleeattack) and damageType == "physical" then
						return { false, 0, heading, crit, backstab, damageType }
					end
				end,
			},
		},
	}
	
end
-------------------------------------------------------------------------------------------------------
-- Redefining conditions                                                                             --    
-------------------------------------------------------------------------------------------------------

function Dungeon:redefineConditions()

defineCondition{
	name = "protective_shield",
	uiName = "Magical Shield",
	description = "",
	icon = 19,
	beneficial = true,
	tickInterval = 1,
	frameColor = {20,100,255,255},
	onStart = function(self, champion, new, power, stacks)
		-- Default values
		if not self:getDuration() then self:setDuration(40) end
		-- if not power or power == 0 then power = 25 end
		-- Set dynamic description
		self:setDescription( string.format("Protection %+d", power or 25) )
	end,
	onStop = function(self, champion, power, stacks)
	end,
	onRecomputeStats = function(self, champion, power, stacks)
		if not power or power == 0 then power = 25 end
		champion:addStatModifier("protection", power)
	end,
	onTick = function(self, champion, power, stacks)
	end,
}

defineCondition{
	name = "fire_shield",
	uiName = "Fire Shield",
	description = "Resist Fire +35",
	icon = 12,
	beneficial = true,
	tickInterval = 1,
	frameColor = {255,100,20,255},
	onStart = function(self, champion, new, power, stacks)
	end,
	onStop = function(self, champion, power, stacks)
	end,
	onRecomputeStats = function(self, champion, power, stacks)
		champion:addStatModifier("resist_fire", power)
	end,
	onTick = function(self, champion, power, stacks)
	end,
}

defineCondition{
	name = "frost_shield",
	uiName = "Frost Shield",
	description = "Resist Cold +35",
	icon = 13,
	beneficial = true,
	tickInterval = 1,
	frameColor = {100,250,250,255},
	onStart = function(self, champion, new, power, stacks)
	end,
	onStop = function(self, champion, power, stacks)
	end,
	onRecomputeStats = function(self, champion, power, stacks)
		champion:addStatModifier("resist_cold", power)
	end,
	onTick = function(self, champion, power, stacks)
	end,
}

defineCondition{
	name = "poison_shield",
	uiName = "Poison Shield",
	description = "Resist Poison +35",
	icon = 14,
	beneficial = true,
	tickInterval = 1,
	frameColor = {20,120,20,255},
	onStart = function(self, champion, new, power, stacks)
	end,
	onStop = function(self, champion, power, stacks)
	end,
	onRecomputeStats = function(self, champion, power, stacks)
		champion:addStatModifier("resist_poison", power)
	end,
	onTick = function(self, champion, power, stacks)
	end,
}

defineCondition{
	name = "shock_shield",
	uiName = "Shock Shield",
	description = "Resist Shock +35",
	icon = 15,
	beneficial = true,
	tickInterval = 1,
	frameColor = {0,200,250,255},
	onStart = function(self, champion, new, power, stacks)
	end,
	onStop = function(self, champion, power, stacks)
	end,
	onRecomputeStats = function(self, champion, power, stacks)
		champion:addStatModifier("resist_shock", power)
	end,
	onTick = function(self, champion, power, stacks)
	end,
}

defineCondition{
	name = "wind_shield",
	uiName = "Wind Shield",
	description = "Evasion +35",
	icon = 15,
	beneficial = true,
	tickInterval = 1,
	frameColor = {50,230,230,255},
	onStart = function(self, champion, new, power, stacks)
	end,
	onStop = function(self, champion, power, stacks)
	end,
	onRecomputeStats = function(self, champion, power, stacks)
		champion:addStatModifier("evasion", power)
	end,
	onTick = function(self, champion, power, stacks)
	end,
}

defineCondition{
	name = "bear_form",
	uiName = "Bear Form",
	description = "Strength +50. Claw attacks deal devastating damage. Cannot use items in hands.",
	icon = 19,
	tickMode = "energy",
	beneficial = true,
	transformation = true,
	noAttackPanelIcon = true,
	tickInterval = 2,
	leftHandTexture = GuiItem.UnarmedAttackBearLeft,
	rightHandTexture = GuiItem.UnarmedAttackBearRight,
	onStart = function(self, champion, new, power, stacks)
		self:setDuration(math.huge) -- condition doesn't end by timer
		champion:setEnergy(champion:getMaxEnergy())
		party.party:shakeCamera(0.1, 0.5)
	end,
	onStop = function(self, champion, power, stacks)
		hudPrint(champion:getName() .. "'s bear form expires.")
		playSound("spell_expires")
	end,
	onRecomputeStats = function(self, champion, power, stacks)
		champion:addStatModifier("strength", power)
	end,
	onTick = function(self, champion, power, stacks)
	end,
}

end

-------------------------------------------------------------------------------------------------------
-- Redefining vanilla spells                                                                         --    
-------------------------------------------------------------------------------------------------------

-- We redefine vanilla spells so we can have their power and skill scaling to not be hard-coded
-- The 20% damage scaling from skills are done on the skills themselves

function Dungeon:redefineSpells()
-- utility spells

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
	
end