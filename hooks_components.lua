
-------------------------------------------------------------------------------
-- Slide Component
-------------------------------------------------------------------------------

SlideComponent = class(Component)

-- @private

function SlideComponent:init(go)
	self:super(go)
	self.activated = false
	self.y = 0
end

function SlideComponent:onInit()
    self:activate()
end

-- @public

function SlideComponent:activate()
	self.activated = true
end

function SlideComponent:deactivate()
	self.activated = false	
end

function SlideComponent:pushRight()
    self:push((self.go.facing + 1)%4)
end

function SlideComponent:pushLeft()
    self:push((self.go.facing - 1)%4)
end

function SlideComponent:push(dir)
	if self.activated and not self:isMoving() then
		local dx,dy = getDxDy(dir)
		local x,y = self.go.x + dx, self.go.y + dy
        -- Position of tile this ladder is connected to
		local fdx, fdy = getDxDy(self.go.facing)
        local fx,fy = self.go.x + dx + fdx, self.go.y + fdy + dy
        local blocked = self:destinationBlocked(dir)
		self.moveTween = 0
		self.moveFromPosition = self.go:getWorldPosition()
		self.moveDelta = vec(dx * Map.ModuleSize, 0, -dy * Map.ModuleSize)	
		-- check that target cell is free and valid
		
        -- console:print(fx, fy, platform)

		if blocked then
			self.go:playSound("pushable_block_blocked")
			self.bumping = true
		else
			-- reserve target cell
			self.go:playSound("pushable_block_push")
            self.go.ladder:disable()
			-- if self.go.obstacle then self.go.obstacle:disable() end
		end
	end
end

function SlideComponent:rightBlocked()
    return self:destinationBlocked((self.go.facing + 1)%4)
end

function SlideComponent:leftBlocked()
    return self:destinationBlocked((self.go.facing - 1)%4)
end

function SlideComponent:destinationBlocked(dir)
    local dx,dy = getDxDy(dir)
    local x,y = self.go.x + dx, self.go.y + dy
    -- Position of tile this ladder is connected to
    local fdx, fdy = getDxDy(self.go.facing)
    local fx,fy = self.go.x + dx + fdx, self.go.y + fdy + dy

    local platform
	local blocked = self.go.map:isBlocked(x, y, self.go.elevation)
    if not blocked then
        -- Check for another ladder at destination
        for _,ladder in self.go.map:componentsAt(LadderComponent, x, y) do
            if self.go.facing == ladder.go.facing then
                blocked = true
            end
        end
        -- Check that the target square has an activated platform
        for _,floor in self.go.map:componentsAt(PlatformComponent, fx, fy) do
            if floor and (self.go.elevation+1) == floor.go.elevation then
                platform = true
            end
        end
        -- Check if the ladder points into a floor tile at destination
        if not platform and (self.go.elevation+1) == self.go.map:getElevation(fx, fy) then
            platform = true
        end
    end
    return blocked or not platform
end

-- @private

function SlideComponent:update()
	-- update moving
    -- console:print(self.moveTween)
	if self.moveTween then
		if self.bumping then
			self.moveTween = math.min(self.moveTween + Time.deltaTime * 1.5, 1)
			local t = math.sin(math.smoothstep(self.moveTween, 0, 1) * math.pi) * 0.023
			self.go:setWorldPosition(self.moveFromPosition + self.moveDelta * t)
		else
			self.moveTween = math.min(self.moveTween + Time.deltaTime * 0.85, 1)
			local t = math.smoothstep(self.moveTween, 0, 1)
			self.go:setWorldPosition(self.moveFromPosition + self.moveDelta * t)
		end
		
		-- arrive
		if self.moveTween == 1 then
			-- if self.go.obstacle then self.go.obstacle:enable() end
			self.moveTween = nil
			self.moveFromPosition = nil
			self.moveDelta = nil
			self.bumping = nil
            self.go.ladder:enable()
		end
	end
end

function SlideComponent:isMoving()
	return self.moveTween ~= nil
end

function SlideComponent:start()
	-- console:print("ok")
end

function LadderComponent:onClick()
	if not party:isMoving() and not self.go.slide then
		party:climbLadder()
	end
end

defineProxyClass{
	class = "SlideComponent",
	baseClass = "Component",
	description = "Allows for objects to be moved left and right.",
	methods = {
		{ "push", "number" },
        { "pushRight" },
        { "pushLeft" },
		{ "destinationBlocked", "number" },
		{ "rightBlocked" },
		{ "leftBlocked" },
		{ "activate" },
		{ "deactivate" },
        { "start" }
	},
}

-------------------------------------------------------------------------------
-- Code Number Pad Component
-------------------------------------------------------------------------------

-- NumberPadComponent = class(Component)

-- -- @private

-- function NumberPadComponent:init(go)
-- 	self:super(go)
-- 	self.activated = false
-- 	self.y = 0
-- end

-- function NumberPadComponent:onInit()
--     self:activate()
-- end

-------------------------------------------------------------------------------
-- Wall Obstacle Component
-------------------------------------------------------------------------------

WallObstacleComponent = class(Component)
	.synthesizeProperty("blockMonsters")		-- whether the obstacle blocks monster movement
	.synthesizeProperty("blockParty")			-- whether the obstacle blocks party movement
	.synthesizeProperty("blockItems")			-- whether items can be dropped to obstacle's square
	.synthesizeProperty("hitSound")				-- sound to play when obstacle is hit
	.synthesizeProperty("hitEffect")			-- particle effect to play when obstacle is hit
	.synthesizeProperty("repelProjectiles")		-- whether impacted projectiles should be pushed out of obstacle's square

-- @private

WallObstacleComponent.HashMap = HashMapComponentManager.create()

function WallObstacleComponent:init(go)
	self:super(go)
	self.blockMonsters = true
	self.blockParty = true
	self.blockItems = true
end

function WallObstacleComponent:onInit()
	-- enable repel projectiles by default for non-breakables
	if self.repelProjectiles == nil and not self.go.health then
		self.repelProjectiles = true
	end

    local key = WallObstacleComponent.computeHashKey(self.go.map, self.go.x, self.go.y, self.go.facing, self.go.arch.placement)
	WallObstacleComponent.HashMap:addWithKey(self, key)
    -- console:print("position set",self.go.x,self.go.y,self.go.facing,self.go.arch.placement)
end

function WallObstacleComponent:destroy()
	WallObstacleComponent.HashMap:remove(self)
end

function WallObstacleComponent:playHitEffects()
	-- sound effect
	if self.hitSound and self.hitSound ~= "$weapon" then
		self.go:playSound(self.hitSound)
	end
	
	-- particle effect
	if self.hitEffect then
		local fx = spawn(self.go.map, "particle_system", self.go.x, self.go.y, 0, self.go.elevation)
		fx.particle:setParticleSystem(self.hitEffect)
		local pos = fx:getWorldPosition()
		pos.x = pos.x + (math.random() - 0.5)
		pos.y = pos.y + math.random() * 0.5 + 0.5
		pos.z = pos.z + (math.random() - 0.5)
		fx:setWorldPosition(pos)
	end
end

function WallObstacleComponent:onPositionChanged()
	-- don't update if onInit hasn't been called yet
	if self._hashkey then
        -- console:print("position changed",self.go.x,self.go.y,self.go.facing,self.go.arch.placement)
		local key = WallObstacleComponent.computeHashKey(self.go.map, self.go.x, self.go.y, self.go.facing, self.go.arch.placement)
		WallObstacleComponent.HashMap:updateWithKey(self, key)
	end
end

function WallObstacleComponent:onAttackedByChampion(champion, weapon, attack, slot, dualWieldSlot)
	if self.enabled and self.go.elevation == party.go.elevation then
		-- can't attack monster blockers
		if self.blockMonsters and not self.blockParty and not self.blockItems then return false end

		self:playHitEffects()

		if self.hitSound == "$weapon" then
			-- use weapon's impact sound
			if weapon then
				if weapon.impactSound then soundSystem:playSound2D(weapon.impactSound) end
			else
				soundSystem:playSound2D("impact_punch")
			end
		end

		local dmg = computeDamage(champion:getDamageWithAttack(weapon, attack))
		
		if attack.cameraShake then
			party:shakeCamera(0.5, 0.3)
		end

		if self.go:sendMessage("onDamage", dmg) then
			-- show damage in attack panel only if something was damaged
			champion:showAttackResult(dmg, GuiItem.HitSplash, dualWieldSlot)
		end

		return true
	end
end

-- function WallObstacleComponent:onPartyPickUpItem(item)
-- 	if self.enabled and self.preventPickUp and party.go.map == self.go.map and item.go.x == self.go.x and item.go.y == self.go.y and self.go.elevation == party.go.elevation then
-- 		return "cancel"
-- 	end
-- end

function WallObstacleComponent:onPartyDropItem(item, x, y)
	if self.enabled and self.blockItems and party.go.map == self.go.map and x == self.go.x and y == self.go.y and self.go.elevation == party.go.elevation then
		return "cancel"
	end
end

function WallObstacleComponent.checkObstacle(map, x, y, elevation, obstacleBits, ignoreEntity)
	local obstacle = WallObstacleComponent.HashMap:getHead(map, x, y)
	while obstacle do
		if obstacle.go.map == map and obstacle.go.x == x and obstacle.go.y == y and
			obstacle.go.elevation == elevation and obstacle.enabled and obstacle.go ~= ignoreEntity then
			if obstacle.blockParty and bit.band(obstacleBits, ObstacleBits.Party) ~= 0 then return true end
			if obstacle.blockMonsters and bit.band(obstacleBits, ObstacleBits.Monster) ~= 0 then return true end
		end
		obstacle = obstacle._next
	end
end

function WallObstacleComponent.getFirstObstacleAt(map, x, y)
	return WallObstacleComponent.HashMap:getHead(map, x, y)
end

function WallObstacleComponent:gameLoaded()
	WallObstacleComponent.HashMap:add(self)
end

function WallObstacleComponent.computeHashKey(map, x, y, facing, placement)
	if placement == "wall" then
		if facing == 2 then
			--facing = 0
			y = y + 1
		elseif facing == 3 then
			--facing = 1
			x = x - 1
		end
	end

	local key = x + y * map.width + map.level * (map.width * map.height)
	return key
end

function WallObstacleComponent.getWallAt(map, x, y, facing, elevation)
	local key = WallObstacleComponent.computeHashKey(map, x, y, facing, "wall")
	local door = WallObstacleComponent.HashMap:getHeadWithKey(key)
	while door do
		if door.go.map == map and door.go.elevation == elevation and door.go.arch.placement == "wall" then
			local dx,dy = getDxDy(facing)
			if (door.go.x == x and door.go.y == y and door.go.facing == facing and door.enabled) or
			   (door.go.x == x + dx and door.go.y == y + dy and door.go.facing == (facing+2)%4 and door.enabled) then
			   	return door
			end
		end
		door = door._next
	end
end

function WallObstacleComponent:onAttackedByChampion(champion, weapon, attack, slot, dualWieldSlot)
	-- if self:callHook("onAttackedByChampion", objectToProxy(champion), objectToProxy(weapon), objectToProxy(attack), slot) == false then
	-- 	return true
	-- end

	if self.hitSound and attack.__class ~= FirearmAttackComponent then
		if self.hitSound == "$weapon" then
			-- use weapon's impact sound
			if weapon then
				if weapon.impactSound then soundSystem:playSound2D(weapon.impactSound) end
			else
				soundSystem:playSound2D("impact_punch")
			end
		else
			soundSystem:playSound2D(self.hitSound)
		end
	end

	champion:showAttackResult("Miss", GuiItem.HitSplash, dualWieldSlot)
	return true
end

function WallObstacleComponent:isPassable()
	return not self.enabled
end

-- CustomMonsterCondition = class(Condition)

-- function CustomMonsterCondition:init(name)
-- 	local desc = dungeon.conditions[name]
-- 	assert(desc, "invalid custom condition: "..tostring(name))
-- 	self:super(desc.uiName, desc.description, desc.icon)
-- 	self.harmful = desc.harmful
-- 	self.beneficial = desc.beneficial
-- 	self.tickInterval = desc.tickInterval
-- 	self.onStart = desc.onStart
-- 	self.onStop = desc.onStop
-- 	self.onTick = desc.onTick
-- 	self.onRecomputeStats = desc.onRecomputeStats

-- 	if desc.iconAtlas then
-- 		self.iconAtlasTex = RenderableTexture.load(desc.iconAtlas)
-- 	end
-- end

-- function CustomMonsterCondition:start(monster)
-- 	if self.onStart then self.onStart(objectToProxy(self), objectToProxy(monster), true) end
-- end

-- function CustomMonsterCondition:restart(monster)
-- 	if self.onStart then self.onStart(objectToProxy(self), objectToProxy(monster), false) end
-- end

-- function CustomMonsterCondition:stop(monster)
-- 	if self.onStop then self.onStop(objectToProxy(self), objectToProxy(monster)) end
-- end

-- function CustomMonsterCondition:tick(monster)
-- 	if self.onTick then self.onTick(objectToProxy(self), objectToProxy(monster)) end
-- 	self.timer = self.tickInterval or 1
-- end

-- function CustomMonsterCondition:recomputeStats(monster)
-- 	if self.onRecomputeStats then self.onRecomputeStats(objectToProxy(self), objectToProxy(monster)) end
-- end
