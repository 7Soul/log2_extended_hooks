local oldSkillInit = Skill.init
function Skill:init(desc)
	oldSkillInit(self, desc)
	self.skillTraits = desc.skillTraits
	self.requirements = desc.requirements
	self.classEffect = desc.classEffect
	self.maxLevel = desc.maxLevel
	self.pointsCost = desc.pointsCost
	self.onComputeCritMultiplier = desc.onComputeCritMultiplier
	self.onComputeDamageModifier = desc.onComputeDamageModifier
	self.onComputeDamageMultiplier = desc.onComputeDamageMultiplier
	self.onComputeDualWieldingModifier = desc.onComputeDualWieldingModifier
	self.onComputeChampionAttackDamage = desc.onComputeChampionAttackDamage
	self.onComputeChampionSpellDamage = desc.onComputeChampionSpellDamage
	self.onCheckDualWielding = desc.onCheckDualWielding
	self.onComputePierce = desc.onComputePierce
	self.onCheckBackstab = desc.onCheckBackstab
	self.onComputeItemWeight = desc.onComputeItemWeight
	self.onComputeItemStats = desc.onComputeItemStats
	self.onComputeToHit = desc.onComputeToHit
	self.onRecomputeFinalStats = desc.onRecomputeFinalStats
	self.onComputeSpellCost = desc.onComputeSpellCost
	self.onComputeSpellCooldown = desc.onComputeSpellCooldown
	self.onComputeSpellDamage = desc.onComputeSpellDamage
	self.onCastSpell = desc.onCastSpell
	self.onComputeHerbMultiplicationRate = desc.onComputeHerbMultiplicationRate
	self.onComputeConditionDuration = desc.onComputeConditionDuration
	self.onComputeConditionPower = desc.onComputeConditionPower
	self.onComputeBombPower = desc.onComputeBombPower
	self.onComputeDamageTaken = desc.onComputeDamageTaken
	self.onComputeRange = desc.onComputeRange
	self.onHitTrigger = desc.onHitTrigger
	self.onKillTrigger = desc.onKillTrigger
	self.onCheckWound = desc.onCheckWound
	self.onComputeBuildupTime = desc.onComputeBuildupTime
	self.onComputePowerAttackCost = desc.onComputePowerAttackCost
	self.onComputeSpellCritChance = desc.onComputeSpellCritChance
	self.onComputeSpellCritDamage = desc.onComputeSpellCritDamage
	self.onRegainHealth = desc.onRegainHealth
	self.onRegainEnergy = desc.onRegainEnergy
	self.onCheckRestrictions = desc.onCheckRestrictions
	self.onLevelUp = desc.onLevelUp
	self.onUseItem = desc.onUseItem
	self.onPerformAddedDamage = desc.onPerformAddedDamage
	self.onDataDurationEnds = desc.onDataDurationEnds
	self.onBrewPotion = desc.onBrewPotion
	self.onJamTrigger = desc.onJamTrigger
	self.onPerformAttack = desc.onPerformAttack
	self.onPostAttack = desc.onPostAttack
	self.onEquip = desc.onEquip
	self.onUnequip = desc.onUnequip
	self.onDeathTrigger = desc.onDeathTrigger
end

local oldCharClassInit = CharClass.init
function CharClass:init(desc)
	oldCharClassInit(self,desc)
	self.skillPointsPerLevel = desc.skillPointsPerLevel
	self.skills = desc.skills
end

-------------------------------------------------------------------------------------------------------
-- Party Functions                                                                                   --    
-------------------------------------------------------------------------------------------------------

-- local oldPartyMoveEnter = PartyMove.enter
-- function PartyMove:enter(direction, speed, forcedMovement)
--     oldPartyMoveEnter(self, direction, speed, forcedMovement)

--     if not party:isUnderwater() then
--     -- update herbalism	
-- 		for i=1,4 do
-- 			local champ = party.champions[i]
-- 			champ:updateHerbalismNew()
--         end
--     end
-- 	self.updTimer = 20
-- end

function PartyMove:enter(direction, speed, forcedMovement)
	local party = self.FSM.owner

	self.moveDirection = direction
	self.timer = 0
	self.speed = speed or 1
	self.forcedMovement = forcedMovement

	local map = party.go.map
	local x,y = party.go:getPosition()
	local dx,dy = getDxDy(direction)

	self.originX = x
	self.originY = y

	if party:callHook("onMove", direction) == false then
		self.FSM:setState("idle")
		return
	end
		
	if map:sendMessage("onPartyMove", direction) == "cancel" then
		self.FSM:setState("idle")
		return
	end

	-- overloaded?
	if party:hasCondition("overloaded") or party.pinnedTimer > 0 then
		if not forcedMovement then
			self.FSM:setState("bump", direction, true)
			return
		end
	end

	-- entering stairs?
	if party:isStandingOnStairs() then
		local stairs = StairsComponent.getStairsAt(party.go.map, party.go.x, party.go.y, party.go.elevation)
		if stairs.go.facing == direction then
			self.FSM:setState("enter_stairs", direction, stairs)
			return
		end
	end

	-- entering ladder?
	for _,ladder in map:componentsAt(LadderComponent, x, y) do
        if not ladder.enabled then return end
        if ladder.go.facing == direction and ladder.go:getElevation() == party.go:getElevation()  then
            if ladder.go.facing == party.go.facing  then
                party:climbLadder()
                return
            else
                self.FSM:setState("bump", direction)
                return
            end
        end
	end

    -- Walking into a ladder from behind?
	-- for _,ladder in map:componentsAt(LadderComponent, x+dx, y+dy) do
    --     if not ladder.enabled then return end
	-- 	if (ladder.go.facing+2)%4 == direction and ladder.go:getElevation() == party.go:getElevation()  then
	-- 		self.FSM:setState("bump", direction)
	-- 		return
	-- 	end
	-- end
		
	-- check obstacles
	local obstacleBits = 0xffff - ObstacleBits.Swarm
	if map:checkObstacle(party.go, direction, obstacleBits) and not party.disableCollisions then
		self.FSM:setState("bump", direction)
		return
	end

	-- going off the map?
	if x + dx < 0 or x + dx >= map.width or
	   y + dy < 0 or y + dy >= map.height then
		self.FSM:setState("idle")
		return
	end
		
	-- mark source cell as unoccupied
	party:unoccupyCell()

	-- mark target cell as occupied
	party:occupyCell(x + dx, y + dy)
	
	if party:isUnderwater() then
		soundSystem:playSound2D("party_move_dive")
		party.go.statistics:increaseStat("tiles_dived", 1)
	else
		local tile = map:getTile(x, y)
		soundSystem:playSound2D(tile.moveSound or "party_move")

		if party:hasCondition("burdened") or party:hasCondition("feet_wound") then
			if not forcedMovement then
				soundSystem:playSound2D("party_move_burdened")
			end
		end

		party.go.statistics:increaseStat("tiles_moved", 1)

		-- update herbalism	
		for i=1,4 do
			local ch = party.champions[i]
			ch:updateHerbalismNew()
			-- if ch:hasTrait("alchemist") then
			-- 	ch:updateHerbalism()
			-- end
		end
	end

	messageSystem:sendMessageNEW("onPartyBeginMove", x, y, direction)

	return true
end

local oldPartyComponentInit = PartyComponent.init
function PartyComponent:init(...)
	oldPartyComponentInit(self, ...)

	self.monstersAround = nil -- number of monsters in the 1 tile radius around party
	self.adjacentMonsters = nil -- number of monsters up to 4 tiles from party
	self.adjacentMonstersList = {}
	self.adjacentMonstersDist = {}
	self.aggroMonsters = nil
	self.monsterInFront = nil
end

PartyComponent:dontAutoSerialize("FSM", "swipes", "inputQueue", "champions", "dreams", "camera", "adjacentMonstersList", "adjacentMonstersDist")

function PartyComponent:loadState(file)	
	self.dreams = {}
	
	-- load chunks
	while file:availableBytes() > 0 do
		local id = file:openChunk()	
		if id == "FSM " then
			self.FSM:loadState(file)
		elseif id == "DREA" then
			self.nextDream = file:readValue()
			while file:availableBytes() > 0 do
				self.dreams[#self.dreams+1] = file:readValue()
			end
		elseif id == "MAST" then
			self.monstersAround = file:readValue()
			self.adjacentMonsters = file:readValue()
			self.aggroMonsters = file:readValue()
			self.monsterInFront = file:readValue()
		end
		file:closeChunk()
	end
end

function PartyComponent:saveState(file)
	-- save state
	file:openChunk("FSM ")
	self.FSM:saveState(file)
	file:closeChunk()

	file:openChunk("MAST")
	file:writeValue(self.monstersAround)
	file:writeValue(self.adjacentMonsters)
	file:writeValue(self.aggroMonsters)
	file:writeValue(self.monsterInFront)
	file:closeChunk()
end

local oldPartyComponentUpdate = PartyComponent.update
function PartyComponent:update()
	oldPartyComponentUpdate(self)
	self:updateTargets()
end

function PartyComponent:updateTargets()
	local dir = self.go.facing
	local dx,dy = getDxDy(dir)

	-- Counts monsters that can see the player
	local aggroMonsters = 0
	for entity in self.go.map:allEntities() do
		if entity.monster then
			local monster = entity.monster
			if entity.brain and entity.brain.seesParty and entity.brain.partyOnLevel then
				aggroMonsters = aggroMonsters + 1
			end
		end
	end
	self.aggroMonsters = aggroMonsters

	-- Get the first monster that the party can see in front of it up to 6 tiles away
	local monsterInFront = nil
	for i=1,6 do
		for e in self.go.map:entitiesAt(self.go.x + (dx * i), self.go.y + (dy * i)) do
			if e.monster then
				local canSee = self.go.map:checkLineOfSight(self.go.x, self.go.y, e.x, e.y, self.go.elevation)
				if canSee then
					monsterInFront = e.id
					break
				end
			end
		end
		if monsterInFront then
			break
		end
	end
	self.monsterInFront = monsterInFront

	-- Counts monsters adjacent to party
	local monsterCount = 0
	local monstersAdjacent = 0
	local mList = {}
	local mDist = {}
	local area = {
		0, 0, 0, 0, 5, 5, 5, 0, 0, 0, 0,
		0, 0, 5, 4, 4, 4, 4, 4, 5, 0, 0,
		0, 5, 4, 3, 3, 3, 3, 3, 4, 5, 0,
		0, 4, 3, 2, 2, 2, 2, 2, 3, 4, 0,
		5, 4, 3, 2, 1, 1, 1, 2, 3, 4, 5,
		5, 4, 3, 2, 1, 0, 1, 2, 3, 4, 5,
		5, 4, 3, 2, 1, 1, 1, 2, 3, 4, 5,
		0, 4, 3, 2, 2, 2, 2, 2, 3, 4, 0,
		0, 5, 4, 3, 3, 3, 3, 3, 4, 5, 0,
		0, 0, 5, 4, 4, 4, 4, 4, 5, 0, 0,
		0, 0, 0, 0, 5, 5, 5, 0, 0, 0, 0,
	}
	for area_x = 1, 11 do
		for area_y = 1, 11 do
			local distance = area[area_x + (area_y-1)*11]
			if distance > 0 then
				for e in self.go.map:entitiesAt(self.go.x - 5 + area_x - 1, self.go.y - 5 + area_y - 1) do
					if e.monster then
						if e.brain then
							local sight = self.go.map:checkLineOfSight(e.x, e.y, self.go.x, self.go.y, self.go.elevation)
							if sight then
								local count = e.monstergroup and e.monstergroup.count or 1
								monsterCount = monsterCount + count
								table.insert(mList, e.monster )
								table.insert(mDist, distance  )
								if distance == 1 then
									monstersAdjacent = monstersAdjacent + count
								end
							end
						end
					end
				end
			end
		end
	end

	if monsterCount then
		self.monstersAround = monsterCount
		self.adjacentMonsters = monstersAdjacent
		self.adjacentMonstersList = mList
		self.adjacentMonstersDist = mDist
	else
		self.monstersAround = nil
		self.adjacentMonsters = nil
		self.adjacentMonstersList = nil
		self.adjacentMonstersDist = nil
	end

	-- call hook
	party:callHook("onCheckEnemies", mList, mDist, monsterCount, monstersAdjacent)
end

function PartyComponent:getAggroMonsters()
	return self.aggroMonsters
end

function PartyComponent:getMonstersAround(dist)
	return self.monstersAround
end

function PartyComponent:getAdjacentMonsters()
	return self.adjacentMonsters
end

function PartyComponent:getAdjacentMonstersTables(name)
	if not name or name and name == "list" then
		return self.adjacentMonstersList
	elseif name and name == "distance" then
		return self.adjacentMonstersDist
	end
end

function PartyComponent:getMonsterInFront()
	return self.monsterInFront
end

-- Returns a target champion for an attack coming from specified direction
-- dir = 0=north, 1=east, 2=south, 3=west
-- side = 0=left, 1=right
function PartyComponent:getAttackTarget(dir, side)
	-- rotate direction to local space (0=front, 1=right, 2=back, 3=left)
	dir = (dir - self.go.facing + 4) % 4
	
	-- champion indices:
	-- 12
	-- 34
	local frontRow =
	{
		2, 1,	-- frontal attack
		4, 2, 	-- right side attack
		3, 4,	-- back side attack
		1, 3,	-- left side attack
	}
	
	local backRow =
	{
		4, 3,	-- frontal attack
		3, 1, 	-- right side attack
		1, 2,	-- back side attack
		2, 4,	-- left side attack
	}

	-- target front row
	local c1 = party.champions[frontRow[dir*2+1]]
	local c2 = party.champions[frontRow[dir*2+2]]

	if c1:isAlive() and c2:isAlive() then
		local threat = c1:getCurrentStat("threat_rate") - c2:getCurrentStat("threat_rate")
		local c = iff(side == 0, c1, c2)
		if threat == 0 then return c end
		if threat > 0 then
			if math.random(0, 100) < 25 then
				return c1
			end
			return c2
		else
			if math.random(0, 100) < 25 then
				return c2
			end
			return c1
		end
		return iff(side == 0, c1, c2)
	elseif c1:isAlive() then
		return c1
	elseif c2:isAlive() then
		return c2
	end

	-- target back row (in case the whole front row is dead)
	local c1 = party.champions[backRow[dir*2+1]]
	local c2 = party.champions[backRow[dir*2+2]]
	if c1:isAlive() and c2:isAlive() then
		return iff(side == 1, c1, c2)	
	elseif c1:isAlive() then
		return c1
	else
		return c2
	end
end

-------------------------------------------------------------------------------------------------------
-- Champion Functions                                                                                --    
-------------------------------------------------------------------------------------------------------

local oldChampionInit = Champion.init
function Champion:init(...)
    oldChampionInit(self, ...)
    self:setBaseStat("critical_multiplier", 250)
    self:setBaseStat("critical_chance", 5)
    self:setBaseStat("dual_wielding", 60)
    self:setBaseStat("resist_fire_max", 100)
    self:setBaseStat("resist_cold_max", 100)
    self:setBaseStat("resist_shock_max", 100)
    self:setBaseStat("resist_poison_max", 100)
    self:setBaseStat("threat_rate", 0)
    self:setBaseStat("pierce", 0)
	self.data = {} -- used to easily store new values into a champion
	self.dataDuration = {}
	self.randomSeed = { math.random(1, 65535), math.random(1, 65535), math.random(1, 65535) }
end

local oldChampionUpdate= Champion.update
function Champion:update()
	oldChampionUpdate(self)

	if self.dataDuration ~= {} then
		for k, v in pairs(self.dataDuration) do
			if self.data[k] then
				v = v - Time.deltaTime
				self.dataDuration[k] = v
				if v <= 0 then
					self:triggerOnDataDurationEnd(k, v)
					-- console:print("duration over " .. k)
					self.dataDuration[k] = nil
					self.data[k] = nil
				end
			end
		end
	end
end

function Champion:triggerOnDataDurationEnd(name, value)
	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onDataDurationEnds then
			skill.onDataDurationEnds(objectToProxy(self), name, value, self:getSkillLevel(name))
		end
	end

	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onDataDurationEnds then
			trait.onDataDurationEnds(objectToProxy(self), name, value, iff(self:hasTrait(name), 1, 0))
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onDataDurationEnds then
						comp:onDataDurationEnds(self, name, value)
					end
				end
			end
		end
	end
end

function Champion:randomNumber(n)
	if not n or (n and n < 1) then n = 1 end
	if n > #self.randomSeed then 
		for i=1,n-#self.randomSeed do
			table.insert(self.randomSeed, math.random(1, 65535)) 
		end
	end
	local r = self.randomSeed[n]
	self.randomSeed[n] = (self.randomSeed[n] * 36969 + 321) % 65535
	return r
end

function Champion:setData(name, value)
	self.data[name] = value
end

function Champion:getData(name)
	return self.data[name]
end

function Champion:addData(name, value)
	self.data[name] = (self.data[name] or 0) + value
end

function Champion:setDataDuration(name, value, duration)
	self.data[name] = value
	self.dataDuration[name] = duration
end

function Champion:getDataDuration(name)
	return self.dataDuration[name]
end

function Champion:getCooldown(index)
	if not index then
		return self.cooldownTimer[1], self.cooldownTimer[2]
	else
		return self.cooldownTimer[index]
	end
end

function Champion:setCooldown(index, value)
	self.cooldownTimer[index] = value
end

-- local oldChampionSaveState = Champion.saveState
-- function Champion:saveState(file)
-- 	file:openChunk("CHAM")
-- 	file:writeValue(self.data)
-- 	file:closeChunk()

-- 	oldChampionSaveState(self,file)
-- end

-- local oldChampionLoadState = Champion.loadState
-- function Champion:loadState(file, loadItems)
-- 	local chunkID = file:openChunk()
-- 	assert(chunkID == "CHAM")
-- 	self.data = file:readValue()
-- 	file:closeChunk()

-- 	oldChampionLoadState(self, file, loadItems)
-- end

function Champion:loadState(file, loadItems)
	local chunkID = file:openChunk()
	assert(chunkID == "CHAM")
	
	self.ordinal = file:readValue()
	self.name = file:readValue()
	self.portraitFile = file:readValue()
	self.cooldownTimer[1] = file:readValue()
	self.cooldownTimer[2] = file:readValue()
	self.weaponSet = file:readValue()
	self.skillPoints = file:readValue()
	self.food = file:readValue()
	self.healthiness = file:readValue()
	self.randomSeed = file:readValue()
	self.enabled = file:readValue()
	self.level = file:readValue()
	self.exp = file:readValue()
	
	--print("load champion ", self.name)
		
	-- load race & class
	self:setRace(file:readValue())
	self:setClass(file:readValue())
	
	self.skills = {}
	self.skillPreview = {}
	self.traits = {}

	self:setSex(file:readValue())
	
	while file:availableBytes() > 0 do
		local id = file:openChunk()		
		if id == "STAT" then
			local name = file:readValue()
			if self.stats[name] then
				self.stats[name].base = file:readValue()
				--print(name, self.stats[name].value, self.stats[name].max)
			end
		elseif id == "SEED" then
			self.randomSeed[#self.randomSeed+1] = file:readValue()
		elseif id == "COND" then
			local name = file:readValue()
			local class = Condition.getConditionClass(name)
			if class then
				local cond = class.create(name)
				cond:loadState(file)
				self.conditions[name] = cond
			end
		elseif id == "ITEM" and loadItems then
			local slot = file:readValue()
			local obj = GameObject.create()
			obj:loadState(file)
			self.items[slot] = obj.item
		elseif id == "SKIL" then
			local skill = file:readValue()
			local level = file:readValue()
			self.skills[skill] = level
		elseif id == "SKLP" then
			local skill = file:readValue()
			local level = file:readValue()
			self.skillPreview[skill] = level
		elseif id == "TRAI" then
			self.traits[#self.traits+1] = file:readValue()
		elseif id == "DATA" then
			local name = file:readValue()
			local value = file:readValue()
			self.data[name] = value
		elseif id == "DATB" then
			local name = file:readValue()
			local value = file:readValue()
			if self.dataDuration then
				self.dataDuration[name] = value
			end
		elseif id == "AUTO" then
			self.autoEquipEmptyHand = file:readValue()
			self.autoEquipOffHand = file:readValue()
			self.autoEquipEmptyHand2 = file:readValue()
			self.autoEquipOffHand2 = file:readValue()
		end
		file:closeChunk()
	end
	
	file:closeChunk()
end

function Champion:saveState(file)
	file:openChunk("CHAM")
	file:writeValue(self.ordinal)
	file:writeValue(self.name)
	file:writeValue(self.portraitFile)
	file:writeValue(self.cooldownTimer[1])
	file:writeValue(self.cooldownTimer[2])
	file:writeValue(self.weaponSet)
	file:writeValue(self.skillPoints)
	file:writeValue(self.food)
	file:writeValue(self.healthiness)
	file:writeValue(self.randomSeed)
	file:writeValue(self.enabled)
	file:writeValue(self.level)
	file:writeValue(self.exp)
	file:writeValue(self:getRace())
	file:writeValue(self:getClass())	
	file:writeValue(self:getSex())

	-- save stats
	for i=1,#Stats do
		local s = Stats[i]
		file:openChunk("STAT")
		file:writeValue(s)
		file:writeValue(self.stats[s].base)
		file:closeChunk()
	end

	for _,value in pairs(self.randomSeed) do
		file:openChunk("SEED")
		file:writeValue(value)
		file:closeChunk()
	end

	-- save conditions
	for name,cond in pairs(self.conditions) do
		file:openChunk("COND")
		file:writeValue(name)
		cond:saveState(file)
		file:closeChunk()
	end
	
	-- save equipment
	for i=1,ItemSlot.MaxSlots do
		local it = self.items[i]
		if it then
			file:openChunk("ITEM")
			file:writeValue(i)
			it.go:saveState(file)
			file:closeChunk()
		end
	end
	
	-- save skills
	for skill,level in pairs(self.skills) do
		file:openChunk("SKIL")
		file:writeValue(skill)
		file:writeValue(level)
		file:closeChunk()
	end
	
	-- save skill previews
	for skill,level in pairs(self.skillPreview) do
		file:openChunk("SKLP")
		file:writeValue(skill)
		file:writeValue(level)
		file:closeChunk()
	end

	-- save traits
	for _,name in ipairs(self.traits) do
		file:openChunk("TRAI")
		file:writeValue(name)
		file:closeChunk()
	end
	
	for name,value in pairs(self.data) do
		file:openChunk("DATA")
		file:writeValue(name)
		file:writeValue(value)
		file:closeChunk()
	end
	
	for name,value in pairs(self.dataDuration) do
		file:openChunk("DATB")
		file:writeValue(name)
		file:writeValue(value)
		file:closeChunk()
	end

	-- save auto-pickup state
	if self.autoEquipEmptyHand or self.autoEquipOffHand or autoEquipEmptyHand2 or autoEquipOffHand then
		file:openChunk("AUTO")
		file:writeValue(self.autoEquipEmptyHand)
		file:writeValue(self.autoEquipOffHand)
		file:writeValue(self.autoEquipEmptyHand2)
		file:writeValue(self.autoEquipOffHand2)
		file:closeChunk()
	end

	file:closeChunk()
end

function Champion:giveItem(it)
	for i=ItemSlot.BackpackFirst,ItemSlot.BackpackLast do
		if not self:getItem(i) then 
			self:insertItem(i, it) 
			return true
		end	
	end

	-- remove from map
	if it.go.map then it.go.map:removeEntity(it.go) end
	-- add to map
	local pos = self.go:getWorldPosition()
	local dx,dy = getDxDy(self.go.facing)
	pos.x = pos.x - dx + (math.random() - 0.5)
	pos.z = pos.z - dy + (math.random() - 0.5)

	local x,y = self.go.map:worldToMap(pos)
	local obj = it.go
	it.where = "floor"
	obj.facing = self.go.facing
	obj.inObject = nil
	self.go.map:addEntity(obj, x, y)
	
	it:constrainFloorItem(self.go.map, pos, self.go.elevation)
	obj:setWorldPosition(pos)
	it:startFalling()
	return false
end

function Champion:levelUp()
	if not self.enabled then return end
	
	self.exp = math.max(self.exp, self:expForNextLevel())
	self.level = self.level + 1

	self:addSkillPoints(self.class.skillPointsPerLevel)

	gui:hudPrint(string.format("%s gained a level!", self.name, self.class.level))

	if self:hasTrait("farmer") and self.level >= 10 then
		steamContext:unlockAchievement("gluttony")
	end

	-- onLevelUp triggers
	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onLevelUp then
			if skill.onLevelUp(objectToProxy(self), self:getSkillLevel(name)) == false then return end
		end
	end

	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onLevelUp then
			if trait.onLevelUp(objectToProxy(self), iff(self:hasTrait(name), 1, 0)) == false then return end
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onLevelUp then
						if comp:onLevelUp(self) == false then return end
					end
				end
			end
		end
	end

	-- call onLevelUp hook
	party:callHook("onLevelUp", objectToProxy(self))
	
	-- check for level up again by adding zero xp
	self:gainExp(0)

	if not soundSystem:isPlayedThisFrame("level_up") then soundSystem:playSound2D("level_up") end
end

function Champion:expForLevel(level)
	local tableSize = #Champion.ExperienceTable
	if level < tableSize then
		return Champion.ExperienceTable[level]
	else
		return (level - tableSize - 1) * 1000000
	end
end

function Champion:getSkillLevel(name, slot)
	-- class skill
	if self.class.name == name then return self:getLevel() end

	local level = math.min((self.skills[name] or 0) + self.class:getSkillLevel(name) + self.race:getSkillLevel(name), 5)

	for i=1,ItemSlot.BackpackFirst-1 do
		-- We don't check skill that recursivelly affects the item itself. Ex: an item that requires Concentration but also gives + skill points to Concentration
		if not slot or (slot and slot ~= i) then 
			local it = self:getItem(i)
			if it then
				local equipment = it.go.equipmentitem
				if equipment then
					local modifier = equipment:getSkillModifier(name)
					if modifier ~= 0 and equipment:isEquipped(self, i) then
						level = level + modifier
					end
				end
			end		
		end
	end	

	return level
end

function Champion:setCondition(name, value, power, stacks)
	if value == nil then value = true end
	
	local class = Condition.getConditionClass(name)
	if not class then
		console:warn("invalid condition: "..tostring(name))
		return
	end

	-- remove condition?
	if not value then
		if self.conditions[name] then
			-- condition must be removed first before calling rotateConditions()
			-- so that currentCondition is updated correctly
			self.conditions[name] = nil
			if self.currentCondition == name then self:rotateConditions() end
		end
		return
	end

	if self:isImmuneTo(name) then return end
	
	if value and name ~= "level_up" then
		-- skill hooks
		for skillName,skill in pairs(dungeon.skills) do
			if skill.onReceiveCondition then
				if skill.onReceiveCondition(objectToProxy(self), name, self:getSkillLevel(skillName)) == false then
					return
				end
			end
		end

		-- trait hooks
		for traitName,trait in pairs(dungeon.traits) do
			if trait.onReceiveCondition then
				if trait.onReceiveCondition(objectToProxy(self), name, iff(self:hasTrait(traitName), 1, 0)) == false then
					return
				end
			end
		end

		if party:callHook("onReceiveCondition", objectToProxy(self), name) == false then
			return
		end
	end
	
	local hadCondition = (self.conditions[name] ~= nil)
	
	-- remove old condition
	self.conditions[name] = nil

	-- HACK: restart bear form condition if drinking another bear form potion while in bear form
	if name == "bear_form" then hadCondition = false end

	-- start condition
	if value then
		local cond = class.create(name)
		self.conditions[name] = cond
		cond.power = power or 0
		if stacks then cond.stacks = math.min((self:getConditionStacks(name) or 0) + stacks, cond.maxStacks or 99) end
		if hadCondition then
			if cond.restart then cond:restart(self) end
		else
			if cond.start then cond:start(self) end
		end
	end
end

function Champion:setConditionValue(name, value, power, stacks)
	-- Now takes more optional parameters
	local curStacks = self:getConditionStacks(name) or 0
	self:setCondition(name, value > 0, power, stacks)

	local cond = self.conditions[name]
	if cond then 
		cond.value = value
		if power then cond.power = power * self:getConditionPower(cond) end
		if stacks then cond.stacks = math.min(curStacks + stacks, cond.maxStacks or 99) end
		if cond.restart then cond:restart(self) end
	end
end

function Champion:getConditionStacks(name)
	local cond = self.conditions[name]
	if cond then return cond.stacks end
end

function Champion:setConditionStacks(name, value)
	local cond = self.conditions[name]
	if cond then 
		cond.stacks = value 
		if cond.stacks <= 0 then
			self:removeCondition(name)
		else
			if cond.restart then cond:restart(self) end
		end
	end
end

function Champion:getConditionDuration(condition)
	local multi = 1
	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onComputeConditionDuration then
            local modifier = skill.onComputeConditionDuration(objectToProxy(condition), objectToProxy(self), condition.name, condition.beneficial, condition.harmful, condition.transformation, self:getSkillLevel(name))
            multi = multi * (modifier or 1)
		end
	end

	-- traits modifiers
    for name,trait in pairs(dungeon.traits) do
		if trait.onComputeConditionDuration then
            local modifier = trait.onComputeConditionDuration(objectToProxy(condition), objectToProxy(self), condition.name, condition.beneficial, condition.harmful, condition.transformation, iff(self:hasTrait(name), 1, 0))
            multi = multi * (modifier or 1)
		end
	end

	-- equipment modifiers (equipped items only)
    for i=1,ItemSlot.BackpackFirst-1 do
        local it = self:getItem(i)
        if it then
            if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
                for i=1,it.go.components.length do
                    local comp = it.go.components[i]
                    if comp.onComputeConditionDuration then
                        multi = multi * (comp:onComputeConditionDuration(condition, self, condition.name, condition.beneficial, condition.harmful, condition.transformation) or 1)
                    end
                end
            end
        end
	end
	-- When energy cost is used, the multiplier is inverted
	if condition.tickMode == "energy" then
		multi = 1 - multi
	end
	return multi
end

function Champion:getConditionPower(condition)
	local multi = 1
	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onComputeConditionPower then
            local modifier = skill.onComputeConditionPower(objectToProxy(condition), objectToProxy(self), condition.name, condition.beneficial, condition.harmful, condition.transformation, self:getSkillLevel(name))
            multi = multi * (modifier or 1)
		end
	end

	-- traits modifiers
    for name,trait in pairs(dungeon.traits) do
		if trait.onComputeConditionPower then
            local modifier = trait.onComputeConditionPower(objectToProxy(condition), objectToProxy(self), condition.name, condition.beneficial, condition.harmful, condition.transformation, iff(self:hasTrait(name), 1, 0))
            multi = multi * (modifier or 1)
		end
	end

	-- equipment modifiers (equipped items only)
    for i=1,ItemSlot.BackpackFirst-1 do
        local it = self:getItem(i)
        if it then
            if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
                for i=1,it.go.components.length do
                    local comp = it.go.components[i]
                    if comp.onComputeConditionPower then
                        multi = multi * (comp:onComputeConditionPower(condition, self, condition.name, condition.beneficial, condition.harmful, condition.transformation) or 1)
                    end
                end
            end
        end
	end
	return multi
end

function Champion:getCooldownWithAttack(weapon, attack, attackType)
	local multi = 1
	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onComputeCooldown then
			local modifier = skill.onComputeCooldown(objectToProxy(self), objectToProxy(weapon), attack and objectToProxy(attack), attackType, self:getSkillLevel(name))
			multi = multi * (modifier or 1)
		end
	end

	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onComputeCooldown then
			local modifier = trait.onComputeCooldown(objectToProxy(self), objectToProxy(weapon), attack and objectToProxy(attack), attackType, iff(self:hasTrait(name), 1, 0))
			multi = multi * (modifier or 1)
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onComputeCooldown then
						local modifier = comp:onComputeCooldown(self, weapon, attack, attackType)
						multi = multi * (modifier or 1)
					end
				end
			end
		end
	end

	return multi
end

function Champion:getMalfunctionChanceWithAttack(weapon, attack, attackType)
	local multi = 1
	-- traits modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onComputeMalfunctionChance then
			local modifier = trait.onComputeMalfunctionChance(objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), attackType, iff(self:hasTrait(name), 1, 0))
			multi = multi * (modifier or 1)
		end
	end

	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onComputeMalfunctionChance then
			local modifier = skill.onComputeMalfunctionChance(objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), attackType, self:getSkillLevel(name))
			multi = multi * (modifier or 1)
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onComputeMalfunctionChance then
						local modifier = comp:onComputeMalfunctionChance(self, weapon, attack, attackType)
						multi = multi * (modifier or 1)
					end
				end
			end
		end
    end

	return multi
end

function Champion:getCooldownWithSpell(spell)
	local multi = 1
	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onComputeSpellCooldown then
			local modifier = skill.onComputeSpellCooldown(objectToProxy(self), spell.name, spell.manaCost, spell.skill, self:getSkillLevel(name))
			multi = multi * (modifier or 1)
		end
	end
	
	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onComputeSpellCooldown then
			local modifier = trait.onComputeSpellCooldown(objectToProxy(self), spell.name, spell.manaCost, spell.skill, iff(self:hasTrait(name), 1, 0))
			multi = multi * (modifier or 1)
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onComputeSpellCooldown then
						local modifier = comp:onComputeSpellCooldown(self, spell.name, spell.manaCost, spell.skill)
						multi = multi * (modifier or 1)
					end
				end
			end
		end
	end

	return multi
end

function Champion:getAccuracyWithAttack(weapon, attack, target)
    -- Updated to having the target of the attack as an optional parameter
	if not attack then return 0 end

	-- check skill level requirement
	if attack.skill and attack.requiredLevel and self:getSkillLevel(attack.skill) < attack.requiredLevel then
		return nil
	end

	local accuracy = attack.accuracy or 0

	-- dexterity bonus
	accuracy = accuracy + self:getAccuracyFromDexterity()
	
	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onComputeAccuracy then
			local modifier = skill.onComputeAccuracy(objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType(), self:getSkillLevel(name), objectToProxy(target))
			accuracy = accuracy + (modifier or 0)
		end
	end

	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onComputeAccuracy then
			local modifier = trait.onComputeAccuracy(objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType(), iff(self:hasTrait(name), 1, 0), objectToProxy(target))
			accuracy = accuracy + (modifier or 0)
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onComputeAccuracy then
						local modifier = comp:onComputeAccuracy(self, weapon, attack, attackType, target)
						accuracy = accuracy + (modifier or 0)					
					end
				end
			end
		end
	end

	-- conditions
	if self:hasCondition("blind") or self:hasCondition("head_wound") then accuracy = accuracy - 50 end
	
	return math.floor(accuracy)
end

function Champion:getToHitChanceWithAttack(weapon, attack, target, accuracy, damageType)
    if not accuracy then accuracy = champion:getAccuracyWithAttack(weapon, attack, target) end
	local evasion = target.evasion
    local tohit = 60 + accuracy - (evasion or 0)
    tohit = tohit + self.luck + (target:hasCondition("isolated") and 10 or 0)
    tohit = math.clamp(tohit, 5, 95)
	if not attack then return tohit end

    -- skill modifiers
    for name,skill in pairs(dungeon.skills) do
		if skill.onComputeToHit then
			local attackType = attack and attack:getAttackType()
            local modifier = skill.onComputeToHit(objectToProxy(target), objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), attackType, damageType, tohit, self:getSkillLevel(name))
            tohit = modifier or tohit
        end
    end

    -- trait modifiers
    for name,trait in pairs(dungeon.traits) do
		if trait.onComputeToHit then
			local attackType = attack and attack:getAttackType()
            local modifier = trait.onComputeToHit(objectToProxy(target), objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), attackType, damageType, tohit, iff(self:hasTrait(name), 1, 0))
            tohit = modifier or tohit
        end
    end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onComputeToHit then
						local modifier = comp:onComputeToHit(target, champion, weapon, attack, attackType, damageType, tohit)
						tohit = modifier or tohit
					end
				end
			end
		end
	end

    return tohit
end

function Champion:getAccuracyFromDexterity()
    return (self:getCurrentStat("dexterity") - 10) * 2
end

function Champion:getCritChanceWithAttack(weapon, attack, target)
    -- Updated to having the target of the attack as an optional parameter
	if not attack then return 3 end
    
	-- check skill level requirement
	if attack.skill and attack.requiredLevel and self:getSkillLevel(attack.skill) < attack.requiredLevel then
		return nil
	end

	local critChance = self.stats.critical_chance.current + (attack.critChance or 0)
	
	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onComputeCritChance then
			local modifier = skill.onComputeCritChance(objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType(), self:getSkillLevel(name), objectToProxy(target), self:getAccuracyWithAttack(weapon, attack, target))
			critChance = critChance + (modifier or 0)
		end
	end
	
	-- traits modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onComputeCritChance then
			local modifier = trait.onComputeCritChance(objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType(), iff(self:hasTrait(name), 1, 0), objectToProxy(target), self:getAccuracyWithAttack(weapon, attack, target))
			critChance = critChance + (modifier or 0)
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onComputeCritChance then
						local modifier = comp:onComputeCritChance(self, weapon, attack, target)
						critChance = critChance + (modifier or 0)
					end
				end
			end
		end
	end
	
	critChance = math.clamp(critChance, 0, 100)

	return critChance
end

function Champion:getCritChanceWithSpell(spell, damageType, target)
	-- check skill level requirement
	if spell.skill and spell.requiredLevel and self:getSkillLevel(spell.skill) < spell.requiredLevel then
		return nil
	end
	local critChance = self.stats.critical_chance.current

	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onComputeSpellCritChance then
			local modifier = skill.onComputeSpellCritChance(objectToProxy(self), damageType, objectToProxy(target), self:getSkillLevel(name))
			critChance = critChance + (modifier or 0)
		end
	end
	
	-- traits modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onComputeSpellCritChance then
			local modifier = trait.onComputeSpellCritChance(objectToProxy(self), damageType, objectToProxy(target), iff(self:hasTrait(name), 1, 0))
			critChance = critChance + (modifier or 0)
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onComputeSpellCritChance then
						local modifier = comp:onComputeSpellCritChance(self, damageType, target)
						critChance = critChance + (modifier or 0)
					end
				end
			end
		end
	end

	critChance = math.clamp(critChance, 0, 100)

	return critChance
end

function Champion:getCritMultiplierWithAttack(weapon, attack, target)
    -- New function to deal with changing the crit damage multiplier
	if not attack then return 250 end

	-- check skill level requirement
	if attack and attack.skill and attack.requiredLevel and self:getSkillLevel(attack.skill) < attack.requiredLevel then
		return nil
	end

	local critMulti = (self.stats.critical_multiplier.current + (attack.critMultiplier or 0))

	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onComputeCritMultiplier then
			local modifier = skill.onComputeCritMultiplier(objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType(), self:getSkillLevel(name), objectToProxy(target), self:getAccuracyWithAttack(weapon, attack, target))
			critMulti = critMulti + (modifier or 0)
		end
	end
	
	-- traits modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onComputeCritMultiplier then
			local modifier = trait.onComputeCritMultiplier(objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType(), iff(self:hasTrait(name), 1, 0), objectToProxy(target), self:getAccuracyWithAttack(weapon, attack, target))
			critMulti = critMulti + (modifier or 0)
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onComputeCritMultiplier then
						critMulti = critMulti + (comp:onComputeCritMultiplier(self, weapon, attack, target) or 0)
					end
				end
			end
		end
	end

	critMulti = math.clamp(critMulti, 0, 1000)

	return critMulti
end

function Champion:getCritMultiplier(slot)
	assert(slot, "missing param 'slot'")
	
	local action = self:getPrimaryAction(slot)
	if action and action.getAttackType then
		local weapon = self:getItem(slot)
		if self:hasCondition("bear_form") then weapon = nil end
		return self:getCritMultiplierWithAttack(weapon, action)
	end
end

function Champion:getCritMultiplierText(slot)
	local crit = self:getCritMultiplier(slot)
	if crit then
		return (crit/100).."x"
	else
		return "--"
	end
end

function Champion:getTwoHanded(slot)
	local item = self:getItem(slot)
	return item and item:hasTrait("two_handed") and not self:hasTrait("two_handed_mastery")
end

function Champion:getDamageText(slot)
	-- when wielding a 2-handed weapon, the stats page should display same damage for the secondary hand
	local item = self:getItem(slot)
	if (slot == ItemSlot.Weapon or slot == ItemSlot.OffHand) and not item then
		local otherSlot = iff(slot == ItemSlot.Weapon, ItemSlot.OffHand, ItemSlot.Weapon)
		if otherItem and self:getTwoHanded(otherSlot) then
			slot = otherSlot
		end
	end

	local power,mod,var = self:getDamage(slot)
	if power then
		local min,max = getDamageRange(power, mod, var)
		return min.." - "..max
	else
		return "--"
	end
end

function Champion:getDamageWithWeapon(item)
	local attack = item:getPrimaryAction()
	assert(attack, "Missing primary action")
	if attack then attack = item.go:getComponent(attack) end
	return computeDamage(self:getDamageWithAttack(item, attack))
end

-- Returns attack power and damage modifier for an attack.
function Champion:getDamageWithAttack(weapon, attack, addedDamage)
    -- Some hard coded effects were turned into trait/skill hooks such as weapon skill bonus and dual wielding penalty
    -- Added the ability to alter damage via hooks and to affect that variation of damage calculated, instead of being always -50% and +50%

	-- check skill level requirement
	if attack.skill and attack.requiredLevel and self:getSkillLevel(attack.skill) < attack.requiredLevel then
		return nil
	end

	local power = attack:getAttackPower() or 0
	local mod = {attack:getMinDamageMod() or 0, attack:getMaxDamageMod() or 0}
	local variation = attack.attackPowerVariation or 0.5
	
	if party:isHookRegistered("onCalculateDamageWithAttack") then
		power = party:callHook("onCalculateDamageWithAttack", objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), power)
	end

	-- dual wield penalty
	if weapon and self:isDualWielding() then
		dualWieldingMulti = self:getCurrentStat("dual_wielding") / 100
		for name,skill in pairs(dungeon.skills) do
			if skill.onComputeDualWieldingModifier then
				local modifier = skill.onComputeDualWieldingModifier(objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType(), self:getSkillLevel(name))
				critMulti = critMulti + (modifier or 0)
			end
		end

		for name,trait in pairs(dungeon.traits) do
			if trait.onComputeDualWieldingModifier then
				local modifier = trait.onComputeDualWieldingModifier(objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType(), iff(self:hasTrait(name), 1, 0))
				dualWieldingMulti = dualWieldingMulti + (modifier or 0)
			end
		end

		-- equipment modifiers (equipped items only)
		for i=1,ItemSlot.BackpackFirst-1 do
			local it = self:getItem(i)
			if it then
				if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
					for i=1,it.go.components.length do
						local comp = it.go.components[i]
						if comp.onComputeDualWieldingModifier then
							local modifier = comp:onComputeDualWieldingModifier(self, weapon, attack)
							dualWieldingMulti = dualWieldingMulti + (modifier or 0)
						end
					end
				end
			end
		end
		power = power * dualWieldingMulti
	end

	-- str/dex stat modifier
	local baseStat = attack:getBaseDamageStat()
	local baseMulti = attack:getBaseDamageMultiplier() or 1
	if baseStat then
		mod[1] = mod[1] + math.floor(math.max((self:getCurrentStat(baseStat) - 10),0) * baseMulti)
		mod[2] = mod[2] + math.floor(math.max((self:getCurrentStat(baseStat) - 10),0) * baseMulti)
	end
		
	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onComputeDamageModifier then
			local modifier = skill.onComputeDamageModifier(objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType(), self:getSkillLevel(name))
			if type(modifier) == "number" then
				if modifier > 0 and modifier < 1 then
					mod[1] = math.floor((attack:getAttackPower() * -0.5 * (modifier or 1)) + 0.5)
					mod[2] = math.floor((attack:getAttackPower() * -1.5 * (modifier or 1)) + 0.5)
				else
					mod[1] = mod[1] + (modifier or 0)
					mod[2] = mod[2] + (modifier or 0)
				end
			elseif type(modifier) == "table" then
				if modifier[1] > 0 and modifier[1] < 1 then
					mod[1] = math.floor((attack:getAttackPower() * -0.5 * (modifier[1] or 1)) + 0.5)
				else
					mod[1] = mod[1] + (modifier[1] or 0)
				end
				if modifier[2] > 0 and modifier[2] < 1 then
					mod[1] = math.floor((attack:getAttackPower() * -1.5 * (modifier[2] or 1)) + 0.5)
				else
					mod[2] = mod[2] + (modifier[2] or 0)
				end
			end
		end

		if skill.onComputeDamageMultiplier then
			local modifier = skill.onComputeDamageMultiplier(objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType(), self:getSkillLevel(name))
			mod[1] = mod[1] * (modifier or 1)
			mod[2] = mod[2] * (modifier or 1)
			power = power * (modifier or 1)
		end
	end
				
	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onComputeDamageModifier then
			local modifier = trait.onComputeDamageModifier(objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType(), iff(self:hasTrait(name), 1, 0))
			if type(modifier) == "number" then
				if modifier > 0 and modifier < 1 then
					mod[1] = math.floor((attack:getAttackPower() * -0.5 * (modifier or 1)) + 0.5)
					mod[2] = math.floor((attack:getAttackPower() * -1.5 * (modifier or 1)) + 0.5)
				else
					mod[1] = mod[1] + (modifier or 0)
					mod[2] = mod[2] + (modifier or 0)
				end
			elseif type(modifier) == "table" then
				if modifier[1] > 0 and modifier[1] < 1 then
					mod[1] = math.floor((attack:getAttackPower() * -0.5 * (modifier[1] or 1)) + 0.5)
				else
					mod[1] = mod[1] + (modifier[1] or 0)
				end
				if modifier[2] > 0 and modifier[2] < 1 then
					mod[1] = math.floor((attack:getAttackPower() * -1.5 * (modifier[2] or 1)) + 0.5)
				else
					mod[2] = mod[2] + (modifier[2] or 0)
				end
			end
		end

		if trait.onComputeDamageMultiplier then
			local modifier = trait.onComputeDamageMultiplier(objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType(), iff(self:hasTrait(name), 1, 0))
			mod[1] = mod[1] * (modifier or 1)
			mod[2] = mod[2] * (modifier or 1)
			power = power * (modifier or 1)
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onComputeDamageModifier then
						local modifier = comp:onComputeDamageModifier(self, weapon, attack)
						if type(modifier) == "number" then
							if modifier > 0 and modifier < 1 then
								mod[1] = math.floor((attack:getAttackPower() * -0.5 * (modifier or 1)) + 0.5)
								mod[2] = math.floor((attack:getAttackPower() * -1.5 * (modifier or 1)) + 0.5)
							else
								mod[1] = mod[1] + (modifier or 0)
								mod[2] = mod[2] + (modifier or 0)
							end
						elseif type(modifier) == "table" then
							if modifier[1] > 0 and modifier[1] < 1 then
								mod[1] = math.floor((attack:getAttackPower() * -0.5 * (modifier[1] or 1)) + 0.5)
							else
								mod[1] = mod[1] + (modifier[1] or 0)
							end
							if modifier[2] > 0 and modifier[2] < 1 then
								mod[1] = math.floor((attack:getAttackPower() * -1.5 * (modifier[2] or 1)) + 0.5)
							else
								mod[2] = mod[2] + (modifier[2] or 0)
							end
						end
					end
					if comp.onComputeDamageMultiplier then
						local modifier = comp:onComputeDamageMultiplier(self, weapon, attack)
						mod[1] = mod[1] * (modifier or 1)
						mod[2] = mod[2] * (modifier or 1)
						power = power * (modifier or 1)
					end
					-- if weapon and it.go == weapon.go then
					-- 	if comp.minDamageMod  then
					-- 		mod[1] = mod[1] + comp.minDamageMod
					-- 	end
					-- 	if comp.maxDamageMod then
					-- 		mod[2] = mod[2] + comp.maxDamageMod
					-- 	end
				end
				if it.go.equipmentitem and not addedDamage then
					mod[1] = mod[1] + (it.go.equipmentitem.minDamageMod or 0)
					mod[2] = mod[2] + (it.go.equipmentitem.maxDamageMod or 0)
				end
			end
		end
	end

	-- ammo bonus for missile weapons
	if attack:getAttackType() == "missile" then
		local slot = iff(self:getItem(ItemSlot.Weapon) == weapon, ItemSlot.Weapon, ItemSlot.OffHand)
		local ammo = self:getOtherHandItem(slot)
		if ammo and attack:checkAmmo(self, slot) then
			local ammoItem = ammo.go.ammoitem
			if ammoItem then
				--print("ammo bonus: ", ammoItem:getAttackPower() or 0)
				mod[1] = mod[1] + (ammoItem:getAttackPower() or 0)
				mod[2] = mod[2] + (ammoItem:getAttackPower() or 0)
			end
		end
	end

	-- conditions
	if self:hasCondition("starving") then power = power / 2 end

	power = math.max(math.floor(power+0.5), 0)

	mod[1] = math.floor(mod[1]+0.5)
	mod[2] = math.floor(mod[2]+0.5)

	mod[1] = math.min(mod[1], mod[2]-1)
	
	return power,mod,variation
end

function Champion:updateHerbalism()
    -- We no longer use this function, since it's only called for the alchemist class
    return
end

function Champion:updateHerbalismNew()
    if not self:hasTrait("herb_multiplication") then return end -- herb multiplication no longer tied to alchemist class
    local multi = { 1, 1, 1, 1, 1, 1 }
	local herbRates = {
		["blooddrop_cap"] = 850,
		["etherweed"] = 930,
		["mudwort"] = 1950,
		["falconskyre"] = 2500,
		["blackmoss"] = 3700,
		["crystal_flower"] = 4500,
	}

    -- Herb multiplication can be canceled. For example, you could make them not multiply during the day, or increase the rate while under water
    local tilesMoved = party.go.statistics:getStat("tiles_moved")
    local returnVal = party:callHook("onMultiplyHerbs", herbRates, objectToProxy(champion)) 
    if returnVal then
        if returnVal[1] == false then return false end
        herbRates = returnVal[2] or herbRates
    end

    for name,skill in pairs(dungeon.skills) do
		if skill.onComputeHerbMultiplicationRate then
            local modifier = skill.onComputeHerbMultiplicationRate(objectToProxy(self), self:getSkillLevel(name))
			if modifier then
				assert(type(modifier)=="table" and modifier[6], "Bad onComputeHerbMultiplicationRate return value")
				if modifier and type(modifier) == "table" then
					for i = 1, 6 do 
						multi[i] = multi[i] * (modifier[i] or 1)
					end
				end
			end
		end
	end

    for name,trait in pairs(dungeon.traits) do
		if trait.onComputeHerbMultiplicationRate then
            local modifier = trait.onComputeHerbMultiplicationRate(objectToProxy(self), iff(self:hasTrait(name), 1, 0))
			if modifier then
				assert(type(modifier)=="table" and modifier[6], "Bad onComputeHerbMultiplicationRate return value")
				if modifier and type(modifier) == "table" then
					for i = 1, 6 do 
						multi[i] = multi[i] * (modifier[i] or 1)
					end
				end
			end
		end
	end

    local i = 1
	for herb,rate in pairs(herbRates) do
		-- check growth rate
		if (tilesMoved % math.floor(rate * multi[i])) == 0 then
			self:updateHerbalism2(herb)
        end
        i = i + 1
	end
end

function Champion:updateHerbalism2(herb)
	-- Updated because containers can now have different numbers of slots
	-- multiply herbs in backpack
	for i=ItemSlot.BackpackFirst,ItemSlot.BackpackLast do
		local it = self:getItem(i)
		if it and it.go.arch.name == herb then
			-- find nearest empty slot
			local slot
			local minDist = 10000
			for j=ItemSlot.BackpackFirst,ItemSlot.BackpackLast do
				if self:getItem(j) == nil then
					local sx1 = (i - ItemSlot.BackpackFirst) % 4
					local sy1 = math.floor((i - ItemSlot.BackpackFirst) / 4)
					local sx2 = (j - ItemSlot.BackpackFirst) % 4
					local sy2 = math.floor((j - ItemSlot.BackpackFirst) / 4)
					local dist = math.abs(sx2 - sx1) + math.abs(sy2 - sy1)
					if dist < minDist then
						slot = j
						minDist = dist
					end
				end
			end

			if slot then
				local newHerb = it:splitStack(1)
				self:insertItem(slot, newHerb)
			end

			it:setStackSize(it:getStackSize() + 1)
			return
		end
	
		-- multiply herbs in containers
		if it and it.go.containeritem then
			local container = it.go.containeritem
			for j=1,container:getCapacity() do
				local it = container:getItem(j)
				if it and it.go.arch.name == herb then
					-- find nearest empty slot
					local slot
					local minDist = 10000
					local containerWidth = container.slots and math.ceil(math.sqrt(container.slots)) or iff(container:getContainerType() == "chest", 4, 3)
					for k=1,container:getCapacity() do
						if container:getItem(k) == nil then
							local sx1 = (j - 1) % containerWidth
							local sy1 = math.floor((j - 1) / containerWidth)
							local sx2 = (k - 1) % containerWidth
							local sy2 = math.floor((k - 1) / containerWidth)
							local dist = math.abs(sx2 - sx1) + math.abs(sy2 - sy1)
							if dist < minDist then
								slot = k
								minDist = dist
							end
						end
					end

					if slot then
						local newHerb = it:splitStack(1)
						container:insertItem(slot, newHerb)
					end

					it:setStackSize(it:getStackSize() + 1)
					return
				end
			end
		end			
	end
end

function Champion:isDualWielding()
    -- Completely reworked to take this info from traits and equipment

	local isDualWielding = false
	local weapon1 = self:getItem(ItemSlot.Weapon)
	local weapon2 = self:getItem(ItemSlot.OffHand)

	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onCheckDualWielding then
			isDualWielding = isDualWielding or skill.onCheckDualWielding(objectToProxy(self), objectToProxy(weapon1), objectToProxy(weapon2),  self:getSkillLevel(name))
		end
	end
				
	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onCheckDualWielding then
			isDualWielding = isDualWielding or trait.onCheckDualWielding(objectToProxy(self), objectToProxy(weapon1), objectToProxy(weapon2), iff(self:hasTrait(name), 1, 0))
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onCheckDualWielding then
						isDualWielding = isDualWielding or comp:onCheckDualWielding(self, weapon1, weapon2)
					end
				end
			end
		end
	end

	return isDualWielding
end

function Champion:attack(slot, powerAttack)
	local item = self:getItem(slot)
	if self:hasCondition("bear_form") then item = nil end
	
	local action
	if not item then
		action = self:getUnarmedAttack()
	elseif powerAttack then
		action = self:getSecondaryAction(slot)
	else
		action = self:getPrimaryAction(slot)
	end
	
	if not action then return end

	-- disable unarmed attacks when holding a two-handed weapon
	if not item then
		local otherItem = self:getOtherHandItem(slot)
		if otherItem and otherItem:hasTrait("two_handed") and not self:hasTrait("two_handed_mastery") then
			return
		end
	end
	
	-- check weapon skill level requirement
	if item and not item:canBeUsedByChampion(self, slot) then
		self:showAttackResult("Can't use")
		return
	end

	-- can't attack with a broken hand
	local attackType = action.attackType and action:getAttackType()
	if (slot == ItemSlot.Weapon and self:checkWound("right_hand_wound", action, action.name, attackType)) or (slot == ItemSlot.OffHand and self:checkWound("left_hand_wound", action, action.name, attackType)) then
		self:showAttackResult("Can't use")
		return
	end

	-- can't attack with 2-handed weapon if one of the hands is broken
	if item and item:hasTrait("two_handed") and not self:hasTrait("two_handed_mastery") then
		if self:checkWound("left_hand_wound", action, action.name, attackType) or self:checkWound("right_hand_wound", action, action.name, attackType) then
		   	self:showAttackResult("Can't use") 
		   	return
		end
	end

	local tRepeatCount = 0
	local tRepeatDelay = 0.2
	if party:isHookRegistered("onAttack") and action ~= self:getUnarmedAttack() then
		local rval = party:callHook("onAttack", objectToProxy(self), objectToProxy(action), slot, tRepeatCount, tRepeatDelay)
		if rval then
			if rval[1] == false then return end
			tRepeatCount = rval[2] or tRepeatCount
			if rval[3] and tRepeatDelay == 0.2 then
				tRepeatDelay = rval[3]
			end
		end
	end

	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onPerformAttack then
			local rval = skill.onPerformAttack(objectToProxy(self), objectToProxy(action), slot, self:getSkillLevel(name))
			if rval then
				if rval[1] == false then return end
				tRepeatCount = tRepeatCount + rval[2]
				if rval[3] and tRepeatDelay == 0.2 then
					tRepeatDelay = rval[3]
				end
			end
		end
	end
				
	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onPerformAttack then
			local rval = trait.onPerformAttack(objectToProxy(self), objectToProxy(action), slot, iff(self:hasTrait(name), 1, 0))
			if rval then
				if rval[1] == false then return end
				tRepeatCount = tRepeatCount + rval[2]
				if rval[3] and tRepeatDelay == 0.2 then
					tRepeatDelay = rval[3]
				end
			end
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onPerformAttack then
						local rval = comp:onPerformAttack(self, action, slot)
						if rval then
							if rval[1] == false then return end
							tRepeatCount = tRepeatCount + rval[2]
							if rval[3] and tRepeatDelay == 0.2 then
								tRepeatDelay = rval[3]
							end
						end
					end
				end
			end
		end
	end

	if action ~= self:getUnarmedAttack() and action:callHook("onAttack", objectToProxy(self), slot, 0) == false then
		return
	end
		
	if action.start then action:start(self, slot, 0) end

	if powerAttack then party.go.statistics:increaseStat("power_attacks", 1) end

	self:addData("attack_count", 1)
	
	-- chain action
	if action.chainAction then
		local next = action:getNextChainAction()
		if next then
			self.pendingAttack = {
				action = next,
				slot = slot,
				time = action.chainActionDelay or 0.2,
				chainIndex = 1,
			}
		end
	end

	-- repeat action
	if (action.repeatCount and action.repeatCount > 1) or tRepeatCount > 0 then
		local delay = action.repeatDelay or 0.2
		self.pendingAttack = {
			action = action,
			slot = slot,
			time = delay,
			chainIndex = 1,
			repeatCount = tRepeatCount + (action.repeatCount or 0) - 1,
			repeatDelay = delay,
		}
	end

	-- double throw
	if self:hasTrait("double_throw") and action.getAttackType and action:getAttackType() == "throw" and self.pendingAttack == nil then
		local otherItem = self:getOtherHandItem(slot)
		if otherItem and otherItem.go.throwattack then
			self.pendingAttack = {
				action = otherItem.go.throwattack,
				slot = iff(slot == ItemSlot.Weapon, ItemSlot.OffHand, ItemSlot.Weapon),
				time = 0.2
			}			
		end
	end

	self:triggerPostAttack(item, action, slot)
end

function Champion:triggerPostAttack(weapon, action, slot)
	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onPostAttack then
			skill.onPostAttack(objectToProxy(self), objectToProxy(weapon), objectToProxy(action), slot, self:getSkillLevel(name))
		end
	end
				
	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onPostAttack then
			trait.onPostAttack(objectToProxy(self), objectToProxy(weapon), objectToProxy(action), slot, iff(self:hasTrait(name), 1, 0))
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onPostAttack then
						comp:onPostAttack(self, weapon, action, slot)
					end
				end
			end
		end
	end
end

function Champion:damage(...)
	local args = {...}
	-- console:print(unpack(args));
	self.damageComplex(self, ...)
end

function Champion:damageComplex(dmg, damageType, hitContext, attacker)
	-- console:print(debug.getinfo(1, "n").name,debug.getinfo(2, "n").name,debug.getinfo(3, "n").name,debug.getinfo(4).name,debug.getinfo(5, "n").name,debug.getinfo(6, "n").name)
	damageType = damageType or "physical"
	dmg = math.floor(dmg)
    local isSpell = hitContext and (hitContext.go.tiledamager or hitContext.go.cloudspell)
	local attackerType
	if attacker then
		if attacker.go.monster then
			attackerType = "monster"
		elseif attacker.go.projectile then
			attackerType = "projectile"
		end
	end
	if debug.getinfo(4, "n").name == "updateConditions" then
		attackerType = "dot"
	end
	if damageType == "dispel" then return end
	
	if self:isAlive() and not self:hasCondition("petrified") then
		-- apply damage resistance
		if damageType ~= "physical" and damageType ~= "drowning" and damageType ~= "pure" then
			local resist = self:getResistance(damageType)
			if resist == 100 then
				dmg = 0
			elseif resist > 0 then
				dmg = math.floor(dmg * (100 - resist) / 100 + 0.5)
			end
		end
		
		local onDamageReturn = party:callHook("onDamage", objectToProxy(self), dmg, damageType, objectToProxy(hitContext))
		if onDamageReturn then
			dmg = dmg + onDamageReturn[2]
			if onDamageReturn[1] == false then
				return
			end
		end

		local dmgMulti = 1
		if dmg > 0 and damageType ~= "pure" then
			-- skill modifiers
			for name,skill in pairs(dungeon.skills) do
				if skill.onComputeDamageTaken then
					local rval = skill.onComputeDamageTaken(objectToProxy(self), objectToProxy(hitContext), objectToProxy(attacker), attackerType, dmg, damageType, isSpell, self:getSkillLevel(name))
					if rval and rval ~= dmg then dmgMulti = dmgMulti + (rval / dmg) - 1 end
					if rval == false then return end
				end
			end
			
			-- traits modifiers
			for name,trait in pairs(dungeon.traits) do
				if trait.onComputeDamageTaken then
					local rval = trait.onComputeDamageTaken(objectToProxy(self), objectToProxy(hitContext), objectToProxy(attacker), attackerType, dmg, damageType, isSpell, iff(self:hasTrait(name), 1, 0))
					if rval and rval ~= dmg then dmgMulti = dmgMulti + (rval / dmg) - 1 end
					if rval == false then return end
				end
			end
			
			-- condition modifiers
			for _,cond in pairs(self.conditions) do
				if cond.onComputeDamageTaken then 
					local rval = cond:onComputeDamageTaken(self, objectToProxy(hitContext), objectToProxy(attacker), attackerType, dmg, damageType, isSpell)
					if rval and rval ~= dmg then dmgMulti = dmgMulti + (rval / dmg) - 1 end
					if rval == false then return end
				end
			end

			-- equipment modifiers (equipped items only)
			for i=1,ItemSlot.BackpackFirst-1 do
				local it = self:getItem(i)
				if it then
					if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
						for i=1,it.go.components.length do
							local comp = it.go.components[i]
							if comp.onComputeDamageTaken then
								local rval = comp:onComputeDamageTaken(self, hitContext, attacker, attackerType, dmg, damageType, isSpell)
								if rval and rval ~= dmg then dmgMulti = dmgMulti + (rval / dmg) - 1 end
								if rval == false then return end
							end
						end
					end
				end
			end
		end

		dmg = dmg * dmgMulti

        dmg = self:triggerOnDamage(dmg, damageType, isSpell, hitContext, attacker, attackerType)

		dmg = math.floor(dmg)
        
		if dmg > 0 then
			self:modifyBaseStat("health", -dmg)
			self:showDamageIndicator(dmg)
			messageSystem:sendMessageNEW("onChampionDamaged", self, dmg, damageType)
		end
		
		-- champion died?
		if not self:isAlive() then
			if party:callHook("onDie", objectToProxy(self)) == false then
				if self:getBaseStat("health") < 1 then self:setBaseStat("health", 1) end
				return
			end
			self:onDeathTrigger(attacker, attackerType)
			self:die()
		end
	end
end

function Champion:triggerOnDamage(dmg, dmgType, isSpell, hitContext, attacker, attackerType)
    return dmg
end

function Champion:onDeathTrigger(attacker, attackerType)
	for c=1,4 do
		local champ = party:getChampion(c)
		-- if champ == champion or not champ:isAlive() then return end
		-- skill modifiers
		for name,skill in pairs(dungeon.skills) do
			if skill.onDeathTrigger then
				skill.onDeathTrigger(objectToProxy(self), objectToProxy(champ), objectToProxy(attacker), attackerType,  champ:getSkillLevel(name))
			end
		end

		-- trait modifiers
		for name,trait in pairs(dungeon.traits) do
			if trait.onDeathTrigger then
				trait.onDeathTrigger(objectToProxy(self), objectToProxy(champ), objectToProxy(attacker), attackerType, iff(champ:hasTrait(name), 1, 0))
			end
		end

		-- equipment modifiers (equipped items only)
		for i=1,ItemSlot.BackpackFirst-1 do
			local it = champ:getItem(i)
			if it then
				if it.go.equipmentitem and it.go.equipmentitem:isEquipped(champ, i) then
					for i=1,it.go.components.length do
						local comp = it.go.components[i]
						if comp.onDeathTrigger then
							comp:onDeathTrigger(self, champ, attacker, attackerType)
						end
					end
				end
			end
		end
	end
end

local oldStatInit = Stat.init
function Stat:init(name, value)
	oldStatInit(self, name, value)
	self.final = value
end

function Champion:addStatFinal(name, amount)
	local stat = self.stats[name]
	if not stat then error("invalid stat", 2) end
	stat.final = stat.final + amount
end

function Champion:recomputeStats()
	local stats = self.stats

	-- reset stats to base values
	for _,s in ipairs(Stats) do
		stats[s].current = stats[s].base
		stats[s].final = 0
	end
	
	-- apply item modifiers
	for i=1,ItemSlot.BackpackFirst-1 do
		local item = self:getItem(i)
		if item then
			item.go:sendMessage("recomputeStats", self, i)
		end
	end
	
	-- apply condition modifiers
	for _,cond in pairs(self.conditions) do
		if cond.recomputeStats then cond:recomputeStats(self) end
	end
	
	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onRecomputeStats then
			local level = self:getSkillLevel(name)
			if level > 0 then
				skill.onRecomputeStats(objectToProxy(self), level)
			end
		end
	end
	
	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onRecomputeStats and self:hasTrait(name) then
			trait.onRecomputeStats(objectToProxy(self), 1)
		end
	end

	-- light/heavy armor penalty
	local lightArmorProf = self:hasTrait("light_armor_proficiency")
	local heavyArmorProf = self:hasTrait("heavy_armor_proficiency")
	for i=1,10 do
		if i ~= ItemSlot.Weapon and i ~= ItemSlot.OffHand then
			local item = self:getItem(i)
			if item then
				if item:hasTrait("heavy_armor") and not heavyArmorProf then
					self:addStatModifier("evasion", -10)
				end
				if item:hasTrait("light_armor") and not lightArmorProf then
					self:addStatModifier("evasion", -5)
				end
			end
		end
	end

	-- leadership
	for i=1,4 do
		local c = party:getChampion(i)
		if c ~= champion and c:isAlive() and c:hasTrait("leadership") then
			stats.strength.current = stats.strength.current + 1
			stats.dexterity.current = stats.dexterity.current + 1
			stats.vitality.current = stats.vitality.current + 1
			stats.willpower.current = stats.willpower.current + 1
		end
	end

	-- nightstalker
	if self:hasTrait("nightstalker") then
		stats.vitality.current = stats.vitality.current + iff(gameMode:getTimeOfDay() < 1, -5, 5)
	end

	-- +5 to max health for each point of vitality
	stats.max_health.current = math.max(stats.max_health.current + (stats.vitality.current-10) * 5, 1)
		
	-- +5 to max energy for each point of willpower
	stats.max_energy.current = math.max(stats.max_energy.current + (stats.willpower.current-10) * 5, 1)
	
	stats.protection.current = math.floor(stats.protection.current + 0.5)

	-- evasion dexterity bonus
	stats.evasion.current = stats.evasion.current + math.max((stats.dexterity.current - 10) * 1, 0)

	-- health and energy regeneration rate
	stats.health_regeneration_rate.current = stats.health_regeneration_rate.current + (stats.vitality.current-10)
	stats.energy_regeneration_rate.current = stats.energy_regeneration_rate.current + (stats.willpower.current-10)

	-- resistance bonuses
	stats.resist_fire.current = stats.resist_fire.current + (stats.strength.current - 10) * 2
	stats.resist_shock.current = stats.resist_shock.current + (stats.dexterity.current - 10) * 2
	stats.resist_poison.current = stats.resist_poison.current + (stats.vitality.current - 10) * 2
	stats.resist_cold.current = stats.resist_cold.current + (stats.willpower.current - 10) * 2
				
	-- clamp resistances between 0 and 100
	stats.resist_fire.current = math.clamp(stats.resist_fire.current, 0, stats.resist_fire_max.current)
	stats.resist_cold.current = math.clamp(stats.resist_cold.current, 0, stats.resist_cold_max.current)
	stats.resist_poison.current = math.clamp(stats.resist_poison.current, 0, stats.resist_poison_max.current)
	stats.resist_shock.current = math.clamp(stats.resist_shock.current, 0, stats.resist_shock_max.current)
	
	stats.food_rate.current = math.max(stats.food_rate.current, 0)
	stats.cooldown_rate.current = math.max(stats.cooldown_rate.current, 1)
	
	-- max load
	stats.max_load.current = stats.max_load.current + stats.strength.current * 3

	stats.threat_rate.current = math.clamp(stats.threat_rate.current, -1, 1)
	stats.pierce.current = math.clamp(stats.pierce.current, -1, 1)

	-- Final stat modifiers
	-- apply item modifiers
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onRecomputeFinalStats then
						comp:onRecomputeFinalStats(self)
					end
				end
			end
		end
	end

	-- apply condition modifiers
	for _,cond in pairs(self.conditions) do
		if cond.recomputeFinalStats then cond:recomputeFinalStats(self) end
	end

	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onRecomputeFinalStats then
			local level = self:getSkillLevel(name)
			if level > 0 then
				skill.onRecomputeFinalStats(objectToProxy(self), level)
			end
		end
	end

	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onRecomputeFinalStats and self:hasTrait(name) then
			trait.onRecomputeFinalStats(objectToProxy(self), 1)
		end
	end

	stats.strength.current = stats.strength.current + stats.strength.final
	stats.dexterity.current = stats.dexterity.current + stats.dexterity.final
	stats.vitality.current = stats.vitality.current + stats.vitality.final
	stats.willpower.current = stats.willpower.current + stats.willpower.final

	stats.threat_rate.current = math.clamp(stats.threat_rate.current + stats.threat_rate.final, -1, 1)

	-- +5 to max health for each point of vitality
	stats.max_health.current = math.max(stats.max_health.current + stats.max_health.final + (stats.vitality.final * 5), 1)
	 
	-- +5 to max energy for each point of willpower
	stats.max_energy.current = math.max(stats.max_energy.current + stats.max_energy.final + (stats.willpower.final * 5), 1)
	
	stats.protection.current = stats.protection.current + stats.protection.final

	-- evasion dexterity bonus
	stats.evasion.current = stats.evasion.current + stats.evasion.final + math.max(stats.dexterity.final, 0)

	-- health and energy regeneration rate
	stats.health_regeneration_rate.current = stats.health_regeneration_rate.current + stats.vitality.final + stats.health_regeneration_rate.final
	stats.energy_regeneration_rate.current = stats.energy_regeneration_rate.current + stats.willpower.final + stats.energy_regeneration_rate.final

	-- resistance bonuses
	stats.resist_fire.current = stats.resist_fire.current + stats.strength.final * 2
	stats.resist_shock.current = stats.resist_shock.current + stats.dexterity.final * 2
	stats.resist_poison.current = stats.resist_poison.current + stats.vitality.final * 2
	stats.resist_cold.current = stats.resist_cold.current + stats.willpower.final * 2

	-- max resistances
	stats.resist_fire_max.current = stats.resist_fire_max.current + stats.resist_fire_max.final
	stats.resist_cold_max.current = stats.resist_cold_max.current + stats.resist_cold_max.final
	stats.resist_poison_max.current = stats.resist_poison_max.current + stats.resist_poison_max.final
	stats.resist_shock_max.current = stats.resist_shock_max.current + stats.resist_shock_max.final
				
	-- clamp resistances between 0 and 100
	stats.resist_fire.current = math.clamp(stats.resist_fire.current + stats.resist_fire.final, 0, stats.resist_fire_max.current)
	stats.resist_cold.current = math.clamp(stats.resist_cold.current + stats.resist_cold.final, 0, stats.resist_cold_max.current)
	stats.resist_poison.current = math.clamp(stats.resist_poison.current + stats.resist_poison.final, 0, stats.resist_poison_max.current)
	stats.resist_shock.current = math.clamp(stats.resist_shock.current + stats.resist_shock.final, 0, stats.resist_shock_max.current)
	
	stats.food_rate.current = math.max(stats.food_rate.current + stats.food_rate.final, 0)
	stats.cooldown_rate.current = math.max(stats.cooldown_rate.current + stats.cooldown_rate.final, 1)
	
	if party:isResting() then stats.evasion.current = stats.evasion.current - 100 end
	
	-- max load
	stats.max_load.current = stats.max_load.current + stats.strength.final * 3
	stats.pierce.current = stats.pierce.current + stats.pierce.final

	-- clamp health and energy to their maximum values
	stats.health.base = math.clamp(0, stats.health.base, stats.max_health.current)
	stats.energy.base = math.clamp(0, stats.energy.base, stats.max_energy.current)
end

function Champion:checkWound(name, action, actionName, actionType)
	local rval
	local rval1, rval2, rval3
	if self:hasCondition(name) then rval = true end
	-- skill modifiers
	for sname,skill in pairs(dungeon.skills) do
		if skill.onCheckWound then
			rval1 = skill.onCheckWound(objectToProxy(self), name, action, actionName, actionType, self:getSkillLevel(sname))
		end
	end
	-- trait modifiers
	for tname,trait in pairs(dungeon.traits) do
		if trait.onCheckWound then
			rval2 = trait.onCheckWound(objectToProxy(self), name, action, actionName, actionType, iff(self:hasTrait(tname), 1, 0))
		end
	end
	-- equipment modifiers 
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onCheckWound then
						rval3 = comp:onCheckWound(self, name, action, actionName, actionType)
					end
				end
			end
		end
	end
	-- console:print("rval", rval1 or rval2 or rval3, rval1 and rval2 and rval3)
	rval = rval1 or rval2 or rval3
	return rval
end

function Champion:castSpell(gesture)
	return self:triggerSpell(gesture, false, 0)
end

function Champion:triggerSpell(gesture, trigger, triggerModifier)
	if type(trigger) == "number" then if trigger == 0 then trigger = false elseif trigger == 1 then trigger = true end end
	if trigger == nil then trigger = true end
	-- Updated to allow traits and equipment to affect spell cost, cooldown and power
	-- find spell
	local spell 
	if type(gesture) == "number" then
		spell = Spell.getSpellByGesture(gesture)
	else
		spell = Spell.getSpell(gesture)
	end

	-- can't cast spell with wounded head
	local checkWound = spell and self:checkWound("head_wound", "spell", spell.name, spell.skill)
	if checkWound then
		self:showAttackResult("Fizzle", GuiItem.SpellFizzle)
		return false
	end
	
	if not spell then
		self:showAttackResult("Fizzle", GuiItem.SpellFizzle)
		soundSystem:playSound2D("spell_fizzle")
		self:spendEnergy(math.random(5,13))
		--self:clearRunes()
		return false
	end
	
	-- check skill level
	if not config.unlimitedSpells and not trigger then
		-- check skill requirements
		if spell.requirements and not Skill.checkRequirements(self, spell.requirements) then
			self:showAttackResult("Fizzle", GuiItem.SpellFizzle)
			soundSystem:playSound2D("spell_fizzle")
			self:spendEnergy(math.random(5,13))
			self:clearRunes()
			return false
		end
	end

	-- spend energy
	if not config.unlimitedSpells and not trigger then
		local cost = spell.manaCost
		-- console:print("cost before", cost)

		-- skill modifiers
		for name,skill in pairs(dungeon.skills) do
			if skill.onComputeSpellCost then
				local modifier = skill.onComputeSpellCost(objectToProxy(self), spell.name, spell.manaCost, spell.skill, self:getSkillLevel(name))
				cost = cost * (modifier or 1)
			end
		end
					
		-- trait modifiers
		for name,trait in pairs(dungeon.traits) do
			if trait.onComputeSpellCost then
				local modifier = trait.onComputeSpellCost(objectToProxy(self), spell.name, spell.manaCost, spell.skill, iff(self:hasTrait(name), 1, 0))
				cost = cost * (modifier or 1)
			end
		end

		-- equipment modifiers (equipped items only)
		for i=1,ItemSlot.BackpackFirst-1 do
			local it = self:getItem(i)
			if it then
				if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
					for i=1,it.go.components.length do
						local comp = it.go.components[i]
						if comp.onComputeSpellCost then
							local modifier = comp:onComputeSpellCost(self, spell.name, spell.manaCost, spell.skill)
							cost = cost * (modifier or 1)
						end
					end
				end
			end
		end
		
		if self:getEnergy() < cost then
			self:showAttackResult("Out of energy", GuiItem.SpellNoEnergy)
			soundSystem:playSound2D("spell_out_of_energy")
			return
		end		
		self:spendEnergy(cost)
	end

	spell = self:getSpellData(spell)
	
	if party:callHook("onCastSpell", objectToProxy(self), spell.name) == false then
		return false
	end

	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onCastSpell then
			if skill.onCastSpell(objectToProxy(self), spell.name, spell.manaCost, spell.skill, self:getSkillLevel(name)) == false then
				return false
			end
		end
	end

	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onCastSpell then
			if trait.onCastSpell(objectToProxy(self), spell.name, spell.manaCost, spell.skill, iff(self:hasTrait(name), 1, 0)) == false then
				return false
			end
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onCastSpell then
						if comp:onCastSpell(self, spell.name, spell.manaCost, spell.skill) == false then
							return false
						end
					end
				end
			end
		end
	end

	messageSystem:sendMessageNEW("onChampionCastSpell", self, spell)
	
	self:clearRunes()
	
	local skill = 0
	if spell.skill then skill = self:getSkillLevel(spell.skill) end
	if trigger and triggerModifier then
		spell.power = spell.power * triggerModifier
	end
	--if config.unlimitedSpells then skill = math.max(skill, 3) end
	local pos = party.go:getWorldPositionFast()
	local x,y = party.go.map:worldToMap(pos)
	local spl = Spell.castSpell(spell, self, x, y, party.go.facing, party.go.elevation, skill)
	local dmg = 0
	local spellObject = nil
	
	if spl then
		if spl.tiledamager then
			dmg = spl.tiledamager.attackPower
			spellObject = spl.tiledamager
		elseif spl.projectile then
			dmg = spl.projectile.attackPower
			spellObject = spl.projectile
		elseif spl.cloudspell then
			dmg = spl.cloudspell.attackPower
			spellObject = spl.cloudspell
		end
	
		-- Spell damage modifiers
		-- skill modifiers
		for name,skill in pairs(dungeon.skills) do
			if skill.onComputeSpellDamage then
				local returnVal = skill.onComputeSpellDamage(objectToProxy(self), objectToProxy(spellObject), spell.name, spell.manaCost, spell.skill, self:getSkillLevel(name), trigger)
				if returnVal then
					if returnVal[1] == false then return end
					if returnVal[2] then
						local tempSpl = returnVal[2]
						spl = tempSpl.go
						if not (spl.tiledamager or spl.projectile or spl.cloudspell) then
							console:print("invalid onComputeSpellDamage return value 2")
						end
					end
				end
			end
		end
					
		-- trait modifiers
		for name,trait in pairs(dungeon.traits) do
			if trait.onComputeSpellDamage then
				local returnVal = trait.onComputeSpellDamage(objectToProxy(self), objectToProxy(spellObject), spell.name, spell.manaCost, spell.skill, iff(self:hasTrait(name), 1, 0), trigger)
				if returnVal then
					if returnVal[1] == false then return end
					if returnVal[2] then
						local tempSpl = returnVal[2]
						spl = tempSpl.go
						if not (spl.tiledamager or spl.projectile or spl.cloudspell) then
							console:print("invalid onComputeSpellDamage return value 2")
						end
					end
				end
			end
		end

		-- equipment modifiers (equipped items only)
		for i=1,ItemSlot.BackpackFirst-1 do
			local it = self:getItem(i)
			if it then
				if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
					for i=1,it.go.components.length do
						local comp = it.go.components[i]
						if comp.onComputeSpellDamage then
							local returnVal = comp:onComputeSpellDamage(self, spellObject, spell.name, spell.manaCost, spell.skill, trigger)
							if returnVal then
								if returnVal[1] == false then return end
								if returnVal[2] then
									local tempSpl = returnVal[2]
									spl = tempSpl.go
									if not (spl.tiledamager or spl.projectile or spl.cloudspell) then
										console:print("invalid onComputeSpellDamage return value 2")
									end
								end
							end
						end
					end
				end
			end
		end
		
	end
	-- end

	-- if trigger and triggerModifier and spellObject then
	-- 	spellObject:setAttackPower(spellObject:getAttackPower() * triggerModifier)
	-- end
	
	-- cool down
	local cooldown = (spell.cooldown or 5) * self:getCooldownWithSpell(spell)

	if not trigger then
		self.cooldownTimer[1] = cooldown
		self.cooldownTimer[2] = cooldown

		-- strenous activity consumes food
		self:consumeFood(math.random(4,9))

		-- learn new spell?
		if not spell.hidden and not self:hasTrait(spell.name) then
			self:addTrait(spell.name)
			gui:hudPrint(self.name.." learned a new spell!")
			soundSystem:playSound2D("discover_spell")
		end
	end

	party.go.statistics:increaseStat("spells_cast", 1)
	
	return true
end

function Champion:getSpellData(spell)
	local name = spell.name
	local power = spell.power or 0
	local powerScaling = spell.powerScaling or 0
	local duration = spell.duration or 0
	local durationScaling = spell.durationScaling or 0
	local skill = spell.skill or 0

	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onComputeSpell then
			local modifier = skill.onComputeSpell(objectToProxy(self), name, power, powerScaling, duration, durationScaling, skill, self:getSkillLevel(name))
			assert(modifier and type(modifier)=="table", "Bad onComputeSpell return value")
			if modifier then
				spell.name = modifier[1]
				spell.power = modifier[2]
				spell.powerScaling = modifier[3]
				spell.duration = modifier[4]
				spell.durationScaling = modifier[5]
				spell.skill = modifier[6]
			end
		end
	end

	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onComputeSpell then
			local modifier = trait.onComputeSpell(objectToProxy(self), item, amount, iff(self:hasTrait(name), 1, 0))
			assert(modifier and type(modifier)=="table" and modifier[6], "Bad onComputeSpell return value")
			if modifier then
				spell.name = modifier[1]
				spell.power = modifier[2]
				spell.powerScaling = modifier[3]
				spell.duration = modifier[4]
				spell.durationScaling = modifier[5]
				spell.skill = modifier[6]
			end
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onComputeSpell then
						local modifier = comp:onComputeSpell(self, item, amount)
						assert(modifier and type(modifier)=="table" and modifier[6], "Bad onComputeSpell return value")
						if modifier then
							spell.name = modifier[1]
							spell.power = modifier[2]
							spell.powerScaling = modifier[3]
							spell.duration = modifier[4]
							spell.durationScaling = modifier[5]
							spell.skill = modifier[6]
						end
					end
				end
			end
		end
	end

	return spell
end

function Champion:getLoad()
    -- Updated to enable affecting item weight with traits
	local c = self:getOrdinal()

	local load = 0

	local armorWeightReductionEquipped = 1
	local armorWeightReduction = 1
	
	-- equipment modifiers (equipped items only)
	for j=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(j)
		if it then
			local equipped = false
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, j) then
				equipped = true
				for k=1,it.go.components.length do
					local comp = it.go.components[k]
					if comp.onComputeItemWeight then
						local modifier = comp:onComputeItemWeight(self, equipped)
						if equipped then
							armorWeightReductionEquipped = armorWeightReductionEquipped * (modifier or 1)
						else 
							armorWeightReduction = armorWeightReduction * (modifier or 1)
						end
					end
				end
			end
		end
	end

	for name,skill in pairs(dungeon.skills) do
		if skill.onComputeItemWeight then
			local modifier = skill.onComputeItemWeight(objectToProxy(self), true, self:getSkillLevel(name))
			armorWeightReductionEquipped = armorWeightReductionEquipped * (modifier or 1)
		end
		if skill.onComputeItemWeight then
			local modifier = skill.onComputeItemWeight(objectToProxy(self), false, self:getSkillLevel(name))
			armorWeightReduction = armorWeightReduction * (modifier or 1)
		end
	end

	for name,trait in pairs(dungeon.traits) do
		if trait.onComputeItemWeight then
			local modifier = trait.onComputeItemWeight(objectToProxy(self), true, iff(self:hasTrait(name), 1, 0))
			armorWeightReductionEquipped = armorWeightReductionEquipped * (modifier or 1)
		end
		if trait.onComputeItemWeight then
			local modifier = trait.onComputeItemWeight(objectToProxy(self), false, iff(self:hasTrait(name), 1, 0))
			armorWeightReduction = armorWeightReduction * (modifier or 1)
		end
	end

	for i=1,ItemSlot.MaxSlots do
		local it = self.items[i]
		if it then
			local equipped = false
			if it.go.equipmentitem then
				equipped = it.go.equipmentitem:isEquipped(self, i)
			end

			local addLoad
			if equipped then
				addLoad = it:getTotalWeight() * armorWeightReductionEquipped
			else
				addLoad = it:getTotalWeight() * armorWeightReduction
			end

			load = load + addLoad
		end
	end
	
	return load
end

function Champion:checkPowerAttackCost(powerAttack, energyCost)
	-- trait modifiers
	local attackType = powerAttack.getAttackType and powerAttack:getAttackType()
	local item = powerAttack.go.item
	if powerAttack:getClass() == "CastSpellComponent" then attackType = "spell" end

	for name,trait in pairs(dungeon.traits) do
		if trait.onComputePowerAttackCost then
			local modifier = trait.onComputePowerAttackCost(objectToProxy(self), objectToProxy(item), objectToProxy(powerAttack), energyCost, attackType, iff(self:hasTrait(name), 1, 0))
			energyCost = (energyCost * (modifier or 1))
		end
	end

	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onComputePowerAttackCost then
			local modifier = skill.onComputePowerAttackCost(objectToProxy(self), objectToProxy(item), objectToProxy(powerAttack), energyCost, attackType, self:getSkillLevel(name))
			energyCost = (energyCost * (modifier or 1))
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onComputePowerAttackCost then
						local modifier = comp:onComputePowerAttackCost(self, item, powerAttack, energyCost, attackType)
						energyCost = (energyCost * (modifier or 1))
					end
				end
			end
		end
	end
	return math.floor(energyCost)
end

function Champion:getPowerAttackBuildup(powerAttack)
	local buildupTime = powerAttack.getBuildup and powerAttack:getBuildup()
	local item = powerAttack.go.item
	-- trait modifiers
	local attackType = powerAttack.getAttackType and powerAttack:getAttackType()
	if powerAttack:getClass() == "CastSpellComponent" then attackType = "spell" end

	for name,trait in pairs(dungeon.traits) do
		if trait.onComputeBuildupTime then
			local modifier = trait.onComputeBuildupTime(objectToProxy(self), objectToProxy(item), objectToProxy(powerAttack), energyCost, attackType, iff(self:hasTrait(name), 1, 0))
			buildupTime = buildupTime * (modifier or 1)
		end
	end

	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onComputeBuildupTime then
			local modifier = skill.onComputeBuildupTime(objectToProxy(self), objectToProxy(item), objectToProxy(powerAttack), energyCost, attackType, self:getSkillLevel(name))
			buildupTime = buildupTime * (modifier or 1)
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onComputeBuildupTime then
						local modifier = comp:onComputeBuildupTime(self, item, powerAttack, energyCost, attackType)
						buildupTime = buildupTime * (modifier or 1)
					end
				end
			end
		end
	end
	return buildupTime
end

function Champion:checkAmmoSlot(attack, slot, dualWieldSide)
	local ammoSlot = iff(slot == ItemSlot.Weapon, ItemSlot.OffHand, ItemSlot.Weapon)
	local item = self:getItem(ammoSlot)
	if item then item = item.go.ammoitem end
	
	local hasAmmo = attack:checkAmmo(self, slot)

	if not hasAmmo or (type(hasAmmo) == "number" and hasAmmo < 1) then
		if attack.clipSize then
			if (attack.loadedCount or 0) < 1 then
				self:showAttackResult("Clip empty", nil, dualWieldSide)
				return false, ammoSlot
			else
				self:showAttackResult("No ammo", nil, dualWieldSide)
				return false, ammoSlot
			end
		else
			self:showAttackResult("No ammo", nil, dualWieldSide)
			return false, ammoSlot
		end
	end
	return item, ammoSlot
end


function Champion:regainHealth(amount)
	local item = debug.getinfo(6).name == "onUseItem"

	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onRegainHealth then
			local modifier = skill.onRegainHealth(objectToProxy(self), item, amount, self:getSkillLevel(name))
			if modifier and type(modifier) == "number" then
				amount = amount * modifier
			end
		end
	end

	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onRegainHealth then
			-- console:print(name, self:hasTrait(name))
			local modifier = trait.onRegainHealth(objectToProxy(self), item, amount, iff(self:hasTrait(name), 1, 0))
			if modifier and type(modifier) == "number" then
				amount = amount * modifier
			end
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onRegainHealth then
						local modifier = comp:onRegainHealth(self, item, amount)
						if modifier and type(modifier) == "number" then
							amount = amount * modifier
						end
					end
				end
			end
		end
	end

	-- dead champions do not regain health
	if self:isAlive() then
		self:modifyBaseStat("health", amount)
		local max = self:getMaxHealth()
		if self:getBaseStat("health") > max then
			self:setBaseStat("health", max)
		end
	end
end

function Champion:regainEnergy(amount)
	local item = debug.getinfo(6).name == "onUseItem"

	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onRegainEnergy then
			local modifier = skill.onRegainEnergy(objectToProxy(self), item, amount, self:getSkillLevel(name))
			if modifier ~= nil then
				amount = amount * modifier
			end
		end
	end

	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onRegainEnergy then
			-- console:print(name, self:hasTrait(name))
			local modifier = trait.onRegainEnergy(objectToProxy(self), item, amount, iff(self:hasTrait(name), 1, 0))
			if modifier ~= nil then
				amount = amount * modifier
			end
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onRegainEnergy then
						local modifier = comp:onRegainEnergy(self, item, amount)
						if modifier ~= nil then
							amount = amount * modifier
						end
					end
				end
			end
		end
	end

	-- dead champions do not regain energy
	if self:isAlive() then
		self:modifyBaseStat("energy", amount)
		local max = self:getMaxEnergy()
		if self:getBaseStat("energy") > max then
			self:setBaseStat("energy", max)
		end
	end
end

function Champion:launchProjectile(attack, slot, ammo)
	local weapon = self:getItem(slot)
	local act

	if weapon.go.rangedattack then 
		act = weapon.go.rangedattack
	elseif weapon.go.throwattack then
		act = weapon.go.throwattack
	elseif weapon.go.meleeattack then
		act = weapon.go.meleeattack
	end
	local dmg = computeDamage(attack:getAttackPower())
	local name = "shuriken"
	if ammo then name = ammo end
	local projectile = create(ammo).item

	local pos = self:getChampionPositionInWorld(0.2)
		
	-- push forward so that item won't collide against a door behind us
	pos = pos + party:getWorldForward() * weapon:getBoundingRadius()

	-- separate projectiles if shooting multiple projectiles
	if attack.spread then
		pos.x = pos.x + (math.random() - 0.5) * attack.spread
		pos.y = pos.y + (math.random() - 0.5) * attack.spread
		pos.z = pos.z + (math.random() - 0.5) * attack.spread
	end
	
	local power = 14
	local gravity = 1
	local velocityUp = 0

	projectile:setItemFlag(ItemFlag.FragileProjectile, true)
	projectile.convertToItemOnImpact = false
	projectile:throw(party, pos, party.go.facing, power, gravity, velocityUp)
	projectile:setItemFlag(ItemFlag.AutoPickUp, true)
	projectile.go.projectile:setVelocity(projectile.go.projectile:getVelocity() * (1+(attack.velocity or 0)) * 1.5)
	projectile.projectileDamage = dmg
	projectile.projectileAccuracy = self:getAccuracyWithAttack(weapon, act)
	projectile.projectileCritChance = self:getCritChanceWithAttack(weapon, act)
	projectile.projectilePierce = attack.pierce
	projectile.thrownByChampion = self.ordinal
	projectile.thrownByWeapon = weapon.go.id
	projectile.thrownByAttack = attack.name

	return projectile
end

-------------------------------------------------------------------------------------------------------
-- Monster Functions                                                                                 --    
-------------------------------------------------------------------------------------------------------

MonsterComponent:autoSerialize("lootDrop", "immunities", "resistances", "traits", "data", "dataDuration")

local oldMonsterInit = MonsterComponent.init
function MonsterComponent:init(go)
	local rval = oldMonsterInit(self, go)
	self.data = {}
	self.dataDuration = {}
	return rval
end

function MonsterComponent:setData(name, value)
	-- if self.data[name].value then self.data[name].value = value end
	self.data[name] = value
end

function MonsterComponent:getData(name)
	return self.data[name]
end

function MonsterComponent:addData(name, value)
	self.data[name] = (self.data[name] or 0) + value
end

function MonsterComponent:setDataDuration(name, value, duration)
	self.data[name] = value
	self.dataDuration[name] = duration
end

function MonsterComponent:getDataDuration(name)
	return self.dataDuration[name]
end

function MonsterComponent:getAIState()
	return self.aiState
end

function MonsterComponent:update()
	if not self.enabled then return end
	
	-- debug
	-- if sys.keyPressed(' ') then
	-- 	damageTile(self.go.map, self.go.x, self.go.y, self.go.facing, self.go.elevation, DamageFlags.Impact, "physical", 100)
	-- end

	self:updateDying()
	
	if self:isAlive() then
		if self.currentAction then
			if not self.currentAction:update() then
				-- action finished
				local action = self.currentAction
				self.currentAction = nil
				if action.finish then action:finish() end
				action:callHook("onEndAction")
				if self.go.entityDestroyed then return end
				self:updateTransform(self.go.x, self.go.y, self.go.facing)
				
				if not self.currentAction then
					self.go.animation:play(self.idleAnimation or "idle", true)
					-- sample animation so that bones are updated to correct location
					-- otherwise if the monster just performed a move action and the monster dies this frame
					-- (before animation component is updated) capsule node is in wrong place
					-- and dropped items and monster death effect are placed in wrong location
					self.go.animation:sample()
				end
			end
		end

		-- HOTFIX: dynamic obstacle state can get messed up when time passes really fast
		-- here was a bug which causes monster move to be finished before the monster was moved to the next cell
		-- happened only when resting and possibly with low fps
		-- repro: sys.setMaxFrameRate(30); gameMode:setTimeMultiplier(10); self:checkDynamicObstacleState()

		if self.currentAction == nil then
			local obs = self.go.dynamicObstacle
			if self.go.x ~= obs.occupiedCellX or self.go.y ~= obs.occupiedCellY then
				obs.occupiedCellX = self.go.x
				obs.occupiedCellY = self.go.y
				--print("fixed dynamic obstacle state for entity "..self.go.id)
			end
		end

		-- choose next action		
		if self:isReadyToAct() and self.go.brain and self:isGroupLeader() then
			self.go.brain:update()
		end
		
		if self.stunTimer then self.stunTimer = self.stunTimer - Time.deltaTime end

		if self.iceShardsImmunityTimer then
			self.iceShardsImmunityTimer = iff(self.iceShardsImmunityTimer > 0, self.iceShardsImmunityTimer - Time.deltaTime, nil)
		end

		self:updateUnderWater()

		if self.juggernaut then
			self:updateJuggernaut()
		end

		if self.dataDuration ~= {} then
			for k, v in pairs(self.dataDuration) do
				if self.data[k] then
					v = v - Time.deltaTime
					self.dataDuration[k] = v
					if v <= 0 then self.dataDuration[k] = nil; self.data[k] = nil end
				end
			end
		end
	end
end

function MonsterComponent:saveState(file)
	-- save monster group
	-- group data is shared between all members so save the group only once with the leader
	if self.group and self.group.leader == self then
		file:openChunk("MGRP")
		local group = self.group
		file:writeValue(group.groupType)
		for i=1,4 do
			local id
			if group.members[i] then id = group.members[i].go.id end
			file:writeValue(id)
		end
		file:closeChunk()
	end
	
	-- save items
	if self.items then
		for i=1,#self.items do
			file:openChunk("ITEM")
			self.items[i].go:saveState(file)
			file:closeChunk()
		end
	end	
	
	-- save current action
	if self.currentAction then
		file:openChunk("CACT")
		file:writeValue(self.currentAction.name)
		file:closeChunk()
	end
	
	-- save data
	if self.data then
		for name,value in pairs(self.data) do
			file:openChunk("DATA")
			file:writeValue(name)
			file:writeValue(value)
			file:closeChunk()
		end
	end
	if self.dataDuration then
		for name,value in pairs(self.dataDuration) do
			file:openChunk("DATB")
			file:writeValue(name)
			file:writeValue(value)
			file:closeChunk()
		end
	end
end

function MonsterComponent:loadState(file)
	-- load chunks
	while file:availableBytes() > 0 do
		local id = file:openChunk()		
		if id == "MGRP" then
			-- load monster group
			local group = {
				leader = self,
				members = {},
			}
			group.groupType = file:readValue()
			for i=1,4 do
				group.members[i] = file:readValue()
			end
			self.groupToBeResolved = group
		elseif id == "ITEM" then
			local obj = GameObject.create()
			obj:loadState(file)
			if not self.items then self.items = Array.create() end
			self.items:add(obj.item)
		elseif id == "CACT" then
			self.currentAction = file:readValue()
		elseif id == "DATA" then
			local name = file:readValue()
			local value = file:readValue()
			self.data[name] = value
		elseif id == "DATB" then
			local name = file:readValue()
			local value = file:readValue()
			if self.dataDuration then
				self.dataDuration[name] = value
			end
		end
		file:closeChunk()
	end
end

function MonsterComponent:onAttackedByChampion(champion, weapon, attack, slot, dualWieldSide, trigger)
	if not self:isAlive() or self.go.elevation ~= party.go.elevation or self:getMonsterFlag(MonsterFlag.NonMaterial) then return end
	
	local target = self

	local damageType = attack.damageType or "physical"
	-- local gauntlets = champion:getItem(ItemSlot.Gloves)
	-- if gauntlets and gauntlets:hasTrait("fire_gauntlets") then damageType = "fire" end
	-- console:print(damageType, attack.attackPower)
		
	-- get target for monster groups
	if target.group then
		target = target:getNearestMonster(champion:getChampionPositionInWorld(0.5))
		if not target then return end
	end

	-- evasion
    if not self:hasCondition("sleep") and not self:hasCondition("frozen") and attack.name ~= "bonusAttack" and not trigger then
        local accuracy = champion:getAccuracyWithAttack(weapon, attack, self)
		local tohit = champion:getToHitChanceWithAttack(weapon, attack, target, accuracy, damageType)

		if math.random() > tohit / 100 or target.evasion >= 1000 then
			target:showDamageText("miss", Color.Grey)
			champion.luck = math.min(champion.luck + 3, 15)
			champion:showAttackResult("Miss", GuiItem.HitSplash, dualWieldSide)
			return "miss"
		end
		champion.luck = 0
	end
	
	-- compute side
	local tside = (party.go.facing - target.go.facing + 6) % 4
	local side
	if tside == 0 then
		-- front left or right?
		local rightSide = (champion.championIndex == 1 or champion.championIndex == 3)
		side = iff(rightSide, "front_right", "front_left")
	elseif tside == 1 then
		side = "right"
	elseif tside == 2 then
		side = "back"
	else
		side = "left"
	end

	-- compute base damage
	local oldAttackMinMod = attack.minDamageMod
	local oldAttackMaxMod = attack.maxDamageMod
	if trigger then
		attack.minDamageMod = 0
		attack.maxDamageMod = 0
	end
	local dmg = computeDamage(champion:getDamageWithAttack(weapon, attack))
	if trigger then
		attack.minDamageMod = oldAttackMinMod
		attack.maxDamageMod = oldAttackMaxMod
	end

	local damageFlags = DamageFlags.Impact
	-- crits & fumbles
	local crit = false
	local critChance = champion:getCritChanceWithAttack(weapon, attack, target) / 100
	if math.random() < critChance then
		crit = true
	elseif math.random() < 0.07 then
		dmg = dmg / 2
	end

	-- backstab
	local backstab = false
	local backStabMult = 0
	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onCheckBackstab then
			local modifier = trait.onCheckBackstab(objectToProxy(self), objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), dmg, damageType, crit, iff(champion:hasTrait(name), 1, 0))
			if type(modifier) == "table" then
				backStabMult = backStabMult + (modifier[1] or 0)
				crit = modifier[2] or crit
				damageType = modifier[3] or damageType
			else
				backStabMult = backStabMult + (modifier or 0)
			end
		end
	end
	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onCheckBackstab then
			local modifier = skill.onCheckBackstab(objectToProxy(self), objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), dmg, damageType, crit, champion:getSkillLevel(name))
			if type(modifier) == "table" then
				backStabMult = backStabMult + (modifier[1] or 0)
				crit = modifier[2] or crit
				damageType = modifier[3] or damageType
			else
				backStabMult = backStabMult + (modifier or 0)
			end
		end
	end
	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = champion:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(champion, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onComputeBackstabMultiplier then
						local modifier = comp:onComputeBackstabMultiplier(champion, weapon, attack, dmg, damageType, crit)
						if type(modifier) == "table" then
							backStabMult = backStabMult + (modifier[1] or 0)
							crit = modifier[2] or crit
							damageType = modifier[3] or damageType
						else
							backStabMult = backStabMult + (modifier or 0)
						end
					end
				end
			end
		end
	end

	if backStabMult > 0 and tside == 2 and not target:isImmuneTo("backstab") then
		local extraDamage = math.floor(dmg * (backStabMult-1) * (math.random() * 0.5 + 0.5))
		--print(string.format("backstab damage bonus +%d", extraDamage))
		dmg = dmg + extraDamage
		backstab = true
	end

	local modifier = self:getChampionAttackDamageModifier(champion, weapon, attack, dmg, damageType, crit, backstab)
	local result = true
	if modifier then
		if type(modifier) == "table" then
			result = modifier[1]
			dmg = modifier[2] or dmg
			heading = modifier[3] ~= nil and modifier[3] or heading
			crit = modifier[4] ~= nil and modifier[4] or crit
			backstab = modifier[5] or backstab
			damageType = modifier[6] or damageType
		end
	end

	if crit then
		local critMult = champion:getCritMultiplierWithAttack(weapon, attack, target) / 100
		if champion:getSecondaryAction(slot) == attack then critMult = 2.5 end
		dmg = dmg * critMult
	end

	-- damage reduction
	local protection = target:getMonsterProtectionWithAttack(champion, weapon, attack, dmg, damageType, crit, backstab)
	
	if protection > 0 then dmg = computeDamageReduction(dmg, protection) end

	-- invulnerability
	if target:isInvulnerable() then
		dmg = 0
		damageFlags = DamageFlags.Impact
	end

	-- damage source
	damageFlags = damageFlags + bit.lshift(DamageFlags.Champion1, champion.ordinal-1)
		
	-- compute impact position
	local impactPos = target:findImpactPosition(champion:getChampionPositionInWorld(0.7))
	
	-- heading
	local heading
	if backstab then
		heading = "Backstab"
	elseif crit then
		heading = "Critical"
	end

	dmg = math.max(math.floor(dmg), 0)
	
	if self.go.goromorgshield and self.go.goromorgshield:getEnergy() == math.huge then dmg = 0 end
	
	-- call hook
	if attack.go and attack:callHook("onHitMonster", objectToProxy(target), tside, dmg, objectToProxy(champion), crit, backstab) == false then
		return true
	end

	if not trigger then
		self:hitTriggers(champion, weapon, attack, crit, backstab, dmg, damageType)
	end

	if attack.knockback then
		self:knockback(party.go.facing)
	end

	-- deal damage to target
	local oldHealth = target:getHealth()
	local rval = target:damage(dmg, side, damageFlags, damageType, impactPos, heading, champion, weapon, attack, slot, dualWieldSide, trigger, result, crit, backstab)
	if rval then dmg = rval end
	-- HACK: show zero damage in attack panel if monster is invulnerable to damage
	if target:getHealth() == oldHealth then dmg = 0 end

	if backstab and not target:isAlive() then	
		steamContext:unlockAchievement("backstabber")
	end

	if dmg >= 0 and result then
		champion:showAttackResult(dmg, GuiItem.HitSplash, dualWieldSide)
	end

	-- cause condition
	if attack.causeCondition then
		champion:causeCondition(self, attack)
	end

	return true
end

function Champion:causeCondition(target, attack)
	local chance = attack.conditionChance or 50
	if math.random(1,100) <= chance then
		local duration = nil
		if attack.causeCondition == "frozen" then duration = 10 end
		target:setCondition(attack.causeCondition, duration)

		-- mark condition so that exp is awarded if monster is killed by the condition
		local cond = target.go:getComponent(attack.causeCondition)
		if cond and cond.setCausedByChampion then
			cond:setCausedByChampion(champion.ordinal)
		end
	end
end

function MonsterComponent:getMonsterProtectionWithAttack(champion, weapon, attack, dmg, damageType, crit, backstab, projectile)
	local protection = self:getProtection()
	if not champion then return protection end
	
	local pierce = champion:getPierceWithAttack(attack, self, champion, weapon, dmg, damageType, crit, backstab, projectile)

	return math.max(protection - pierce, 0)
end

function Champion:getPierceText(slot)
	local action = self:getPrimaryAction(slot)
	if not action or (action and not action.getAttackType) then
		return "--"
	end

	local pierce = self:getPierceWithAttack(action)
	if pierce and pierce ~= 0 then
		return pierce
	else
		return "--"
	end
end

function Champion:getPierceWithAttack(attack, monster, champion, weapon, dmg, damageType, crit, backstab, projectile)
	local pierce = self:getCurrentStat("pierce")
	if attack and attack.pierce then pierce = pierce + attack.pierce end
	if projectile and projectile.projectilePierce then pierce = pierce + projectile.projectilePierce end

	-- traits modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onComputePierce then
			local attackType = attack and attack:getAttackType() or nil
			local modifier = trait.onComputePierce(objectToProxy(monster), objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), objectToProxy(projectile), dmg, damageType, attackType, crit, backstab, iff(self:hasTrait(name), 1, 0))
			pierce = pierce + (modifier or 0)
		end
	end

	-- skills modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onComputePierce then
			local attackType = attack and attack:getAttackType()
			local modifier = skill.onComputePierce(objectToProxy(monster), objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), objectToProxy(projectile), dmg, damageType, attackType, crit, backstab, self:getSkillLevel(name))
			pierce = pierce + (modifier or 0)
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = self:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onComputePierce then
						local modifier = comp:onComputePierce(monster, self, weapon, attack, projectile, dmg, damageType, attackType, crit, backstab)
						pierce = pierce + (modifier or 0)
					end
				end
			end
		end
	end

	return pierce
end

function MonsterComponent:hitTriggers(champion, weapon, attack, crit, backstab, dmg, dmgType)
	if not champion then return false end
	local isSpell = attack and attack.go and (attack.go.tiledamager or attack.go.cloudspell)
	local isAttack = attack and not isSpell
	local attackType = isAttack and attack:getAttackType() or isSpell and "spell"
	
	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onHitTrigger then
			skill.onHitTrigger(objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), attackType, dmg, dmgType, crit, backstab, objectToProxy(self), champion:getSkillLevel(name))
		end
	end

	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onHitTrigger then
			trait.onHitTrigger(objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), attackType, dmg, dmgType, crit, backstab, objectToProxy(self), iff(champion:hasTrait(name), 1, 0))
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = champion:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(champion, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onHitTrigger then
						comp:onHitTrigger(champion, weapon, attack, attackType, dmg, dmgType, crit, backstab, self)
					end
				end
			end
		end
	end
end

function isAttack(attack)
	if attack then
		if attack:getClass() == "MeleeAttackComponent" then
			return true
		elseif attack:getClass() == "RangedAttackComponent" then
			return true
		elseif attack:getClass() == "ThrowAttackComponent" then
			return true
		elseif attack:getClass() == "FirearmAttackComponent" then
			return true
		end
	end
	return false
end

function isSpell(attack)
	if attack then
		if attack and attack.go and (attack.go.tiledamager or attack.go.cloudspell) then
			return true
		end
	end
	return false
end

function Champion:performAddedDamage(monster, weapon, attack, slot, dualWieldSide, crit, backstab)
	local damageList = {"fire","cold","shock","poison","neutral","physical"}
	for _,e in pairs(damageList) do
		local property = attack["attack" .. e:gsub("^%l", string.upper)] or 0
		
		-- skill modifiers
		for name,skill in pairs(dungeon.skills) do
			if skill.onPerformAddedDamage then
				local rval = skill.onPerformAddedDamage(objectToProxy(self), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType(), e, self:getSkillLevel(name), objectToProxy(monster), crit, backstab)
				property = (property or 0) + (rval or 0)
			end
		end

		-- trait modifiers
		for name,trait in pairs(dungeon.traits) do
			if trait.onPerformAddedDamage then
				local rval = trait.onPerformAddedDamage(objectToProxy(self), objectToProxy(weapon), objectToProxy(attack),attack:getAttackType(), e, iff(self:hasTrait(name), 1, 0), objectToProxy(monster), crit, backstab)
				property = (property or 0) + (rval or 0)
			end
		end

		-- equipment modifiers (equipped items only)
		for i=1,ItemSlot.BackpackFirst-1 do
			local it = self:getItem(i)
			if it then
				if it.go.equipmentitem and it.go.equipmentitem:isEquipped(self, i) then
					for i=1,it.go.components.length do
						local comp = it.go.components[i]
						if comp.onPerformAddedDamage then
							local rval = comp:onPerformAddedDamage(self, weapon, attack, attack:getAttackType(), e, monster, crit, backstab)
							property = (property or 0) + (rval or 0)
						end
					end
				end
			end
		end

		if property and property > 0 then
			local oldAttack = {}
			oldAttack.damageType = attack.damageType
			oldAttack.attackPower = attack.attackPower
			oldAttack.baseDamageStat = attack.baseDamageStat
			attack.damageType = e
			attack.attackPower = property
			attack.baseDamageStat = "none"
			monster:onAttackedByChampion(self, weapon, attack, slot, dualWieldSide, true)
			attack.damageType = oldAttack.damageType
			attack.attackPower = oldAttack.attackPower
			attack.baseDamageStat = oldAttack.baseDamageStat
		end
	end
end

function MonsterComponent:damage(dmg, side, damageFlags, damageType, impactPos, heading, champion, weapon, attack, slot, dualWieldSide, trigger, result, crit, backstab)
	if result == nil then result = true end
	damageFlags = damageFlags or 0
	local isSpell = isSpell(attack)
	local isAttack = isAttack(attack)
	local attackType = isAttack and attack:getAttackType() or isSpell and "spell"
	local spell = nil
	if attack and attack.go and attack.go.tiledamager then
		spell = attack.go.tiledamager
	end
	if attack and attack.go and attack.go.cloudspell then
		spell = attack.go.cloudspell
	end
	
	if not trigger then
		if isAttack and champion and attack and slot then
			champion:performAddedDamage(self, weapon, attack, slot, dualWieldSide, crit, backstab)
		end
	end

	if not self:isAlive() then return end
	
	-- tentacles hiding below ground ignore all damage
	if self.go.arch.name == "tentacles" and not self:getMonsterFlag(MonsterFlag.Collides) then return end
	
	if self:isInvulnerable() then dmg = 0 end

	-- resist
	local resist = self:getResistance(damageType)
	if resist then dmg = math.floor(dmg * getResistanceDamageMultiplier(resist, damageType)) end

	-- goromorg shield
	if self.go.goromorgshield and resist ~= "immune" and resist ~= "absorb" and self.go.goromorgshield:shieldHit(dmg) then return end

	-- dispel
	if damageType == "dispel" and not self:hasTrait("elemental") then return end

	local onDamageReturn = self:callHook("onDamage", dmg, damageType)
	if onDamageReturn then
		dmg = onDamageReturn[2]
		if onDamageReturn[1] == false then
			return
		end
	end

	-- remember who hit us
	local c = nil
	if not champion then
		for i=0,3 do
			if bit.band(damageFlags, bit.lshift(DamageFlags.Champion1, i)) ~= 0 then
				c = i + 1
				champion = party.champions[c]
				self:setMonsterFlag(bit.lshift(MonsterFlag.DamagedByChampion1, i), true)
			end
		end
	end

	if isSpell then
		local onSpellDamageReturn = self:callHook("onSpellDamage", dmg, damageType, objectToProxy(champion), objectToProxy(attack), heading)
		if onSpellDamageReturn then
			if onSpellDamageReturn[1] == false then
				return
			end
			dmg = onSpellDamageReturn[2]
			heading = onSpellDamageReturn[3] or heading
		end
	end

	-- crits & fumbles
	if champion and isSpell and dmg > 0 then
		local critChance = champion:getCritChanceWithSpell(attack, damageType, target) / 100
		if math.random() < critChance / 100 then
			crit = true
			dmg = dmg * (champion.stats.critical_multiplier.current / 100)
			heading = "Critical"
		end
	end

	-- trait modifiers
	if champion and isSpell then
		for name,skill in pairs(dungeon.skills) do
			if skill.onComputeChampionSpellDamage then
				local modifier = skill.onComputeChampionSpellDamage(objectToProxy(self), objectToProxy(champion), objectToProxy(spell), dmg, damageType, champion:getSkillLevel(name))
                if modifier then
					assert(modifier and type(modifier)=="table", "Bad onComputeChampionSpellDamage return value")
                    if modifier[1] == false then return end
					dmg = modifier[2]
					heading = modifier[3] or heading
				end
			end
		end

		for name,trait in pairs(dungeon.traits) do
			if trait.onComputeChampionSpellDamage then
				local modifier = trait.onComputeChampionSpellDamage(objectToProxy(self), objectToProxy(champion), objectToProxy(spell), dmg, damageType, iff(champion:hasTrait(name), 1, 0))
                if modifier then
					assert(modifier and type(modifier)=="table", "Bad onComputeChampionSpellDamage return value")
                    if modifier[1] == false then return end
					dmg = modifier[2]
					heading = modifier[3] or heading
				end
			end
		end
	end

	dmg = math.ceil(dmg)
	
	if spell then
		self:hitTriggers(champion, nil, spell, nil, nil, dmg, damageType)
	end
	
	if dmg >= 0 then
		self.health = self.health - dmg
	else
		-- absorb
		self.health = math.min(self.health - dmg, self:getMaxHealth())
	end

	-- play get hit effects
	if bit.band(damageFlags, DamageFlags.Impact) ~= 0 then
		-- play get hit animation?
		if dmg > 0 and self.currentAction == nil then
			local anim
			if side == "front_left" then
				anim = "getHitFrontLeft"
			elseif side == "front_right" then
				anim = "getHitFrontRight"
			elseif side == "left" then
				anim = "getHitLeft"
			elseif side == "right" then
				anim = "getHitRight"
			elseif side == "back" then
				anim = "getHitBack"
			else
				error("invalid get hit side")
			end
			
			-- create get hit action
			if not self.go.damaged then
				self.go:createComponent(MonsterActionComponent, "damaged")
			end
			
			self.go.damaged:setAnimation(anim)
			self:performAction("damaged")
		end

		if self:hasCondition("frozen") then
			self.go:playSound("ice_hit")
		else
			if self.hitSound then self.go:playSound(self.hitSound) end
		end
	end
	
	-- show damage in hud
	local color
	if heading then
		color = Color.White
	else
		color = Color.Grey
	end

	if resist == "weak" or resist == "vulnerable" then color = Color.Red end
	local showDamage = true
	if dmg == 0 and bit.band(damageFlags, DamageFlags.OngoingDamage) ~= 0 then showDamage = false end
	if not result then showDamage = false end
	if showDamage then
		if dmg >= 0 and dmg < 9999 then
			self:showDamageText(dmg, color, heading)
		elseif dmg < 0 then
			self:showDamageText(-dmg, {0,200,0,255}, heading)
		else
			self:showDamageText("", Color.Red, heading)
		end
	end

	if self.health > 0 then
		if dmg > 0 then self.go:sendMessage("onMonsterDamaged", dmg, damageType) end
		
		-- play get hit particle effect
		if bit.band(damageFlags, DamageFlags.Impact) ~= 0 and bit.band(damageFlags, DamageFlags.NoLingeringEffects) == 0 then
			if dmg > 0 then
				if damageType == "physical" and impactPos then
					self:playHitEffect(impactPos)
				elseif damageType == "fire" then
					self:playParticleEffect("damage_fire")
				elseif damageType == "shock" then
					self:playParticleEffect("damage_shock")
				end
			end
		end
	else
		local rval
		if champion then
			rval = self:killTriggers(champion, weapon, attack, dmg, heading)
		end
		if (rval ~= nil and rval == false) or rval == nil then
			-- freeze monster if death from cold
			if not self:hasCondition("frozen") and damageType == "cold" then
				self:setCondition("frozen", 1)
			end
			
			local gainExp = false
			local anyChampion = DamageFlags.Champion1 + DamageFlags.Champion2 + DamageFlags.Champion3 + DamageFlags.Champion4
			local gainExp = bit.band(damageFlags, anyChampion) ~= 0

			self:die(gainExp)
		else
			self.health = 1
		end
	end
	return dmg
end

function MonsterComponent:killTriggers(champion, weapon, attack, dmg, heading)
	-- Death triggers here
	local isSpell = attack and attack.go and (attack.go.tiledamager or attack.go.cloudspell)
	local isAttack = attack and not isSpell
	local attackType = isAttack and attack:getAttackType() or isSpell and "spell"
	local crit = heading == "Critical"
	local backstab = heading == "Backstab"
	local rval
	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onKillTrigger then
			local modifier = skill.onKillTrigger(objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), attackType, dmg, crit, backstab, objectToProxy(self), champion:getSkillLevel(name))
			if modifier ~= nil then
				rval = modifier
			end
		end
	end

	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onKillTrigger then
			local modifier = trait.onKillTrigger(objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), attackType, dmg, crit, backstab, objectToProxy(self), iff(champion:hasTrait(name), 1, 0))
			if modifier ~= nil then
				rval = modifier
			end
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = champion:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(champion, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onKillTrigger then
						local modifier = comp:onKillTrigger(champion, weapon, attack, attackType, dmg, crit, backstab, self)
						if modifier ~= nil then
							rval = modifier
						end
					end
				end
			end
		end
	end

	return rval
end

function MonsterComponent:getChampionAttackDamageModifier(champion, weapon, attack, dmg, damageType, crit, backstab)
	local rval = {}
	local result, heading
	local dmgMulti = 1
	if not champion then return nil end
	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onComputeChampionAttackDamage then
			local modifier = skill.onComputeChampionAttackDamage(objectToProxy(self), objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), dmg, damageType, crit, backstab, champion:getSkillLevel(name))
			if modifier then
				if type(modifier) == "table" then
					if result == nil or result == true then result = modifier[1] end
					if modifier[2] and modifier[2] ~= dmg then dmgMulti = dmgMulti + (modifier[2] / dmg) - 1 end
					heading = modifier[3] ~= nil and modifier[3] or heading
					crit = modifier[4] ~= nil and modifier[4] or crit
					backstab = modifier[5] or backstab
					damageType = modifier[6] or damageType
				elseif type(modifier) == "number" then
					dmgMulti = dmgMulti * modifier
				end
			end
		end
	end
	
	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onComputeChampionAttackDamage then
			local modifier = trait.onComputeChampionAttackDamage(objectToProxy(self), objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), dmg, damageType, crit, backstab, iff(champion:hasTrait(name), 1, 0))
			if modifier then
				if type(modifier) == "table" then
					if result == nil or result == true then result = modifier[1] end
					if modifier[2] and modifier[2] ~= dmg then dmgMulti = dmgMulti + (modifier[2] / dmg) - 1 end
					heading = modifier[3] ~= nil and modifier[3] or heading
					crit = modifier[4] ~= nil and modifier[4] or crit
					backstab = modifier[5] or backstab
					damageType = modifier[6] or damageType
				elseif type(modifier) == "number" then
					dmgMulti = dmgMulti * modifier
				end
			end
		end
	end

	local checkedThrownWeapon = false
	if weapon and weapon:hasTrait("throwing_weapon") then
		local it = weapon
		if it.go.equipmentitem and not it.go.equipmentitem:isEquipped(champion, i) then
			for i=1,it.go.components.length do
				local comp = it.go.components[i]
				if comp.onComputeChampionAttackDamage then
					local modifier = comp:onComputeChampionAttackDamage(self, champion, weapon, attack, dmg, damageType, crit, backstab, level)
					if modifier then
						if type(modifier) == "table" then
							if result == nil or result == true then result = modifier[1] end
							if modifier[2] and modifier[2] ~= dmg then dmgMulti = dmgMulti + (modifier[2] / dmg) - 1 end
							heading = modifier[3] ~= nil and modifier[3] or heading
							crit = modifier[4] ~= nil and modifier[4] or crit
							backstab = modifier[5] or backstab
							damageType = modifier[6] or damageType
						elseif type(modifier) == "number" then
							dmgMulti = dmgMulti * modifier
						end
					end
					checkedThrownWeapon = true
				end
			end
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = champion:getItem(i)
		if it and not (checkedThrownWeapon == true and it == weapon) then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(champion, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onComputeChampionAttackDamage then
						local modifier = comp:onComputeChampionAttackDamage(self, champion, weapon, attack, dmg, damageType, crit, backstab, level)
						if modifier then
							if type(modifier) == "table" then
								if result == nil or result == true then result = modifier[1] end
								if modifier[2] and modifier[2] ~= dmg then dmgMulti = dmgMulti + (modifier[2] / dmg) - 1 end
								heading = modifier[3] ~= nil and modifier[3] or heading
								crit = modifier[4] ~= nil and modifier[4] or crit
								backstab = modifier[5] or backstab
								damageType = modifier[6] or damageType
							elseif type(modifier) == "number" then
								dmgMulti = dmgMulti * modifier
							end
						end
					end
				end
			end
		end
	end

	dmg = dmg * dmgMulti
	return { result, dmg, heading, crit, backstab, damageType }
end


extendProxyClass(MonsterAttackComponent, "type") 

function MonsterAttackComponent:attackParty()
	local monster = self.go.monster
	local direction = self.go.facing

	if self.direction ~= "front_left" and self.direction ~= "front_right" then
		direction = (direction + self.direction) % 4
	end

	-- compute side
	
	local side = monster:getSide()
	if not side then side = math.random(0,1) end
	
	-- choose champion to attack
	local target = party:getAttackTarget((direction + 2) % 4, side)
	if not target then return end
	
	-- evasion
	if self.accuracy and self.accuracy < 100 then
		local roll = math.random(1,100)

		local accuracy = self.accuracy + DifficultyLevels[config.difficulty].monsterAccuracy
		if monster:hasCondition("blinded") then accuracy = accuracy - 30 end
		local hitRoll = roll + accuracy + monster.luck

		local tohit = 15 + target:getEvasion()
		local hits = (roll > 5 and hitRoll >= tohit) or roll >= 92

		-- debug
		--print("ROLL "..roll.." + ACCURACY "..accuracy.." + LUCK "..monster.luck.." = "..hitRoll.." "..iff(hits, "HITS", "MISS"))

		if hits then
			-- hit -> decrease luck
			monster.luck = math.max(monster.luck - 10, -20)
		else
			-- miss -> increase luck
			monster.luck = math.min(monster.luck + 5, 20)
			return
		end
	end
	
	if self:callHook("onAttackHit", objectToProxy(target)) == false then return end
	
	-- attack power
	local attackPower = self.attackPower or 0
	
	-- automatic crit if party is resting
	if party:isResting() then attackPower = attackPower * 2 end

	-- compute damage
	local dmg = computeDamage(attackPower)
	dmg = dmg * DifficultyLevels[config.difficulty].damageMultiplier
	
	-- choose body part to attack (chest 31%, head 22%, legs 25%, feet 22%)
	local r = math.random(1, 100)
	local bodySlot
	if r <= 31 then
		bodySlot = ItemSlot.Chest
	elseif r <= 31+22 then
		bodySlot = ItemSlot.Head
	elseif r <= 31+22+25 then
		bodySlot = ItemSlot.Legs
	else
		bodySlot = ItemSlot.Feet
	end
	--print("body slot: ", bodySlot)
	
	-- damage reduction
	local protection = target:getProtectionForBodyPart(bodySlot)
	if self.pierce then protection = math.max(protection - self.pierce, 0) end
	if protection > 0 then dmg = computeDamageReduction(dmg, protection) end

	if self.type then
		for k, v in pairs(self.type) do
			local eleDmg = v * (1 - (target:getResistance(k) / 100))
			eleDmg = math.floor(eleDmg)
			target:damage(eleDmg, k, nil, self.go.monster)
		end
	end

	dmg = math.floor(dmg)
	
	if dmg > 0 then
		if self:callHook("onDealDamage", objectToProxy(target), dmg) == false then return end

		-- cause condition
		if self.causeCondition then
			local chance = self.conditionChance or 50
			if math.random(1,100) <= chance then
				target:setCondition(self.causeCondition)
			end
		end

		-- wound chance
		if self.woundChance then
			local slot = bodySlot
			-- small chance to inflict hand wound
			local r = math.random(1,11)
			if r == 1 then slot = ItemSlot.Weapon end
			if r == 2 then slot = ItemSlot.OffHand end
			woundChampion(target, self.woundChance, slot)
		end

		-- shake camera
		if self.cameraShake then
			party:shakeCamera(self.cameraShakeIntensity or 0.5, self.cameraShakeDuration or 0.3)
		end
		
		-- screen effect
		if self.screenEffect then
			party:playScreenEffect(self.screenEffect)
		end

		local damageType = self.damageType or "physical"
		
		self.go:sendMessage("onMonsterHitChampion", target, dmg, damageType)
		target:damage(dmg, damageType, nil, self.go.monster)
		party:wakeUp(true)
		
		if self.knockback then
			party:knockback(self.go.facing)
		end
		
		-- play impact sound
		if self.impactSound then self.go:playSound(self.impactSound) end
		
		-- play damage sound
		if target:isAlive() then target:playDamageSound() end
	end
end

function MonsterComponent:getResistanceDamageMultiplier(resist, damageType)
	if not damageType then damageType = "physical" end
	local multiplier = 1
	local reduction = self:getResistanceReduction(resist, damageType)
	if resist == "immune" then
		multiplier = 0
		reduction = reduction / 2
	elseif resist == "vulnerable" then
		multiplier = 2
	elseif resist == "weak" then
		multiplier = 1.5
	elseif resist == "resist" then
		multiplier = 0.5
	elseif resist == "absorb" then
		multiplier = -1
		reduction = reduction / 2
	end
	
	return multiplier + reduction
end

function MonsterComponent:getResistanceReduction(resist, damageType)
	if self.resistanceReduction then
		return (self.resistanceReduction[element] or 0) / 100
	end
	return 0
end

function MonsterComponent:showDamageText(text, color, flags)
	if self.go.map == party.go.map and not party:isResting() and not config.disableDamageTexts then
		if type(color) == "string" then color = hexToColor(tonumber(color, 16)) end

		local pos = self:getCenterPoint()
		local x,y = self.go.map:worldToMap(pos)
		if self.go.map:checkLineOfSight(party.go.x, party.go.y, x, y, self.go.elevation) then
			pos.y = pos.y + 0.3
			pos.x = pos.x + (math.random() - 0.5) * 1.125
			pos.z = pos.z + (math.random() - 0.5) * 1.125
			gui:addFloatingText(pos, text, color, flags)
		end
	end
end

function MonsterComponent:setConditionValue(name, value)
	return self:setCondition(name, value)
end

-------------------------------------------------------------------------------------------------------
-- Combat Functions                                                                                  --    
-------------------------------------------------------------------------------------------------------

function computeDamage(attackPower, modifier, variation)
    -- Updated in order to be able to affect the damage variation
	if type(modifier) == "number" then
		modifier = {modifier, modifier}
	end
	local min,max = getDamageRange(attackPower, modifier, variation)
	return math.max(math.random(min, max), 0)
end

-- Returns min and max damage.
function getDamageRange(attackPower, modifier, variation)
    -- Updated in order to be able to affect the damage variation and to directly affect the damage modifier min/max
	variation = variation or 0.5
	modifier = modifier or {0,0}
	
	if attackPower == 0 then return modifier[1],modifier[2] end
	
	if attackPower then
		local power = attackPower
		local min = math.max(math.floor( (power - power * variation) + (modifier[1] or 0) ), 1)
		local max = math.max(math.floor( (power + power * variation) + (modifier[2] or 0) ), 1)
		
		local minModded = math.clamp(min, 1, math.max(max - 1, 1))
		min = minModded
		local maxModded = math.clamp(max, min + 1, 999)
		
		return minModded,maxModded
	end
end

-- Damages all creatures in a tile
function damageTile(map, x, y, direction, elevation, damageFlags, damageType, power, screenEffect, hitCallback, hitContext)
	-- hit monster
	for _,monster in map:componentsAt(MonsterComponent, x, y) do
		local ent = monster.go
		if ent.elevation == elevation and not monster:getMonsterFlag(MonsterFlag.NonMaterial) and power and power > 0 then
			-- check temporal ice shards immunity
			local immune = bit.band(damageFlags, DamageFlags.DamageSourceIceShards) ~= 0 and monster.iceShardsImmunityTimer
			if not immune then 
				local side = computeSide(direction, ent.facing)
				local dmg = computeDamage(power)
				if prob(0.08) then dmg = dmg * 2 end
				
				-- compute approximate impact position
				local impactPos
				if bit.band(damageFlags, DamageFlags.Impact) ~= 0 then
					local dx,dy = getDxDy(direction)
					local pos = map:mapToWorld(x + dx, y + dy)
					impactPos = monster:findImpactPosition(pos)
				end

				local status
				if hitCallback then status = hitCallback(hitContext, "monster", monster, dmg, damageType) end
				
				local champion
				for c=0,3 do
					if bit.band(damageFlags, bit.lshift(DamageFlags.Champion1, c)) ~= 0 then
						champion = party:getChampionByOrdinal(c+1)
					end
				end
				
				if status ~= false then
					monster:damage(dmg, side, damageFlags, damageType, impactPos, heading, champion, weapon, hitContext, slot, dualWieldSide, false)
				end
			end
		end
	end

	-- hit obstacle
	-- avoid hitting just spawned obstacles in reaction to getting obstacle destroyed
	local obstacles
	for _,obstacle in map:componentsAt(ObstacleComponent, x, y) do
		if obstacle.go.elevation == elevation then
			if obstacles == nil then obstacles = {} end
			obstacles[#obstacles+1] = obstacle
		end
	end

	if obstacles then
		for i=1, #obstacles do
			local obstacle = obstacles[i]
			local dmg = computeDamage(power)
			local status
			if hitCallback then status = hitCallback(hitContext, "obstacle", obstacle, dmg, damageType) end
			if status ~= false and obstacle.go:sendMessage("onDamage", dmg, damageType) then
				obstacle:playHitEffects()
			end
		end
	end

	-- hit party?
	for _,party in map:componentsAt(PartyComponent, x, y) do
		if party.go.elevation == elevation then
			-- check temporal ice shards immunity
			local immune = bit.band(damageFlags, DamageFlags.DamageSourceIceShards) ~= 0 and party.iceShardsImmunityTimer
			if not immune then 
				local partyHit = false
				
				for i=1,4 do
					local dmg = 0
					if power and power > 0 then dmg = computeDamage(power) end
					
					-- halve damage for backrow
					if damageFlags and bit.band(damageFlags, DamageFlags.HalveBackRowDamage) ~= 0 and checkPartyCover(i, direction) then
						dmg = math.floor(dmg / 2)
					end
					
					local status
					if hitCallback then status = hitCallback(hitContext, "champion", party.champions[i], dmg, damageType) end

					if status ~= false then
						partyHit = true
						if dmg > 0 then party.champions[i]:damage(dmg, damageType, hitContext) end
					end
				end
				
				if partyHit then
					party:wakeUp(true)
					
					if screenEffect then
						party:playScreenEffect(screenEffect)
					end

					if bit.band(damageFlags, DamageFlags.CameraShake) ~= 0 then
						party:shakeCamera(0.5, 0.3)
					end
				end
			end
		end
	end
end

-------------------------------------------------------------------------------------------------------
-- Item Functions                                                                                    --    
-------------------------------------------------------------------------------------------------------

ItemComponent:autoSerialize("traits", "thrownByAttack", "data")

local oldItemInit = ItemComponent.init
function ItemComponent:init(go)
    oldItemInit(self, go)
    
	self.data = self.data or {} -- gonna be used to easily store new values into an item
end

function ItemComponent:setData(name, value)
	self.data[name] = value
end

function ItemComponent:getData(name)
	local rval = self.data[name]
	if rval and type(rval) == "table" and rval.value and rval.duration then
		rval = rval.value
	end
	return rval
end

function ItemComponent:addData(name, value)
	self.data[name] = (self.data[name] or 0) + value
end

function ItemComponent:equipItem(champion, slot)
	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onEquip then
			skill.onEquip(objectToProxy(self), objectToProxy(champion), slot, champion:getSkillLevel(name))
		end
	end

	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onEquip then
			trait.onEquip(objectToProxy(self), objectToProxy(champion), slot, iff(champion:hasTrait(name), 1, 0))
		end
	end

	if self.go.equipmentitem then
		for i=1,self.go.components.length do
			local comp = self.go.components[i]
			if comp.onEquip then
				comp:onEquip(champion, slot)
			end
		end
	end

	self.go:sendMessage("onEquipItem", champion, slot)
	-- call onEquipItem hook
	self:callHook("onEquipItem", objectToProxy(champion), slot)
end

function ItemComponent:unequipItem(champion, slot)
	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onUnequip then
			skill.onUnequip(objectToProxy(self), objectToProxy(champion), slot, champion:getSkillLevel(name))
		end
	end

	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onUnequip then
			trait.onUnequip(objectToProxy(self), objectToProxy(champion), slot, iff(champion:hasTrait(name), 1, 0))
		end
	end

	if self.go.equipmentitem then
		for i=1,self.go.components.length do
			local comp = self.go.components[i]
			if comp.onUnequip then
				comp:onUnequip(champion, slot)
			end
		end
	end

	self.go:sendMessage("onUnequipItem", champion, slot)
	-- call onUnequipItem hook
	self:callHook("onUnequipItem", objectToProxy(champion), slot)
end

function ItemComponent:getItemNameColor()
	local color = iff(self:hasTrait("epic"), {255,225,128,255}, Color.White)
	return color
end

function ItemComponent:dragItemToThrowZone(x, y)
	local champion = gameMode:getActiveChampion()
	if champion then	
		local vx,vy,vw,vh = gameMode:getViewport()
		local side = iff(x < vw/2, 0, 1)
		local origin = party.champions[side+1]:getChampionPositionInWorld(0.4)
		
		-- push forward so that item won't collide against a door behind us
		origin = origin + party:getWorldForward() * self:getBoundingRadius()
		
		local power = math.max(14 - self.weight, 10)
		local gravity = math.clamp(2 + self.weight*1.5, 4, 10)
		local velocityUp = 0
		local weapon = nil
		local attack = nil

		if self:hasTrait("throwing_weapon") then
			power = 14
			gravity = 1
			velocityUp = 0
			weapon = self
			attack = self.go.throwattack
		end

		self:throw(party, origin, party.go.facing, power, gravity, velocityUp)
        self.thrownByChampion = champion.ordinal
        -- store original weapon and attack data in projectile
		self.thrownByWeapon = weapon and weapon.go.id or nil
		self.thrownByAttack = attack and attack.name or nil
		champion.cooldownTimer[1] = math.max(champion.cooldownTimer[1], 1)
		champion.cooldownTimer[2] = math.max(champion.cooldownTimer[2], 1)
		soundSystem:playSound2D("swipe")
		return true
	end
end

function ItemComponent:projectileHitEntity(target)	
    -- Updated for extra hook goodness
	-- compute damage
	local dmg = self.projectileDamage or math.random(1,3)
	local damageType = self.projectileDamageType or "physical"
	local pierce = self.projectilePierce or 0
	local accuracy = self.projectileAccuracy or 0
	local critChance = self.projectileCritChance or 5
	local item, champion, weapon, attack, slot
	if self.thrownByChampion then
		champion = party:getChampionByOrdinal(self.thrownByChampion)
		item = champion:getItem(ItemSlot.Weapon); slot = ItemSlot.Weapon
		if not item then item = champion:getItem(ItemSlot.OffHand); slot = ItemSlot.OffHand end
		if not item then item = champion:getItem(ItemSlot.Weapon2); slot = ItemSlot.Weapon2 end
		if not item then item = champion:getItem(ItemSlot.OffHand2); slot = ItemSlot.OffHand2 end
		if item and item.go.id ~= self.thrownByWeapon then item = nil end
	end
	if item then weapon = item end

	if weapon == nil and self.thrownByWeapon then 
		item = dungeon:findEntity(self.thrownByWeapon)
		if item and item.item ~= self then weapon = item.item end
	end -- if you used a weapon to shoot the projectile and then removed that weapon, we find it in the world
	if weapon == nil then
		item = dungeon:findEntity(self.go.id)
		if item and item.item then weapon = item.item end
	end -- if there is no weapon that shot this projectile, the weapon is the projectile itself
	if weapon == nil then 
		item = gui:getMouseItem()
		if item then weapon = item end
	end -- if all fails, the weapon can only be in the mouse

	if weapon and self.thrownByAttack then
		attack = weapon.go:getComponent(self.thrownByAttack)
	end
	-- if there is no attack that shot this projectile, the attack is the throwAttack component of the projectile itself
	if attack == nil then
		if self.go.throwattack then
			attack = self.go.throwattack
		end
	end 
	if weapon and attack == nil then
		attack = weapon.go.rangedattack
	end 
	
	-- crits & fumbles
	local crit = false
	if math.random() < critChance/100 then
		if dmg > 0 then
			crit = true
		end
	elseif math.random() < 0.1 then
		dmg = math.floor(dmg / 2)
	end
	local heading = nil
	if crit then heading = "Critical" end
		
	if target.monster then
		local target = target.monster

		-- evasion
		if not target:hasCondition("sleep") and not target:hasCondition("frozen") then
			local tohit = 0
			if champion then
				tohit = champion:getToHitChanceWithAttack(weapon, attack, target, accuracy, damageType)
			else
				tohit = 60 + accuracy - (target.evasion or 0)
			end
			
			if math.random() > tohit / 100 or target.evasion >= 1000 then
				target:showDamageText("miss", Color.Grey)
				if champion then
					champion.luck = math.min(champion.luck + 3, 15)
				end
				self.go:playSound("impact_blunt")
				return "miss"
			end

			if champion then champion.luck = 0 end
		end
		
		local result = true
		if champion then
			local modifier = target:getChampionAttackDamageModifier(champion, weapon, attack, dmg, damageType, crit, nil)			
			if modifier then
				if type(modifier) == "table" then
					result = modifier[1]
					dmg = modifier[2] or dmg
					heading = modifier[3] ~= nil and modifier[3] or heading
					crit = modifier[4] ~= nil and modifier[4] or crit
					backstab = modifier[5] or backstab
					damageType = modifier[6] or damageType
				end
			end
		end

        if crit then
			if champion then
				local critMult = champion:getCritMultiplierWithAttack(weapon, attack, target) / 100
				dmg = dmg * critMult
			else
				dmg = dmg * 2
			end

			if dmg <= 0 then
				crit = false
			end
        end

		-- damage reduction
		local protection = target:getMonsterProtectionWithAttack(champion, weapon, attack, dmg, damageType, crit, nil, self)

		if protection > 0 then dmg = computeDamageReduction(dmg, protection) end

		-- hit monster
		local side = "front_left" -- TODO: compute side
		local impactPos = target:findImpactPosition(self.go:getWorldPosition())
		local damageFlags = DamageFlags.Impact
		
		if self.thrownByChampion then damageFlags = damageFlags + bit.lshift(DamageFlags.Champion1, self.thrownByChampion-1) end
		
		local returnValue = target:callHook("onProjectileHit", objectToProxy(self), objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), dmg, damageType, heading, crit)
		if returnValue then
			if returnValue[1] == false then return end
			dmg = returnValue[2] or dmg
			damageType = returnValue[3] or damageType
			heading = returnValue[4] or heading
		end
		
		target:damage(dmg, side, damageFlags, damageType, impactPos, heading, champion, weapon, attack, slot, 1, false, result, crit, backstab)

		self:callHook("onThrowAttackHitMonster", objectToProxy(target))

		target:hitTriggers(champion, weapon, attack, crit, nil, dmg, damageType)
				
		-- stick projectile into monster
		if target:isAlive() then
			local sharp = self:getItemFlag(ItemFlag.SharpProjectile)
			local fragile = self:getItemFlag(ItemFlag.FragileProjectile)
			
			if self.projectileDamage and sharp and not fragile then
				self.go.map:removeEntity(self.go)
				if self.convertToItemOnImpact then self.convertItem = true end
				target:addItem(self)
			end

			-- cause condition
			if self.causeCondition then
				if self.causeCondition == "knockback" then
					if not target:isFalling() and target:getCurrentAction() ~= "knockback" then
						target.go:setPosition(target.go.x,target.go.y,target.go.facing,target.go.elevation,target.go.level)
						target:knockback(self.go.facing or party.facing)
					end
				else
					local chance = self.conditionChance or 50
					if math.random(1,100) <= chance then
						local duration = nil
						if self.causeCondition == "frozen" then duration = 10 end
						target:setCondition(self.causeCondition, duration)

						-- mark condition so that exp is awarded if monster is killed by the condition
						local cond = target.go:getComponent(self.causeCondition)
						if cond and cond.setCausedByChampion then
							cond:setCausedByChampion(champion.ordinal)
						end
					end
				end
			end
		end

		if not target:isAlive() and self:hasTrait("leg_armor") then
			steamContext:unlockAchievement("full_monty")
		end
	elseif target.obstacle then
		-- hit obstacle
		target:sendMessage("onDamage", dmg)
		target.obstacle:playHitEffects()
	elseif target.party then
		-- hit party
		local target = party:getAttackTarget((self.go.facing+2) % 4, math.random(0,1))
		if target then
			if party:isHookRegistered("onProjectileHit") then
				if party:callHook("onProjectileHit", objectToProxy(target), objectToProxy(self), dmg, damageType) == false then
					return
				end
			end

			soundSystem:playSound2D("projectile_hit_party")
			party:wakeUp(true)
			target:damage(dmg, damageType, self)

			-- HACK: hard code medusa arrow, 20% chance to petrify
			if self.go.arch.name == "petrifying_arrow" then
				local petrified = math.random() < 0.2
				if petrified and target:isAlive() and not target:hasCondition("petrified") then
					target:setCondition("petrified")
				end
			end

			if target:isAlive() then target:playDamageSound() end
		end
	end	
end

-- function ItemActionComponent:getRequirementsText(champion)
-- 	if self.requirements then
-- 		local subLevel = 0
-- 		if champion then
-- 			if self.spell or self.go.runepanel then
-- 				if champion:getClass() == "wizard" then subLevel = 1 end
-- 			else
-- 				if champion:getClass() == "champion" then subLevel = 1 end
-- 			end
-- 		end
-- 		return Skill.formatRequirements(self.requirements, subLevel)
-- 	end
-- end

function ItemComponent:getTotalWeight()
	local weight = (self.weight or 0) * (self.count or 1)
	local champion = gameMode:getActiveChampion()
	-- add weight of contained items
	local container = self.go.containeritem
	if container then
		for _,it in container:contents() do
			-- local w = (it.weight or 0) * (it.count or 1)
			if container.onCalculateWeight then
				weight = weight + container:onCalculateWeight(it:getTotalWeight(), item, champion)
			else
				weight = weight + it:getTotalWeight()
			end
		end
	end
	return weight
end

function ItemComponent:canBeUsedByChampion(champion, slot)
	-- check two-handedness
	if self:hasTrait("two_handed") and not champion:hasTrait("two_handed_mastery") then
		-- check that the other slot is empty
		local otherSlot = iff(slot == ItemSlot.Weapon, ItemSlot.OffHand, ItemSlot.Weapon)
		if champion:getItem(otherSlot) then
			return false
		end
	end
	
	-- check any skill requirements for primary action
	if self.primaryAction then
		local action = self.go:getComponent(self.primaryAction)
		if action and not action:checkRequirements(champion, slot) then
			return false
		end
	end

	return true
end

function ItemComponent:modifyProjectile(newStats)
	for k, v in pairs(newStats) do
		self[k] = v
	end

end

function UsableItemComponent:onUseItem(champion)
	if self:canBeUsedByChampion(champion) then
		if self:callHook("onUseItem", objectToProxy(champion)) == false then return end

		for name,skill in pairs(dungeon.skills) do
			if skill.onUseItem then
				if skill.onUseItem(objectToProxy(champion), objectToProxy(self.go.item), champion:getSkillLevel(name)) == false then return end
			end
		end

		-- trait modifiers
		for name,trait in pairs(dungeon.traits) do
			if trait.onUseItem then
				if trait.onUseItem(objectToProxy(champion), objectToProxy(self.go.item), iff(champion:hasTrait(name), 1, 0)) == false then return end
			end
		end

		-- equipment modifiers (equipped items only)
		for i=1,ItemSlot.BackpackFirst-1 do
			local it = champion:getItem(i)
			if it then
				if it.go.equipmentitem and it.go.equipmentitem:isEquipped(champion, i) then
					for i=1,it.go.components.length do
						local comp = it.go.components[i]
						if comp.onUseItem then
							if comp:onUseItem(champion, self.go.item) == false then return end
						end
					end
				end
			end
		end

		if self.sound and self.sound ~= "none" then soundSystem:playSound2D(self.sound) end
		if self.nutritionValue then
			champion:modifyFood(self.nutritionValue)
		end
		
		-- preferred racial food
		if self.racialFood and self.racialFood == champion:getRace() then
			self:consumePreferredFood(champion)
		end

		messageSystem:sendMessageNEW("onChampionUsedItem", champion, self)

		if self.go.scrollitem then
			if self.go.scrollitem:getPages() > 0 then
				self.go.scrollitem:nextPage()
				return
			end
		end

		return true,self.emptyItem
	end
end

extendProxyClass(UsableItemComponent, "racialFood")

-------------------------------------------------------------------------------------------------------
-- EquipmentItem Functions                                                                           --    
-------------------------------------------------------------------------------------------------------

defineProxyClass{
	class = "EquipmentItemComponent",
	baseClass = "Component",
	description = "Implemented various modifiers to stats of an Champion when the item is equipped. The traits of an item define where the item can be equipped.",
	methods = {	
		{ "setSlot", "number" },
		{ "setStrength", "number" },
		{ "setDexterity", "number" },
		{ "setVitality", "number" },
		{ "setWillpower", "number" },
		{ "setProtection", "number" },
		{ "setEvasion", "number" },
		{ "setResistFire", "number" },
		{ "setResistCold", "number" },
		{ "setResistShock", "number" },
		{ "setResistPoison", "number" },
		{ "setHealth", "number" },
		{ "setEnergy", "number" },
		{ "setExpRate", "number" },
		{ "setFoodRate", "number" },
		{ "setHealthRegenerationRate", "number" },
		{ "setEnergyRegenerationRate", "number" },
		{ "setCooldownRate", "number" },
		{ "setAccuracy", "number" },
		{ "setDamage", "number" },
		{ "setCritChance", "number" },
		{ "setCritMultiplier", "number" },
		{ "setDualWielding", "number" },
		{ "getSlot" },
		{ "getStrength" },
		{ "getDexterity" },
		{ "getVitality" },		
		{ "getWillpower" },
		{ "getProtection" },
		{ "getEvasion" },
		{ "getResistFire" },
		{ "getResistCold" },
		{ "getResistShock" },
		{ "getResistPoison" },
		{ "getHealth" },
		{ "getEnergy" },
		{ "getExpRate" },
		{ "getFoodRate" },
		{ "getHealthRegenerationRate" },
		{ "getEnergyRegenerationRate" },
		{ "getCooldownRate" },
		{ "getAccuracy" }, 
		{ "getDamage" },
		{ "getCritChance" },
		{ "getCritMultiplier" },
		{ "getDualWielding" },
		{ "getMinDamageMod" },
		{ "getMaxDamageMod" },
		{ "setMinDamageMod", "number" },
		{ "setMaxDamageMod", "number" },
		{ "getThreat" },
		{ "setRequirements", "table"},
		{ "getRequirements" },
		{ "setRequirementsText", "string"},
		{ "getRequirementsText" },
		{ "setPierce", "number" },
		{ "getPierce" },
	},
	hooks = {
		"onRecomputeStats(self, champion)",
		"onRecomputeFinalStats(self, champion)",
		"onComputeAccuracy(self, champion, weapon, attack, attackType, monster)",
		"onComputeCritChance(self, champion, weapon, attack, attackType, monster)",
		"onComputeDamageModifier(self, champion, weapon, attack, attackType)",
		"onComputeDamageMultiplier(self, champion, weapon, attack, attackType)",
		"onCheckDualWielding(self, champion, weapon1, weapon2)",
		"onComputeDualWieldingModifier(self, champion, weapon, attack, attackType)",
		"onComputeBackstabMultiplier(self, champion, weapon, attack, dmg, damageType, crit)",
		"onComputeCritMultiplier(self, champion, weapon, attack, attackType, monster)",
		"onComputeChampionAttackDamage(self, monster, champion, weapon, attack, dmg, damageType, crit, backstab)",
		"onComputePierce(self, monster, champion, weapon, attack, projectile, dmg, damageType, crit, backstab)",
		"onComputeSpellCost(self, champion, name, cost, skill)",
		"onComputeCooldown(self, weapon, attack, attackType)",
		"onComputeSpellCooldown(self, champion, name, cost, skill)",
		"onComputeSpellDamage(self, champion, spell, name, cost, skill, trigger)",
		"onCastSpell(self, champion, name, cost, skill)",
		"onComputeBombPower(self, bombItem, champion, power, entity)",
		"onComputeConditionDuration(self, condition, champion, name, beneficial, harmful, transformation)",
		"onComputeConditionPower(self, condition, champion, name, beneficial, harmful, transformation)",
		"onComputeDamageTaken(self, champion, attack, attacker, attackType, dmg, dmgType, isSpell)",
		"onComputeMalfunctionChance(self, champion, weapon, attack, attackType)",
		"onComputeRange(self, champion, weapon, attack, attackType)",
		"onHitTrigger(self, champion, weapon, attack, attackType, dmg, damageType, crit, backstab, monster)",
		"onKillTrigger(self, champion, weapon, attack, attackType, dmg, crit, backstab, monster)",
		"onComputeBuildupTime(self, champion, weapon, attack, buildup, attackType)",
		"onComputePowerAttackCost(self, champion, weapon, attack, cost, attackType)",
		"onCheckWound(self, champion, wound, action, actionName, actionType)",
		"onComputeSpellCritChance(self, champion, damageType, monster)",
		"onComputeItemWeight(self, champion, equipped)",
		"onComputeToHit(self, monster, champion, weapon, attack, attackType, damageType, toHit)",
		"onRegainHealth(self, champion, isItem, amount)",
		"onRegainEnergy(self, champion, isItem, amount)",
		"onLevelUp(self, champion)",
		"onUseItem(self, champion, item)",
		"onPerformAddedDamage(self, champion, weapon, attack, attackType, damageType, monster, crit, backstab)",
		"onComputeItemStats(self, champion, slot, statName, statValue)",
		"onDataDurationEnds(self, champion, name, value)",
		"onBrewPotion(self, champion, potion, count, recipe)",
		"onJamTrigger(self, champion, item, jammed)",
		"onPerformAttack(self, champion, action, slot)",
		"onPostAttack(self, champion, weapon, action, slot)",
		"onEquip(self, champion, slot)",
		"onUnequip(self, champion, slot)",
		"onDeathTrigger(self, deadChampion, champion, attacker, attackerType)",
	},
}

extendProxyClass(EquipmentItemComponent, "critMultiplier")
extendProxyClass(EquipmentItemComponent, "criticalChance")
extendProxyClass(EquipmentItemComponent, "dualWielding")
extendProxyClass(EquipmentItemComponent, "minDamageMod")
extendProxyClass(EquipmentItemComponent, "maxDamageMod")
extendProxyClass(EquipmentItemComponent, "threat")
extendProxyClass(EquipmentItemComponent, "pierce")
extendProxyClass(EquipmentItemComponent, "requirements")
extendProxyClass(EquipmentItemComponent, "requirementsText")

EquipmentItemComponent:autoSerialize("requirements", "immunities", "skillModifiers")

function EquipmentItemComponent:recomputeStats(champion, slot)
	-- called at the beginning of each frame, updates champions stats
	if not self.enabled then return end
	
	if self:isEquipped(champion, slot) then
		local stats = champion.stats
		
		local championList = {
			"strength", "dexterity", "vitality", "willpower", "protection", "evasion", "resist_fire", "resist_cold", "resist_shock", "resist_poison", "exp_rate", "food_rate", "health_regeneration_rate", "energy_regeneration_rate", "cooldown_rate", "critical_chance", "critical_multiplier", "dual_wielding", "threat_rate", "pierce", "max_health", "max_energy"
		}

		local equipList = {
			"strength", "dexterity", "vitality", "willpower", "protection", "evasion", "resistFire", "resistCold", "resistShock", "resistPoison", "expRate", "foodRate", "healthRegenerationRate", "energyRegenerationRate", "cooldownRate", "criticalChance", "critMultiplier", "dualWielding", "threat", "pierce"
		}

		for _, name in pairs(championList) do
			local statValue = self[equipList[_]] or 0

			if string.match(name, "resist_*") then
				statValue = statValue + (self.resistAll or 0)
			end

			if name == "max_health" or name == "max_energy" then
				statValue = statValue + (self.health or 0)
			end

			-- Alters stat given by item
			if statValue ~= 0 then
				local statName = equipList[_]
				if statName then
					for name,skill in pairs(dungeon.skills) do
						if skill.onComputeItemStats then
							local rval = skill.onComputeItemStats(objectToProxy(self), objectToProxy(champion), slot, statName, statValue, champion:getSkillLevel(name))
							if rval and type(rval) == "number" then
								statValue = rval
							end
						end
					end
				
					for name,trait in pairs(dungeon.traits) do
						if trait.onComputeItemStats then
							local rval = trait.onComputeItemStats(objectToProxy(self), objectToProxy(champion), slot, statName, statValue, iff(champion:hasTrait(name), 1, 0))
							if rval and type(rval) == "number" then
								statValue = rval
							end
						end
					end

					-- equipment modifiers (equipped items only)
					for i=1,ItemSlot.BackpackFirst-1 do
						local it = champion:getItem(i)
						if it then
							if it.go.equipmentitem and it.go.equipmentitem:isEquipped(champion, i) then
								for i=1,it.go.components.length do
									local comp = it.go.components[i]
									if comp.onComputeItemStats then
										local rval = comp:onComputeItemStats(champion, slot, statName, statValue)
										if rval and type(rval) == "number" then
											statValue = rval
										end
									end
								end
							end
						end
					end
				end
			end

			stats[name].current = stats[name].current + statValue
		end
	end

	if EquipmentItemComponent.armorSetPieces then
		for i=1,#EquipmentItemComponent.armorSetPieces do
			local set = EquipmentItemComponent.armorSetPieces[i]
			if champion:isArmorSetEquipped(set) then
				if not champion:hasTrait( set .. "_set" ) then
					champion:addTrait( set .. "_set" )
				end
			else
				champion:removeTrait( set .. "_set" )
			end
		end
	end

	self:callHook("onRecomputeStats", objectToProxy(champion))
end

function EquipmentItemComponent:onComputeAccuracy(champion, weapon, attack, attackType, monster)
	if self.enabled then
		local modifier = self:callHook("onComputeAccuracy", objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType(), objectToProxy(monster))
		modifier = modifier or 0
		if self.accuracy then modifier = modifier + self.accuracy end
		return modifier
	end
end

function EquipmentItemComponent:onComputeCritChance(champion, weapon, attack, monster)
	if self.enabled then
		local modifier = self:callHook("onComputeCritChance", objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType(), objectToProxy(monster))
		modifier = modifier or 0
		if self.criticalChance then modifier = modifier + self.criticalChance end
		return modifier
	end
end

function EquipmentItemComponent:onComputeDamageModifier(champion, weapon, attack)
	if self.enabled then
		local retVal = self:callHook("onComputeDamageModifier", objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType())
		if not retVal then retVal = 0 end
		local modifier = {}
		if retVal and type(retVal) == "number" then
			modifier[1] = retVal
			modifier[2] = retVal
		elseif retVal and type(retVal) == "table" then
			return retVal
		end
		return modifier
	end
end

function EquipmentItemComponent:onComputeDamageMultiplier(champion, weapon, attack)
	if self.enabled then
		local modifier = self:callHook("onComputeDamageMultiplier", objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType())
		return modifier
	end
end

function EquipmentItemComponent:onCheckDualWielding(champion, weapon1, weapon2)
	if self.enabled then
		local modifier = self:callHook("onCheckDualWielding", objectToProxy(champion), objectToProxy(weapon1), objectToProxy(weapon2))
		return modifier
	end
end

function EquipmentItemComponent:onComputeDualWieldingModifier(champion, weapon, attack)
	if self.enabled then
		local modifier = self:callHook("onComputeDualWieldingModifier", objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType())
		return modifier
	end
end

function EquipmentItemComponent:onComputeBackstabMultiplier(champion, weapon, attack, dmg, damageType, crit)
	if self.enabled then
		local modifier = self:callHook("onComputeBackstabMultiplier", objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), dmg, damageType, crit)
		return modifier
	end
end

function EquipmentItemComponent:onComputeCritMultiplier(champion, weapon, attack, monster)
	if self.enabled then
		local modifier = self:callHook("onComputeCritMultiplier", objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), attack:getAttackType(), objectToProxy(monster))
		return modifier
	end
end

function EquipmentItemComponent:onComputeChampionAttackDamage(monster, champion, weapon, attack, dmg, damageType, crit, backstab)
	if self.enabled then
		local modifier = self:callHook("onComputeChampionAttackDamage", objectToProxy(monster), objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), dmg, damageType, crit, backstab)
		return modifier
	end
end

function EquipmentItemComponent:onComputePierce(monster, champion, weapon, attack, projectile, dmg, damageType, attackType, crit, backstab)
	if self.enabled then
		local attackType = attack and attack:getAttackType()
		local modifier = self:callHook("onComputePierce", objectToProxy(monster), objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), objectToProxy(projectile), dmg, damageType, attackType, crit, backstab)
		return modifier
	end
end

function EquipmentItemComponent:onRecomputeFinalStats(champion)
	if self.enabled then
		local modifier = self:callHook("onRecomputeFinalStats", objectToProxy(champion))
		return modifier
	end
end

function EquipmentItemComponent:onComputeCooldown(champion, weapon, attack, attackType)
	if self.enabled then
		local modifier = self:callHook("onComputeCooldown", objectToProxy(champion), objectToProxy(weapon), attack and objectToProxy(attack), attackType)
		return modifier
	end
end

function EquipmentItemComponent:onComputeSpellCost(champion, name, cost, skill)
	if self.enabled then
		local modifier = self:callHook("onComputeSpellCost", objectToProxy(champion), name, cost, skill)
		return modifier
	end
end

function EquipmentItemComponent:onComputeSpellCooldown(champion, name, cost, skill)
	if self.enabled then
		local modifier = self:callHook("onComputeSpellCooldown", objectToProxy(champion), name, cost, skill)
		return modifier
	end
end

function EquipmentItemComponent:onComputeSpellDamage(champion, spellObject, name, cost, skill, trigger)
	if self.enabled then
		local modifier = self:callHook("onComputeSpellDamage", objectToProxy(champion), objectToProxy(spellObject), name, cost, skill, trigger)
		return modifier
	end
end

function EquipmentItemComponent:onCastSpell(champion, name, cost, skill)
	if self.enabled then
		local modifier = self:callHook("onCastSpell", objectToProxy(champion), name, cost, skill)
		return modifier
	end
end

function EquipmentItemComponent:onComputeBombPower(bombItem, champion, power, entity)
	if self.enabled then
		local modifier = self:callHook("onComputeBombPower", objectToProxy(bombItem), objectToProxy(champion), power, entity)
		return modifier
	end
end

function EquipmentItemComponent:onComputeConditionDuration(condition, champion, name, beneficial, harmful, transformation)
	if self.enabled then
		local modifier = self:callHook("onComputeConditionDuration", condition, objectToProxy(champion), name, beneficial, harmful, transformation)
		return modifier
	end
end

function EquipmentItemComponent:onComputeConditionPower(condition, champion, name, beneficial, harmful, transformation)
	if self.enabled then
		local modifier = self:callHook("onComputeConditionPower", condition, objectToProxy(champion), name, beneficial, harmful, transformation)
		return modifier
	end
end

function EquipmentItemComponent:onComputeBearFormDuration(champion)
	if self.enabled then
		local modifier = self:callHook("onComputeBearFormDuration", objectToProxy(champion))
		return modifier
	end
end

-- Modifies damage taken by champion
function EquipmentItemComponent:onComputeDamageTaken(champion, attack, attacker, attackType, dmg, dmgType, isSpell)
	if self.enabled then
		local modifier = self:callHook("onComputeDamageTaken", objectToProxy(champion), objectToProxy(hitContext), objectToProxy(attacker), attackerType, dmg, dmgType, isSpell)
		return modifier
	end
end

function EquipmentItemComponent:onComputeMalfunctionChance(champion, weapon, attack, attackType)
	if self.enabled then
		local modifier = self:callHook("onComputeMalfunctionChance", objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), attackType)
		return modifier
	end
end

function EquipmentItemComponent:onComputeRange(champion, weapon, attack, attackType)
	if self.enabled then
		local modifier = self:callHook("onComputeRange", objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), attackType)
		return modifier
	end
end

function EquipmentItemComponent:onHitTrigger(champion, weapon, attack, attackType, dmg, damageType, crit, backstab, monster)
	if self.enabled then
		local modifier = self:callHook("onHitTrigger", objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), attackType, dmg, damageType, crit, backstab, objectToProxy(monster))
		return modifier
	end
end

function EquipmentItemComponent:onKillTrigger(champion, weapon, attack, attackType, dmg, crit, backstab, monster)
	if self.enabled then
		local modifier = self:callHook("onKillTrigger", objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), attackType, dmg, crit, backstab, objectToProxy(monster))
		return modifier
	end
end

function EquipmentItemComponent:onComputeBuildupTime(champion, weapon, attack, buildup, attackType)
	if self.enabled then
		local modifier = self:callHook("onComputeBuildupTime", objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), buildup, attackType)
		return modifier
	end
end

function EquipmentItemComponent:onComputePowerAttackCost(champion, weapon, attack, cost, attackType)
	if self.enabled then
		local modifier = self:callHook("onComputePowerAttackCost", objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), cost, attackType)
		return modifier
	end
end

function EquipmentItemComponent:onCheckWound(champion, wound, action, actionName, actionType)
	if self.enabled then
		local action = (action and type(action) ~= "string") and objectToProxy(action) or action
		local modifier = self:callHook("onCheckWound", objectToProxy(champion), wound, action, actionName, actionType)
		return modifier
	end
end

function EquipmentItemComponent:onComputeSpellCritChance(champion, spell, damageType, monster)
	if self.enabled then
		local modifier = self:callHook("onComputeSpellCritChance", objectToProxy(champion),  damageType, objectToProxy(monster))
		return modifier
	end
end

function EquipmentItemComponent:onComputeItemWeight(champion, equipped)
	if self.enabled then
		local modifier = self:callHook("onComputeItemWeight", objectToProxy(champion), equipped)
		return modifier
	end
end

function EquipmentItemComponent:onComputeToHit(monster, champion, weapon, attack, attackType, damageType, toHit)
	if self.enabled then
		local modifier = self:callHook("onComputeToHit", objectToProxy(monster), objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), attackType, damageType, toHit)
		return modifier
	end
end

function EquipmentItemComponent:onRegainHealth(champion, isItem, amount)
	if self.enabled then
		local modifier = self:callHook("onRegainHealth", objectToProxy(champion), isItem, amount)
		return modifier
	end
end

function EquipmentItemComponent:onRegainEnergy(champion, isItem, amount)
	if self.enabled then
		local modifier = self:callHook("onRegainEnergy", objectToProxy(champion), isItem, amount)
		return modifier
	end
end

function EquipmentItemComponent:onLevelUp(champion)
	if self.enabled then
		if self:callHook("onLevelUp", objectToProxy(champion)) == false then return false end
	end
end

function EquipmentItemComponent:onUseItem(champion, item)
	if self.enabled then
		if self:callHook("onUseItem", objectToProxy(champion), objectToProxy(item)) == false then return false end
	end
end

function EquipmentItemComponent:onPerformAddedDamage(champion, weapon, attack, attackType, damageType, crit, backstab)
	if self.enabled then
		local modifier = self:callHook("onPerformAddedDamage", objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), attackType, damageType, objectToProxy(monster), crit, backstab)
		return modifier
	end
end

function EquipmentItemComponent:onComputeItemStats(champion, slot, statName, statValue)
	if self.enabled then
		local modifier = self:callHook("onComputeItemStats", objectToProxy(champion), slot, statName, statValue)
		return modifier
	end
end

function EquipmentItemComponent:onDataDurationEnds(champion, name, value)
	if self.enabled then
		self:callHook("onDataDurationEnds", objectToProxy(champion), name, value)
	end
end

function EquipmentItemComponent:onBrewPotion(champion, potion, count, recipe)
	if self.enabled then
		self:callHook("onBrewPotion", objectToProxy(champion), potion, count, recipe)
	end
end

function EquipmentItemComponent:onJamTrigger(champion, item, jammed)
	if self.enabled then
		local champ
		if champion then champ = objectToProxy(champion) end
		self:callHook("onJamTrigger", champ, objectToProxy(item), jammed)
	end
end

function EquipmentItemComponent:onPerformAttack(champion, action, slot)
	if self.enabled then
		self:callHook("onPerformAttack", objectToProxy(champion), objectToProxy(action), slot)
	end
end

function EquipmentItemComponent:onPostAttack(champion, weapon, action, slot)
	if self.enabled then
		self:callHook("onPostAttack", objectToProxy(champion), objectToProxy(weapon), objectToProxy(action), slot)
	end
end

function EquipmentItemComponent:onEquip(champion, slot)
	if self.enabled then
		self:callHook("onEquip", objectToProxy(champion), slot)
	end
end

function EquipmentItemComponent:onUnequip(champion, slot)
	if self.enabled then
		self:callHook("onUnequip", objectToProxy(champion), slot)
	end
end

function EquipmentItemComponent:onDeathTrigger(deadChampion, champion, attacker, attackerType)
	if self.enabled then
		self:callHook("onDeathTrigger", objectToProxy(deadChampion), objectToProxy(champion), objectToProxy(attacker), attackerType)
	end
end

function EquipmentItemComponent:isEquipped(champion, slot)
	if not self.enabled then return false end

	local equipped = false

	if self.slot then
		-- item is considered to be equipped when it is placed in the specified slot
		equipped = (self.slot == slot)

		-- weapon and offhand slots are equal
		if self.slot == ItemSlot.Weapon and slot == ItemSlot.OffHand then equipped = true end
		if self.slot == ItemSlot.OffHand and slot == ItemSlot.Weapon then equipped = true end
	else
		-- slot not specified
		-- item is considered to be equipped when it is in non-hand slot
		equipped = 
			slot == ItemSlot.Head or
			slot == ItemSlot.Chest or
			slot == ItemSlot.Legs or
			slot == ItemSlot.Feet or
			slot == ItemSlot.Cloak or
			slot == ItemSlot.Necklace or
			slot == ItemSlot.Gloves or
			slot == ItemSlot.Bracers
	end

	-- no bonuses if slot is injured
	if champion:isBodyPartWounded(slot) then equipped = false end

	if equipped and not self.go.item:canBeUsedByChampion(champion, slot) then equipped = false end

	if (slot == ItemSlot.Weapon or slot == ItemSlot.OffHand) and champion:hasCondition("bear_form") then equipped = false end

	if not self:canBeUsedByChampion(champion) then
		equipped = false
	end
	
	return equipped
end

function EquipmentItemComponent:canBeUsedByChampion(champion)
	return (champion:isAlive() or self.canBeUsedByDeadChampion) and self:checkRequirements(champion)
end

function EquipmentItemComponent:checkRequirements(champion)
	return self.requirements == nil or Skill.checkRequirements(champion, self.requirements)
end

function EquipmentItemComponent:getRequirementsText()
	if self.requirements then
		return Skill.formatRequirements(self.requirements)
	end
end

-------------------------------------------------------------------------------------------------------
-- MeleeAttack Functions                                                                             --
-------------------------------------------------------------------------------------------------------

defineProxyClass{
	class = "MeleeAttackComponent",
	baseClass = "ItemActionComponent",
	description = "Implements melee attack action for items. Melee attacks can hit and damage a single target in front of the party.",
	methods = {
		{ "setAttackPower", "number" },
		{ "setAttackPowerVariation", "number" },
		{ "setAccuracy", "number" },
		{ "setCooldown", "number" },
		{ "setSwipe", "string" },
		{ "setAttackSound", "string" },
		{ "setDamageType", "string" },
		{ "setReachWeapon", "boolean" },
		{ "setSkill", "string" },
		{ "setRequiredLevel", "number" },
		{ "setBaseDamageStat", "string" },
		{ "setCauseCondition", "string" },
		{ "setConditionChance", "number" },
		{ "setPierce", "number" },
		{ "setUnarmedAttack", "boolean" },
		{ "setCameraShake", "boolean" },
		{ "getAttackPower" },
		{ "getAccuracy" },
		{ "getCooldown" },
		{ "getSwipe" },
		{ "getAttackSound" },
		{ "getDamageType" },
		{ "getReachWeapon" },
		{ "getSkill" },
		{ "getRequiredLevel" },
		{ "getBaseDamageStat" },
		{ "getCauseCondition" },
		{ "getConditionChance" },
		{ "getPierce" },
		{ "getUnarmedAttack" },
        { "getCameraShake" },
        { "setBaseDamageMultiplier", "number" },
		{ "getBaseDamageMultiplier" },
		{ "getMinDamageMod" },
		{ "getMaxDamageMod" },
		{ "setMinDamageMod", "number" },
		{ "setMaxDamageMod", "number" },
        { "setJamText", "string" },
        { "setJamChance", "number" },
		{ "getJamChance" },
		{ "setJammed", "boolean" },
		{ "getJammed" },
		{ "getAttackFire" },
		{ "getAttackCold" },
		{ "getAttackShock" },
		{ "getAttackPoison" },
	},
	hooks = {
		"onPostAttack(self, champion, slot)",
		"onHitMonster(self, monster, tside, damage, champion, crit, backstab)",
	},
}

extendProxyClass(MeleeAttackComponent, "pierce")
extendProxyClass(MeleeAttackComponent, "attackPowerVariation")
extendProxyClass(MeleeAttackComponent, "baseDamageMultiplier")
extendProxyClass(MeleeAttackComponent, "minDamageMod")
extendProxyClass(MeleeAttackComponent, "maxDamageMod")
extendProxyClass(MeleeAttackComponent, "jamChance")
extendProxyClass(MeleeAttackComponent, "jamCount")
extendProxyClass(MeleeAttackComponent, "jamText")
extendProxyClass(MeleeAttackComponent, "velocity")
extendProxyClass(MeleeAttackComponent, "attackFire")
extendProxyClass(MeleeAttackComponent, "attackCold")
extendProxyClass(MeleeAttackComponent, "attackShock")
extendProxyClass(MeleeAttackComponent, "attackPoison")

function MeleeAttackComponent:start(champion, slot, chainIndex)
	local weapon = champion:getItem(slot)
	if champion:hasCondition("bear_form") then weapon = nil end
	
	if not champion:getDamage(slot) then
		console:warn("no attack power")
		return
	end

	if self.unarmedAttack then
		party.go.statistics:increaseStat("unarmed_attacks", 1)
	else
		party.go.statistics:increaseStat("melee_attacks", 1)
	end
	
	local dualWield = champion:isDualWielding()
	local dualWieldSide = iff(dualWield, slot, nil)

	-- Melee weapons could jam if you wanted to
	if self.jamChance then
		local chance = self.jamChance * champion:getMalfunctionChanceWithAttack(weapon, self, "melee")
		if not weapon:getJammed() and math.random(1, 100) <= chance then
			weapon:setJammed(true, champion)
			weapon.jamCount = math.random(2, 6)
		end
	end
	
	-- fix jammed weapon
	if weapon and weapon:getJammed() then
		weapon.jamCount = (weapon.jamCount or 3) - 1
		if weapon.jamCount < 0 then
			weapon:setJammed(false, champion)
			weapon.jamCount = nil
		end
	end

	if weapon and weapon:getJammed() then
		soundSystem:playSound2D("firearm_jammed")
		champion:showAttackResult(self.jamText or "Jammed!", nil, dualWieldSide)
		return
	end

	-- consume food
	champion:consumeFood(0.5 + math.random() * 2)

	-- cooldown
	local cooldown = (self.cooldown or 0) * champion:getCooldownWithAttack(weapon, self, "melee")
	
	if dualWield then
		if slot == ItemSlot.Weapon then
			champion.cooldownTimer[1] = math.max(champion.cooldownTimer[1], cooldown)
		else
			champion.cooldownTimer[2] = math.max(champion.cooldownTimer[2], cooldown)
		end
	else
		champion.cooldownTimer[1] = math.max(champion.cooldownTimer[1], cooldown)
		champion.cooldownTimer[2] = math.max(champion.cooldownTimer[2], cooldown)
	end
	
	party:endCondition("invisibility")
		
	-- play swipe effect
	if self.swipe then
		local swipe = self.swipe
		if swipe == "flurry" then
			swipe = iff(chainIndex == 1, "vertical", "horizontal")
		end
		local side = iff(champion.championIndex == 1 or champion.championIndex == 3, 0, 1)	
		party.swipes[swipe]:play(side)
	end
	
	-- play sound
	if self.attackSound then
		champion:playSound(self.attackSound)
	end

	if self.cameraShake then
		party:shakeCamera(0.5, 0.3)
	end

	-- get source and target tiles for attack
	local x,y = party.go.map:worldToMap(party.go:getWorldPosition())
	local dx,dy = getDxDy(party.go.facing)
	local tx = x + dx
	local ty = y + dy
	
	local map = party.go.map

	-- check reach
	if champion.championIndex == 3 or champion.championIndex == 4 then
		if not self.reachWeapon and not champion:hasTrait("reach") then
			champion:showAttackResult("Can't reach")
			return
		end
	end

	-- hit wall
	if map:isWall(tx,ty) or map:getElevation(tx,ty) > party.go.elevation or map:isForceField(x, y, party.go.elevation) then
		if self.unarmedAttack then
			soundSystem:playSound2D("impact_punch")
		else
			if self.go.item.impactSound then soundSystem:playSound2D(self.go.item.impactSound) end
		end
		champion:showAttackResult("Miss", GuiItem.HitSplash, dualWieldSide)
		return
	end

	-- hit door	
	local door = map:findDoor(x, y, party.go.facing, party.go.elevation)
	if door and not door:isPassable() then
		if door:onAttackedByChampion(champion, weapon, self, slot, dualWieldSide) then
			return
		end
	end

	-- hit force field
	for _,f in map:componentsAt(ForceFieldComponent, tx, ty) do
		if f.enabled then
			if f:onAttackedByChampion(champion, weapon, self, slot, dualWieldSide) then
				return
			end
		end
	end	

	-- hit obstacle first (so that monsters inside obstacles get cover)
	for _,obstacle in map:componentsAt(ObstacleComponent, tx, ty) do
		if obstacle.enabled then
			if obstacle:onAttackedByChampion(champion, weapon, self, slot, dualWieldSide) then
				return
			end
		end
	end	

	-- hit monster
	for _,monster in map:componentsAt(MonsterComponent, tx, ty) do
		local fullHealth = monster:getHealth() == monster:getMaxHealth()
		if monster:onAttackedByChampion(champion, weapon, self, slot, dualWieldSide) then
			-- unstoppable achievement: kill monster with a single blow
			if fullHealth and not monster:isAlive() then
				steamContext:unlockAchievement("unstoppable")
			end
			if not monster:isAlive() and not weapon then
				steamContext:unlockAchievement("fist_fighter")
			end
			return
		end
	end	

	champion:showAttackResult("Miss", GuiItem.HitSplash, dualWieldSide)

	-- HACK: self.go is nil for bear claw attacks
	if self.go then
		self:callHook("onPostAttack", objectToProxy(champion), slot)
	end
end

-------------------------------------------------------------------------------------------------------
-- RangedAttack Functions                                                                            --    
-------------------------------------------------------------------------------------------------------

defineProxyClass{
	class = "RangedAttackComponent",
	baseClass = "ItemActionComponent",
	description = "Implements missile attack action for items. Missile attacks require ammo that must be held in champion's other hand.",
	methods = {
		{ "setAttackPower", "number" },
		{ "setAttackPowerVariation", "number" },
		{ "setCooldown", "number" },
		{ "setSwipe", "string" },
		{ "setAttackSound", "string" },
		{ "setSkill", "string" },
		{ "setRequiredLevel", "number" },
		{ "setAmmo", "string" },
		{ "setBaseDamageStat", "string" },
		{ "setDamageType", "string" },
		{ "setProjectileItem", "string" },
		{ "getAttackPower" },
		{ "getAttackPowerVariation" },
		{ "getCooldown" },
		{ "getSwipe" },
		{ "getAttackSound" },
		{ "getSkill" },
		{ "getRequiredLevel" },
		{ "getAmmo" },
		{ "getBaseDamageStat" },
		{ "getDamageType" },
		{ "getProjectileItem" },
		{ "setBaseDamageMultiplier", "number" },
		{ "getBaseDamageMultiplier" },
		{ "getMinDamageMod" },
		{ "getMaxDamageMod" },
		{ "setMinDamageMod", "number" },
		{ "setMaxDamageMod", "number" },
		{ "setPierce", "number" },
		{ "getPierce" },
        { "setJamText", "string" },
		{ "setJamChance", "number" },
		{ "getJamChance" },
		{ "setJammed", "boolean" },
		{ "getJammed" },
		{ "setCritMultiplier", "number" },
		{ "getCritMultiplier" },
	},
	hooks = {
		"onPostAttack(self, champion, slot)",
	},
}

extendProxyClass(RangedAttackComponent, "pierce")
extendProxyClass(RangedAttackComponent, "critChance")
extendProxyClass(RangedAttackComponent, "critMultiplier")
extendProxyClass(RangedAttackComponent, "attackPowerVariation")
extendProxyClass(RangedAttackComponent, "baseDamageMultiplier")
extendProxyClass(RangedAttackComponent, "minDamageMod")
extendProxyClass(RangedAttackComponent, "maxDamageMod")
extendProxyClass(RangedAttackComponent, "jamChance")
extendProxyClass(RangedAttackComponent, "jamCount")
extendProxyClass(RangedAttackComponent, "jamText")
extendProxyClass(RangedAttackComponent, "velocity")
extendProxyClass(RangedAttackComponent, "attackFire")
extendProxyClass(RangedAttackComponent, "attackCold")
extendProxyClass(RangedAttackComponent, "attackShock")
extendProxyClass(RangedAttackComponent, "attackPoison")

local oldRangedAttackComponentInit = RangedAttackComponent.init
function RangedAttackComponent:init(go)
	oldRangedAttackComponentInit(self, go)
	self.pierce = 0
	self.jamChance = 0
end

function RangedAttackComponent:start(champion, slot)
	local weapon = champion:getItem(slot)
	local dualWield = champion:isDualWielding()
	local dualWieldSide = iff(dualWield, slot, nil)

	-- cooldown
	local cooldown = (self.cooldown or 0) * champion:getCooldownWithAttack(weapon, self, "missile")

	-- Missile weapons could jam if you wanted to
	if self.jamChance then
		local chance = self.jamChance * champion:getMalfunctionChanceWithAttack(weapon, self, "missile")
		if not weapon:getJammed() and math.random(1, 100) <= chance then
			weapon:setJammed(true, champion)
			weapon.jamCount = math.random(2, 6)
		end
	end
	
	-- fix jammed weapon
	if weapon:getJammed() then
		weapon.jamCount = (weapon.jamCount or 3) - 1
		if weapon.jamCount < 0 then
			weapon:setJammed(false, champion)
			weapon.jamCount = nil
		end
	end

	if weapon:getJammed() then
		soundSystem:playSound2D("firearm_jammed")
		champion:showAttackResult(self.jamText or "Jammed!", nil, dualWieldSide)
		return
	end
	
	-- check ammo
	local ammo, ammoSlot = champion:checkAmmoSlot(self, slot, dualWieldSide)
	if not ammo then
		return
    end

	-- check dual wielding
	if dualWield then
		if slot == ItemSlot.Weapon then
			champion.cooldownTimer[1] = math.max(champion.cooldownTimer[1], cooldown)
		else
			champion.cooldownTimer[2] = math.max(champion.cooldownTimer[2], cooldown)
		end
	else
		champion.cooldownTimer[1] = math.max(champion.cooldownTimer[1], cooldown)
		champion.cooldownTimer[2] = math.max(champion.cooldownTimer[2], cooldown)
	end

	-- consume energy
	if math.random() < 0.8 then
		local cost = self.cooldown * (math.random() * 0.6 + 0.4)
		cost = math.floor(cost + 0.5)
		--print("consume energy: "..cost)
		champion:modifyBaseStat("energy", -cost)
	end

	-- consume food
	champion:consumeFood(0.5 + math.random() * 2)

	party:endCondition("invisibility")

	party.go.statistics:increaseStat("missile_attacks", 1)
	
	-- play sound
	if self.attackSound then
		champion:playSound(self.attackSound)
	end	

	local count = 1
	
	for i=1,count do
		if not ammo then return end
		ammo = ammo.go.item
		
		-- determine damage
		-- note: this has to be done before removing the ammo from hand!
		local dmg = computeDamage(champion:getDamageWithAttack(self.go.item, self))

		-- split stack
		if ammo.stackable and ammo.count > 1 then
			ammo = ammo:splitStack(1)
		else
			-- shoot last
			champion:removeItemFromSlot(ammoSlot)
			if ammoSlot == ItemSlot.Weapon then
				champion.autoEquipEmptyHand = ammo.go.arch.name
			else
				champion.autoEquipOffHand = ammo.go.arch.name
			end
		end

		local side = iff(champion.championIndex == 1 or champion.championIndex == 3, 0, 1)
		local power = 14
		local gravity = 1
		local pos = champion:getChampionPositionInWorld(0.4) 
		
		-- push forward so that item won't collide against a door behind us
		pos = pos + party:getWorldForward() * ammo:getBoundingRadius()

		-- separate missiles if shooting multiple missiles
		if i > 1 then
			pos = pos + party:getWorldForward() * (i-1) * 0.9
			if i == 2 then
				pos.y = pos.y - 0.1
			elseif i == 3 then
				pos.y = pos.y + 0.1
			end
		end
		
		-- convert projectile type (e.g. normal arrow to fire arrow)
		if self.projectileItem then
			ammo = create(self.projectileItem).item
		end
		
		ammo:throw(party, pos, party.go.facing, power, gravity, 0)
		ammo:setItemFlag(ItemFlag.AutoPickUp, true)
		ammo.projectileDamage = dmg
		ammo.projectileDamageType = self.damageType
		ammo.causeCondition = ammo.go.ammoitem.causeCondition
		ammo.conditionChance = ammo.go.ammoitem.conditionChance
		ammo.projectileAccuracy = champion:getAccuracyWithAttack(weapon, self)
		ammo.projectileCritChance = champion:getCritChanceWithAttack(weapon, self)
		ammo.projectilePierce = self.pierce or 0
		ammo.go.projectile:setVelocity(ammo.go.projectile:getVelocity() * (1+(self.velocity or 0)))
        ammo.thrownByChampion = champion.ordinal
        -- store original weapon and attack data in projectile
		ammo.thrownByWeapon = weapon.go.id
		ammo.thrownByAttack = self.name
	end
	
	champion:showAttackResult("Shoot", nil, dualWieldSide)
	self:callHook("onPostAttack", objectToProxy(champion), slot)
end

-------------------------------------------------------------------------------------------------------
-- ThrowAttack Functions                                                                             --    
-------------------------------------------------------------------------------------------------------

defineProxyClass{
	class = "ThrowAttackComponent",
	baseClass = "ItemActionComponent",
	description = "Implements throw attack action for items. When thrown, a Projectile component is dynamically created and added to the thrown item.",
	methods = {
		{ "setAttackPower", "number" },
		{ "setAttackPowerVariation", "number" },
		{ "setCooldown", "number" },
		{ "setSwipe", "string" },
		{ "setAttackSound", "string" },
		{ "setSkill", "string" },
		{ "setRequiredLevel", "number" },
		{ "setBaseDamageStat", "string" },
		{ "getAttackPower" },
		{ "getAttackPowerVariation" },
		{ "getCooldown" },
		{ "getSwipe" },
		{ "getAttackSound" },
		{ "getSkill" },
		{ "getRequiredLevel" },
		{ "getBaseDamageStat" },
		{ "setBaseDamageMultiplier", "number" },
		{ "getBaseDamageMultiplier" },
		{ "getMinDamageMod" },
		{ "getMaxDamageMod" },
		{ "setMinDamageMod", "number" },
        { "setMaxDamageMod", "number" },
        { "setJamText", "string" },
        { "setJamChance", "number" },
		{ "getJamChance" },
		{ "setJammed", "boolean" },
		{ "getJammed" },
		{ "setCritMultiplier", "number" },
		{ "getCritMultiplier" },
		{ "getDamageType" },
	},
	hooks = {
		"onPostAttack(self, champion, slot)",
	}
}

extendProxyClass(ThrowAttackComponent, "critChance")
extendProxyClass(ThrowAttackComponent, "critMultiplier")
extendProxyClass(ThrowAttackComponent, "attackPowerVariation")
extendProxyClass(ThrowAttackComponent, "baseDamageMultiplier")
extendProxyClass(ThrowAttackComponent, "minDamageMod")
extendProxyClass(ThrowAttackComponent, "maxDamageMod")
extendProxyClass(ThrowAttackComponent, "jamChance")
extendProxyClass(ThrowAttackComponent, "jamCount")
extendProxyClass(ThrowAttackComponent, "jamText")
extendProxyClass(ThrowAttackComponent, "attackFire")
extendProxyClass(ThrowAttackComponent, "attackCold")
extendProxyClass(ThrowAttackComponent, "attackShock")
extendProxyClass(ThrowAttackComponent, "attackPoison")
extendProxyClass(ThrowAttackComponent, "damageType")

function ThrowAttackComponent:start(champion, slot)
	local weapon = champion:getItem(slot)
    party.go.statistics:increaseStat("throw_attacks", 1)
    local dualWield = champion:isDualWielding()
    local dualWieldSide = iff(dualWield, slot, nil)

	-- Throw weapons could jam if you wanted to
	if self.jamChance then
		local chance = self.jamChance * champion:getMalfunctionChanceWithAttack(weapon, self, "throw")
		if not weapon:getJammed() and math.random(1, 100) <= chance then
			weapon:setJammed(true, champion)
			weapon.jamCount = math.random(2, 6)
		end
	end
	
	-- fix jammed weapon
	if weapon:getJammed() then
		weapon.jamCount = (weapon.jamCount or 3) - 1
		if weapon.jamCount < 0 then
			weapon:setJammed(false, champion)
			weapon.jamCount = nil
		end
	end

	if weapon:getJammed() then
		soundSystem:playSound2D("firearm_jammed")
		champion:showAttackResult(self.jamText or "Jammed!", nil, dualWieldSide)
		return
	end
		
	-- consume energy
	if math.random() < 0.8 then
		local cost = self.cooldown * (math.random() * 0.6 + 0.4)
		cost = math.floor(cost + 0.5)
		--print("consume energy: "..cost)
		champion:modifyBaseStat("energy", -cost)
	end

	-- consume food
	champion:consumeFood(0.5 + math.random() * 2)

	-- cooldown
	local cooldown = (self.cooldown or 0) * champion:getCooldownWithAttack(weapon, self, "throw")

	champion.cooldownTimer[1] = math.max(champion.cooldownTimer[1], cooldown)
	champion.cooldownTimer[2] = math.max(champion.cooldownTimer[2], cooldown)

	party:endCondition("invisibility")

	-- play sound
	if self.attackSound then
		champion:playSound(self.attackSound)
	end

	local count = 1
	--if champion:getSkillLevel("double_throw") > 0 then count = 2 end

	for i=1,count do
		-- weapons left to throw?
		local item = champion:getItem(slot)
		if not item then return end
		
		-- determine damage
		-- note: this has to be done before removing the item from hand!
		local dmg = computeDamage(champion:getDamageWithAttack(weapon, self))
		
		-- split stack
		local projectile
		if item.stackable and item.count > 1 then
			projectile = item:splitStack(1)
		else
			-- throw last
			if champion:getItem(ItemSlot.Weapon) == item then
				champion:removeItemFromSlot(ItemSlot.Weapon)
				champion.autoEquipEmptyHand = item.go.arch.name
			else
				champion:removeItemFromSlot(ItemSlot.OffHand)
				champion.autoEquipOffHand = item.go.arch.name
			end
			projectile = item
		end
		
		local pos = champion:getChampionPositionInWorld(0.4)
		
		-- push forward so that item won't collide against a door behind us
		pos = pos + party:getWorldForward() * item:getBoundingRadius()

		-- separate projectiles if shooting multiple projectiles
		if self.spread then
			pos.x = pos.x + (math.random() - 0.5) * self.spread
			pos.y = pos.y + (math.random() - 0.5) * self.spread
			pos.z = pos.z + (math.random() - 0.5) * self.spread
		end
		
		local power = 14
		local gravity = 1
		local velocityUp = 0

		if projectile.go.arch.bombType then
			local weight = 0.8
			power = math.max(14 - weight, 10)
			gravity = math.clamp(2 + weight*1.5, 4, 10)
			velocityUp = 0
		end
		
		projectile:throw(party, pos, party.go.facing, power, gravity, velocityUp)
		projectile:setItemFlag(ItemFlag.AutoPickUp, true)
		projectile.go.projectile:setVelocity(projectile.go.projectile:getVelocity() * (1+(self.velocity or 0)))
		projectile.projectileDamage = dmg
		projectile.projectileAccuracy = champion:getAccuracyWithAttack(weapon, self)
		projectile.projectileCritChance = champion:getCritChanceWithAttack(weapon, self)
		projectile.projectilePierce = self.pierce
		projectile.thrownByChampion = champion.ordinal
		projectile.thrownByWeapon = weapon.go.id
		projectile.thrownByAttack = self.name

		messageSystem:sendMessageNEW("onPartyThrowItem", projectile)
	end
	
	champion:showAttackResult("Throw")

	self:callHook("onPostAttack", objectToProxy(champion), slot)
end

-------------------------------------------------------------------------------------------------------
-- FirearmAttack Functions                                                                           --    
-------------------------------------------------------------------------------------------------------

defineProxyClass{
	class = "FirearmAttackComponent",
	baseClass = "ItemActionComponent",
	description = "Implements firearm attacks. Firearm attacks need ammo.",
	methods = {
		{ "setAttackPower", "number" },
		{ "setAttackPowerVariation", "number" },
		{ "setRange", "number" },
		{ "setCooldown", "number" },
		{ "setAttackSound", "string" },
		{ "setSkill", "string" },
		{ "setRequiredLevel", "number" },
		{ "setAccuracy", "number" },
		{ "setAmmo", "string" },
		{ "setBaseDamageStat", "string" },
		{ "setClipSize", "number" },
		{ "setDamageType", "string" },
		{ "setLoadedCount", "number" },
		{ "setPierce", "number" },
		{ "getAttackPower" },
		{ "getAttackPowerVariation" },
		{ "getRange" },
		{ "getCooldown" },
		{ "getAttackSound" },
		{ "getSkill" },
		{ "getRequiredLevel" },
		{ "getAccuracy" },
		{ "getAmmo" },
		{ "getBaseDamageStat" },
		{ "getClipSize" },
		{ "getDamageType" },
		{ "getLoadedCount" },
		{ "getPierce" },
		{ "setBaseDamageMultiplier", "number" },
		{ "getBaseDamageMultiplier" },
		{ "getMinDamageMod" },
		{ "getMaxDamageMod" },
		{ "setMinDamageMod", "number" },
		{ "setMaxDamageMod", "number" },
        { "setJamText", "string" },
		{ "setJamChance", "number" },
		{ "getJamChance" },
		{ "setJammed", "boolean" },
		{ "getJammed" },
		{ "setCritMultiplier", "number" },
		{ "getCritMultiplier" },
	},
	hooks = {
		"onBackfire(self, champion)",
		"onPostAttack(self, champion, slot)",
	},
}

extendProxyClass(FirearmAttackComponent, "critChance")
extendProxyClass(FirearmAttackComponent, "critMultiplier")
extendProxyClass(FirearmAttackComponent, "attackPowerVariation")
extendProxyClass(FirearmAttackComponent, "baseDamageMultiplier")
extendProxyClass(FirearmAttackComponent, "minDamageMod")
extendProxyClass(FirearmAttackComponent, "maxDamageMod")
extendProxyClass(FirearmAttackComponent, "jamText")
extendProxyClass(FirearmAttackComponent, "attackFire")
extendProxyClass(FirearmAttackComponent, "attackCold")
extendProxyClass(FirearmAttackComponent, "attackShock")
extendProxyClass(FirearmAttackComponent, "attackPoison")

function FirearmAttackComponent:start(champion, slot)
	local weapon = champion:getItem(slot)
	local dualWield = champion:isDualWielding()
	local dualWieldSide = iff(dualWield, slot, nil)

	if not champion:getDamage(slot) then
		console:warn("no attack power")
		return
	end

	-- jam
	if self.jamChance then
		local chance = self.jamChance * champion:getMalfunctionChanceWithAttack(weapon, self, "firearm")
		if not weapon:getJammed() and math.random(1, 100) <= chance then
			weapon:setJammed(true, champion)
			weapon.jamCount = math.random(2, 6)
		end
	end
	
	-- fix jammed weapon
	if weapon:getJammed() then
		weapon.jamCount = (weapon.jamCount or 3) - 1
		if weapon.jamCount < 0 then
			weapon:setJammed(false, champion)
			weapon.jamCount = nil
		end
	end

	if weapon:getJammed() then
		soundSystem:playSound2D("firearm_jammed")
		champion:showAttackResult(self.jamText or "Jammed!", nil, dualWieldSide)
		return
	end
	
	-- check ammo
	local ammo, ammoSlot = champion:checkAmmoSlot(self, slot, dualWieldSide)
	if not ammo then
		return
	end
	-- consume ammo
	if self.clipSize then
		self.loadedCount = self.loadedCount - 1
	else
		self:consumeAmmo(champion, ammoSlot, 1)
	end

	-- backfire
	if self.backfireChance then
		local chance = self.backfireChance * champion:getMalfunctionChanceWithAttack(weapon, self, "firearm")
		--print("backfire chance = ", chance)
		if math.random(1, 100) <= chance then
			if self:callHook("onBackfire", objectToProxy(champion)) ~= false then
				party.go:spawn("fireburst")
				party:shakeCamera(1, 0.3)
				champion:showAttackResult("Backfire!")
				champion:playDamageSound()
				if self.attackSound then champion:playSound(self.attackSound) end
				weapon:setJammed(true, champion)
				return
			end
		end
	end
	
	-- cooldown
	local cooldown = (self.cooldown or 0) * champion:getCooldownWithAttack(weapon, self, "firearm")
	if dualWield then
		if slot == ItemSlot.Weapon then
			champion.cooldownTimer[1] = math.max(champion.cooldownTimer[1], cooldown)
		else
			champion.cooldownTimer[2] = math.max(champion.cooldownTimer[2], cooldown)
		end
	else
		champion.cooldownTimer[1] = math.max(champion.cooldownTimer[1], cooldown)
		champion.cooldownTimer[2] = math.max(champion.cooldownTimer[2], cooldown)
	end
	
	champion:consumeFood(0.5 + math.random() * 2)

	party:endCondition("invisibility")

	party.go.statistics:increaseStat("firearm_attacks", 1)
		
	-- play sound
	if self.attackSound then
		champion:playSound(self.attackSound)
	end

	-- trace ray
	local origin = party.go:getWorldPosition()
    origin.y = origin.y + 1.3
    
    local range = self.range

    -- traits modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onComputeRange then
			local modifier = trait.onComputeRange(objectToProxy(champion), objectToProxy(weapon), objectToProxy(self), "firearm", iff(champion:hasTrait(name), 1, 0))
			range = range + (modifier or 0)
		end
	end

	-- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onComputeRange then
			local modifier = skill.onComputeRange(objectToProxy(champion), objectToProxy(weapon), objectToProxy(self), "firearm", champion:getSkillLevel(name))
			range = range + (modifier or 0)
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = champion:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(champion, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onComputeRange then
						local modifier = comp:onComputeRange(champion, weapon, self, "firearm")
						range = range + (modifier or 0)
					end
				end
			end
		end
    end
    
	local hitWhat, hitEntity, hitPos = self.raycast(origin, party.go.facing, range, party)

	local hitStatus
	if hitEntity then
		--print(hitWhat, hitEntity.arch.name)
		hitStatus = hitEntity:sendMessage("onAttackedByChampion", champion, weapon, self, slot, dualWieldSide)
	end

	-- spawn particle effect
	if hitWhat and hitStatus ~= "miss" then
		local map = party.go.map
		local x,y = map:worldToMap(hitPos)
		local fx = spawn(map, "particle_system", x, y, 0, party.go.elevation)
		fx.particle:setParticleSystem("hit_firearm")

		-- random spread
		local spread = 0.5
		local dx,dy = getDxDy(party.go.facing)
		local pos = vec(hitPos.x + (math.random() - 0.5) * spread * dy, hitPos.y + (math.random() - 0.5) * spread, hitPos.z + (math.random() - 0.5) * spread * dx)

		fx:setWorldPosition(pos)
	end

	if not hitStatus then
		champion:showAttackResult("Miss", GuiItem.HitSplash, dualWieldSide)
	end

	self:callHook("onPostAttack", objectToProxy(champion), slot)
end

-------------------------------------------------------------------------------------------------------
-- AmmoItem Functions                                                                                --
-------------------------------------------------------------------------------------------------------

extendProxyClass(AmmoItemComponent, "causeCondition")
extendProxyClass(AmmoItemComponent, "conditionChance")

-------------------------------------------------------------------------------------------------------
-- Condition Functions                                                                               --
-------------------------------------------------------------------------------------------------------

local oldConditionInit = Condition.init
function Condition:init(uiName, description, iconIndex, ...)
    oldConditionInit(self, uiName, description, iconIndex, ...)
	self.power = 0
	self.stacks = 0
	self.tickMode = nil
end

function Condition:setPower(value)
	self.power = value
end

function Condition:getPower()
	return self.power
end

function Champion:loadState(file, loadItems)
	local chunkID = file:openChunk()
	assert(chunkID == "CHAM")
	
	self.ordinal = file:readValue()
	self.name = file:readValue()
	self.portraitFile = file:readValue()
	self.cooldownTimer[1] = file:readValue()
	self.cooldownTimer[2] = file:readValue()
	self.weaponSet = file:readValue()
	self.skillPoints = file:readValue()
	self.food = file:readValue()
	self.healthiness = file:readValue()
	self.randomSeed = file:readValue()
	self.enabled = file:readValue()
	self.level = file:readValue()
	self.exp = file:readValue()
			
	-- load race & class
	self:setRace(file:readValue())
	self:setClass(file:readValue())
	
	self.skills = {}
	self.skillPreview = {}
	self.traits = {}

	self:setSex(file:readValue())
	
	while file:availableBytes() > 0 do
		local id = file:openChunk()		
		if id == "STAT" then
			local name = file:readValue()
			if self.stats[name] then
				self.stats[name].base = file:readValue()
				--print(name, self.stats[name].value, self.stats[name].max)
			end
		elseif id == "COND" then
			local name = file:readValue()
			local class = Condition.getConditionClass(name)
			if class then
				local cond = class.create(name)
				cond:loadState(file)
				self.conditions[name] = cond
			end
		elseif id == "ITEM" and loadItems then
			local slot = file:readValue()
			local obj = GameObject.create()
			obj:loadState(file)
			self.items[slot] = obj.item
		elseif id == "SKIL" then
			local skill = file:readValue()
			local level = file:readValue()
			self.skills[skill] = level
		elseif id == "SKLP" then
			local skill = file:readValue()
			local level = file:readValue()
			self.skillPreview[skill] = level
		elseif id == "TRAI" then
			self.traits[#self.traits+1] = file:readValue()
		elseif id == "DATA" then
			local name = file:readValue()
			local value = file:readValue()
			self.data[name] = value
		elseif id == "AUTO" then
			self.autoEquipEmptyHand = file:readValue()
			self.autoEquipOffHand = file:readValue()
			self.autoEquipEmptyHand2 = file:readValue()
			self.autoEquipOffHand2 = file:readValue()
		end
		file:closeChunk()
	end
	
	file:closeChunk()
end

function Champion:saveState(file)
	file:openChunk("CHAM")
	file:writeValue(self.ordinal)
	file:writeValue(self.name)
	file:writeValue(self.portraitFile)
	file:writeValue(self.cooldownTimer[1])
	file:writeValue(self.cooldownTimer[2])
	file:writeValue(self.weaponSet)
	file:writeValue(self.skillPoints)
	file:writeValue(self.food)
	file:writeValue(self.healthiness)
	file:writeValue(self.randomSeed)
	file:writeValue(self.enabled)
	file:writeValue(self.level)
	file:writeValue(self.exp)
	file:writeValue(self:getRace())
	file:writeValue(self:getClass())	
	file:writeValue(self:getSex())

	-- save stats
	for i=1,#Stats do
		local s = Stats[i]
		file:openChunk("STAT")
		file:writeValue(s)
		file:writeValue(self.stats[s].base)
		file:closeChunk()
	end

	-- save conditions
	for name,cond in pairs(self.conditions) do
		file:openChunk("COND")
		file:writeValue(name)
		cond:saveState(file)
		file:closeChunk()
	end
	
	-- save equipment
	for i=1,ItemSlot.MaxSlots do
		local it = self.items[i]
		if it then
			file:openChunk("ITEM")
			file:writeValue(i)
			it.go:saveState(file)
			file:closeChunk()
		end
	end
	
	-- save skills
	for skill,level in pairs(self.skills) do
		file:openChunk("SKIL")
		file:writeValue(skill)
		file:writeValue(level)
		file:closeChunk()
	end
	
	-- save skill previews
	for skill,level in pairs(self.skillPreview) do
		file:openChunk("SKLP")
		file:writeValue(skill)
		file:writeValue(level)
		file:closeChunk()
	end

	-- save traits
	for _,name in ipairs(self.traits) do
		file:openChunk("TRAI")
		file:writeValue(name)
		file:closeChunk()
	end

	-- save data
	for name,value in pairs(self.data) do
		file:openChunk("DATA")
		file:writeValue(name)
		file:writeValue(value)
		file:closeChunk()
	end
	
	-- save auto-pickup state
	if self.autoEquipEmptyHand or self.autoEquipOffHand or autoEquipEmptyHand2 or autoEquipOffHand then
		file:openChunk("AUTO")
		file:writeValue(self.autoEquipEmptyHand)
		file:writeValue(self.autoEquipOffHand)
		file:writeValue(self.autoEquipEmptyHand2)
		file:writeValue(self.autoEquipOffHand2)
		file:closeChunk()
	end

	file:closeChunk()
end

function Condition:update(champion)
	if self.tickMode == "deltaTime" or not self.tickMode then
		self.timer = self.timer - Time.deltaTime
		if self.timer <= 0 then
			self:tick(champion)
		end
	elseif self.tickMode == "energy" then
		local cost = Time.deltaTime * self.timer
		if champion:getEnergy() < cost then
			return false
		end
		-- spend energy
		champion:modifyBaseStat("energy", -cost)
		self:tick(champion)
	elseif self.tickMode == "health" then
		local cost = Time.deltaTime * self.timer
		if champion:getEnergy() < cost then
			return false
		end
		-- spend energy
		champion:modifyBaseStat("health", -cost)
		self:tick(champion)
	end

	-- count faster when duration is lower
	local multi = 1 / champion:getConditionDuration(self)
	
	if self.value then
		self.value = self.value - (Time.deltaTime * multi)
		if self.value <= 0 then
			if self.stacks > 1 then
				self.stacks = self.stacks - 1
				self.value = self.stackTimer
			elseif self.stacks == 1 then
				self.stacks = self.stacks - 1
			else
				return false
			end
		end
	end
end

function Condition:getName()
	return self.name
end

local oldCustomConditionInit = CustomCondition.init
function CustomCondition:init(name)
	oldCustomConditionInit(self, name)
	local desc = dungeon.conditions[name]
	self.maxStacks = desc.maxStacks
	self.stackTimer = desc.stackTimer
	-- if self.stackTimer == 0 then self.stackTimer = self.power end
	self.name = desc.name
	self.healthBarColor = desc.healthBarColor
	self.energyBarColor = desc.energyBarColor
	self.frameColor = desc.frameColor
	self.transformation = desc.transformation
	self.noAttackPanelIcon = desc.noAttackPanelIcon
	self.leftHandTexture = desc.leftHandTexture
	self.rightHandTexture = desc.rightHandTexture
	self.tickMode = desc.tickMode
end

function Condition:getStacks()
	return self.stacks or 0
end

function Condition:setStacks(value)
	self.stacks = value
end

function CustomCondition:start(champion)
	if self.onStart then self.onStart(objectToProxy(self), objectToProxy(champion), true, self.power, self.stacks) end
end

function CustomCondition:restart(champion)
	if self.onStart then self.onStart(objectToProxy(self), objectToProxy(champion), false, self.power, self.stacks) end
end

function CustomCondition:stop(champion)
	if self.onStop then self.onStop(objectToProxy(self), objectToProxy(champion), self.power, self.stacks) end
end

function CustomCondition:tick(champion)
	if self.onTick then self.onTick(objectToProxy(self), objectToProxy(champion), self.power, self.stacks) end
	self.timer = self.tickInterval or 1
end

function CustomCondition:recomputeStats(champion)
	if self.onRecomputeStats then self.onRecomputeStats(objectToProxy(self), objectToProxy(champion), self.power, self.stacks) end
end

function CustomCondition:setDescription(desc)
	self.description = desc
end

-------------------------------------------------------------------------------------------------------
-- Spell Functions                                                                                   --
-------------------------------------------------------------------------------------------------------

function Spell.castSpell(spell, caster, x, y, direction, elevation, skill)
	-- caster = champion casting the spell
	-- skill = caster's skill in spell's school of magic (or wand's strength for wand spells)
		
	if type(spell.onCast) == "string" then
		-- built-in spell
		local spellFunc = BuiltInSpell[spell.onCast]
		if spellFunc then
			local spl = spellFunc(caster, x, y, direction, elevation, skill, spell) -- adds spell data to call
			return spl
		else
			console:warn("unknown built-in spell: "..spell.onCast)
		end
	else
		-- custom spell
		local spl = spell.onCast(objectToProxy(caster), x, y, direction, elevation, skill, spell) -- adds spell data to call
		return spl
	end
end

-- BuiltInSpell = {}

-- We redefine built-in spells so it can take the spell definition data instead of using hard-coded values

function BuiltInSpell.shield(caster, x, y, direction, elevation, skill, spl)
	soundSystem:playSound2D("generic_spell")
    local duration = spl.duration + skill * (spl.durationScaling or 0)
    local power = spl.power + skill * (spl.powerScaling or 0)
	caster:setConditionValue("protective_shield", duration, power)
	-- gui:hudPrint(caster.name.." conjures a magical shield.")
end

function BuiltInSpell.light(caster, x, y, direction, elevation, skill, spl)
	soundSystem:playSound2D("light")
	if party.lightSpell < 0 then
		-- light cancels darkness
		party.lightSpell = 0
	else
		party.lightSpell = spl.duration + skill * (spl.durationScaling or 0)
	end
	-- gui:hudPrint(caster.name.." conjures magical light.")
end
		
function BuiltInSpell.darkness(caster, x, y, direction, elevation, skill, spl)
	soundSystem:playSound2D("generic_spell")
	if party.lightSpell > 0 then
		-- darkness cancels light
		party.lightSpell = 0
	else
		party.lightSpell = (spl.duration + skill * (spl.durationScaling or 0)) * -1
	end
end

function BuiltInSpell.darkbolt(caster, x, y, direction, elevation, skill, spl)
	--soundSystem:playSound2D("generic_spell")
	local spell = spawn(party.go.map, "dark_bolt", x, y, direction, elevation)
    spell:setWorldPosition(Spell.getCasterPositionInWorld(caster))
    local power = spl.power + skill * (spl.powerScaling or 0)
	spell.projectile:setAttackPower(power)
	spell.projectile:setIgnoreEntity(party.go)
	spell.projectile:setCastByChampion(caster.ordinal)
	party:endCondition("invisibility")
	return spell
end

function BuiltInSpell.forceField(caster, x, y, direction, elevation, skill, spl)
	x,y = Spell.getBurstTargetTile(x, y, direction)

	local duration = math.max(spl.duration + skill * (spl.durationScaling or 0), 5)
	soundSystem:playSound2D("force_field_cast")

	for _,f in party.go.map:componentsAt(ForceFieldComponent, x, y) do
		if f.enabled then
			if not f.duration then
				-- square already has a permanent force field
				return
			else
				-- square already has a temporary force field -> reset duration
				f.duration = math.max(f.duration, duration)
				return
			end
		end
	end

	local spell = spawn(party.go.map, "force_field", x, y, direction, elevation)
	spell.forcefield:setDuration(duration)
	return spell
end

function BuiltInSpell.fireburst(caster, x, y, direction, elevation, skill, spl)
	local map = party.go.map
    x,y = Spell.getBurstTargetTile(x, y, direction)
    local spell = spawn(map, "fireburst", x, y, direction, elevation)
    local power = spl.power + skill * (spl.powerScaling or 0)
	spell.tiledamager:setAttackPower(power)
	spell.tiledamager:setCastByChampion(caster.ordinal)

	if skill == 1 then spell.tiledamager:setDamageFlags(DamageFlags.NoLingeringEffects) end

    -- cause burning condition
    local chance = spl.duration * (1 + skill * (spl.durationScaling or 0))
	if skill >= 3 and math.random() < chance then
		for _,monster in map:componentsAt(MonsterComponent, x, y) do
			if monster.go.elevation == elevation then
				monster:setCondition("burning")

				-- mark condition so that exp is awarded if monster is killed by the condition
				local burningCondition = monster.go.burning
				if burningCondition then
					burningCondition:setCausedByChampion(caster.ordinal)
				end
			end
		end
	end

    party:endCondition("invisibility")
    return spell
end

function BuiltInSpell.fireball(caster, x, y, direction, elevation, skill, spl)
	local spell
	if skill < 2 then
		spell = spawn(party.go.map, "fireball_small", x, y, direction, elevation)
	elseif skill == 2 then
		spell = spawn(party.go.map, "fireball_medium", x, y, direction, elevation)
	else
		spell = spawn(party.go.map, "fireball_large", x, y, direction, elevation)
	end

	local power = spl.power + skill * (spl.powerScaling or 0)

	spell:setWorldPosition(Spell.getCasterPositionInWorld(caster))
	spell.projectile:setAttackPower(power)
	spell.projectile:setIgnoreEntity(party.go)
	spell.projectile:setCastByChampion(caster.ordinal)
    party:endCondition("invisibility")
    return spell
end

function Spell_meteorStorm(casterOrdinal, spreadX, spreadY, gesture, skill)
	if party:isUnderwater() then return end
	local spl = Spell.getSpellByGesture(gesture)

	local spell = spawn(party.go.map, "fireball_medium", party.go.x, party.go.y, party.go.facing, party.go.elevation)
	local caster = party:getChampionByOrdinal(casterOrdinal)
	local pos = Spell.getCasterPositionInWorld(caster)

	-- offset position
	local rdx,rdy = getDxDy((party.go.facing+1)%4)
	pos.x = pos.x - rdx * spreadX * 0.8
	pos.y = pos.y + spreadY
	pos.z = pos.z + rdy * spreadX * 0.8

    spell:setWorldPosition(pos)
    local power = spl.power + skill * (spl.powerScaling or 0)
	spell.projectile:setAttackPower(power)
	spell.projectile:setIgnoreEntity(party.go)
	spell.projectile:setCastByChampion(casterOrdinal)
	return spell
end

function BuiltInSpell.meteorStorm(caster, x, y, direction, elevation, skill, spl)
	local meteorCount = 5

	for i=1,meteorCount do
		local spreadX = math.random() * 0.5 * iff((i % 2) == 0, 1, -1)
		local spreadY = -(i / meteorCount - 0.5)
		messageSystem:delayedFunctionCall("Spell_meteorStorm", (i-1) * 0.15, caster.ordinal, spreadX, spreadY, spl.gesture, skill)
	end

	party:endCondition("invisibility")
end

function BuiltInSpell.fireShield(caster, x, y, direction, elevation, skill, spl)
    local duration = spl.duration + skill * (spl.durationScaling or 0)
    local power = spl.power + skill * (spl.powerScaling or 0)
	Spell.elementalShield("fire_shield", duration, power)
end

function BuiltInSpell.iceShards(caster, x, y, direction, elevation, skill, spl)
	local map = party.go.map
	x,y = Spell.getBurstTargetTile(x, y, direction)
    local spell = spawn(party.go.map, "ice_shards", x, y, direction, elevation)
    local power = spl.power + skill * (spl.powerScaling or 0)
    spell.tiledamager:setAttackPower(power)
    local range = spl.duration + skill * (spl.durationScaling or 0)
	spell.iceshards:setRange(range)
	spell.tiledamager:setCastByChampion(caster.ordinal)
	party:endCondition("invisibility")

	-- cast on invalid space (e.g. empty air)?
	if not spell.tiledamager:isEnabled() then
		soundSystem:playSound2D("spell_fizzle")
	end
	return spell
end
		
function BuiltInSpell.frostbolt(caster, x, y, direction, elevation, skill, spl)
	local name = "frostbolt_"..math.clamp(skill, 1, 5)
	local spell = spawn(party.go.map, name, x, y, direction, elevation)
    spell:setWorldPosition(Spell.getCasterPositionInWorld(caster))
    local power = spl.power + skill * (spl.powerScaling or 0)
	spell.projectile:setAttackPower(power)
	spell.projectile:setIgnoreEntity(party.go)
	spell.projectile:setCastByChampion(caster.ordinal)
	party:endCondition("invisibility")
	return spell
end
		
function BuiltInSpell.frostShield(caster, x, y, direction, elevation, skill, spl)
    local duration = spl.duration + skill * (spl.durationScaling or 0)
    local power = spl.power + skill * (spl.powerScaling or 0)
	Spell.elementalShield("frost_shield", duration, power)
end

function BuiltInSpell.shock(caster, x, y, direction, elevation, skill, spl)
	local map = party.go.map
	x,y = Spell.getBurstTargetTile(x, y, direction)
    local spell = spawn(party.go.map, "shockburst", x, y, direction, elevation)
    local power = spl.power + skill * (spl.powerScaling or 0)
	spell.tiledamager:setAttackPower(power)
	spell.tiledamager:setCastByChampion(caster.ordinal)

	if skill == 1 then spell.tiledamager:setDamageFlags(DamageFlags.NoLingeringEffects) end

	party:endCondition("invisibility")
	return spell
end

function BuiltInSpell.invisibility(caster, x, y, direction, elevation, skill, spl)
    local duration = spl.duration + skill * (spl.durationScaling or 0)
	for i=1,4 do
		party.champions[i]:setConditionValue("invisibility", duration)
	end
	soundSystem:playSound2D("generic_spell")
end

function BuiltInSpell.lightningBolt(caster, x, y, direction, elevation, skill, spl)
	local spell
	if skill > 1 then
		spell = spawn(party.go.map, "lightning_bolt_greater", x, y, direction, elevation)
	else
		spell = spawn(party.go.map, "lightning_bolt", x, y, direction, elevation)
	end
    spell:setWorldPosition(Spell.getCasterPositionInWorld(caster))
    local power = spl.power + skill * (spl.powerScaling or 0)
	spell.projectile:setAttackPower(power)
	spell.projectile:setIgnoreEntity(party.go)
	spell.projectile:setCastByChampion(caster.ordinal)
	party:endCondition("invisibility")
	return spell
end

function BuiltInSpell.shockShield(caster, x, y, direction, elevation, skill, spl)
    local duration = spl.duration + skill * (spl.durationScaling or 0)
    local power = spl.power + skill * (spl.powerScaling or 0)
	Spell.elementalShield("shock_shield", duration, power)
end

function BuiltInSpell.poisonCloud(caster, x, y, direction, elevation, skill, spl)
	local map = party.go.map
	x,y = Spell.getBurstTargetTile(x, y, direction, true)
	local spell
	if skill >= 5 then
		spell = spawn(party.go.map, "poison_cloud_large", x, y, 0, elevation)
	elseif skill >= 3 then
		spell = spawn(party.go.map, "poison_cloud_medium", x, y, 0, elevation)
	else
        spell = spawn(party.go.map, "poison_cloud_small", x, y, 0, elevation)
    end
    local power = spl.power + skill * (spl.powerScaling or 0)
    spell.cloudspell:setAttackPower(power)
	spell.cloudspell:setCastByChampion(caster.ordinal)
	spell.cloudspell:setDamageInterval(math.max(0.8 - skill * 0.4 / 5, 0.2))	-- damage doubles with 5 skill levels
	spell.cloudspell:combineClouds()
	party:endCondition("invisibility")
	return spell
end
		
function BuiltInSpell.poisonBolt(caster, x, y, direction, elevation, skill, spl)
	local spell
	if skill >= 3 then
		spell = spawn(party.go.map, "poison_bolt_greater", x, y, direction, elevation)
	else
		spell = spawn(party.go.map, "poison_bolt", x, y, direction, elevation)
	end
    spell:setWorldPosition(Spell.getCasterPositionInWorld(caster))
    local power = spl.power + skill * (spl.powerScaling or 0)
	spell.projectile:setAttackPower(power)
	spell.projectile:setIgnoreEntity(party.go)
	spell.projectile:setCastByChampion(caster.ordinal)
	party:endCondition("invisibility")
	return spell
end

function BuiltInSpell.poisonShield(caster, x, y, direction, elevation, skill, spl)
    local duration = spl.duration + skill * (spl.durationScaling or 0)
    local power = spl.power + skill * (spl.powerScaling or 0)
	Spell.elementalShield("poison_shield", duration, power)
end

function BuiltInSpell.dispel(caster, x, y, direction, elevation, skill, spl)
	local spell = spawn(party.go.map, "dispel_projectile", x, y, direction, elevation)
    spell:setWorldPosition(Spell.getCasterPositionInWorld(caster))
    local power = spl.power + skill * (spl.powerScaling or 0)
	spell.projectile:setAttackPower(power)
	spell.projectile:setIgnoreEntity(party.go)
	spell.projectile:setCastByChampion(caster.ordinal)
	return spell
end

function BuiltInSpell.causeFear(caster, x, y, direction, elevation, skill, spl)
	local map = party.go.map
	x,y = Spell.getBurstTargetTile(x, y, direction, true)
	local power = spl.power + skill * (spl.powerScaling or 0)

	for _,monster in party.go.map:componentsAt(MonsterComponent, x, y) do
		if monster:isAlive() and not monster.fleeing then
			local brain = monster.go.brain
			if brain then
				if math.random(power, 100) > brain.morale then
					brain:startFleeing()
				else
					monster:showDamageText("Resists", Color.White)
				end
			end
		end
	end	

	-- hit self?
	if x == party.go.x and y == party.go.y then
		for i=1,4 do
			local ch = party.champions[i]
			if ch and ch:isAlive() and not ch:hasCondition("paralyzed") and math.random() < 0.5 then
				ch:setCondition("paralyzed")
			end
		end
	end

	local fx = spawn(party.go.map, "particle_system", x, y, 0, elevation)
	fx.particle:setParticleSystem("fear_cloud")
	fx.particle:setOffset(vec(0, 1.5, 0))

	soundSystem:playSound2D("wand_fear")

	party:endCondition("invisibility")
end

function BuiltInSpell.heal(caster, x, y, direction, elevation, skill, spl)
	local power = spl.power + skill * (spl.powerScaling or 0)
	for i=1,4 do
		local champion = party:getChampion(i)
		if champion:isAlive() then
			champion:regainHealth(power)
			champion:playHealingIndicator()
			soundSystem:playSound2D("heal_party")
		end
	end
end

function Spell.elementalShield(condition, duration, power)
	-- cancel existing shields
	for i=1,4 do
		party.champions[i]:removeCondition("fire_shield")
		party.champions[i]:removeCondition("frost_shield")
		party.champions[i]:removeCondition("poison_shield")
		party.champions[i]:removeCondition("shock_shield")
	end
	
	for i=1,4 do
		party.champions[i]:setConditionValue(condition, duration, power)
	end

	soundSystem:playSound2D("generic_spell")
end

function GameObject:saveState(file)
	-- systemLog:write("")
	-- systemLog:write("save begin")
	--print("saving game object", self.id)
	file:writeValue(self.arch.name)
	file:writeValue(self.id)
	file:writeValue(self.x)
	file:writeValue(self.y)
	file:writeValue(self.facing)
	file:writeValue(self.elevation)
	file:writeValue(self.node:getTransform())
	
	-- NOTE: we don't need to store inObject in save games
	-- because we always know the container item when deserializing contained items

	for i=1,self.components.length do
		local comp = self.components[i]
		--print("saving component", comp.name)

		file:openChunk("COMP")

		-- save class name
		local className = comp.__className
		assert(className)
		className = string.match(className, "(.+)Component$")
		assert(className)
		file:writeValue(className)
		-- if comp.uiName then
		-- 	systemLog:write(className .. " " .. comp.uiName and comp.uiName or "")
		-- end
		
		-- save node transform
		if comp.node then
			file:openChunk("TFRM")
			file:writeValue(comp.node:getTransform())
			file:closeChunk()
		end
		
		-- save properties
		for k,v in pairs(comp) do
			local persist = true
			if k == "go" or k == "node" or k == "__proxyObject" or k == "hooks" or k == "connectors" or k == "_next" or k == "_hashkey" or k == "_handle" then persist = false end
			
			local dontAutoSerialize = comp.__class._dontAutoSerialize
			if dontAutoSerialize and dontAutoSerialize[k] then persist = false end
			
			if persist then
				local tv = typex(v)
				
				-- serialize primitive and compound datatypes
				local serialize				
				if tv == "string" or tv == "number" or tv == "boolean" or tv == "vec" or tv == "mat" or
				   tv == "Sphere" or tv == "Box" or tv == "Plane" or tv == "Ray" then serialize = true end
				
				-- serialize tables which have been manually flagged for auto-serialization
				local autoSerialize = comp.__class._autoSerialize
				if autoSerialize and autoSerialize[k] then serialize = true end
				
				if serialize then
					-- if type(k) == "string" and type(v) == "string" then
					-- 	systemLog:write(k .. " " .. v)
					-- end
					file:openChunk("PROP")
					file:writeValue(k)
					file:writeValue(v)
					file:closeChunk()
				else
					console:warn(string.format("game object property not saved: %s.%s.%s", self.id, comp.name, k))
				end
			end
		end
		
		-- save hooks
		if comp.hooks then
			for k,v in pairs(comp.hooks) do
				file:openChunk("HOOK")
				file:writeValue(k)
				file:writeValue(v)
				file:closeChunk()
			end
		end
		
		-- save connectors
		if comp.connectors then
			for _,c in ipairs(comp.connectors) do
				file:openChunk("CONN")
				file:writeValue(c.event)
				file:writeValue(c.target)
				file:writeValue(c.action)
				file:closeChunk()
			end
		end
		
		-- save extended state
		if comp.saveState then
			file:openChunk("EXTS")
			comp:saveState(file)
			file:closeChunk()
		end

		file:closeChunk()
	end
end

function GameObject:loadState(file)
	-- systemLog:write("")
	-- systemLog:write("load begin")
	-- load game object state
	local name = file:readValue()
	self.arch = findArch(name)
	self.id = file:readValue()
	self.x = file:readValue()
	self.y = file:readValue()
	self.facing = file:readValue()
	self.elevation = file:readValue()

	if self.map == nil then
		dungeon.tempMap:addEntity(self, 0, 0)
	end

	self.node = self.map.scene:addNode()
	self.node:setTransform(file:readValue())
	
	-- load components
	while file:availableBytes() > 0 do
		local id = file:openChunk()
		if id == "COMP" then
			local className = file:readValue()
			-- TODO: sandboxing, make sure that the class name is a valid component class
			local class = _G[className.."Component"]
			assert(class, "invalid component class: "..className)

			-- instantiate component
			local comp = self:createComponent(class)
			-- if comp.__className then
			-- 	systemLog:write(className .. " " .. comp.__className)
			-- end
	
			while file:availableBytes() > 0 do
				local id = file:openChunk()
				if id == "TFRM" then
					-- load node transform
					if comp.node then comp.node:setTransform(file:readValue()) end
				elseif id == "PROP" then
					-- load property
					local prop = file:readValue()
					-- if type(prop) == "string" or type(prop) == "number" then
					-- 	systemLog:write("prop:" .. tostring(prop))
					-- elseif type(prop) == "table" then
					-- 	systemLog:write("value: table")
					-- end
					local value = file:readValue()
					-- if type(value) == "string" or type(value) == "number" then
					-- 	systemLog:write("value:" .. tostring(value))
					-- elseif type(value) == "table" then
					-- 	systemLog:write("value: table")
					-- end
					comp[prop] = value
				elseif id == "HOOK" then
					-- load hook
					local name = file:readValue()
					local func = file:readValue()
					if func then
						setfenv(func, globalHookEnv)
						comp.hooks = comp.hooks or {}
						comp.hooks[name] = func
					else
						console:warn("hook not loaded: "..self.id.."."..name)
					end
				elseif id == "CONN" then
					local event = file:readValue()
					local target = file:readValue()
					local action = file:readValue()
					comp:addConnector(event, target, action)
				elseif id == "EXTS" then
					-- load extended state
					if comp.loadState then comp:loadState(file) end
				end
				file:closeChunk()
			end

			-- attach to parent node
			if comp.parentNode then comp:setParentNode(comp.parentNode) end
		end
		file:closeChunk()
	end

	if self.map == dungeon.tempMap then
		self.map:removeEntity(self)
	end
end

oldItemComponentSetJammed = ItemComponent.setJammed
function ItemComponent:setJammed(jammed, champion)
	oldItemComponentSetJammed(self, jammed, champion)
	if not champion then return end
	-- skill triggers
	for name,skill in pairs(dungeon.skills) do
		if skill.onJamTrigger then
			local champ
			if champion then champ = objectToProxy(champion) end
			skill.onJamTrigger(champ, objectToProxy(self), jammed, champion:getSkillLevel(name))
		end
	end
	
	-- trait triggers
	for name,trait in pairs(dungeon.traits) do
		if trait.onJamTrigger then
			local champ
			if champion then champ = objectToProxy(champion) end
			trait.onJamTrigger(champ, objectToProxy(self), jammed, iff(champion:hasTrait(name), 1, 0))
		end
	end
	
	-- equipment triggers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = champion:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(champion, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onJamTrigger then
						comp:onJamTrigger(champion, self, jammed)
					end
				end
			end
		end
	end
end

function ButtonComponent:activate()
	if self.go.animation then self.go.animation:play("press") end
	if self.enabled then
		if self.sound then self.go:playSound(self.sound) end
		self:callHook("onActivate")
		if self.disableSelf then self:disable() end
	end
end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end