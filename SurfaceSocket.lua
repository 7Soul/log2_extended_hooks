function SurfaceComponent.__proxyClass:dropItem(item, triggerHook)
	-- Removes item from surface component and drops it in front of it
	local it = proxyToObject(item)
	self = proxyToObject(self)
	assert(it.__class == ItemComponent)
	if self.items then
		if self.items:remove(it) then
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
			if triggerHook then
				self.go:sendMessage("onRemoveItem", item)
				self:callHook("onRemoveItem", objectToProxy(item))
			end
			return true
		end
	end
	return false
end

function SurfaceComponent:getItemByIndex(index)
	-- Gets the Nth item from this surface
	if not index then index = 1 end
	if self.items and index <= self.items.length then
		return self.items[index]
	end
	return nil
end

function SocketComponent.__proxyClass:dropItem(item, triggerHook)
	-- Removes item from socket component and drops it in front of it
	local it = proxyToObject(item)
	self = proxyToObject(self)
	assert(it.__class == ItemComponent)
	if self.items then
		if self.items:remove(it) then
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

			if triggerHook then
				self.go:sendMessage("onRemoveItem", item)
				self:callHook("onRemoveItem", objectToProxy(item))
			end
			return true
		end
	end
	return false
end

function SocketComponent:getItemByIndex(index)
	-- Gets the Nth item from this socket
	if not index then index = 1 end
	if self.items and index <= self.items.length then
		return self.items[index]
	end
	return nil
end