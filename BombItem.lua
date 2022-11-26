
function BombItemComponent:explode(map, x, y, facing)
	if self:callHook("onExplode", map.level, x, y, facing, self.go.elevation) == false then
		return
	end

	local power = self.bombPower or 0

	-- damage multiplier from multiple bombs
	local item = self.go.item
	if item and item.count and item.count > 1 then
		power = math.floor(power * (1 + (item.count-1) * 0.2))
	end

	local thrownByChampion, champion

	if item and item.thrownByChampion then
		thrownByChampion = item.thrownByChampion
		champion = party:getChampionByOrdinal(thrownByChampion)
		
		-- traits modifiers
		for name,skill in pairs(dungeon.skills) do
			if skill.onComputeBombPower then
				power = skill.onComputeBombPower(objectToProxy(self), objectToProxy(champion), power, champion:getSkillLevel(name)) or power
			end
		end
		
		-- traits modifiers
		for name,trait in pairs(dungeon.traits) do
			if trait.onComputeBombPower then
				power = trait.onComputeBombPower(objectToProxy(self), objectToProxy(champion), power, iff(champion:hasTrait(name), 1, 0)) or power
			end
		end

		-- equipment modifiers (equipped items only)
		for i=1,ItemSlot.BackpackFirst-1 do
			local it = champion:getItem(i)
			if it then
				if it.go.equipmentitem and it.go.equipmentitem:isEquipped(champion, i) then
					for i=1,it.go.components.length do
						local comp = it.go.components[i]
						if comp.onComputeBombPower then
							power = comp:onComputeBombPower(self, champion, power) or power
						end
					end
				end
			end
		end
	end
	
	local elevation = self.go.elevation

	if self.bombType == "shock" then
		local ent = spawn(map, "shockburst", x, y, facing, elevation)
		ent.tiledamager:setAttackPower(power)
		ent.tiledamager:setCastByChampion(thrownByChampion)
	elseif self.bombType == "fire" then
		local ent = spawn(map, "fireburst", x, y, facing, elevation)
		ent.tiledamager:setAttackPower(power)
		ent.tiledamager:setCastByChampion(thrownByChampion)

		-- spawn wall of fire but only if there's ground or a platform underneath
		if elevation == map:getElevation(x, y) or PlatformComponent.getPlatformAt(map, x, y, elevation) then
			local ent = spawn(map, "wall_fire", x, y, facing, elevation)
			ent.tiledamager:setAttackPower(5)
			ent.tiledamager:setCastByChampion(thrownByChampion)
		end
	elseif self.bombType == "frost" then
		local ent = spawn(map, "frostburst", x, y, facing, elevation)
		ent.tiledamager:setAttackPower(power)
		ent.tiledamager:setCastByChampion(thrownByChampion)
	elseif self.bombType == "poison" then
		local ent = spawn(map, "poison_cloud_medium", x, y, 0, elevation)
		ent.cloudspell:setAttackPower(power)
		ent.cloudspell:setCastByChampion(thrownByChampion)
	else
		console:warn("unknown bomb type: "..tostring(self.bombType))
	end
end
