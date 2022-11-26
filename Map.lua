
local oldMapCheckDoor = Map.checkDoor
function Map:checkDoor(x, y, dir, elevation, ignoreSparseDoors)
	local rval = oldMapCheckDoor(self, x, y, dir, elevation, ignoreSparseDoors)

    -- Let's also check for our custom WallObstacleComponent
	local wall = WallObstacleComponent.getWallAt(self, x, y, dir, elevation)
	if wall then rval = wall end

	return rval
end

local oldMapFindDoor = Map.findDoor
function Map:findDoor(x, y, dir, elevation)
	local rval = oldMapFindDoor(self, x, y, dir, elevation)

    -- Let's also check for our custom WallObstacleComponent
	local wall = WallObstacleComponent.getWallAt(self, x, y, dir, elevation)
	if wall then rval = wall end
    
	return rval
end

function Map:moveEntity(ent, x, y)
	assert(ent and x and y)
	self:removeEntityFromCell(ent, ent.x, ent.y)

	-- Objects that are placed on a wall now properly rest in the tile they're located in, instead of having a bias towards the top-right
	if ent.arch.placement == "wall" and (ent.facing == 0 or ent.facing == 1) then
		local dx,dy = getDxDy(ent.facing)
		x = x - dx
		y = y - dy
	end

	ent.x = x
	ent.y = y
	self:addEntityToCell(ent, ent.x, ent.y)

	-- notify teleporters
	for _,t in self:componentsAt(TeleporterComponent, x, y) do
		t:entityAddedToCell(ent)
	end
end