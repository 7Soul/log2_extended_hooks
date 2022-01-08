Install Instructions

1 - First you have to be on the new beta branch. On steam, right click the game > Properties > Betas. Add the code "ggllooeegggg" to unlock the secret "nutcracker" beta

2 - Go to "\Documents\Almost Human\legend of grimrock 2". Once the beta is downloaded, you'll see a file named "mods.cfg" and a "Mods" folder

3 - Extract the "hooks" folder into the Mods folder, so it looks like /Mods/hooks

4 - Add the mod to mods.cfg so it looks like this:

mods = {
	"hooks/hooks_def.lua",
	"hooks/hooks_gui.lua",
	"hooks/hooks_redefines.lua",
	"hooks/hooks_1.lua",
}


Reference List version 0.3.8b

 -- New weapon stats

 	minDamageMod - adds to the minimum damage of the weapon. The min damage doesn't go over the max damage -1
 	maxDamageMod - adds to the maximum damage of the weapon. The max damage doesn't go under the min damage +1
 	attackPowerVariation - by default is 0.5, making all attacks have a variation of -0.5x to +0.5x the attackPower. This number overrides this value
 	critMultiplier - adds to your current critical multiplier, which is 2.5 (works on all weapon types)
 	jamChance - any weapon can jam if they contain this value
 	jamText - used to replace the "Jammed!" text if you want
 	velocity - mutlipliers the base velocity for projectiles. Works with missile weapons and throw weapons


 -- New equipmentItem stats

critChance, critMultiplier, minDamageMod, maxDamageMod - same as above
dualWielding - adds to the base dual wielding damage multiplier, which by default is 0.6. Adding 0.4 makes so there's no penalty


 -- Condition functions

Conditions now support stacks and a "power" value
champion:setConditionValue(name, value, power, stacks)
	power (optional) - stores a "power" value in the condition. Shield conditions have been updated to use this value
	stacks (optional) - if true, adds 1 stack to the condition
condition:getName() - returns name of condition
condition:getStacks() - returns current stack count of condition
	
These condition functions now have the "power" and "stacks" parameters:
	onRecomputeStats = function(self, champion, power, stacks)
	onStop = function(self, champion, power, stacks)
	onTick = function(self, champion, power, stacks)
	
Same as above, and also has the "new" boolean. If true it's a new condition, if false the champion already had it:
	onStart = function(self, champion, new, power, stacks)
	
The default conditions were rewritten to allow customization. Ex: You can call champion:setConditionValue("fire_shield", 120, 100) to use a Fire Shield that lasts 120 seconds and raises resistance by 100

 -- Condition definition

maxStacks - maximum number of stacks
stackTimer - timer it takes for each stack to count down after the initial timer has run
healthBarColor = {r,g,b,a} - colors the health bar
energyBarColor = {r,g,b,a} - colors the energy bar
frameColor = {r,g,b,a} - creates a frame around the champion, like with shields
tickMode = "energy" "health" - makes the condition drain the champion's energy or health. The tickInterval dictates amount per deltaTime
leftHandTexture, rightHandTexture = replaces hand graphic. Can use a GuiItem object or a texture
noAttackPanelIcon = makes items unusable in hand (eg: bear form)


 -- Potion crafting
The first 6 items with the "herb" trait are now used in crafting. The order that they appear and their recipe index is defined by the order of their gfxIndex
Bug fix: allows potions to have custom icons

 -- Party hooks

onCalculateDamageWithAttack = function(self, champion, weapon, attack, power)
	Runs at the start of damage calculation, the return value will replace the power of the attack
	return power
onBrewPotion = function(self, potion, champion)
	Runs before potion/bomb item is spawned
	Can be used to cancel potion making, alter the count or the item you get from crafting
	"potion" is the name of the potion
	Return { true, count, potion }
onMultiplyHerbs = function(self, herbRates, champion)
	Called after every step for a champion that has the "herb_multiplication" trait. Can be used to cancel herb multiplication or alter a particular herb rate
	"herbRates" is a table containing each herb name as a key and the number of steps taken as a value
	return { true, herbRates }
onLoadDefaultParty(self, defaultParty)
	Can be used to override the default party table
	return defaultParty

 -- Champion hooks and functions

setData(name, value)
addData(name, value)
getData(name)
	Stores values in a table
setCooldown(index, value)
getCooldown(index)
	Directly change a champion's current cooldown
getConditionStacks(name)
	Returns the stack count of a condition
giveItem(itemComponent)
	Inserts an item into the first available slot of the champion's backpack
addStatFinal(name, value)
	Works like addStatModifier but runs after all other addStatModifier instances
	
 -- New champion stats
 
critical_chance: changes the base critical chance (default: 5)
critical_multiplier: changes the base critical attack damage (default: 250)
dual_wielding: changes the base dual wielding multiplier (default: 60)
resist_fire_max: alters the maximum resistance (default: 100)
resist_cold_max: alters the maximum resistance (default: 100)
resist_shock_max: alters the maximum resistance (default: 100)
resist_poison_max: alters the maximum resistance (default: 100)
 

 -- Monster hooks and functions

setData(name, value)
addData(name, value)
getData(name)
	Stores values in a table
getAIState
	Existed for MonsterGroupComponent but not for MonsterComponent
	
	
 -- Item hooks and functions

setData(name, value)
addData(name, value)
getData(name)
	Stores values in a table
getAIState
	Existed for MonsterGroupComponent but not for MonsterComponent

 -- Trait/Skill Hooks
	
onRecomputeStats = function(champion, level)
onComputeAccuracy = function(champion, weapon, attack, attackType, level, monster)
onComputeCritChance = function(champion, weapon, attack, attackType, level, monster, accuracy)
onReceiveCondition = function(champion, cond, level)

For all of these: 
weapon = the itemComponent of the weapon. It's nil when unarmed
attack = the attackComponent

onComputeCritMultiplier = function(champion, weapon, attack, attackType, monster, level)
	Adds to the base multiplier
	return number
onComputeDamageModifier = function(champion, weapon, attack, attackType, level) 
	Modifies damage (shows in stats window)
	return number
	or 
	return { min, max }
onComputeDamageMultiplier = function(champion, weapon, attack, attackType, level)
	Multiplies damage (shows in stats window)
	return number
onComputeDamageTaken = function(champion, attack, attacker, attackerType, dmg, dmgType, isSpell, level)
	Modifies damage a champion takes
	return dmg
onComputeChampionAttackDamage = function(monster, champion, weapon, attack, dmg, damageType, crit, backstab, level)
	Can modify attack results
	return { true, dmg, heading, crit, backstab, damageType }
onComputeChampionSpellDamage = function(monster, champion, spell, dmg, damageType, level) 
	Computed the moment the spell hits the monster. Can modify the damage, the heading or cancel the hit altogether
	return { true, dmg, heading }
onComputeSpellDamage = function(champion, spell, name, cost, skill, level)
	Computed the moment the spell is cast
	'spell' is the damage component of the spell (tiledamager, projectile or cloudspell)
	return { boolean, spell }
onComputeSpellCritChance = function(champion, damageType, monster, level)
	return number
onComputeSpellCost = function(champion, name, cost, skill, level)
	Returns a multiplier to the cost of a spell when casting
	return number
onComputeSpellCooldown = function(champion, name, cost, skill, level)
	Returns a multiplier to the spell cooldown when casting
	return number
onCheckDualWielding = function(champion, weapon1, weapon2, level)
	Returns true for when weapon1 + weapon2 is a valid dual wield option
	return boolean
onComputeDualWieldingModifier = function(champion, weapon, attack, attackType, level)
	Adds to dual wielding multiplier. By default its 0.6, so returing 0.4 means dual wield damage is multiplied by 1 (shows in stats window)
	return number
onCheckBackstab = function(monster, champion, weapon, attack, dmg, dmgType, crit, level)
	Melee/Firearm only
	Adds a value to the backstab multiplier. If the final multiplier is 0, it's not a backstab
	return number
onComputePierce = function(monster, champion, weapon, attack, projectile, dmg, dmgType, attackType, crit, backstab, level)
	Adds a value to your pierce amount. Works with all attack types
	return number
onComputeItemWeight = function(champion, equipped, level)
	Multiplies weight of item during champion:getLoad()
	Returns multiplier
onComputeToHit = function(monster, champion, weapon, attack, attackType, damageType, toHit, level)
	Overrites hit chance, able to go over the min/max of 5/95
	return toHit
onComputeHerbMultiplicationRate = function(champion)
	Returns a table that multiplies the rate of each herb, the higher the value the longer it takes for them to multiply
	return { 1, 1, 1, 1, 1, 1 }
onComputeConditionDuration = function(condition, champion, name, beneficial, harmful, transformation, level)
	Multiplier to condition's tickInterval
	return number
onComputeBombPower = function(bombitem, champion, power, level)
	Modifies power of bomb being thrown
	return power
onComputeMalfunctionChance = function(champion, weapon, attack, attackType, level)
	Multiplies weapon malfunction chance
	return number
onComputeRange = function(champion, weapon, attack, attackType, level)
	Adds to weapon range
	return number
onHitTrigger = function(champion, weapon, attack, attackType, dmg, crit, backstab, monster, level)
	Called just before a monster takes damage
	Doesn't return any values
onKillTrigger = function(champion, weapon, attack, attackType, dmg, crit, backstab, monster, level)
	Called when from monster:damage() when the monster is about to die
	If it returns false, the monster will survive at 1 hp
	return boolean
onComputeBuildupTime = function(champion, weapon, attack, buildup, attackType, level)
	Multiplies power attack buildup
	Return number
onComputePowerAttackCost = function(champion, weapon, attack, cost, attackType, level)
	Multiplies power attack energy cost
	Return number
onCheckWound = function(champion, wound, action, actionName, actionType, level)
	Overrides a wound that would prevent an action (eg a hand wound preventing an attack or head wound preventing casting)
	action - attack component. In the case of a spell, it's "spell"
	actionName - name of attack or name of spell
	actionType - type of attack or skill of spell
	Return true to ignore wound
onRegainHealth(champion, isItem, amount, level)
	Can be used to multiply all health gains, such as regeneration and healing from potions
	return number
onRegainEnergy(champion, isItem, amount, level)
	Can be used to multiply all health gains, such as regeneration and healing from potions
	return number
	

	
 -- EquipmentItem hooks
	
onRecomputeStats(self, champion)
onComputeAccuracy(self, champion, weapon, attack, attackType, monster)
onComputeCritChance(self, champion, weapon, attack, monster, attackType)

onComputeCritMultiplier = function(self, champion, weapon, attack, attackType, monster)
onCheckDualWielding(self, champion, weapon1, weapon2)
onComputeDamageModifier = function(self, champion, weapon, attack, attackType)
	Modifies damage (shows in stats window)
	return number
	or 
	return { min, max }
onComputeBackstabMultiplier = function(self, champion, weapon, attack)
	Melee/Firearm only
	Adds a value to the backstab multiplier. If the final multiplier is 0, it's not a backstab
	return number
onComputeChampionAttackDamage = function(self, monster, champion, weapon, attack, dmg, damageType, crit, backstab)
	Can modify attack retults
	return { true, dmg, heading, crit, backstab, damageType }
onComputePierce = function(self, monster, champion, weapon, attack, projectile, dmg, dmgType, attackType, crit, backstab)
	Adds a value to your pierce amount. Works with all attack types
	return number
onComputeSpellCost = function(self, champion, name, cost, skill)
	Returns a multiplier to the cost of a spell when casting
	return number
onComputeSpellCooldown = function(self, champion, name, cost, skill)
	Returns a multiplier to the spell cooldown when casting
	return number
onComputeItemStats = function(self, equipmentitem, champion, slot, level)
	Runs during EquipmentItem stat calculation, before onRecomputeStats
onComputeSpellDamage = function(self, champion, spell, name, cost, skill)
	spell is the damage component of the spell (tiledamager, projectile or cloudspell)
	return { boolean, spell }
onComputeConditionDuration = function(self, condition, champion, name, beneficial, harmful, transformation, level)
	Multiplier to condition duration
	return number
onComputeBombPower = function(self, bombitem, champion, power)
	modifies power of bomb being thrown
	return power
onComputeDamageTaken = function(self, champion, attack, attacker, attackerType, dmg, dmgType, isSpell, level)
	modifies damage a champion takes
	return dmg
onComputeMalfunctionChance = function(self, champion, weapon, attack, attackType)
	Multiplies weapon malfunction chance
	return number
onComputeRange = function(self, champion, weapon, attack, attackType)
	Adds to weapon range
	return number
onHitTrigger = function(self, champion, weapon, attack, attackType, dmg, crit, backstab, monster)
	Called just before a monster takes damage
	Doesn't return any values
onComputeBuildupTime = function(self, champion, weapon, attack, buildup, attackType)
	Multiplies power attack buildup
	Return number
onComputePowerAttackCost = function(self, champion, weapon, attack, cost, attackType)
	Multiplies power attack energy cost
	Return number
onCheckWound = function(self, champion, wound, action, actionName, actionType)
	Overrides a wound that would prevent an action (eg a hand wound preventing an attack or head wound preventing casting)
	action - attack component. In the case of a spell, it's "spell"
	actionName - name of attack or name of spell
	actionType - type of attack or skill of spell
	Return true to ignore wound
onComputeSpellCritChance = function(self, champion, damageType, monster)
	return number
onComputeItemWeight = function(self, champion, equipped)
	Multiplies weight of item during champion:getLoad()
	Returns multiplier

