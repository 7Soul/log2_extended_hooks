
function CraftPotionComponent:updatePanel(champion, x, y)
	-- eat mouse pressed
	gui:buttonLogic("potion_panel", x, y, GuiItem.SpellPanel.width, GuiItem.SpellPanel.height)

    -- New: draw a blank background. Slots are drawn later
	local panelTex = RenderableTexture.load(ExtendedHooks.gfxFolder.."craftPotionPanelBlank.tga")
	do
		local x = x * gui.guiScale + gui.guiBiasX
		local y = y * gui.guiScale + gui.guiBiasY
		
		local width = 172 * gui.guiScale
		local height = 118 * gui.guiScale

		ImmediateMode.drawImage(panelTex, x, y, 0, 0, 172, 118, width, height, Color.White)
	end

	-- spellcasting disabled?
	local enabled = champion:isReadyToAttack(ItemSlot.Weapon) and champion:isReadyToAttack(ItemSlot.OffHand)
	if not enabled then
		gui:fillRect(x, y, GuiItem.SpellPanel.width, GuiItem.SpellPanel.height, {23,23,23,180})
	end

	-- close panel automatically if mortar is removed from hand
	local mortarInHand = champion:getItem(ItemSlot.Weapon) == self.go.item or champion:getItem(ItemSlot.OffHand) == self.go.item
	if not mortarInHand then
		self:close(champion)
	end

	-- close panel if hand is wounded
	if champion:getItem(ItemSlot.Weapon) == self.go.item and champion:hasCondition("right_hand_wound") then self:close(champion) end
	if champion:getItem(ItemSlot.OffHand) == self.go.item and champion:hasCondition("left_hand_wound") then self:close(champion) end

	-- close panel if character is disabled
	if champion:hasCondition("petrified") or champion:hasCondition("paralyzed") then
		self:close(champion)
	end
	
	-- close button
	do
		local w = 40
		local h = 24
		local x = x + 130
		--gui:drawRect(x, y, w, h)
		if gui:buttonLogic("brew_potion_close_panel", x, y, w, h, "any") then
		 	champion:showAttackPanel(nil)
		end
	end

	if enabled then
		self:countHerbs(champion)
		self:reserveHerbs(champion)
		self:drawHerbs(champion, x, y)
		self:previewButton(champion, x + 130, y + 24)
		self:drawRecipe(champion, x, y + 85)
		self:eraseButton(champion, x + 130, y + 85)
	end	
end

function CraftPotionComponent:drawHerbs(champion, x, y)
    -- The only change here is that we draw our custom herbs instead of the default pre-made buttons
	local w = 44
	local h = 44
	
	for ty=0,1 do
		for tx=0,2 do
			local symbol = ty * 3 + tx + 1
			local x = x + tx * w
			local y = y + ty * h

            -- Draw a semi-transparent herb icon
			local it = CraftPotionComponent.Herbs[ty * 3 + tx + 1]
			gui:drawItemIcon(it, x, y, w/75, false, {80,80,80,128})
		
			-- draw herb
			local it = CraftPotionComponent.Herbs[ty*3 + tx + 1]
			if it.count > 0 then
				it.count = it.count - it.reserved
				gui:drawItemIcon(it, x, y, w/75, true)
				it.count = it.count + it.reserved

				if gui:buttonLogic("herb_button"..symbol, x, y, w, h, "any") and self.recipe < 1000 then
					if it.reserved < it.count then
						self.recipe = self.recipe * 10 + symbol
					end
				end
			end
		end
	end
end

function CraftPotionComponent:brewPotion(champion)
	if self.recipe == 0 then return end

	local alchemy = champion:getSkillLevel("alchemy")

	-- verify that champion has enough herbs
	local herbs = CraftPotionComponent.Herbs
	for i=1,#herbs do
		if herbs[i].count < herbs[i].reserved then
			gui:hudPrint(champion.name.." does not have enough herbs to craft this potion.")
			return
		end
	end

	-- get recipe
	local recipe = self:getPotionRecipe(self.recipe)
	if not recipe then
		gui:hudPrint(champion.name.." failed to brew a potion.")
		self.recipe = 0
		champion:showAttackPanel(nil)
		return
	end

	-- check alchemy skill
	if alchemy < (recipe.level or 0) then
		gui:hudPrint(champion.name.." is not skilled enough in Alchemy to brew this potion.")
		return
	end

	-- consume herbs
	local r = self.recipe
	for i=5,0,-1 do
		-- extract herb from recipe
		local h = math.floor(r / 10^i)
		r = r - h * 10^i

		if h ~= 0 then
			self:consumeHerb(champion, CraftPotionComponent.Herbs[h%10].name)
		end
	end

	local potion = recipe.potion
    local count = 1
    local returnVal = party:callHook("onBrewPotion", count, potion, objectToProxy(champion)) 
    if returnVal then
        if returnVal[1] == false then return false end
        potion = returnVal[2] or potion
        count = returnVal[3] or count
    end

    -- Hooks
    local rval = true
    rval, potion, count = self:onBrewPotion(champion, potion, count, recipe)
    if rval == false then return false end
	-- console:print(rval, potion, count)

	local mouseItem = gui:getMouseItem()
	if mouseItem == nil then
		-- create new potion to mouse hand
		local item = create(potion).item
		item:setStackSize(count)
		gui:setMouseItem(item)
	elseif mouseItem.go.arch.name == potion then
		-- merge new potion to stack in hand
		mouseItem.count = mouseItem.count + count
	else
		-- create new potion on the ground
		local item = spawn(party.go.map, potion, party.go.x, party.go.y, party.go.facing, party.go.elevation).item
		item:setStackSize(count)
	end

	soundSystem:playSound2D("brew_potion")

	party.go.statistics:increaseStat("potions_mixed", 1)

	self.recipe = 0
	champion:showAttackPanel(nil)
end

function CraftPotionComponent:onBrewPotion(champion, potion, count, recipe)
	-- Triggers on potion crafted
    local rval = true
    local count2 = count
    local potion2 = potion
    -- skill modifiers
	for name,skill in pairs(dungeon.skills) do
		if skill.onBrewPotion then
			rval, potion2, count2 = skill.onBrewPotion(objectToProxy(champion), potion, count, recipe, champion:getSkillLevel(name))
            
            if rval == false then return false end
			-- If the hook changes the potion, we exit with it right away
            if potion2 ~= nil and potion2 ~= potion then return rval, potion2, (count2 or 1) end
		end
	end

	-- trait modifiers
	for name,trait in pairs(dungeon.traits) do
		if trait.onBrewPotion then
			rval, potion2, count2 = trait.onBrewPotion(objectToProxy(champion), potion, count, recipe, iff(champion:hasTrait(name), 1, 0))

			if rval == false then return false end
            -- If the hook changes the potion, we exit with it right away
            if potion2 ~= nil and potion2 ~= potion then return rval, potion2, (count2 or 1) end
		end
	end

	-- equipment modifiers (equipped items only)
	for i=1,ItemSlot.BackpackFirst-1 do
		local it = champion:getItem(i)
		if it then
			if it.go.equipmentitem and it.go.equipmentitem:isEquipped(champion, i) then
				for i=1,it.go.components.length do
					local comp = it.go.components[i]
					if comp.onBrewPotion then
						rval, potion2, count2 = comp:onBrewPotion(champion, potion, count, recipe)

						if rval == false then return false end
           				-- If the hook changes the potion, we exit with it right away
            			if potion2 ~= nil and potion2 ~= potion then return rval, potion2, (count2 or 1) end
					end
				end
			end
		end
	end
	
	if count2 then count  = count2 end
    return rval, potion, count
end
