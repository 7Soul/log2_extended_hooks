ExtendedHooks = class()

ExtendedHooks.modVersion = "0.3.13"
ExtendedHooks.modFolder = config.documentsFolder .. "/Mods/hooks/"
ExtendedHooks.gfxFolder = ExtendedHooks.modFolder .. "gfx/"

-- config.developer = true

function extendProxyClass(class, prop)
	class.__class.synthesizeProperty(prop)
end


-- ScriptComponent.baseEnv.GameMode = {
-- 	completeGame = function(cinematicsFile)
-- 		if config.editor then
-- 			gui:hudPrint("Game completed!")
-- 		else
-- 			gameMode:completeGame(cinematicsFile)
-- 		end
-- 	end,
	
-- 	playVideo = function(filename)
-- 		if config.editor then
-- 			console:warn("video not played in editor mode")
-- 		else
-- 			gameMode:playVideo(filename)
-- 		end
-- 	end,

-- 	playStream = function(name)
-- 		soundSystem:playStream(name)
-- 	end,

-- 	showImage = function(image)
-- 		gameMode:showImage(image)
-- 	end,

-- 	setMaxStatistic = function(stat, max)
-- 		checkArg(1, stat, "setMaxStatistic", "string")
-- 		checkArg(2, max, "setMaxStatistic", "number")
-- 		return party.go.statistics:setStatMax(stat, max)
-- 	end,

-- 	getMaxStatistic = function(stat)
-- 		checkArg(1, stat, "getMaxStatistic", "string")
-- 		return party.go.statistics:getStatMax(stat)
-- 	end,

-- 	getStatistic = function(stat)
-- 		checkArg(1, stat, "getStatistic", "string")
-- 		return party.go.statistics:getStat(stat)
-- 	end,

-- 	setTimeMultiplier = function(mult)
-- 		checkArg(1, mult, "setTimeMultiplier", "number")
-- 		gameMode:setTimeMultiplier(mult)
-- 	end,

-- 	getTimeMultiplier = function()
-- 		return gameMode.timeMultiplier
-- 	end,

-- 	setEnableControls = function(enable)
-- 		checkArg(1, enable, "setEnableControls", "boolean")
-- 		party.controlsEnabled = enable
-- 	end,

-- 	getEnableControls = function()
-- 		return party.controlsEnabled
-- 	end,

-- 	setGameFlag = function(flag, value)
-- 		checkArg(1, flag, "setGameFlag", "string")
-- 		checkArg(2, value, "setGameFlag", "boolean")
-- 		gameMode:setGameFlag(flag, value)
-- 	end,

-- 	getGameFlag = function(flag)
-- 		checkArg(1, flag, "getGameFlag", "string")
-- 		return gameMode:getGameFlag(flag)
-- 	end,

-- 	setTimeOfDay = function(time)
-- 		checkArg(1, time, "setTimeOfDay", "number")
-- 		gameMode:setTimeOfDay(time)
-- 	end,

-- 	getTimeOfDay = function()
-- 		return gameMode:getTimeOfDay()
-- 	end,

-- 	advanceTime = function(step)
-- 		checkArg(1, step, "advanceTime", "number")
-- 		gameMode:advanceTime(step)
-- 	end,

-- 	fadeIn = function(color, length)
-- 		checkArg(1, color, "fadeIn", "number")
-- 		checkArg(2, length, "fadeIn", "number")
-- 		gameMode:fadeIn(hexToColor(color), length)
-- 	end,

-- 	fadeOut = function(color, length)
-- 		checkArg(1, color, "fadeOut", "number")
-- 		checkArg(2, length, "fadeOut", "number")
-- 		gameMode:fadeOut(hexToColor(color), length)
-- 	end,

-- 	setCamera = function(camera)
-- 		if camera then
-- 			if camera and getmetatable(camera) ~= CameraComponent.__proxyClass then error("invalid camera", 2) end
-- 			camera = proxyToObject(camera)
-- 			if not camera then error("bad object", 2) end
-- 		end

-- 		if camera then
-- 			gameMode:setCamera(camera.camera)
-- 		else
-- 			gameMode:setCamera(nil)
-- 		end
-- 	end,

-- 	unlockAchievement = function(name)
-- 		checkArg(1, name, "unlockAchievement", "string")	
-- 		steamContext:unlockAchievement(name)
-- 	end,

-- 	performMeleeHit = function(championId, weapon, attack, slot, target)
-- 		checkArg(1, championId, "performMeleeHit", "number")
-- 		checkArg(2, weapon, "performMeleeHit", "table")
-- 		checkArg(3, attack, "performMeleeHit", "table")
-- 		checkArg(4, slot, "performMeleeHit", "number")
-- 		checkArg(5, target, "performMeleeHit", "table")
-- 		gameMode:performMeleeHit(championId, weapon, attack, slot, target)
-- 	end,
-- }

defineProxyClass{
	class = "PartyComponent",
	description = "The singular party component that holds the four champions. Champion's position in the party can change when party formation is changed. However champions can be identified with their ordinal number that never changes.",
	baseClass = "Component",
	methods = {
		{ "heal" },
		{ "rest" },
		{ "wakeUp", "boolean" },
		{ "move", "number" },
		{ "turn", "number" },
		{ "isResting" },
		{ "isMoving" },
		{ "isFalling" },
		{ "isClimbing" },
		{ "isIdle" },
		{ "isCarrying", "string" },
		{ "setMovementSpeed", "number" },
		{ "getMovementSpeed" },
		{ "swapChampions", {"number", "number"} },
		{ "getChampion", "number" },
		{ "getChampionByOrdinal", "number" },
		{ "playScreenEffect", "string" },
		{ "shakeCamera", {"number", "number"} },
		{ "knockback", "number" },
		{ "grapple", "number" },
		{ "getMonstersAround" }, -- new
		{ "getAggroMonsters" },
		{ "getAdjacentMonsters" },
		{ "getAdjacentMonstersTables", "string"},
	},
	hooks = {
		"onCastSpell(self, champion, spell)",
		"onDamage(self, champion, damage, damageType)",
		"onDie(self, champion)",
		"onAttack(self, champion, action, slot)",
		"onLevelUp(self, champion)",
		"onUseItem(self, champion, item)",
		"onReceiveCondition(self, champion, condition)",
		"onDrawGui(self, context)",		
		"onDrawInventory(self, context, champion)",
		"onDrawStats(self, context, champion)",
		"onDrawSkills(self, context, champion)",
		"onDrawTraits(self, context, champion)",
		"onPickUpItem(self, item)",
		"onProjectileHit(self, champion, item, damage, damageType)",
		"onRest(self)",
		"onWakeUp(self)",
		"onTurn(self, direction)",
		"onMove(self, direction)",
		"onCalculateDamageWithAttack(self, champion, weapon, attack, power)", -- new
		"onBrewPotion(self, potion, champion)", -- new
		"onMultiplyHerbs(self, herbRates, champion)", -- new
		"onLoadDefaultParty(self)",
		"onCheckEnemies(self, mList, mDist, monsterCount, monstersAround)"
	},
}

defineProxyClass{
	class = "Champion",
	description = "Champion's attributes, skills, traits, conditions and other statistics can be accessed through this class.",
	methods = {
		{ "setEnabled", "boolean" },
		{ "setName", "string" },
		{ "setRace", "string" },
		{ "setSex", "string" },
		{ "setClass", "string" },
		{ "setHealth", "number" },
		{ "setEnergy", "number" },
		{ "getEnabled" },
		{ "getName" },
		{ "getRace" },
		{ "getSex" },
		{ "getClass" },
		{ "getDualClass" },
		{ "getLevel" },
		{ "getExp" },
		{ "getOrdinal" },
		{ "setPortrait", "string" },
		{ "isAlive" },
		{ "gainExp", "number" },
		{ "resetExp" },
		{ "levelUp" },
		{ "setSkillPoints", "number" },
		{ "getSkillPoints" },
		{ "addSkillPoints", "number" },
		{ "getSkillLevel", {"string", "number"} },
		{ "getSkillLevel", "string" },
		{ "trainSkill", {"string", "number"} },
		{ "addTrait", "string" },
		{ "removeTrait", "string" },
		{ "hasTrait", "string" },
		{ "setFood", "number" },
		{ "getFood" },
		{ "consumeFood", "number" },
		{ "modifyFood", "number" },
		{ "setCondition", "string" },
		{ "removeCondition", "string" },
		{ "hasCondition", "string" },
		{ "setConditionValue", {"string", "number"} },
		{ "getConditionValue", "string" },
		{ "isBodyPartWounded", "number" },
		{ "damage", {"number", "string"} },
		{ "playDamageSound" },
		{ "playSound", "string" },
		{ "showAttackResult", {"any", "string"} },
		{ "setBaseStat", {"string", "number"} },
		{ "modifyBaseStat", {"string", "number"} },
		{ "upgradeBaseStat", {"string", "number"} },
		{ "addStatModifier", {"string", "number"} },
		{ "getBaseStat", "string" },
		{ "getCurrentStat", "string" },
		{ "regainHealth", "number" },
		{ "regainEnergy", "number" },
		{ "getHealth" },
		{ "getMaxHealth" },
		{ "getEnergy" },
		{ "getMaxEnergy" },
		{ "getProtection" },
		{ "getEvasion" },
		{ "getResistance", "string" },
		{ "getLoad" },
		{ "getMaxLoad" },
		{ "getArmorSetPiecesEquipped", "string" },
		{ "isArmorSetEquipped", "string" },
		{ "isDualWielding" },
		{ "isReadyToAttack", "number" },
		{ "insertItem", {"number", "ItemComponent"} },
		{ "removeItem", "ItemComponent" },
		{ "removeItemFromSlot", "number" },
		{ "swapItems", {"number", "number"} },
		{ "swapWeaponSets" },
		{ "getItem", "number" },
		{ "getOtherHandItem", "number" },
		{ "playHealingIndicator" },
		{ "castSpell", "number" },
		{ "attack", {"number", "boolean"} },

        { "getConditionStacks" }, -- new
        { "setConditionStacks", {"string", "number"} }, -- new
        { "setData", { "string", "number" } },
		{ "setDataDuration", { "string", "number", "number" } },
		{ "getData", "string" },
		{ "getDataDuration", "string" },
		{ "addData", { "string", "number" } },
		{ "getCooldown" },
		{ "setCooldown", {"number", "number"} },
		{ "addStatFinal", {"string", "number"} },
		{ "giveItem", {"ItemComponent"} },
		{ "randomNumber", "number" },
		{ "triggerSpell", {"number", "number"} },
		{ "expForLevel", "number" },
		{ "getDamageWithWeapon" , { "ItemComponent" } },
		{ "performMeleeHit" , { "number", "ItemComponent", "table", "number", "MonsterComponent" } },
	},
}

defineProxyClass{
	class = "MonsterComponent",
	baseClass = "Component",
	description = "Makes the object a monster. Requires Model, Animation and a brain component. Most monsters (depending on the brain) also require MonsterMove, MonsterTurn and MonsterAttack components.",
	methods = {
		{ "setAIState", "string" },
		{ "setHealth", "number" },
		{ "setMaxHealth", "number" },
		{ "setLevel", "number" },
		{ "setCondition", "string" },
		{ "setCapsuleHeight", "number" },
		{ "setCapsuleRadius", "number" },
		{ "setCollisionRadius", "number" },
		{ "setDeathEffect", "string" },
		{ "setDieSound" },	-- accepts string or nil
		{ "setEvasion", "number" },
		{ "setExp", "number" },
		{ "setFlying", "boolean" },
		{ "setFootstepSound", "string" },
		{ "setHitEffect", "string" },
		{ "setHitSound", "string" },
		{ "setIdleAnimation", "string" },
		{ "setImmunities", "table" },
		{ "setLootDrop", "table" },
		{ "setMeshName", "string" },
		{ "setHeadRotation", "vec" },
		{ "setProtection", "number" },
		{ "setResistances", "table" },
		{ "setShape", "string" },
		{ "setSwarm", "boolean" },
		{ "setMonsterFlag", {"string", "boolean"} },
		{ "getHealth" },
		{ "getMaxHealth" },
		{ "getLevel" },
		{ "getCapsuleHeight" },
		{ "getCapsuleRadius" },
		{ "getCollisionRadius" },
		{ "getDeathEffect" },
		{ "getDieSound" },
		{ "getEvasion" },
		{ "getExp" },
		{ "getFlying" },
		{ "getFootstepSound" },
		{ "getGroupSize" },
		{ "getHitEffect" },
		{ "getHitSound" },
		{ "getIdleAnimation" },
		{ "getImmunities" },
		{ "getLootDrop" },
		{ "getMeshName" },
		{ "getHeadRotation" },
		{ "getProtection" },
		{ "getResistance", "string" },
		{ "getShape" },
		{ "getSwarm" },
		{ "getCurrentAction" },
		{ "getMonsterFlag", "string" },
		{ "addItem", "ItemComponent" },
		{ "removeItem", "ItemComponent" },
		{ "dropAllItems" },
		{ "performAction", "string" },	-- TODO: optional parameters!
		{ "moveForward" },
		{ "moveBackward" },
		{ "turnLeft" },
		{ "turnRight" },
		{ "strafeLeft" },
		{ "strafeRight" },
		{ "attack" },
		{ "shootProjectile", {"string", "number", "number"} },
		{ "throwItem", {"string", "number", "number"} },
		{ "showDamageText", {"string"} },
		{ "die" },	-- optional arg: gainExp
		{ "isInBackRow" },
		{ "isIdle" },
		{ "isAlive" },
		{ "isChangingAltitude" },
		{ "isFalling" },
		{ "isGroupLeader" },
		{ "isImmuneTo", "string" },
		{ "isInvulnerable" },
		{ "isMoving" },
		{ "isPerformingAction", "string" },
		{ "isReadyToAct" },
		{ "knockback", "number" },
		{ "setTraits", "table" },
		{ "addTrait" , "string" },
		{ "removeTrait" , "string" },
		{ "hasTrait" , "string" },
		 -- new
		{ "setData", { "string", "number" } },
		{ "setDataDuration", { "string", "number", "number" } },
		{ "getData", "string" },
		{ "getDataDuration", "string" },
		{ "addData", { "string", "number" } },
		{ "getAIState" },
		{ "getResistanceDamageMultiplier", "string" },
		{ "hasCondition" , "string" },
		{ "setConditionValue", {"string", "number"} },
		-- contents() is defined at the end of this file
	},
	hooks = {
		"onProjectileHit(self, item, champion, weapon, attack, damage, damageType, heading, crit)",
		"onPerformAction(self, name)",
		"onDamage(self, damage, damageType)",
		"onSpellDamage(self, damage, damageType, c, spell, heading)", -- new
		"onDie(self)",
	},
}

extendProxyClass(MonsterComponent, "resistanceReduction")
MonsterComponent:autoSerialize("lootDrop", "immunities", "resistances", "traits", "resistanceReduction")

defineProxyClass{
	class = "ItemComponent",
	baseClass = "Component",
	description = "Makes the object an item that can be picked up, dropped, thrown and placed into champions' hands and inventory. Requires Model component.",
	methods = {
		{ "setStackSize", "number" },
		{ "setMultiple", "number" },
		{ "setCharges", "number" },
		{ "setFuel", "number" },
		{ "setUiName", "string" },
		{ "setGfxIndex", "number" },
		{ "setAchievement", "string" },
		{ "setArmorSet", "string" },
		{ "setConvertToItemOnImpact", "string" },
		{ "setDescription", "string" },
		{ "setFitContainer", "boolean" },
		{ "setFragile", "boolean" },
		{ "setJammed", "boolean" },
		{ "setGameEffect", "any" },		-- accepts string or nil
		{ "setGfxAtlas", "string" },
		{ "setGfxIndexInHand", "number" },
		{ "setGfxIndexPowerAttack", "number" },
		{ "setImpactSound", "string" },
		{ "setPrimaryAction", "string" },
		{ "setProjectileRotationSpeed", "number" },
		{ "setProjectileRotationX", "number" },
		{ "setProjectileRotationY", "number" },
		{ "setProjectileRotationZ", "number" },
		{ "setSecondaryAction", "string" },
		{ "setSharpProjectile", "boolean" },
		{ "setStackable", "boolean" },
		{ "setWeight", "number" },
		{ "getStackSize" },
		{ "getMultiple" },
		{ "getCharges" },
		{ "getFuel" },
		{ "getWeight" },
		{ "getFormattedName" },
		{ "getUiName" },
		{ "getGfxIndex" },
		{ "getAchievement" },
		{ "getArmorSet" },
		{ "getConvertToItemOnImpact" },
		{ "getDescription" },
		{ "getFitContainer" },
		{ "getFragile" },
		{ "getJammed" },
		{ "getGameEffect" },
		{ "getGfxAtlas" },
		{ "getGfxIndexInHand" },
		{ "getGfxIndexPowerAttack" },
		{ "getImpactSound" },
		{ "getPrimaryAction" },
		{ "getProjectileRotationSpeed" },
		{ "getProjectileRotationX" },
		{ "getProjectileRotationY" },
		{ "getProjectileRotationZ" },
		{ "getSecondaryAction" },
		{ "getSharpProjectile" },
		{ "getStackable" },
		{ "getTotalWeight" },
		{ "setTraits", "table" },
		{ "addTrait" , "string" },
		{ "removeTrait" , "string" },
		{ "hasTrait" , "string" },
		{ "throwItem", {"number", "number"} },
		{ "land" },
		{ "updateBoundingBox" },

		{ "setData", { "string", "number" } }, -- new
		{ "getData", "string" },
		{ "addData", { "string", "number" } },
	},
	hooks = {
		"onThrowAttackHitMonster(self, monster)",
		"onEquipItem(self, champion, slot)",
		"onUnequipItem(self, champion, slot)",
	},
}


defineProxyClass{
	class = "UsableItemComponent",
	baseClass = "ItemActionComponent",
	description = "Makes an item Usable by right-clicking on it.",
	methods = {
		{ "setSound", "string" },
		{ "setNutritionValue", "number" },
		{ "setEmptyItem", "string" },
		{ "setCanBeUsedByDeadChampion", "boolean" },
		{ "setRequirements", "table" },
		{ "getSound" },
		{ "getNutritionValue" },
		{ "getEmptyItem" },
		{ "getCanBeUsedByDeadChampion" },
		{ "getRequirements" },
		{ "getPierce" } -- new
	},
	hooks = {
		"onUseItem(self, champion)",
	}
}

local oldDefineSkill = defineSkill
function defineSkill(desc)
	local f = "defineSkill"
	checkNamedArgOpt("skillTraits", desc, f, "table") -- used to display traits in a more organized way
	checkNamedArgOpt("maxLevel", desc, f, "number")
	checkNamedArgOpt("pointsCost", desc, f, "table")
	checkNamedArgOpt("onCheckRestrictions", desc, f, "function")
	checkNamedArgOpt("requirements", desc, f, "table")
	oldDefineSkill(desc)
end

local oldDefineTrait = defineTrait
function defineTrait(desc)
	local f = "defineTrait"
	oldDefineTrait(desc)
end

local oldDefineCharClass = defineCharClass
function defineCharClass(desc)
	desc.order = desc.order or 99
	desc.skillPointsPerLevel = desc.skillPointsPerLevel or 1
	desc.availableSkills = desc.availableSkills or {}
	local f = "defineCharClass"
	checkNamedArgOpt("order", desc, f, "number") -- used to put classes in a specific order
	checkNamedArgOpt("skillPointsPerLevel", desc, f, "number") -- 
	checkNamedArgOpt("availableSkills", desc, f, "table") -- 
	oldDefineCharClass(desc)
end


local oldDefineCondition = defineCondition
function defineCondition(desc)
	local f = "defineCondition"
	checkNamedArgOpt("onRecomputeFinalStats", desc, f, "function")
	checkNamedArgOpt("maxStacks", desc, f, "number") -- 
	checkNamedArgOpt("stackTimer", desc, f, "number") -- 
	checkNamedArgOpt("healthBarColor", desc, f, "table") -- 
	checkNamedArgOpt("energyBarColor", desc, f, "table") -- 
	checkNamedArgOpt("frameColor", desc, f, "table") -- 
	checkNamedArgOpt("noAttackPanelIcon", desc, f, "boolean") -- 
	checkNamedArgOpt("transformation", desc, f, "boolean") --  
	checkNamedArgOpt("tickMode", desc, f, "string") --  
	oldDefineCondition(desc)
end

defineProxyClass{
	class = "Condition",
	description = "Custom condition.",
	methods = {
		{ "setDuration", "number" }, 
		{ "getDuration" }, 
		{ "getName" }, -- new
		{ "getStacks" }, -- new
		{ "setStacks", "number" }, -- new
		{ "setDescription", "string" }, -- new
	},
}

local oldDefineSpell = defineSpell
function defineSpell(desc)
	desc = table.copy(desc)	
	local f = "defineSpell"
	checkNamedArgOpt("duration", desc, f, "number")
	checkNamedArgOpt("durationScaling", desc, f, "number")
	checkNamedArgOpt("power", desc, f, "number")
	checkNamedArgOpt("powerScaling", desc, f, "number")
	
	oldDefineSpell(desc)
end

defineProxyClass{
	class = "SurfaceComponent",
	baseClass = "Component",
	description = "A support for placing items. Altars, alcoves and chests are typically surfaces.",
	methods = {
		{ "setDebugDraw", "boolean" },
		{ "setSize", "vec" },
		{ "getDebugDraw" },
		{ "getSize" },
		{ "addItem", "ItemComponent" },
		{ "count" },
		{ "dropItem", { "ItemComponent", "boolean" } }, -- new
		{ "getItemByIndex" } -- optional number parameter. Default: 1
		-- contents() is defined at the end of this file
	},
	hooks = {
		"onInsertItem(self, item)",
		"onRemoveItem(self, item)",
	},
}

defineProxyClass{
	class = "SocketComponent",
	baseClass = "Component",
	description = "An attachment point for items. Wall hooks, sconces, statue's hand could be sockets. A socket can hold a single item.",
	methods = {
		{ "getItem" },
		{ "setDebugDraw", "boolean" },
		{ "getDebugDraw" },
		{ "addItem", "ItemComponent" },
		{ "count", },
		{ "dropItem", { "ItemComponent", "boolean" } }, -- new
		{ "getItemByIndex" }, -- optional number parameter. Default: 1
		-- contents() is defined at the end of this file
	},
	hooks = {
		"onInsertItem(self, item)",
		"onRemoveItem(self, item)",
		"onAcceptItem(self, item)",
	},
}

defineProxyClass{
	class = "ContainerItemComponent",
	baseClass = "Component",
	description = "Makes an item a container for other items.",
	methods = {
		{ "setContainerType", "string" },
		{ "getCapacity" },
		{ "getContainerType" },
		{ "getItemCount" },
		{ "addItem", "ItemComponent" },
		{ "insertItem", {"number", "ItemComponent"} },
		{ "removeItem", "ItemComponent" },
		{ "removeItemFromSlot", "number" },
		{ "getItem", "number" },
		{ "setCapacity", "number" },
		-- contents() is defined at the end of this file
	},
	hooks = {
		"onInsertItem(self, item, slot)",
		"onRemoveItem(self, item, slot)",
		"onCalculateWeight(self, weight, item, champion)",
		"onAcceptItem(self, item, champion)",
		"onOpen(self, champion)",
	},
}


local oldDungeonLoadInitFile = Dungeon.loadInitFile
function Dungeon:loadInitFile()
	oldDungeonLoadInitFile(self)
	self:AddToolTips()
	self:AddStats()
	self:AddStatNames()
	self:redefineTraits()
	self:redefineSkills()
	self:redefineSpells()
	self:redefineConditions()
	self:redefineItems()
	self:setHerbs()
	self:setExpTable(Champion.ExperienceTable)
	self:addCustomComponents(SlideComponent)
end

function Dungeon:setExpTable(table)
	assert(#table >= 20, "exp table must have at least 20 entries")
	Champion.ExperienceTable = table
end

ExtendedHooks.customComponents = {}

function Dungeon:addCustomComponents(comp, index)
	if index then
		assert(index < 1, "array index starts at 1")
		index = math.max(index, #ExtendedHooks.customComponents)
		table.insert(ExtendedHooks.customComponents, index, comp)
	else
		table.insert(ExtendedHooks.customComponents, comp)
	end
end

function Dungeon:setHerbs()
	self.herbs = {}
	-- collect set of traits from archs
	local traits = {}
	do
		local s = {}
		for _,a in pairs(dungeon.archs) do
			if a.editorIcon and a.components then
				for _,c in ipairs(a.components) do
					local gotHerb
					if c.traits and c.name == "item" then
						for _,t in pairs(c.traits) do
							if t == "herb" then
								s[#s+1] = { ["name"] = a.name, ["gfxIndex"] = c.gfxIndex }
								gotHerb = true
								break
							end
							
						end
					end
					if gotHerb then break end
				end
			end
			if #s >= 6 then break end
		end

		if #s == 0 then CraftPotionComponent.Herbs = {} end
		table.sort(s, function(a, b) return a.gfxIndex < b.gfxIndex end)
		CraftPotionComponent.Herbs = s
	end
	assert(CraftPotionComponent.Herbs ~= {}, "Could not load herb list")
end

local oldNewGameMenuStartGame = NewGameMenu.startGame
function NewGameMenu:startGame()
	if not modSystem:getCurrentMod() then
		oldDungeon = dungeon
		dungeon:redefineTraits()
		dungeon:redefineSkills()
		dungeon:redefineSpells()
		dungeon = oldDungeon
	end

	oldNewGameMenuStartGame(self)
end

local oldNewGame = GameMode.newGame
function GameMode:newGame()
	oldNewGame(self)
	dungeon:redefineSpells()
	dungeon:redefineConditions()
	dungeon:redefineItems()
	dungeon:setHerbs()
end

function Dungeon:AddStats()
	table.insert(Stats, "critical_multiplier")
	table.insert(Stats, "critical_chance")
	table.insert(Stats, "dual_wielding")
	table.insert(Stats, "resist_fire_max")
	table.insert(Stats, "resist_cold_max")
	table.insert(Stats, "resist_shock_max")
	table.insert(Stats, "resist_poison_max")
	table.insert(Stats, "threat_rate")
	table.insert(Stats, "pierce")
end

function Dungeon:AddStatNames()
	table.insert(ToolTip.toolTips, "Critical Damage") -- 21
	table.insert(ToolTip.toolTips, "Critical Chance")
	table.insert(ToolTip.toolTips, "Dual Wielding")
	table.insert(ToolTip.toolTips, "Maximum Fire Resist")
	table.insert(ToolTip.toolTips, "Maximum Cold Resist")
	table.insert(ToolTip.toolTips, "Maximum Shock Resist")
	table.insert(ToolTip.toolTips, "Maximum Poison Resist")
	table.insert(ToolTip.toolTips, "Threat")
	table.insert(ToolTip.toolTips, "Pierce")
	
	table.insert(StatNames, "Critical Damage")
	table.insert(StatNames, "Critical Chance")
	table.insert(StatNames, "Dual Wielding")
	table.insert(StatNames, "Maximum Fire Resist")
	table.insert(StatNames, "Maximum Cold Resist")
	table.insert(StatNames, "Maximum Shock Resist")
	table.insert(StatNames, "Maximum Poison Resist")
	table.insert(StatNames, "Threat")
	table.insert(StatNames, "Pierce")
end

function Dungeon:AddToolTips()
	local toolTips = ToolTip.toolTips
	toolTips["Critical Multiplier"] = "Multiplies damage dealt with criticals by the amount displayed."
	toolTips["Threat"] = "."
	table.insert(ToolTip.toolTips, toolTips)
end

GameMode.defaultParty = {
	{
		name = "Shadow",
		class = "fighter",
		race = "human",
		sex = "female",
		portrait = "assets/textures/portraits/human_female_01.tga",
		strength = 5,
		dexterity = 3,
		vitality = 2,
		willpower = 0,
		skills = { "light_weapons", 1, "armors", 1 },
		traits = { "tough", "agile" },
	},
	{
		name = "Mulrag",
		class = "barbarian",
		race = "minotaur",
		sex = "male",
		portrait = "assets/textures/portraits/minotaur_male_01.tga",
		strength = 5,
		dexterity = 1,
		vitality = 4,
		willpower = 0,
		skills = { "athletics", 1, "dodge", 1 },
		traits = { "aggressive", "head_hunter" },
	},
	{
		name = "Fang",
		class = "alchemist",
		race = "ratling",
		sex = "male",
		portrait = "assets/textures/portraits/ratling_male_01.tga",
		strength = 2,
		dexterity = 4,
		vitality = 2,
		willpower = 2,
		skills = { "alchemy", 1, "firearms", 1 },
		traits = { "mutation", "tough" },
	},
	{
		name = "Astaroth",
		class = "wizard",
		race = "human",
		sex = "male",
		portrait = "assets/textures/portraits/human_male_02.tga",
		strength = 0,
		dexterity = 2,
		vitality = 2,
		willpower = 6,
		skills = { "concentration", 1, "fire_magic", 1 },
		traits = { "aura", "strong_mind" },
	},
}

function GameMode:loadDefaultParty()
	if party:isHookRegistered("onLoadDefaultParty") then
		newDefaultParty = party:callHook("onLoadDefaultParty", objectToProxy(self), GameMode.defaultParty)
		if newDefaultParty then 
			assert(newDefaultParty[4], "default party must be a table with 4 entries")
			GameMode.defaultParty = newDefaultParty
		end
	end

	for i=1,4 do
		local champion = Champion.create()
		local def = GameMode.defaultParty[i]
		champion.ordinal = i
		champion:setName(def.name)
		champion:setClass(def.class)
		champion:setRace(def.race)
		champion:setSex(def.sex)
		champion:setPortrait(def.portrait)
		champion:setBaseStat("strength", def.strength + 10)
		champion:setBaseStat("dexterity", def.dexterity + 10)
		champion:setBaseStat("vitality", def.vitality + 10)
		champion:setBaseStat("willpower", def.willpower + 10)
		party:setChampion(i, champion)
		champion:recomputeStats()
		champion:setBaseStat("health", champion:getMaxHealth())
		champion:setBaseStat("energy", champion:getMaxEnergy())

		for j=1,#def.skills,2 do
			champion:setSkillLevel(def.skills[j], 0) -- avoid gaining +1 skill every time we preview the game
			champion:trainSkill(def.skills[j], def.skills[j+1])
		end

		for j=1,#def.traits do
			champion:addTrait(def.traits[j])
		end
	end
end

function Map:updateEntities()
	if config.verifyEntityIDs then self:verifyIDs() end

	-- update all components
	-- note that it's perfectly valid to add/remove components and entities during traversal
	-- new entities and components are added to the end so that they are always updated in the same frame they were created
	-- removed entities and components are simply skipped (nil entry in list)
	
	-- monster groups must be updated first because they will spawn monsters on first update
	self:updateComponents(MonsterGroupComponent)
	self:updateComponents(SkyComponent, true)	-- update sky first so that far clip is updated as soon as possible
	self:updateComponents(BeaconFurnaceControllerComponent)
	self:updateComponents(BlastComponent)
	self:updateComponents(BlindedMonsterComponent)
	self:updateComponents(StunnedMonsterComponent)
	self:updateComponents(BurningMonsterComponent)
	self:updateComponents(TileDamagerComponent)
	self:updateComponents(CameraShakeComponent)
	self:updateComponents(ChestComponent)
	self:updateComponents(ClickableComponent, true)
	self:updateComponents(CloudSpellComponent)
	self:updateComponents(CrowControllerComponent, true)
	self:updateComponents(CrystalComponent)
	self:updateComponents(DoorComponent)
	--self:updateComponents(DynamicObstacleComponent, true)
	self:updateComponents(EarthquakeComponent)
	self:updateComponents(ExitComponent, true)
	self:updateComponents(FloorTriggerComponent)
	self:updateComponents(ForceFieldComponent)
	self:updateComponents(FogParamsComponent, true)
	self:updateComponents(FogParticlesComponent, true)
	self:updateComponents(FrozenMonsterComponent)
	self:updateComponents(GoromorgShieldComponent)
	self:updateComponents(GravityComponent)
	self:updateComponents(IceShardsComponent)
	self:updateComponents(ItemComponent)
	self:updateComponents(ItemConstrainBoxComponent, true)
	self:updateComponents(LightComponent)
	self:updateComponents(MimicCameraAnimationComponent)
	self:updateComponents(MonsterComponent)
	self:updateComponents(MonsterLightCullerComponent)
	self:updateComponents(PartyComponent)
	self:updateComponents(PlatformComponent, true)
	self:updateComponents(PoisonedMonsterComponent)
	self:updateComponents(ProjectileColliderComponent, true)
	self:updateComponents(ProjectileComponent)
	self:updateComponents(PushableBlockComponent)
	self:updateComponents(SleepingMonsterComponent)
	self:updateComponents(SmallFishControllerComponent, true)
	self:updateComponents(SocketComponent, true)
	self:updateComponents(SpawnerComponent)
	self:updateComponents(StairsComponent)
	self:updateComponents(StonePhilosopherControllerComponent, true)
	self:updateComponents(SurfaceComponent, true)
	self:updateComponents(TeleporterComponent)
	self:updateComponents(ThornWallComponent)
	self:updateComponents(TimerComponent)
	self:updateComponents(TinyCritterControllerComponent, true)
	self:updateComponents(WaterSurfaceComponent, true)
	self:updateComponents(WaterSurfaceMeshComponent, true)
	self:updateComponents(BossFightComponent, true)
	self:updateComponents(CameraComponent, true)
	-- Update custom components added via mods
	for _,comp in ipairs(ExtendedHooks.customComponents) do
		self:updateComponents(comp)
	end	
	-- animations has to be updated after monsters, otherwise animations will flicker when moving animations ends
	-- animations also have to be updated after monsters have been spawned e.g. from a script triggered by a timer/pressure plate
	self:updateComponents(AnimationComponent)	
	-- emit particles last so that transforms are set
	self:updateComponents(ParticleComponent)
	self:updateComponents(UggardianFlamesComponent, true)
	-- update sounds last so that if party is teleported to another level, all sounds in the previous level
	-- are stopped immediately instead of when the old level is updated the next time (which may be dozens of frames away)
	self:updateComponents(SoundComponent)

	-- post update monsters
	Profiler.beginBlock("_PostUpdate")
	if party.go.map == self then
		local components = self.components[MonsterComponent]
		if components then
			for i=1,components.n do 
				if components[i] then
					components[i]:postUpdate()
				end
			end
		end
	end
	Profiler.endBlock()
	
	-- verify script globals
	if config.editor then
		for _,script in self:allComponents(ScriptComponent) do
			script:verifyGlobals()
		end
	end

	-- process pending destroys
	Profiler.beginBlock("_DestroyDelayed")
	GameObject.processPendingDestroys()
	Profiler.endBlock()

	-- update entities
	Profiler.beginBlock("_CompactEntities")
	local entities = self.entities
	local i = 1
	while i <= self.maxEntities do
		local ent = entities[i]
		if ent then
			i = i + 1
		else
			-- move component from the end of the array to the hole
			--print("compact hole")
			entities[i] = entities[self.maxEntities]
			--if entities[i] then entities[i]._handle = i end
			entities[self.maxEntities] = nil
			self.maxEntities = self.maxEntities - 1
		end
	end
	Profiler.endBlock()

	

	-- debug
	--self:verifyComponents()
end

local function arrayIterator(self, i)
	self = proxyToObject(self)
	if not self then error("bad self", 2) end
	local obj
	i,obj = Array.nextItem(self.items, i)
	if i and obj then return i,objectToProxy(obj) end
end

function SurfaceComponent.__proxyClass:contents()
	return arrayIterator, self, 0
end

function SocketComponent.__proxyClass:contents()
	return arrayIterator, self, 0
end

function ContainerItemComponent.__proxyClass:contents()
	return arrayIterator, self, 0
end

-- Fix a game start error due to objects being redefined
local oldParticleComponentUpdateGroundPlane = ParticleComponent.updateGroundPlane
function ParticleComponent:updateGroundPlane()
	if not self.go.map then return end
	oldParticleComponentUpdateGroundPlane(self)
end

-- function Gui:addFloatingText(pos, text, color, heading, duration)
-- 	if type(text) ~= "string" then text = tostring(text) end
	
-- 	color = color or Color.White
-- 	duration = duration or 1.5
	
-- 	-- copy color so that we can fade it out
-- 	color = {color[1], color[2], color[3], color[4]}
	
-- 	local t = { pos = pos, text = text, color = color, heading = heading, timer = 0, duration = duration }
	
-- 	for i=1,math.huge do
-- 		if not self.floatingTexts[i] then
-- 			self.floatingTexts[i] = t
-- 			self.floatingTexts.max = math.max(self.floatingTexts.max or 0, i)
-- 			break
-- 		end
-- 	end
-- end

-- function Gui:updateFloatingTexts()
-- 	local dt = Time.deltaTime
	
-- 	local font = iff(self.tabletMode, FontType.PalatinoSmall, FontType.Palatino)		
-- 	local count = self.floatingTexts.max or 0
	
-- 	for i=1,count do
-- 		local t = self.floatingTexts[i]
-- 		if t then	
-- 			local pos = gameMode:projectPointToScreen(t.pos)
-- 			if pos then
-- 				pos.y = pos.y - t.timer * 30

-- 				-- fade out
-- 				local alpha = 255
-- 				if t.duration > 1 then
-- 					alpha = math.clamp(255 - (t.timer - (t.duration-1)) * 255, 0, 255)
-- 				end
-- 				t.color[4] = alpha

-- 				gui:drawTextCentered(t.text, pos.x, pos.y, FontType.PalatinoBeegScaled, t.color)

-- 				if t.heading then
-- 					gui:drawTextCentered(t.heading, pos.x, pos.y - 30, FontType.PalatinoBeegScaled, Color.White)
-- 				end
-- 			end
			
-- 			t.timer = t.timer + dt

-- 			-- remove old lines
-- 			if t.timer > t.duration then
-- 				self.floatingTexts[i] = nil
-- 			end
-- 		end
-- 	end	
-- end


-- function Gui:setUIScaleFactor(scale)
-- 	scale = math.min(scale, 1)
-- 	if self.uiScaleFactor == scale then return end
	
-- 	self.uiScaleFactor = scale

-- 	-- dispose all scaled fonts
-- 	for k,v in pairs(FontType) do
-- 		if string.match(k, ".*Scaled$") then
-- 			v:dispose()
-- 		end
-- 	end

-- 	FontType.PalatinoScaled = Font.loadTrueType("assets/fonts/palab.ttf", 24 * self.uiScaleFactor, "stroke")
-- 	FontType.PalatinoPlainScaled = Font.loadTrueType("assets/fonts/pala.ttf", 24 * self.uiScaleFactor, "stroke")
-- 	FontType.PalatinoLargeScaled = Font.loadTrueType("assets/fonts/palab.ttf", 30 * self.uiScaleFactor, "stroke")
-- 	FontType.PalatinoBeegScaled = Font.loadTrueType("assets/fonts/palab.ttf", 34 * self.uiScaleFactor, "stroke")
-- 	FontType.ScrollScaled = Font.loadTrueType("assets/fonts/palai.ttf", 18 * self.uiScaleFactor)
-- 	FontType.ScrollTitleScaled = Font.loadTrueType("assets/fonts/palai.ttf", 28 * self.uiScaleFactor)
	
-- 	-- create small font
-- 	-- HACK: size 12 looks terrible in 1280x720
-- 	local size = math.floor(18 * self.uiScaleFactor + 0.5)
-- 	if size == 12 then size = 13 end
-- 	self.emulateSmallFontStroke = (size < 14)
-- 	if self.emulateSmallFontStroke then
-- 		--print("emulating small stroked font")
-- 		FontType.PalatinoSmallScaled = Font.loadTrueType("assets/fonts/palab.ttf", size)
-- 	else
-- 		FontType.PalatinoSmallScaled = Font.loadTrueType("assets/fonts/palab.ttf", size, "stroke")
-- 	end
	
-- 	FontType.PalatinoSmallPlainScaled = Font.loadTrueType("assets/fonts/pala.ttf", size, "stroke")

-- 	-- create tiny font
-- 	local size = 16 * self.uiScaleFactor
-- 	self.emulateTinyFontStroke = (size < 14)	
-- 	if self.emulateTinyFontStroke then
-- 		--print("emulating tiny stroked font")
-- 		FontType.PalatinoTinyScaled = Font.loadTrueType("assets/fonts/palab.ttf", size)
-- 	else
-- 		FontType.PalatinoTinyScaled = Font.loadTrueType("assets/fonts/palab.ttf", size, "stroke")
-- 	end
			
-- 	self.fontStrokeColor = {0,0,0,170}
-- end
