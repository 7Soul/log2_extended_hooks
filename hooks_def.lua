ExtendedHooks = class()

ExtendedHooks.modVersion = "0.3.8b"
ExtendedHooks.modFolder = config.documentsFolder .. "/Mods/hooks/"
ExtendedHooks.gfxFolder = ExtendedHooks.modFolder .. "gfx/"

-- config.developer = true

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
		{ "getAdjacentMonstersTables" },
	},
	hooks = {
		"onCastSpell(self, champion, spell)",
		"onDamage(self, champion, damage, damageType)",
		"onDie(self, champion)",
		"onAttack(self, champion, action, slot)",
		"onLevelUp(self, champion)",
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
		{ "getData" },
		{ "addData", { "string", "number" } },
		{ "getCooldown" },
		{ "setCooldown", "number"},
		{ "addStatFinal", {"string", "number"} },
		{ "giveItem", {"ItemComponent"} },
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
		{ "getData" },
		{ "addData", { "string", "number" } },
		{ "getAIState" },
		{ "getResistanceDamageMultiplier", "string" },
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
		{ "getData" },
		{ "addData", { "string", "number" } },
	},
	hooks = {
		"onThrowAttackHitMonster(self, monster)",
		"onEquipItem(self, champion, slot)",
		"onUnequipItem(self, champion, slot)",
	},
}

local oldDefineSkill = defineSkill
function defineSkill(desc)
	local f = "defineSkill"
	checkNamedArgOpt("skillTraits", desc, f, "table") -- used to display traits in a more organized way
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
	local f = "defineCharClass"
	checkNamedArgOpt("order", desc, f, "number") -- used to put classes in a specific order
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
	checkNamedArgOpt("transformatSurfaceComponention", desc, f, "boolean") --  
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

-- defineProxyClass{
-- 	class = "SurfaceComponent",
-- 	baseClass = "Component",
-- 	description = "A support for placing items. Altars, alcoves and chests are typically surfaces.",
-- 	methods = {
-- 		{ "setDebugDraw", "boolean" },
-- 		{ "setSize", "vec" },
-- 		{ "getDebugDraw" },
-- 		{ "getSize" },
-- 		{ "addItem", "ItemComponent" },
-- 		{ "count" },
-- 		{ "removeItem", "ItemComponent" }, -- new
-- 		-- contents() is defined at the end of this file
-- 	},
-- 	hooks = {
-- 		"onInsertItem(self, item)",
-- 		"onRemoveItem(self, item)",
-- 	},
-- }

-- function SurfaceComponent.__proxyClass:contents()
-- 	return arrayIterator, self, 0
-- end

-- defineProxyClass{
-- 	class = "SocketComponent",
-- 	baseClass = "Component",
-- 	description = "An attachment point for items. Wall hooks, sconces, statue's hand could be sockets. A socket can hold a single item.",
-- 	methods = {
-- 		{ "setDebugDraw", "boolean" },
-- 		{ "getDebugDraw" },
-- 		{ "addItem", "ItemComponent" },
-- 		{ "count", },
-- 		{ "removeItem", "ItemComponent" }, -- new
-- 		-- contents() is defined at the end of this file
-- 		{ "getItem" },
-- 	},
-- 	hooks = {
-- 		"onInsertItem(self, item)",
-- 		"onRemoveItem(self, item)",
-- 		"onAcceptItem(self, item)",
-- 	},
-- }

-- function SocketComponent.__proxyClass:contents()
-- 	return arrayIterator, self, 0
-- end

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
	self:setHerbs()
	self:addCustomComponents(CurrencyComponent)
	self:addCustomComponents(SlideComponent)
	-- self:addCustomComponents(WallObstacleComponent)
	-- self:addCustomComponents(NumberPadComponent)
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
	dungeon:setHerbs()
end

function extendProxyClass(class, prop)
	class.__class.synthesizeProperty(prop)
end

function Dungeon:AddStats()
	table.insert(Stats, "critical_multiplier")
	table.insert(Stats, "critical_chance")
	table.insert(Stats, "dual_wielding")
	table.insert(Stats, "resist_fire_max")
	table.insert(Stats, "resist_cold_max")
	table.insert(Stats, "resist_shock_max")
	table.insert(Stats, "resist_poison_max")
end

function Dungeon:AddStatNames()
	table.insert(ToolTip.toolTips, "Critical Damage")
	table.insert(ToolTip.toolTips, "Critical Chance")
	table.insert(ToolTip.toolTips, "Dual Wielding")
	table.insert(ToolTip.toolTips, "Maximum Fire Resist")
	table.insert(ToolTip.toolTips, "Maximum Cold Resist")
	table.insert(ToolTip.toolTips, "Maximum Shock Resist")
	table.insert(ToolTip.toolTips, "Maximum Poison Resist")
end

function Dungeon:AddToolTips()
	local toolTips = ToolTip.toolTips
	toolTips["Critical Multiplier"] = "Multiplies damage dealt with criticals by the amount displayed."
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