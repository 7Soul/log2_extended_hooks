extendProxyClass(ContainerItemComponent, "slots")
extendProxyClass(ContainerItemComponent, "uiName")
extendProxyClass(ContainerItemComponent, "customSlots")
extendProxyClass(ContainerItemComponent, "closeButton")
extendProxyClass(ContainerItemComponent, "customSlotGfx")
extendProxyClass(ContainerItemComponent, "gfx")

local oldContainerItemComponentGetCapacity = ContainerItemComponent.getCapacity
function ContainerItemComponent:getCapacity()
	local rval = self.slots or oldContainerItemComponentGetCapacity(self)

    -- Addition to allow a custom amount of slots
	if customSlots then
		assert(type(customSlots) == "table")
		for i=1,#customSlots do
			rval = rval + 1
		end
	end
	return rval
end

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