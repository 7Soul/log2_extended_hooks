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
	"hooks/hooks_components.lua",
	"hooks/BombItem.lua",
	"hooks/CastSpell.lua",
	"hooks/ContainerItem.lua",
	"hooks/CraftPotion.lua",
	"hooks/Map.lua",
	"hooks/SurfaceSocket.lua",
}


			============== 0.3.20 Changelog ==============

- Fixed crash related to the triggerSpell hook
- Fixed a compatibility issue with Party:onDamage and Party:onSpellDamage hooks

			============== 0.3.19 Changelog ==============

- Fixed a bug with traits that modify for bomb damage
- When the game checks for invisibility, it'll now take into consideration if only some champions are invisible. Each invisible champion contributes 1/4 of the invisibility check
- Added onDeathTrigger hook
	EquipmentItem: onDeathTrigger(self, deadChampion, champion, attacker, attackerType)
	Skill/Trait: onDeathTrigger(deadChampion, champion, attacker, attackerType, level)


			============== 0.3.18 Changelog ==============
			
- Added setPierce/getPierce for equipmentItem
- Added Champion:launchProjectile(attack, slot, ammo)
- Changed ContainerItem slots drawing function to only use the "slots" property

			============== 0.3.17 Changelog ==============
			
- Fixed a bug where modded items with "onComputePierce" were being used for calculating accuracy
- Added scrollItem tags:
	- Put "<page>" in the text box to create pages
		- Right-clicking a note moves on to the next page
	- <pic> Draws a picture from the "mod_assets/textures/gui/" folder onto the page (ex: <pic>image.dds)
		- <picx> and <picy> Adds spacing to the picture (ex: <picx>10)
		- <picCenter> Centers the image horizontally
		- <picInline> Draws image in the same space as the text, instead of after it
	- <textOffset> Alters the horizontal offset for drawing text. Can be used multiple times, altering the subsequent text lines

			============== 0.3.16 Changelog ==============
			
- Fixed bug with enemies hitting each other with projectiles
- Fixed missing Dual Wielding bonus calculations

			============== 0.3.15 Changelog ==============
			
- Added a "requirements" property for the "equipmentItem" component. The item can be equipped if the requirements aren't met but the stats won't count

			============== 0.3.14 Changelog ==============

- The parameter "attackerType" from onComputeDamageTaken can now have the value "dot" when the champion takes damage over time
- The function 'party:getAdjacentMonstersTables(name)' now takes the name of the table to return, which is "list" or "distance". "List" returns the list of monsters, and "distance" returns their distance from the party
- onHitTrigger now has the "damageType" parameter
- onPerformAddedDamage now triggers for "neutral" and "physical" damage types

- Misc:
	- GUI: The Velocity stat displayed the inverse signal. It now also uses the key words "faster" or "slower"
	- GUI: Fixed an issue when an item had a negative minumum damage bonus with a positive maximum damage bonus (and vice versa)
	- GUI: The weapon cooldown now displays at the bottom of the weapon's info
	- Changed spread of floating damage text so it doesn't overlap as much
	
- Bugfixes:
	- Fixed a crash related Farmers using consumable items (again)
	- Fixed an issue with Champion:getData() and Champion:getDataDuration()



============== 0.3.13 Changelog ==============

- New trait/skill hook:
	onJamTrigger(champion, item, jammed, level)

- New equipment hook:
	onJamTrigger(self, champion, item, jammed)
	
- New condition hook:
	onComputeDamageTaken(champion, attack, attacker, attackerType, dmg, dmgType, isSpell)
	
- Misc:
	- GUI: The attack stats of weapons now appear before their other stats
	
- Bugfixes:
	- Fixed a crash related Farmers using consumable items
	- Fixed the Resist All stat being ignored (again)
	- Fixed an issue where multiple instances of 'onComputeDamageTaken' would overwrite each other 
	- Fixed the Mutation trait being applied to other champions in some cases



============== 0.3.12 Changelog ==============

- Parts of the code were moved to their own files (see instructions above)

- New trait/skill hooks:
	onBrewPotion(champion, potion, count, recipe, level)

- New equipment hooks:
	onBrewPotion(self, champion, potion, count, recipe)
	
- Bugfixes:
	- Fixed an issue with weapons that use ammo not firing
	- Fixed a crash related to herb multiplication
	- Fixed the Forcefield spell duration not scaling
	- Fixed the Resist All stat being ignored
	
	

============== 0.3.11 Changelog ==============

- Added equipment hooks that already existed as trait hooks:
	onComputeDamageMultiplier(self, champion, weapon, attack, attackType)
	onComputeDualWieldingModifier(self, champion, weapon, attack, attackType)
	onCastSpell(self, champion, name, cost, skill)
	onDataDurationEnds(self, champion, name, value)
	
- New trait/skill/equipment hooks:
	onCastSpell(champion, name, cost, skill, level)
	onDataDurationEnds(champion, name, value, level)

- New champion functions:
	setDataDuration(name, value, duration)
	getDataDuration(name)
	getDamageWithWeapon(itemComponent)

- Bugfixes:
	- Fixed an issue with onComputeConditionDuration and onComputeConditionPower on equipmentItem
	- Fixed an issue with onRecomputeStats
	- Fixed an inconsistency with onComputeDamageModifier, minDamageMod and maxDamageMod on items
	- Fixed instances of min damage being higher than max damage
	- onComputeDamageTaken is now consistent across all instances, calculating the new damage only after all hooks are checked
	- Fixed an issue with recalculating final Health and Energy
	- Fixed a particle crash when starting custom dungeons
	
- Added new stat: Threat
	- Champion stat = threat_rate, Equipment stat = threat
	- Can be either -1, 0 or 1. Enemies will prioritize the highest threat target 25% of the time

- Misc changes:
	- For resists and health/energy regen, when multiple stats are equal, the item description will summarize them. Eg: "Fire and Cold Resist +10"
	- Food consumption text is now clearer, saying "higher" or "lower" consumption
	- Same with EXP gain
	- Armor proficiency text always appears at the end 

	
	
============== 0.3.10 Changelog ==============

- Added trait hooks: 
	onComputeConditionDuration = function(condition, champion, name, beneficial, harmful, transformation)
	onComputeConditionPower = function(condition, champion, name, beneficial, harmful, transformation)
	onPerformAddedDamage = function(champion, weapon, attack, attackType, damageType, level)

- Added equipment hooks: 
	onComputeConditionDuration = function(self, condition, champion, name, beneficial, harmful, transformation)
	onComputeConditionPower = function(self, condition, champion, name, beneficial, harmful, transformation)
	onPerformAddedDamage = function(self, champion, weapon, attack, attackType, damageType)

- Hooks change:
	onComputeItemStats(equipmentItem, champion, slot, level)
		Changed to:
	onComputeItemStats(equipmentItem, champion, slot, statName, statValue, level)
	Can now be used to return a new value for the stat being checked
	
	onComputeChampionAttackDamage
	First return value now causes damage number to not be displayed (previously it did nothing)

- Added equipment hooks that already existed as trait hooks:
	onComputeToHit = function(self, monster, champion, weapon, attack, attackType, damageType, toHit)
	onLevelUp = function(self, champion)
	onUseItem = function(self, champion, item)
	onComputeItemStats = function(self, champion, slot, statName, statValue)

- Item change:
	The effect on the Fire Gauntlets is no longer hardcoded. It uses the onPerformAddedDamage and onComputeChampionAttackDamage hooks

- Bugfixes:
	- Fixed an issue with the Mutation trait
	- Fixed a display error with exp boost items


 
============== Reference List  ==============

Check: https://github.com/7Soul/log2_extended_hooks/wiki for a more up-to-date version

 -- Weapon stats

 	minDamageMod - adds to the minimum damage of the weapon. The min damage doesn't go over the max damage -1
 	maxDamageMod - adds to the maximum damage of the weapon. The max damage doesn't go under the min damage +1
 	attackPowerVariation - by default is 0.5, making all attacks have a variation of -0.5x to +0.5x the attackPower. This number overrides this value
 	critMultiplier - adds to your current critical multiplier, which is 2.5 (works on all weapon types)
 	jamChance - any weapon can jam if they contain this value
 	jamText - used to replace the "Jammed!" text if you want
 	velocity - mutlipliers the base velocity for projectiles. Works with missile weapons and throw weapons
	attackFire, attackCold, attackShock, attackPoison - adds elemental damage to the attack


 -- EquipmentItem stats

	critMultiplier, minDamageMod, maxDamageMod - same as above
	dualWielding - adds to the base dual wielding damage multiplier, which by default is 0.6. Adding 0.4 makes so there's no penalty


 -- ContainerItem properties
	slots: number of slots that fit in the window (16, 9, 4 or 1)
	gfx: custom texture to be used as a background
	closeButton: where to put the close button {x,y,width,height}. Defaul: {x = 207, y = 15, width = 40, height = 40}
	customSlots: used to place slots in custom positions (slots number is still used to determine where they can go). Uses a table of x and y indexes. Ex: When "slots=9", {0,0} places a slot in the first position. {2,2} places a slot in the last position
	customSlotGfx: causes the Gui to draw slot squares graphics. If "true" it'll use a default slot texture, or you can set to your own texture

 -- ContainerItem hooks
onAcceptItem(item, champion)
	If return false causes container to not accept an item 
onOpen(champion)
	If return false causes container to be unopenable
onCalculateWeight(weight, item, champion)
	Returns the new weight of the item while it exists inside the container
	
	
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
		

 -- Condition definition

maxStacks - maximum number of stacks
stackTimer - timer it takes for each stack to count down after the initial timer has run
healthBarColor = {r,g,b,a} - colors the health bar
energyBarColor = {r,g,b,a} - colors the energy bar
frameColor = {r,g,b,a} - creates a frame around the champion, like with shields
tickMode = "energy" - makes the condition drain the champion's energy. The tickInterval dictates amount per deltaTime
leftHandTexture, rightHandTexture = replaces hand graphic. Can use a GuiItem object or a texture
noAttackPanelIcon = makes items unusable in hand (eg: bear form)

	
 --  SurfaceComponent and SocketComponent functions
getItemByIndex(index)
	Returns an item component from this surface/socket
dropItem(item, bool)
	Causes the surface/socket to drop an item on the floor. Triggers onRemoveItem hook if 'bool' is true
	
	
 -- Party hooks

onCalculateDamageWithAttack = function(self, champion, weapon, attack, power)
	Runs at the start of damage calculation, the return value will replace the power of the attack
	return number
onBrewPotion = function(self, potion, champion)
	Runs before potion/bomb item is spawned
	Can be used to cancel potion making, alter the count or the item you get from crafting
	"potion" is the name of the potion
	Return { true, potion, count }
onMultiplyHerbs = function(self, herbRates, champion)
	Called after every step for a champion that has the "herb_multiplication" trait. 	Can be used to cancel herb multiplication or alter a particular herb rate
	"herbRates" is a table containing each herb name as a key and the number of steps 	taken as a value
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

 -- Monster hooks and functions

setData(name, value)
setDataDuration(name, value, duration)
addData(name, value)
getData(name)
getDataDuration(name)
	Stores values in a table
getAIState
	Existed for MonsterGroupComponent but not for MonsterComponent

 -- Trait/Skill Hooks
	
onRecomputeStats = function(champion, level)
onComputeAccuracy = function(champion, weapon, attack, attackType, level, monster)
onComputeCritChance = function(champion, weapon, attack, attackType, level, monster, accuracy)
onReceiveCondition = function(champion, cond, level)

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
onComputeChampionAttackDamage = function(monster, champion, weapon, attack, dmg, damageType, crit, backstab, level)
	Can modify attack results
	Return false on the first value to cause damage number to not be displayed
	return { true, dmg, heading, crit, backstab, damageType }
			or
	return dmg
onComputeChampionSpellDamage = function(monster, champion, spell, dmg, damageType, level) 
	Can modify spell results
	return { true, dmg, heading }
onComputeDualWieldingModifier = function(champion, weapon, attack, attackType, level)
	Adds to dual wielding multiplier. By default its 0.6, so returing 0.4 means dual wield damage is multiplied by 1 (shows in stats window)
	return number
onCheckDualWielding = function(champion, weapon1, weapon2, level)
	Returns true for when weapon1 + weapon2 is a valid dual wield option
	return boolean
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
onComputeItemStats = function(equipmentItem, champion, slot, statName, statValue, level)
	Runs during EquipmentItem stat calculation, before onRecomputeStats
	Can return a new value for the current statName being checked
onComputeToHit = function(monster, champion, weapon, attack, attackType, damageType, toHit, level)
	Overrites hit chance, able to go over the min/max of 5/95
	return toHit
onComputeSpellCost = function(champion, name, cost, skill, level)
	Returns a multiplier to the cost of a spell when casting
	return number
onComputeSpellCooldown = function(champion, name, cost, skill, level)
	Returns a multiplier to the spell cooldown when casting
	return number
onComputeSpellDamage = function(champion, spell, name, cost, skill, level)
	'spell' is the damage component of the spell (tiledamager, projectile or cloudspell)
	return { boolean, spell }
onComputeHerbMultiplicationRate = function(champion)
	Returns a table that multiplies the rate of each herb, the higher the value the longer it takes for them to multiply
	return { 1, 1, 1, 1, 1, 1 }
onComputeConditionDuration = function(condition, champion, name, beneficial, harmful, transformation, level)
	Multiplier to condition's tickInterval
	return number
onComputeBombPower = function(bombitem, champion, power, target, level)
	Modifies power of bomb being thrown
	return power
onComputeDamageTaken = function(champion, attack, attacker, attackerType, dmg, dmgType, isSpell, level)
	Modifies damage a champion takes
	return dmg
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
onComputeSpellCritChance = function(champion, damageType, monster, level)
	return number
onRegainHealth = function(champion, item, amount, level)
	Multiplier for any source of health recover
	'item' is true if the source of healing is a onUseItem
	return number
onRegainEnergy = function(champion, item, amount, level)
	> See onRegainHealth
onCheckRestrictions = function(champion, skill, level)
	Used to create restrictions for learning skills.
	'skill' is a table containing the skill definition
onLevelUp = function(champion, level)
	Triggers when a character levels up
	Can return false to cancel level up
onUseItem = function(champion, item, level)
	Triggers when an item with UsableItem component is used
	Can return false to cancel item being consumed
onPerformAddedDamage = function(champion, weapon, attack, attackType, element, level)
	Adds elemental damage to an attack
	This function is called for each element, so to add damage of an specific element you can do
	if (element == "fire") then
		return 10
	end
	This damage is then calculated the same way attackPower is calculated
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
	Return false on the first value to cause damage number to not be displayed
	return { true, dmg, heading, crit, backstab, damageType }
		or
	return dmg
onComputePierce = function(self, monster, champion, weapon, attack, projectile, dmg, dmgType, attackType, crit, backstab)
	Adds a value to your pierce amount. Works with all attack types
	return number
onComputeSpellCost = function(self, champion, name, cost, skill)
	Returns a multiplier to the cost of a spell when casting
	return number
onComputeSpellCooldown = function(self, champion, name, cost, skill)
	Returns a multiplier to the spell cooldown when casting
	return number
onComputeItemStats = function(self, champion, slot, statName, statValue)
	Runs during EquipmentItem stat calculation, before onRecomputeStats
	Can return a new value for the current statName being checked
onComputeSpellDamage = function(self, champion, spell, name, cost, skill)
	spell is the damage component of the spell (tiledamager, projectile or cloudspell)
	return { boolean, spell }
onComputeConditionDuration = function(self, condition, champion, name, beneficial, harmful, transformation, level)
	Multiplier to condition duration
	return number
onComputeBombPower = function(self, bombitem, champion, power, target)
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
onHitTrigger = function(self, champion, weapon, attack, attackType, dmg, damageType, crit, backstab, monster)
	Called just before a monster takes damage
	Doesn't return any values
onKillTrigger = function(self, champion, weapon, attack, attackType, dmg, damageType, crit, backstab, monster)
	Called from monster:damage() when the monster is about to die
	If it returns false, the monster will survive at 1 hp
	return boolean
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
onComputeToHit = function(self, monster, champion, weapon, attack, attackType, damageType, toHit)
	Overrites hit chance, able to go over the min/max of 5/95
	return toHit
onRegainHealth = function(self, champion, item, amount)
	Multiplier for any source of health recover
	'item' is true if the source of healing is a onUseItem
	return number
onRegainEnergy = function(self, champion, item, amount)
	> See onRegainHealth
onLevelUp = function(self, champion)
	Triggers when a character levels up
	Can return false to cancel level up
onUseItem = function(self, champion, item)
	Triggers when an item with UsableItem component is used
	Can return false to cancel item being consumed
onPerformAddedDamage = function(self, champion, weapon, attack, attackType, element)
	Adds elemental damage to an attack
	This function is called for each element, so to add damage of an specific element you can do
	if (element == "fire") then
		return 10
	end
	This damage is then calculated the same way attackPower is calculated
	return number
	
