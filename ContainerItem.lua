extendProxyClass(ContainerItemComponent, "slots")
extendProxyClass(ContainerItemComponent, "uiName")
extendProxyClass(ContainerItemComponent, "customSlots")
extendProxyClass(ContainerItemComponent, "closeButton")
extendProxyClass(ContainerItemComponent, "customSlotGfx")
extendProxyClass(ContainerItemComponent, "gfx")

ContainerItemComponent:dontAutoSerialize("items", "customSlots")

local oldContainerItemComponentGetCapacity = ContainerItemComponent.getCapacity
function ContainerItemComponent:getCapacity()
	local rval = self.slots or oldContainerItemComponentGetCapacity(self)

    -- Addition to allow a custom amount of slots
	if self.customSlots then
		rval = 0
		assert(type(self.customSlots) == "table")
		for i=1,#self.customSlots do
			rval = rval + 1
		end
		return rval
	else
		return rval
	end
end

function ContainerItemComponent:loadState(file)
	-- load slots references
	if not self.customSlots then self.customSlots = {} end
	while file:availableBytes() > 0 do
		local id = file:openChunk()
		-- 0, 0, 1, 0, 2, 0...
		if id == "SLTS" then
			local t = {}
			table.insert(t, file:readValue())
			table.insert(t, file:readValue())
			table.insert(self.customSlots, t)
			t = {}
		end
		file:closeChunk()
	end
end

function ContainerItemComponent:saveState(file)
	-- save slots references
	if self.customSlots then
		file:openChunk("SLTS")
		for i=1,#self.customSlots do
			-- entry values
			for n=1,2 do
				file:writeValue(self.customSlots[n])
			end
		end
		file:closeChunk()
	end
end

-- function AmateriaComponent:gameLoaded()
-- 	-- resolve monster references
-- 	for i=1,self.monsters.length do
-- 		local id = self.monsters[i]
-- 		local ent = self.go.map.dungeon:findEntity(id)
-- 		if not ent then
-- 			assert(false, "could not resolve object reference with id "..tostring(id).." (referenced by "..self.go.id..")")
-- 		end
-- 		self.monsters[i] = ent.monster
-- 	end
-- end

function ContainerItemComponent:acceptsItem(item, slot)
	if not item:getFitContainer() then return false end

    -- Extra conditions can now be added to accept only certain items
	if self.onAcceptItem then
		return self:onAcceptItem(item, champion)
	end
	return true
end

local oldContainerItemComponentOnUseItem = ContainerItemComponent.onUseItem
function ContainerItemComponent:onUseItem(champion)
    -- A new hook to prevent the container from being oppened
	if self.onOpen then
		if not self:onOpen(champion) then return false end
	end

    oldContainerItemComponentOnUseItem(self, champion)
end

function ContainerItemComponent:onCalculateWeight(weight, item, champion)
    -- A new hook to alter the content's weight
	if self.enabled then
		local modifier = self:callHook("onCalculateWeight", weight, objectToProxy(item), objectToProxy(champion))
		return modifier or weight
	end
end

function ContainerItemComponent:onAcceptItem(item, champion)
    -- Hook to check if the container can take the item
    -- The item wont be accepted if it returns false
	if self.enabled then
		local modifier = self:callHook("onAcceptItem", objectToProxy(item), objectToProxy(champion))
		if modifier == false then return false end
		return true
	end
end

function ContainerItemComponent:onOpen(champion)
    -- Hook to check if the container can be opened by the champion
    -- It wont open if it returns false
	if self.enabled then
		local modifier = self:callHook("onOpen", objectToProxy(champion))
		if modifier == false then return false end
		return true
	end
end