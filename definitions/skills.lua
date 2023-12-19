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
		[9] = "When dual wielding you suffer a 40% penalty to weapon damage.",
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
		if equipmentitem:getProtection() and slot ~= ItemSlot.Weapon and slot ~= ItemSlot.OffHand then
			champion:addStatModifier("protection", equipmentitem:getProtection() * level * 0.05)
		end
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
	end,
	
	onComputeDamageMultiplier = function(champion, weapon, attack, attackType, level)
		if level > 0 and attack:getDamageType() == "fire" then
			dmg = dmg * (1 + (level * 0.2))
			return { true, dmg, heading, crit, backstab, damageType }
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