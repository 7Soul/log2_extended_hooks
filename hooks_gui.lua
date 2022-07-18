
-------------------------------------------------------------------------------------------------------
-- Tooltip Functions                                                                                 --
-------------------------------------------------------------------------------------------------------

-- Item Tooltip
function ToolTip.drawItem(item, x, y, width, height)
	local actualWidth = 0
	local actualHeight = 0

	if ToolTip.style == "rounded_rect" then
		-- add little extra to width to make it look nicer
		gui:drawToolTipRect(x, y, width + 4, height)
	end
	
	local tx,ty = x + 16, y + 16		
	--ImmediateMode.fillRoundedRectAntialiased(tx, ty, 75, 75, 4, {0,0,0,120})
	gui:drawItemIcon(item, tx, ty - 5, 1, false)

	tx = tx + 90
	ty = ty + 4

	-- draw caption
	local desc = item:getFormattedName()	
	local font = ToolTip.titleFont
	ty = ty + font:getMaxBearingY()
	actualWidth = math.max(actualWidth, gui:drawText(desc, tx, ty, font, item:getItemNameColor()))
	
	ty = ty + math.floor(font:getMaxBearingY() * 1.1) --24

	local font = ToolTip.normalFont
	local h = font:getLineHeight() --22

	-- weapon/armor traits
	local traits = item:getTraitsText()
	-- armor set info
	if item.armorSet and dungeon.conditions[item.armorSet .. "_set"] then
		local name = string.capitalize(string.underscoreToCamelCase(item.armorSet))
		if traits ~= "" then
			traits = traits .. string.format("- %s Set", name)
		else
			traits = traits .. string.format("%s Set", name)
		end
	end

	if #traits > 0 then
		actualWidth = math.max(actualWidth, gui:drawText(traits, tx, ty, font, Color.White))
		ty = ty + h*1.3
	else
		ty = ty + h*0.3
	end

	if not config.hideItemProperties then				
		if item.go.equipmentitem then
			ty,actualWidth = ToolTip.drawEquipmentItem(item.go.equipmentitem, tx, ty, actualWidth, height)
		end
		
		local attack = item:getPrimaryAction()
		if attack then attack = item.go:getComponent(attack) end
		
		if attack then
			ty,actualWidth = ToolTip.drawAttack(attack, tx, ty, actualWidth, height)
		end
		
		-- ammo
		if item.go.ammoitem and item.go.ammoitem.attackPower then
			actualWidth = math.max(actualWidth, gui:drawText(string.format("Damage: %+d", item.go.ammoitem:getAttackPower()), tx, ty, font))
			ty = ty + h
		end

		-- game effect description
		if item.gameEffect then
			local tw,th = gui:drawTextParagraph(item.gameEffect, tx, ty, 450, font)
			actualWidth = math.max(actualWidth, tw)
			ty = ty + th
			ty = ty + 4
		end

		-- draw nutritional value bar for food items
		if item.go.usableitem and item.go.usableitem.nutritionValue then
			gui:drawText("Nutrition:", tx, ty, font)

			local x = tx + 100

			local width = 150
			local height = 18
			gui:drawThickRect(x, ty-14, width, height, "606060FF")

			width = width - 6
			local bwidth = math.clamp(item.go.usableitem.nutritionValue * width / 1000, 0, width)
			local bheight = height - 6
			gui:fillRect(x+3, ty-11, bwidth, bheight, "3A903AFF")

			actualWidth = math.max(actualWidth, width + 100)
			ty = ty + h
		end

		-- usable item requirements
		local usableitem = item.go.usableitem
		if usableitem then
			local requirements = usableitem:getRequirementsText()
			if requirements then
				local color = iff(usableitem:checkRequirements(charSheet:getActiveChampion()), Color.White, Color.Red)
				actualWidth = math.max(actualWidth, gui:drawText(requirements, tx, ty, font, color))
				ty = ty + h
			end
		end

		if item.weight then
			local fmt = "%.1f"
			local weight = iff(item.stackable, item.weight, item:getTotalWeight())
			if weight < 0.1 and weight ~= 0 then
				weight = string.format("%.2f", weight)
			else
				weight = string.format("%.1f", weight)
			end

			if item.stackable then
				actualWidth = math.max(actualWidth, gui:drawText("Weight: "..weight.." kg each", tx, ty, font))
			else
				actualWidth = math.max(actualWidth, gui:drawText("Weight: "..weight.." kg", tx, ty, font))
			end
			ty = ty + h		
		end
		
		if item.go.spellscrollitem then
			ty,actualWidth = ToolTip.drawSpellScrollItem(item.go.spellscrollitem, tx, ty, actualWidth, height)
		end

		local sa = item:getSecondaryAction()
		if sa then sa = item.go:getComponent(sa) end
		
		if sa then
			local champion = charSheet:getActiveChampion()
			if sa.requirements == nil or sa:checkRequirements(champion) then
				ty = ty + 10
				actualWidth = math.max(actualWidth, gui:drawText(string.format("%s (Special attack)", sa.uiName or "???"), tx, ty, font, {255,225,128,255}))
				ty = ty + 20
				ty,actualWidth = ToolTip.drawAttack(sa, tx, ty, actualWidth, height, true)
				actualWidth = math.max(actualWidth, gui:drawText("(Hold down attack button to use)", tx, ty, font))
				ty = ty + 20
			else
				ty = ty + 10
				actualWidth = math.max(actualWidth, gui:drawText(string.format("%s (Special attack)", sa.uiName or "???"), tx, ty, font, {255,225,128,255}))
				ty = ty + 20

				local text = sa:getRequirementsText(champion)
				if text then
					actualWidth = math.max(actualWidth,  gui:drawText(text, tx, ty, font, Color.Red))
					ty = ty + 20
				end

			end
		end
	end
	
	do
		local text
		if item:hasTrait("consumable") then
			text = "(Right-click to consume)"
		elseif item:hasTrait("readable") then
			text = "(Right-click to read)"
		elseif item:hasTrait("usable") or item.go.usableitem then
			text = "(Right-click to use)"
		elseif item.go.containeritem then
			text = "(Right-click to open)"
		end

		if text then
			actualWidth = math.max(actualWidth, gui:drawText(text, tx, ty, font))
			ty = ty + h
		end
	end
	
	if item.stackable then
		actualWidth = math.max(actualWidth, gui:drawText("(Shift-click to handle single items)", tx, ty, font))
		ty = ty + h
	end

	-- description
	if item.description then
		ty = ty + FontType.ScrollScaled:getLineHeight() * 0.3 + 3
		local tw,th = gui:drawTextParagraph(item.description, tx, ty, 450, FontType.ScrollScaled)
		actualWidth = math.max(actualWidth, tw)
		ty = ty + th
		ty = ty + 4
	end

	-- scrolls
	if item.go.scrollitem then
		ty,actualWidth = ToolTip.drawScrollItem(item.go.scrollitem, tx, ty, actualWidth, height)
	end
	
	actualWidth = actualWidth / gui.guiScale + 90 + 32
	actualHeight = math.max(ty - y, 75 + 32)
	
	return actualWidth, actualHeight
end

-- Attack

function ToolTip.drawAttack(attack, tx, ty, width, height, powerAttack)
	local actualWidth = width
	local font = ToolTip.normalFont
	local h = font:getLineHeight() --22

	-- charges
	if attack.charges and attack.maxCharges then
		local w = gui:drawText(string.format("Charges: ", attack.charges), tx, ty, font)
		actualWidth = math.max(actualWidth, w)
		local x,y = tx + w,ty - 13
		gui:drawRect(x, y, attack.maxCharges * 10 + 2, 12 + 4, {40,40,40,255})
		for i=1,attack.charges do
			gui:fillRect(x + 2, y + 2, 8, 12, {200, 50, 20, 255}) --{99,114,105,255})
			x = x + 8 + 2
		end
		actualWidth = math.max(actualWidth, attack.maxCharges * 10 + 65)
		ty = ty + h
	end

	-- energy cost
	if attack.energyCost and attack.energyCost ~= 0 then
		actualWidth = math.max(actualWidth, gui:drawText(string.format("Energy Cost: %d", attack.energyCost), tx, ty, font))
		ty = ty + h
	end

	if not powerAttack then
        if attack.attackPower and attack.attackPower ~= 0 then
            local mod = { attack.minDamageMod, attack.maxDamageMod }
			local variation = attack.attackPowerVariation or 0.5
			local min,max = getDamageRange(attack.attackPower, mod, variation)
			
			local text
			if attack.damageType and attack.damageType ~= "physical" then
				local damageType = attack.damageType
				if damageType == "dispel" then
					damageType = "Ethereal"
				else
					damageType = string.capitalize(damageType)
				end
				text = string.format("Damage: %s %d - %d", damageType, min, max)
			else
				text = string.format("Damage: %d - %d", min, max)
			end

			-- bonus
			local baseStat = attack:getBaseDamageStat()
			local baseMulti = attack:getBaseDamageMultiplier() or 1
			if baseStat then
				if baseMulti and baseMulti ~= 1 then
					text = string.format("%s + %s%% of user's %s", text, baseMulti*100, getStatName(baseStat))
				else
					text = string.format("%s + %s", text, getStatName(baseStat))
				end
			end

			local damageList = {"fire","cold","shock","poison"}
			for _,e in pairs(damageList) do
				local upperName = e:gsub("^%l", string.upper)
				local property = attack["attack" .. upperName]
				if property then
					local mod = { 0, 0 }
					local variation = attack.attackPowerVariation or 0.5
					local min,max = getDamageRange(property, mod, variation)
					-- console:print(property, mod, variation, min, max)
					text = string.format("%s +(%d - %d %s)", text, min, max, upperName)
				end
			end

			actualWidth = math.max(actualWidth, gui:drawText(text, tx, ty, font))
			ty = ty + h
		end
		
		if attack.accuracy then
			local text = "Accuracy:"
			local accuracy = attack.accuracy or 0

			if accuracy ~= 0 then
				text = string.format("%s %+d", text, accuracy)
			end
					
			if accuracy ~= 0 then
				actualWidth = math.max(actualWidth, gui:drawText(text, tx, ty, font))
				ty = ty + h
			end
		end

		if attack.critChance and attack.critChance ~= 0 then
			actualWidth = math.max(actualWidth, gui:drawText(string.format("Critical Chance: %+d%%", attack.critChance), tx, ty, font))
			ty = ty + h
		end

		if attack.critMultiplier and attack.critMultiplier ~= 0 then
			actualWidth = math.max(actualWidth, gui:drawText(string.format("Critical Damage: %+d%%", attack.critMultiplier), tx, ty, font))
			ty = ty + h
		end

		if attack.range and attack.range ~= 0 then
			actualWidth = math.max(actualWidth, gui:drawText(string.format("Range: %d", attack.range), tx, ty, font))
			ty = ty + h
        end
        
        if attack.jamChance and attack.jamChance ~= 0 then
			actualWidth = math.max(actualWidth, gui:drawText(string.format("Chance to malfunction: %d%%", attack.jamChance), tx, ty, font))
			ty = ty + h
		end

		if attack.cooldown and attack.cooldown ~= 0 then
			actualWidth = math.max(actualWidth, gui:drawText(string.format("Cooldown: %.1f seconds", attack.cooldown), tx, ty, font))
			ty = ty + h
		end
			
		if attack.pierce and attack.pierce ~= 0 then
			actualWidth = math.max(actualWidth, gui:drawText(string.format("Ignores %d point%s of enemy's armor", attack.pierce, attack.pierce == 1 and "" or "s"), tx, ty, font))
			ty = ty + h
        end
        
        if attack.velocity and attack.velocity ~= 0 then
			actualWidth = math.max(actualWidth, gui:drawText(string.format("Projectiles are %d%% faster", (attack.velocity - 1) * 100), tx, ty, font))
			ty = ty + h
		end

		if attack and attack.reachWeapon then
			actualWidth = math.max(actualWidth, gui:drawText("Reach Weapon", tx, ty, font))
			ty = ty + h
		end
	end

	if attack.requirements then
		local champion = charSheet:getActiveChampion()
		local text = attack:getRequirementsText()
		local color = iff(attack:checkRequirements(champion), Color.White, Color.Red)
		if text then
			actualWidth = math.max(actualWidth, gui:drawText(text, tx, ty, font, color))
			ty = ty + h
		end
	end

	if attack.gameEffect then
		actualWidth = math.max(actualWidth, gui:drawText(attack.gameEffect, tx, ty, font))
		ty = ty + h
	end

	return ty,actualWidth
end

-- EquipmentItem
-- Shows some of the new stats, such as Min/Max Damage bonus and Crit Multiplier
function ToolTip.drawEquipmentItem(item, tx, ty, width, height)
	local actualWidth = width
	local font = ToolTip.normalFont
	local h = font:getLineHeight()
	
	if item.protection and item.protection ~= 0 then
		actualWidth = math.max(actualWidth, gui:drawText(string.format("Protection %+d", item.protection), tx, ty, font))
		ty = ty + h
	end
	
	if item.evasion then
		actualWidth = math.max(actualWidth, gui:drawText(string.format("Evasion %+d", item.evasion), tx, ty, font))
		ty = ty + h
	end
	
	if item.accuracy then
		actualWidth = math.max(actualWidth, gui:drawText(string.format("Accuracy %+d", item.accuracy), tx, ty, font))
		ty = ty + h
    end
    
	-- stat modifiers
	for i=1,#Stats do
		local stat = Stats[i]
		local modifier = item[stat]
		if modifier and stat ~= "protection" and stat ~= "evasion" then
			if modifier > 0 then
				actualWidth = math.max(actualWidth, gui:drawText(string.format("%s +%d", StatNames[i], modifier), tx, ty, font))
				ty = ty + h		
			else
				actualWidth = math.max(actualWidth, gui:drawText(string.format("%s %d", StatNames[i], modifier), tx, ty, font))
				ty = ty + h		
			end
		end
	end

	-- resistances
	if item.resistAll then
		actualWidth = math.max(actualWidth, gui:drawText(string.format("Resist All %+d", item.resistAll), tx, ty, font))
		ty = ty + h
	end

	local elementTable = {}
	for i=1,#Elements do
		local resist = elementToResistance(Elements[i])
		if item[resist] then
			if not elementTable[item[resist]] then
				elementTable[item[resist]] = {}
			end
			table.insert(elementTable[item[resist]], Elements[i])
		end
	end

	if elementTable ~= {} then
		for _,table in pairs(elementTable) do
			local text
			-- local table = v
			if #table == 3 then
				text = string.format("Resist %, %s and %s %+d", string.capitalize(table[1]), string.capitalize(table[2]), string.capitalize(table[3]), _)
			elseif #table == 2 then
				text = string.format("Resist %s and %s %+d", string.capitalize(table[1]), string.capitalize(table[2]), _)
			else
				text = string.format("Resist %s %+d", string.capitalize(table[1]), _)
			end
			actualWidth = math.max(actualWidth, gui:drawText(text, tx, ty, font))
			ty = ty + h
		end
	end

	if item.critMultiplier then
		actualWidth = math.max(actualWidth, gui:drawText(string.format("Critical Damage %+d%%", item.critMultiplier), tx, ty, font))
		ty = ty + h
    end
    
    if item.criticalChance then
		actualWidth = math.max(actualWidth, gui:drawText(string.format("Critical Chance %+d%%", item.criticalChance), tx, ty, font))
		ty = ty + h
    end
    
    if item.minDamageMod and not item.maxDamageMod then
		actualWidth = math.max(actualWidth, gui:drawText(string.format("Min Damage %+d", item.minDamageMod), tx, ty, font))
		ty = ty + h
	end
	
	if item.maxDamageMod and not item.minDamageMod then
		actualWidth = math.max(actualWidth, gui:drawText(string.format("Max Damage %+d", item.maxDamageMod), tx, ty, font))
		ty = ty + h
    end
    
	if item.maxDamageMod and item.minDamageMod then
		local text
		if item.maxDamageMod > 0 and item.minDamageMod > 0 then
			text = string.format("Adds %d - %d damage to all attacks", item.minDamageMod, item.maxDamageMod)
		elseif item.maxDamageMod < 0 and item.minDamageMod < 0 then
			text = string.format("Subtracts %d - %d damage from all attacks", -item.minDamageMod, -item.maxDamageMod)
		end
		
		actualWidth = math.max(actualWidth, gui:drawText(text, tx, ty, font))
		ty = ty + h
	end

	-- skill modifiers
	if item.skillModifiers then
		for name,value in pairs(item.skillModifiers) do
			local skill = Skill.getSkill(name)
			if skill then
				name = skill.uiName
			else
				name = "???"
			end
			actualWidth = math.max(actualWidth, gui:drawText(string.format("%s %+d", name, value), tx, ty, font))
			ty = ty + h				
		end
	end

	if item.cooldownRate and item.cooldownRate ~= 0 then
		local text
		if item.cooldownRate > 0 then
			text = string.format("%d%% faster cooldown", item.cooldownRate)
		else
			text = string.format("%d%% slower cooldown", -item.cooldownRate)
		end
		actualWidth = math.max(actualWidth, gui:drawText(text, tx, ty, font))
		ty = ty + h		
	end

	-- local regenTable = {}
	if (item.healthRegenerationRate and item.healthRegenerationRate ~= 0) and (item.energyRegenerationRate and item.energyRegenerationRate ~= 0) and (item.healthRegenerationRate == item.energyRegenerationRate) then
			local text = string.format("Health and Energy Regeneration Rate %+d%%", item.healthRegenerationRate) 
			actualWidth = math.max(actualWidth, gui:drawText(text, tx, ty, font))
			ty = ty + h	
		-- end
	else
		if item.healthRegenerationRate and item.healthRegenerationRate ~= 0 then
			local text = string.format("Health Regeneration Rate %+d%%", item.healthRegenerationRate) 
			actualWidth = math.max(actualWidth, gui:drawText(text, tx, ty, font))
			ty = ty + h		
		end
		if item.energyRegenerationRate and item.energyRegenerationRate ~= 0 then
			local text = string.format("Energy Regeneration Rate %+d%%", item.energyRegenerationRate) 
			actualWidth = math.max(actualWidth, gui:drawText(text, tx, ty, font))
			ty = ty + h		
		end
	end

	if item.expRate and item.expRate ~= 0 then
		local text
		if item.expRate > 0 then
			text = string.format("Wearer gains experience points %d%% faster", item.expRate)
		else
			text = string.format("Wearer gains experience points %d%% slower", -item.expRate)
		end
		actualWidth = math.max(actualWidth, gui:drawText(text, tx, ty, font))
		ty = ty + h		
	end

	if item.foodRate and item.foodRate ~= 0 then
		local text
		if item.foodRate > 0 then
			text = string.format("Food Consumption is %d%% higher", item.foodRate)
		else
			text = string.format("Food Consumption is %d%% lower", -item.foodRate)
		end
		actualWidth = math.max(actualWidth, gui:drawText(text, tx, ty, font))
		ty = ty + h		
	end

	if item.threat and item.threat ~= 0 then
		local text
		if item.threat > 0 then
			text = "Increases threat"
		else
			text = "Reduces threat"
		end
		actualWidth = math.max(actualWidth, gui:drawText(text, tx, ty, font))
		ty = ty + h		
	end

	if item.go.item:hasTrait("light_armor") then
		actualWidth = math.max(actualWidth, gui:drawText(string.format("Evasion -5 without Light Armor proficiency"), tx, ty, font))
		ty = ty + h
	elseif item.go.item:hasTrait("heavy_armor") then
		actualWidth = math.max(actualWidth, gui:drawText(string.format("Evasion -10 without Heavy Armor proficiency"), tx, ty, font))
		ty = ty + h
	end

	return ty,actualWidth
end

function ToolTip.drawChampion(champion, x, y, width, height)
	local actualWidth = 0

	if ToolTip.style == "rounded_rect" then
		-- add little extra to width to make it look nicer
		gui:drawToolTipRect(x, y, width + 4, height)
	end
	
	local tx,ty = x + 25, y + 16
	local h = 22
	local font = ToolTip.normalFont

	-- conditions	
	local cnt = 0
	for name,c in pairs(champion.conditions) do
		if c.uiName ~= "" then
			c:drawIcon(tx, ty)
			local stacks = c:getStacks() or 0
			local stacksText = stacks > 0 and (" (" .. stacks .. " stacks)") or ""
			local tw,th = gui:drawTextParagraph(c.uiName .. stacksText .. ": " .. c:getDescription(), tx + 42, ty + 22, 350, font) 
			actualWidth = math.max(actualWidth, 100 + tw / gui.guiScale)
		
			ty = ty + math.max(th + 10, 45)
			cnt = cnt + 1
		end
	end
	
	if cnt == 0 then
		ty = ty + 20
		gui:drawText("You are healthy.", tx, ty, font)
		ty = ty + 10
		actualWidth = 190
	end
	
	ty = ty + 10
	
	local actualHeight = ty - y
	return actualWidth,actualHeight
end

function Condition:drawIcon(x, y)
	if self.iconIndex then
		local s = 32
		local sx = ((self.iconIndex-1) % 4) * s
		local sy = math.floor((self.iconIndex-1) / 4) * s
		gui:drawImage2(self.iconAtlasTex or gui.conditionsTex, x, y, sx, sy, s, s, s, s, Color.White)

		local stacks = self:getStacks()
		if stacks > 0 then
			gui:drawTextCentered(stacks, x+16, y+26, FontType.PalatinoSmallScaled, Color.Grey)
		end
	end
end

-- Updated for aesthetic reasons
-- When a trait has a description and a game effect, the desc shows in a blueish hue
-- Skills have the option to show the traits separately from the gameEffect text
function ToolTip.drawSkill(skill, x, y, width, height)
	local points = ToolTip.hints["skill_level"] or 0
	local compact = ToolTip.hints["compact"]

	local actualWidth = 0
	local actualHeight = 0
	local paragraphWidth = 450

	if ToolTip.style == "rounded_rect" then
		gui:drawToolTipRect(x, y, width, height)
	end
	
	local tx,ty = x + 16, y + 16
	
	gui:drawSkillIcon(skill, tx, ty, 75)
	tx = tx + 90
	
	-- draw caption
	local font = ToolTip.titleFont
	local maxBearing = font:getMaxBearingY()
	ty = ty + maxBearing
	actualWidth = math.max(actualWidth, gui:drawText(skill.uiName, tx, ty, font, Color.White))
	ty = ty + 24 + 5

	local font = ToolTip.normalFont
	if compact then font = FontType.PalatinoTiny end
	
	-- description
	local desc = skill:getDescriptionText()
	local descColor = iff(not skill.gameEffect, Color.White, {162,183,206,255})
	if desc and string.len(desc) > 0 then 
		local tw,th = gui:drawTextParagraph(desc, tx, ty, paragraphWidth, font, descColor)
		actualWidth = math.max(actualWidth, tw / gui.guiScale)
		ty = ty + th / gui.guiScale
	end

	local champion = charSheet:getActiveChampion()

	-- game effect
	if skill.gameEffect then
		if desc and string.len(desc) > 0 then ty = ty + 8 end
		local tw,th = gui:drawTextParagraph(skill.gameEffect, tx, ty, paragraphWidth, font)
		actualWidth = math.max(actualWidth, tw / gui.guiScale)
		ty = ty + th / gui.guiScale
	end

	-- skill traits
	if skill.skillTraits then
		ty = math.max(ty + 8, y + 16 + 75 + maxBearing )
		tx = tx - 88
		if skill.traits then
			for traitLevel = 1, skill.maxLevel or 5 do
				local reqText, reqColor
				if skill.requirements and skill.requirements[traitLevel] then
					local requirements = true
					if skill.onCheckRestrictions then
						local rval = skill.onCheckRestrictions(objectToProxy(champion), skill, traitLevel)
						requirements = rval
						if rval == nil then requirements = true end
					end
					local color = requirements and Color.Grey or Color.Red
					local tw, th
					reqText = skill.requirements[traitLevel]
					reqColor = color
					-- tw,th = gui:drawTextParagraph(" Level " .. traitLevel .. ": " .. skill.requirements[traitLevel], tx, ty, paragraphWidth+75, font, color)
					-- actualWidth = math.max(actualWidth, paragraphWidth)
					-- ty = ty + th / gui.guiScale
				end

				if skill.traits[traitLevel] or skill.skillTraits[traitLevel] then
                    local trait = Skill.getTrait(skill.traits[traitLevel])
					local color = Color.White
					local tw, th, tempx
					if trait then
						-- Writes traits and descriptions
						tw,th = gui:drawTextParagraph("Level " .. traitLevel .. ": " .. trait.uiName, tx, ty, paragraphWidth, font, {153,244,124,255})
						ty = ty + th / gui.guiScale
						tempx = 0
					else
						-- Writes a list of traits and levels, similarly to how it worked in the first game
						tw,th = gui:drawTextAligned(traitLevel .. ":", tx+16, ty, "right", font, {153,244,124,255})
						tempx = 12
					end
					
					if reqText then
						tw,th = gui:drawTextParagraph(reqText, tx, ty, paragraphWidth+75, font, reqColor)
						actualWidth = math.max(actualWidth, paragraphWidth)
						ty = ty + th / gui.guiScale
					end

					if skill.skillTraits[traitLevel] then
						tw,th = gui:drawTextParagraph(skill.skillTraits[traitLevel], tx+12+tempx, ty, paragraphWidth+75, font, color)
						actualWidth = math.max(actualWidth, paragraphWidth)
						ty = ty + th / gui.guiScale
					end
                end
			end

			local last = (skill.maxLevel or 5) + 1
			if skill.skillTraits[last] then
				ty = ty + 4
				local tw,th = gui:drawTextParagraph("*" .. skill.skillTraits[last], tx, ty, paragraphWidth + 40, FontType.ScrollScaled, {162,183,206,255})
				-- actualWidth = math.max(actualWidth, tw / gui.guiScale)
				ty = ty + th / gui.guiScale
			end
		end
		tx = tx + 88
	end

	-- levels
	if skill.levels then
		for i=1,#skill.levels do
			local color = iff(champion:getSkillLevel(skill.name) >= i, Color.White, {110,110,110,255})
			local tw,th = gui:drawTextParagraph(skill.levels[i], tx, ty, paragraphWidth, font, color)
			actualWidth = math.max(actualWidth, tw / gui.guiScale)
			ty = ty + th / gui.guiScale
		end
	end

	-- requirements
	-- if skill.requirements then
	-- 	local champion = charSheet:getActiveChampion()
	-- 	local color
	-- 	if champion and not skill:checkRequirements(champion) then color = Color.Red end
		
	-- 	local text = skill:getRequirementsText(champion)
	-- 	if text then
	-- 		local tw,th = gui:drawTextParagraph(text, tx, ty, 400, font, color)
	-- 		actualWidth = math.max(actualWidth, tw / gui.guiScale)
	-- 		ty = ty + th / gui.guiScale
	-- 	end
	-- end

	-- draw spell gesture
	local spell = Spell.getSpell(skill.name)
	if spell then
		local width = actualWidth+90
		local w = 48
		local h = 40
		do
			local tx = tx + (width - 3*w)/2 - 90
			local ty = ty - 25
			
			gui:drawGuiItem(GuiItem.SpellPanelNoButtons, tx+10, ty+20)
			
			local maxLen = math.min(math.floor(ToolTip.time*5), ToolTip.runePanel:getGestureLength(spell.gesture))
			ToolTip.runePanel:drawGesture(spell.gesture, tx + w/2, ty + h/2, w, h, maxLen)
		end
		
		ty = ty + 3 * h + 10
	end

	ty = ty + 4

	actualWidth = actualWidth + 32 + 70 + 20
	actualHeight = math.max(ty - y + 2, 105)
	
	return actualWidth, actualHeight
end

function Skill.formatRequirements(requirements, subLevel)
	local text = "Requires "
	local reqCount = 0

	if type(requirements) == "text" then
		text = text..requirements
		reqCount = reqCount + 1
	else
		for i=1,#requirements,2 do
			local requirement = requirements[i]
			local level = requirements[i+1]
			reqCount = reqCount + 1

			if requirement == "char_level" then
				text = text.."Character Level "..level
			else
				local skill = Skill.getSkill(requirement)

				if i > 1 then text = text..", " end

				if skill then
					text = text..skill.uiName.." "..level
					if subLevel then
						text = text .. " (-" .. subLevel .. ")"
					end
				else
					text = text.."???"
				end
			end
		end
	end
	if reqCount == 0 then return nil end
	return text
end

-------------------------------------------------------------------------------------------------------
-- AttackPanel Functions                                                                             --
-------------------------------------------------------------------------------------------------------

function AttackFrame:drawItemSlot(x, y, width, height, slot)
	local champion = party.champions[self.championIndex]
	
	-- get power attack of item
	local item = champion:getItem(slot)
	if champion:hasCondition("bear_form") then item = nil end
	local powerAttack
	if item then 
		powerAttack = champion:getSecondaryAction(slot) 
		if powerAttack and not powerAttack.enabled then
			powerAttack = nil -- cannot use disabled power attacks
		end
	end

	-- cancel power attack if weapon changed
	if (self.powerAttackState == "charging" or self.powerAttackState == "ready") and not champion.chargingPowerAttack then
		if self.spentEnergy then champion:modifyBaseStat("energy", self.spentEnergy) end
		self:resetPowerAttack(champion)
	end

	--gui:fillRect(x, y, 75, 75, {30,30,30,200})
	--gui:drawRect(x, y, width, height, Color.Green)

	if not party:isResting() then
		local hot = gui:mouseRect(x, y, width, height)
		local but = iff(config.tabletMode, 0, 2)

		if hot and sys.mousePressed(0) and (not config.tabletMode or gui:getMouseItem() or sys.keyDown("shift")) then
			self:select(0, slot)
		elseif hot and sys.mousePressed(but) and champion:isReadyToAttack(slot) then
			-- mouse was pressed on attack icon
			-- start timer
			self.attackTimer = -0.5
			self.attackingWithSlot = slot
		elseif sys.mouseReleased(but) and self.attackingWithSlot == slot then
			-- mouse was released on attack icon
			if hot then
				if self.powerAttackState == "ready" then
					-- power attack
					self:select(2, slot, true)
					self.spentEnergy = nil
				elseif self.powerAttackState == nil then
					-- normal attack
					self:select(2, slot)
				end
			end

			-- power attack cancelled?
			if self.powerAttackState then
				-- restore energy for cancelled power attack
				if self.spentEnergy then champion:modifyBaseStat("energy", self.spentEnergy) end
				if self.powerAttackState ~= "ready" and self.powerAttackState ~= "out_of_energy" then
					soundSystem:playSound2D("power_attack_fail")
				end
			end

			-- stop timer
			self.attackTimer = nil
			self.attackingWithSlot = nil
			self.powerAttackState = nil
			champion.chargingPowerAttack = false	-- enables regeneration of energy
		end
	end

	-- update attack timer
	if self.attackingWithSlot == slot and self.attackTimer then
		local dt = Time.deltaTime
		self.attackTimer = self.attackTimer + dt
	end

	-- item in slot may have changed if slot was clicked
	item = champion:getItem(slot)
	if champion:hasCondition("bear_form") then item = nil end
	if item then 
		powerAttack = champion:getSecondaryAction(slot) 
		if powerAttack and not powerAttack.enabled then
			powerAttack = nil -- cannot use disabled power attacks
		end
	end

	local buildupTime = 1
	if powerAttack then
		buildupTime =  champion:getPowerAttackBuildup(powerAttack)
		-- console:print(buildupTime)
	end

	-- draw icon
	do
		local y = y + math.floor((height - 75)/2)
		if item then
			gui:drawItemIconInHand(item, x, y)

			-- draw clip size
			local firearmAttack = item.go.firearmattack
			if firearmAttack and firearmAttack.clipSize then
				gui:drawText(tostring(firearmAttack.loadedCount), x + 16, y + 18, FontType.PalatinoTiny)
			end

			if self.attackingWithSlot == slot and powerAttack then
				-- power attack ready indicator
				if self.powerAttackState == "ready" then
					-- flash icon bright when power attack is loaded
					local flash = math.sqr(math.max(1 - math.max(self.attackTimer - buildupTime, 0), 0))

					ImmediateMode.setBlendMode("Additive")
					local oldGfxIndex = item.gfxIndex
					item.gfxIndex = item.gfxIndexPowerAttack or item.gfxIndex
					local k = math.sin(Time.currentTime * 2) * 0.2 + 0.45 + flash * 0.5
					gui:drawItemIconInHand(item, x, y, nil, nil, { 80*k, 150*k, 190*k, 255 } )
					item.gfxIndex = oldGfxIndex

					-- glow
					local a = math.sin(Time.currentTime*4) * 0.25 + 1 + flash
					local color = vec(40 * a, 64 * a, 100 * a, 255)
					gui:drawGuiItem(GuiItem.SpellRuneGlow, x - 10, y - 40, color)

					-- glow2
					local a = math.sin(Time.currentTime*3 + 123) * 0.25 + 0.8 + flash
					local color = vec(40 * a, 64 * a, 100 * a, 255)
					gui:drawGuiItem(GuiItem.SpellRuneGlow, x - 40, y - 10, color)

					ImmediateMode.setBlendMode("Translucent")
				elseif self.powerAttackState == "charging" then
					-- charging
					local t = (self.attackTimer / buildupTime) * 0.5

					ImmediateMode.setBlendMode("Additive")
					local oldGfxIndex = item.gfxIndex
					item.gfxIndex = item.gfxIndexPowerAttack or item.gfxIndex
					gui:drawItemIconInHand(item, x, y, nil, nil, { 80*t, 150*t, 190*t, 255 } )
					item.gfxIndex = oldGfxIndex
					ImmediateMode.setBlendMode("Translucent")
				end
			end
		else
			-- draw shaded version of two handed item?
			local otherItem = champion:getOtherHandItem(slot)
			local leftHand, rightHand = GuiItem.UnarmedAttackLeft, GuiItem.UnarmedAttackRight
			local noAttackPanelIcon

			if champion:getUnarmedAttack() == champion.runePanel then
				-- glowing hands
				leftHand = GuiItem.UnarmedAttackMageLeft
				rightHand = GuiItem.UnarmedAttackMageRight
			end

			for name,cond in pairs(champion.conditions) do
				if cond then
					if cond.leftHandTexture then
						leftHand = cond.leftHandTexture
					end
					if cond.rightHandTexture then
						rightHand = cond.rightHandTexture
					end
				end

				if cond.noAttackPanelIcon then
					noAttackPanelIcon = cond.noAttackPanelIcon
				end
			end

			if otherItem and otherItem:hasTrait("two_handed") and not champion:hasTrait("two_handed_mastery") then
				gui:drawItemIcon(otherItem, x, y, 1, nil, {255,255,255,128})
			elseif (leftHand or rightHand) or noAttackPanelIcon then
				gui:drawGuiItem(iff(slot == ItemSlot.Weapon, leftHand, rightHand), x, y)
			end	
		end
	end

	-- draw charges
	if item and item.charges then
		gui:fillRect(x + 8, y + 70, 60, 7, Color.Black)
		gui:fillRect(x + 10, y + 71, 56 * item.charges / item.maxCharges, 5, {200, 50, 20, 255})
	end
	
	-- update power attack
	if self.attackTimer and powerAttack and self.attackingWithSlot == slot then
		local energyCost = powerAttack.energyCost or 0
		energyCost = champion:checkPowerAttackCost(powerAttack, energyCost)
		if self.powerAttackState == nil then
			if self.attackTimer >= 0 then
				if powerAttack:checkRequirements(champion) then
					if champion:getEnergy() >= energyCost then
						self.powerAttackState = "charging"
						self.spentEnergy = 0
						champion.chargingPowerAttack = true	-- disables regeneration of energy
						soundSystem:playSound2D("power_attack_charging")
					else
						-- out of energy
						champion:showAttackResult("Out of energy", GuiItem.SpellNoEnergy)
						soundSystem:playSound2D("power_attack_fail")
						self.powerAttackState = "out_of_energy"
					end
				else
					self.powerAttackState = "out_of_energy"
					champion:showAttackResult("Can't use")
					soundSystem:playSound2D("power_attack_fail")
				end
			end
		elseif self.powerAttackState == "charging" then
			-- charging
	
			local displayCost
			if buildupTime == math.huge then
				-- infinite buildup time, energy cost is interpreted as energy/second
				displayCost = (energyCost or 0) * Time.deltaTime
			else
				displayCost = (energyCost or 0) * Time.deltaTime / buildupTime
			end

			-- energyCost = champion:checkPowerAttackCost(powerAttack, energyCost)

			if champion:spendEnergy(displayCost) then
				-- store spent energy unless infinite build up time
				if buildupTime ~= math.huge then
					self.spentEnergy = self.spentEnergy + displayCost
				end

				if self.powerAttackState and self.attackTimer >= buildupTime then
					--print("power attack state: charging -> ready")
					if powerAttack:checkRequirements(champion) then
						self.powerAttackState = "ready"
						soundSystem:playSound2D("power_attack_ready")
					else
						self.powerAttackState = "out_of_energy"
						champion:showAttackResult("Can't use")
					end
				end
			else
				-- out of energy
				champion:showAttackResult("Out of energy", GuiItem.SpellNoEnergy)

				soundSystem:playSound2D("power_attack_fail")
				self.powerAttackState = "out_of_energy"

			end
		elseif self.powerAttackState == "ready" then
			-- ready
		end
	end
end

function AttackFrame:update()
	self:updateAnimation()	

	local champion = party.champions[self.championIndex]	

	local x,y = self.panelX,self.panelY

	if not champion.enabled then
		gui:drawGuiItem(GuiItem.AttackFrameDisabled, x, y, {5,5,5,100})
		self.healingIndicator.enabled = false
		return
	end
	
	gui:drawGuiItem(GuiItem.AttackFrame, x, y)

	-- quick-swap hand items
	for i=0,1 do
		local x = x - 6
		local y = y + 75 + i * 55 - 4
		local sel = champion.weaponSet == i

		if i == 0 then
			gui:drawGuiItem(iff(sel, GuiItem.QuickSwapButtonDown1, GuiItem.QuickSwapButtonUp1), x, y)
		else
			gui:drawGuiItem(iff(sel, GuiItem.QuickSwapButtonDown2, GuiItem.QuickSwapButtonUp2), x, y)
		end

		if gui:buttonLogic("quickswap"..i, x, y, 22, 57) and not sel then
			champion:swapWeaponSets()
		end
	end

	if party.swapWeaponsKeyPressed and gui:mouseRect(x, y, GuiItem.AttackFrame.width, GuiItem.AttackFrame.height) then
		champion:swapWeaponSets()
		party.swapWeaponsKeyPressed = nil
	end

	local condition = champion.currentCondition
	if not champion:isAlive() then 	
		-- show burdened or overloaded status even when champion is dead 
		if condition ~= "burdened" and condition ~= "overloaded" then
			-- these must be set explicitly to avoid condition icon rotation
			if champion:hasCondition("burdened") then condition = "burdened" 
			elseif champion:hasCondition("overloaded") then condition = "overloaded"
			else condition = nil end
		end
	end

	-- draw portrait
	local portraitRect = GuiItem.AttackFramePortraitRect
	local tex = champion:getPortraitTexture()
	if not champion:isAlive() and not champion:hasCondition("petrified") then tex = gui.deadTex end
	local color = Color.White	
	if condition and champion.conditions[condition] and champion.conditions[condition].portraitColor then
		color = champion.conditions[condition].portraitColor
	end
	gui:drawImage2(tex, x + portraitRect.x, y + portraitRect.y, 0, 0, 128, 128, portraitRect.width, portraitRect.height, color)

	-- gray out portrait is champion is petrified
	if champion:hasCondition("petrified") then
		local x,y = x + portraitRect.x, y + portraitRect.y
		local w,h = portraitRect.width, portraitRect.height
		gui:fillRect(x, y, w, h, {37,37,37,180})
	else
		-- draw red rectangle around portrait if champion has harmful conditions
		if champion:hasHarmfulConditions() then
			gui:drawGuiItem(GuiItem.AttackFrameConditionRect, x - 7, y - 7, Color.Red)
		end
	end
	
	-- health bar
	do
		local x = x + 74
		local y = y + 29
		gui:drawGuiItem(GuiItem.AttackFrameBarBackground, x-2, y-2)
		local item = GuiItem.AttackFrameHealthRed
		if champion:isAlive() then
			if champion:hasCondition("poison") then
				item = GuiItem.AttackFrameHealthGreen
			elseif champion:hasCondition("diseased") then
				item = GuiItem.AttackFrameHealthYellow
			end
		end

		local value = champion:getHealth() / champion:getMaxHealth()
		champion.healthBar = champion.healthBar or value
		if value < champion.healthBar then
			champion.healthBar = value
		else
			champion.healthBar = math.min(champion.healthBar + Time.deltaTime * 0.4, value)
		end
		local color
		if condition and champion.conditions[condition] and champion.conditions[condition].healthBarColor then
			color = champion.conditions[condition].healthBarColor
		end
		gui:drawMeter(item, x, y, champion.healthBar, value, color)
	end
		
	-- energy bar
	do
		local x = x + 74
		local y = y + 46
		local item = GuiItem.AttackFrameEnergy
		gui:drawGuiItem(GuiItem.AttackFrameBarBackground, x-2, y-2)

		local value = champion:getEnergy() / champion:getMaxEnergy()
		champion.energyBar = champion.energyBar or value
		if value < champion.energyBar then
			champion.energyBar = value
		else
			champion.energyBar = math.min(champion.energyBar + Time.deltaTime * 0.4, value)
		end
		local color
		if condition and champion.conditions[condition] and champion.conditions[condition].healthBarColor then
			color = champion.conditions[condition].healthBarColor
		end
		gui:drawMeter(item, x, y, champion.energyBar, value, color)
	end
		
	self:updateHealingIndicator(x, y)
	self:updateDamageIndicator(champion, x, y)
	
	-- shield
	do
		local x = x - 14
		local y = y - 14
		local color
		local defaultColors = { ["fire_shield"] = {255,100,20,255}, ["poison_shield"] = {20,120,20,255}, ["shock_shield"] = {0,200,250,255}, ["frost_shield"] = {100,250,250,255}, ["protective_shield"] = {20,100,255,255} }
		for name, defaultColor in pairs(defaultColors) do
			if champion:hasCondition(name) then
				color = defaultColor
			end
		end
		if condition and champion.conditions[condition] and champion.conditions[condition].frameColor then
			color = champion.conditions[condition].frameColor
		end
		if color then
			gui:drawGuiItem(GuiItem.AttackFrameShield, x, y, color)
		end
	end
	
	-- level up
	if champion:hasCondition("level_up") then
		gui:drawTextCentered("Level up!", x+134, y+15, FontType.PalatinoSmallScaled)
	end

	-- draw selection rectangle
	local selected = charSheet:isVisible() and charSheet.champion == champion
	if selected then
		gui:drawGuiItem(iff(champion.weaponSet == 0, GuiItem.AttackFrameSelected1, GuiItem.AttackFrameSelected2), x - 3, y - 3)
	end

	if condition then
		local c = champion.conditions[condition]
		if not c.noAttackPanelIcon then
			c:drawIcon(x, y+2, 255)
		end
	end

	-- head/chest/leg/feet wound
	local wound = champion:hasCondition("head_wound") or champion:hasCondition("chest_wound") or champion:hasCondition("leg_wound") or champion:hasCondition("feet_wound")
	if wound then
		gui:drawGuiItem(GuiItem.InjurySmall, x, y, Color.RedFlashing)
	end

	-- portrait clicked?
	if not party:isResting() and party.controlsEnabled then
		local width = GuiItem.AttackFrame.width - 14	-- minus shadow
		local height = GuiItem.AttackFramePortraitRect.height
		local leftClick = gui:buttonLogic("portrait"..champion.championIndex, x, y, width, height, 0)
		local rightClick = gui:buttonLogic("portrait"..champion.championIndex, x, y, width, height, 2)
		
		if leftClick and gui:getMouseItem() then
			-- put item into champion's inventory
			if champion:addToBackpack(gui:getMouseItem(), false) then
				soundSystem:playSound2D("item_drop")
				gui:setMouseItem(nil)
			end
		elseif leftClick then
			if sys.platform() == "ios" then
				charSheet:toggle(champion)
			else
				gui.attackPanel:startDragging(self.championIndex)
			end
		elseif rightClick then
			charSheet:toggle(champion)
		end
	end

	-- show custom attack panel
	if party:isHookRegistered("onDrawAttackPanel") then
		local ctx = gui:createCustomGuiContext(gui.guiScale, gui.guiScale, gui.guiBiasX, gui.guiBiasY)
		if party:callHook("onDrawAttackPanel", objectToProxy(champion), ctx, x + 21, y + 68) == false then return end
	end

	if champion.attackPanel then
		champion.attackPanel:updatePanel(champion, x + 21, y + 68)
		if champion.attackResult.enabled then
			gui:fillRect(x + 20, y + 67, 174, 119, {23,23,23,180})
			self:updateAttackResult(champion, x + GuiItem.AttackFrameItemSlot.x, y + GuiItem.AttackFrameItemSlot.y)
		end
	else
		self:updateAttackButtons(champion, x, y)
		self:updateAttackResult(champion, x + GuiItem.AttackFrameItemSlot.x, y + GuiItem.AttackFrameItemSlot.y)

		local w = GuiItem.AttackFrame.width
		local h = GuiItem.AttackFrame.height
		if champion:hasCondition("petrified") then
			gui:drawTextCentered("Petrified", x + w/2, y + h/2 + 27, FontType.PalatinoSmallScaled)
		elseif champion:hasCondition("paralyzed") then
			gui:drawTextCentered("Paralyzed", x + w/2, y + h/2 + 27, FontType.PalatinoSmallScaled)
		end
	end

	-- add-ons
	-- do
	-- 	local x,y = x,y + 70
	-- 	local w,h = 16,30
	-- 	local spacing = 2
		
	-- 	for i=0,3 do
	-- 		local it = champion:getItem(ItemSlot.FirstAccessory + i)
	-- 		if it then
	-- 			for i=1,it.go.components.length do
	-- 				local comp = it.go.components[i]
	-- 				if comp and comp.enabled and comp.onDrawAttackPanelAddOn then
	-- 					comp:onDrawAttackPanelAddOn(champion, x, y, w, h)
	-- 					y = y + h + spacing
	-- 				end
	-- 			end
	-- 		end
	-- 	end
	-- end
end

-- Adds a color parameter
function Gui:drawMeter(item, x, y, value, targetValue, color)
	if item.offsetX then x = x + item.offsetX end
	if item.offsetY then y = y + item.offsetY end
	if not color then color = Color.White end

	x = x * self.guiScale + self.guiBiasX
	y = y * self.guiScale + self.guiBiasY
	
	local width = item.width * self.guiScale
	local height = item.height * self.guiScale

	if not item.texture then item.texture = RenderableTexture.load(item.image) end

	-- for regeneration
	if targetValue then
		local destWidth = width * targetValue
		if targetValue > 0 then destWidth = math.max(destWidth, 1) end
		ImmediateMode.drawImage(item.texture, x, y, item.x, item.y, item.width * value, item.height, destWidth, height, "606060FF")
	end

	local destWidth = width * value
	if value > 0 then destWidth = math.max(destWidth, 1) end
	ImmediateMode.drawImage(item.texture, x, y, item.x, item.y, item.width * value, item.height, destWidth, height, color)
end

-- This fixes potions not being able to have a custom gfxAtlas
function Gui:drawItemIcon(item, x, y, scale, drawCount, color, inHand, armorSet, container)
	scale = scale or 1
	if drawCount == nil then drawCount = true end
	color = color or Color.White
	
	local gfxIndex = item.gfxIndex
	if inHand and item.gfxIndexInHand then gfxIndex = item.gfxIndexInHand end
	if armorSet and item.gfxIndexArmorSet then gfxIndex = item.gfxIndexArmorSet end
	if container and item.gfxIndexContainer then gfxIndex = item.gfxIndexContainer end
	
	local tex = item.gfxAtlas or self.itemsTex
	if item.go or not item.gfxAtlas then
		tex = item.gfxAtlas or self.itemsTex
		-- console:print("item.go", item.uiName, item.gfxAtlas or self.itemsTex)
	elseif item.gfxAtlas then
		tex = RenderableTexture.load(item.gfxAtlas)
		-- console:print("item.gfxAtlas", item.uiName, item.gfxAtlas)
	end

	-- assert(type(tex) == "string", "Gui:drawItemIcon(): RenderableTexture expected, got string")

	if gfxIndex >= 400 then
		tex = self.itemsTex3
		gfxIndex = gfxIndex - 400
	elseif gfxIndex >= 200 then
		tex = self.itemsTex2
		gfxIndex = gfxIndex - 200
	end
		
	local srcW = 75
	local srcH = 75
	local destW = srcW * scale
	local destH = srcH * scale
	local sx = (gfxIndex % 13) * srcW
	local sy = math.floor(gfxIndex / 13) * srcH
	
	x = x * self.guiScale + self.guiBiasX
	y = y * self.guiScale + self.guiBiasY
	destW = destW * self.guiScale
	destH = destH * self.guiScale

	ImmediateMode.drawImage(tex, x, y, sx, sy, srcW, srcH, destW, destH, color)
	
	if item.stackable and drawCount and item.count then
		local font = FontType.PalatinoSmallScaled
		local text = tostring(item.count)
		local w = font:getTextWidth(text) * self.guiScale
		local x = x + 63 * scale * self.guiScale - w
		local y = y + 5 * self.guiScale + font:getMaxBearingY()
		ImmediateMode.drawText(text, x, y, font, Color.White)
	end
end

function CharSheet:updateContainer(container, x, y)
	local champion = self.champion
	local slots = container:getCapacity()
	local size = 55
	local resize = 75
	local gfxBg = container:getGfx()

	if gfxBg then
		local img = RenderableTexture.load(ExtendedHooks.gfxFolder .. gfxBg)
		gui:drawImage(img, x-3, y-4)
	else
		if container.containerType == "chest" then
			gui:drawGuiItem(GuiItem.ContainerChest, x, y) 
		elseif container.containerType == "sack" then
			gui:drawGuiItem(GuiItem.ContainerSack, x, y)
		end
	end

	gui:drawItemIcon(container.go.item, x + 26, y + 20, 50/75, nil, nil, false, false, true)
	if container.uiName then
		gui:drawTextAligned(container.uiName, x + 276/2, y + 44, "center", FontType.PalatinoSmallScaled)
	end

	-- close by right-clicking on top bar
	if gui:buttonLogic("container_panel", x, y, GuiItem.ContainerChest.width, 80, 2) then
		soundSystem:playSound2D(container.closeSound or "item_pick_up")
		champion.openContainer = nil
	end
	
	local area = math.ceil(math.sqrt(slots))
	local marginX, marginY = 25 + ((4-area) * 27), 80 + ((4-area) * 23)
	local customSlots = container:getCustomSlots()
	if customSlots then
		for i=1,#customSlots do
			local x = x + customSlots[i][1] * size + marginX
			local y = y + customSlots[i][2] * size + marginY
			-- gui:drawRect(x, y, size, size)
			local customSlot = container.customSlotGfx
			if customSlot then
				if type(customSlot) == "string" then
					gui:drawImage(RenderableTexture.load(customSlot), x, y)
				else
					gui:drawImage(RenderableTexture.load(ExtendedHooks.gfxFolder .. "slot.tga"), x, y)
				end
			end
			self:containerSlot(container, i, x, y, size, size, size/resize)
		end
	else
		for i=1,slots do
			local x = x + ((i-1) % area) * size + marginX
			local y = y + math.floor((i-1) / area) * size + marginY
			-- gui:drawRect(x, y, size, size)
			local customSlot = container.customSlotGfx
			if customSlot then
				if type(customSlot) == "string" then
					gui:drawImage(RenderableTexture.load(customSlot), x, y)
				else
					gui:drawImage(RenderableTexture.load(ExtendedHooks.gfxFolder .. "slot.tga"), x, y)
				end
			end
			self:containerSlot(container, i, x, y, size, size, size/resize)
		end
	end

	do
		if container.closeButton then
			-- custom close button
			x,y,width,height = x + container.closeButton.x, y + container.closeButton.y, container.closeButton.width, container.closeButton.height
		else
			-- default close button
			x,y,width,height = x + 207, y + 15, 40, 40
		end
		-- gui:drawRect(x, y, width, height)
		if gui:buttonLogic("container_close", x, y, width, height, "any") then
			soundSystem:playSound2D(container.closeSound or "item_pick_up")
			champion.openContainer = nil
		end
	end
end

-- -- Equipment tab

-- function CharSheet:equipmentTab(x, y)
-- 	local champion = self.champion
	
-- 	gui:drawGuiItem(GuiItem.InventoryTab, x, y)

-- 	-- backpack slots
-- 	for i=0,19 do
-- 		local x = x + 1 + (i % 4) * 63 + 48
-- 		local y = y + math.floor(i / 4) * 63 + 66
-- 		local width = 63
-- 		local height = 63
-- 		local scale = 63/75
-- 		--gui:drawRect(x, y, width, height)
-- 		self:updateEquipmentSlot(ItemSlot.BackpackFirst + i, x, y, width, height, scale, 0)
-- 	end

-- 	if champion.openContainer then
-- 		self:updateContainer(champion.openContainer, x + 305, y + 65)
-- 	else
-- 		-- draw race specific background
-- 		do
-- 			local x = x + 304
-- 			local y = y + 52
-- 			ImmediateMode.setBlendMode("Modulative")
-- 			gui:drawImage(champion:getInventoryBackgroundTex(), x, y)
-- 			ImmediateMode.setBlendMode("Translucent")
-- 			gui:drawGuiItem(GuiItem.EquipmentSlots, x, y)
-- 		end

-- 		self:updateEquipment(x, y)
-- 	end

-- 	-- load
-- 	do
-- 		local x = x + 304
-- 		local y = y + 59
-- 		local font = FontType.PalatinoTinyScaled
-- 		local load = champion:getLoad()
-- 		local maxLoad = champion:getMaxLoad()
-- 		local loadColor
-- 		if self.champion:hasCondition("overloaded") then
-- 			loadColor = Color.Red
-- 		elseif self.champion:hasCondition("burdened") then
-- 			loadColor = Color.Yellow
-- 		else
-- 			loadColor = "EBF0D5" --{235, 240, 213, 255}
-- 		end
-- 		local x = x + 260
-- 		local y = y + 343
-- 		local text = string.format("Load:  %.1f/%.0f kg", load, maxLoad)
-- 		local w = font:getTextWidth(text)
-- 		gui:drawTextAligned(text, x, y, "right", font, loadColor)
-- 		ToolTip.tooltipTextLine("Load", x - w, y, w, 15)
-- 	end
		
-- 	if party:isHookRegistered("onDrawInventory") then
-- 		party:callHook("onDrawInventory", gui:createCustomGuiContext(), objectToProxy(champion))
-- 	end
-- end

-- Skills tab

function CharSheet:skillsTab(x, y)
	local champion = self.champion
	
	gui:drawGuiItem(GuiItem.SkillsTab, x, y)
		
	local x = x + 52
	local y = y + 60
	local width = 520 - 10
	local height = 340
	--gui:drawRect(x, y, width, height)

	local classSkills = {}
	local skills = {}
	if champion.class.availableSkills and #champion.class.availableSkills ~= 0 then
		for _,name in pairs(champion.class.availableSkills) do
			classSkills[name] = dungeon.skills[name]
		end
		table.sort(classSkills, function(a, b) return dungeon.skills[a].priority < dungeon.skills[b].priority end)
		assert(classSkills ~= {}, "empty skills")
		skills = table.keys(classSkills)
	else
		skills = Skill.getSkills()
	end

	-- layout skills
	local pages = 0
	local numRows = 0
	local cur = 1
	while true do
		local skillsLeft = #skills - cur + 1
		if skillsLeft < 1 then break end

		local rows = math.min(math.ceil(skillsLeft / 2), 8)
		if #skills <= 8 then rows = 8 end
		
		for j=0,skillsLeft-1 do
			local skill = Skill.getSkill(skills[cur+j])
			local col = math.floor(j / rows)
			if #skills <= 8 then col = 0 end
			local row = j % rows
			skill._x = col * 252
			skill._y = row * 31
		end

		cur = cur + 16
		numRows = numRows + rows
	end

	local x = x + 0
	local y = y + 14
	if #skills <= 8 then x = x + 125 end

	do
		local height = 268
		local mouseInside = gui:mouseRect(0, y, config.width, height)
		local y = y

		if #skills > 16 then
			self.skillScroll = gui:beginScrollArea("skills_scroll_area", x, y + 8, width, height - 12, self.skillScroll or 0, numRows * 31 + 10, 31*4, nil, -8)
			self.skillScroll,self.skillScrollSmoothed = gui:smoothScroll(self.skillScroll, self.skillScrollSmoothed)
			y = y - self.skillScrollSmoothed
		end

		for i=1,#skills do
			local skill = Skill.getSkill(skills[i])

			local x = x + skill._x --col * 252
			local y = y + skill._y --row * 31

			skill._x = nil
			skill._y = nil

			gui:drawText(skill.uiName, x + 20, y + 32, FontType.PalatinoSmallScaled)

			local pressed,hover = gui:buttonLogic(skill.name, x, y + 10, 240, 28, "any", iff(mouseInside, skill, nil))
			if not mouseInside then pressed = nil; hover = nil end

			local preview = champion.skillPreview[skill.name] or 0
			local maxLevel = skill.maxLevel or 5

			-- draw ticks
			do
				local x = x + 185
				local y = y + 16
				local width = 60
				local height = 20
				local m = 2

				if maxLevel <= 5 then
					gui:drawGuiItem(iff(hover, GuiItem.SkillSlotsHighlight, GuiItem.SkillSlots), x - 1, y)

					x = x + 2
					y = y + 3
					for i=1,5 do
						if champion:getSkillLevel(skill.name) + preview >= i then
							local color
							if champion:getSkillLevel(skill.name) < i then
								color = {250,120,100,250}
							end

							if skill.traits and skill.traits[i] then
								gui:drawGuiItem(GuiItem.SkillTickUpgradeSelected, x, y, color)
							else
								gui:drawGuiItem(GuiItem.SkillTick, x, y, color)
							end
						elseif skill.traits and skill.traits[i] then
							gui:drawGuiItem(GuiItem.SkillTickUpgrade, x, y)
						end
						x = x + 11
					end
				else
					gui:drawTextAligned(champion:getSkillLevel(skill.name) + preview, x + 54, y + 16, "right", FontType.PalatinoSmallScaled, color)
				end
			end

			if pressed then
				if sys.mousePressed(2) then
					-- remove points
					if champion.skillPreview[skill.name] then
						local cost = self:nextSkillCost(champion, skill, 0)
						champion.skillPreview[skill.name] = champion.skillPreview[skill.name] - 1
						if champion.skillPreview[skill.name] < 1 then
							champion.skillPreview[skill.name] = nil
						end
						champion:addSkillPoints(cost)
						soundSystem:playSound2D("click_down")
					end
				elseif  champion:getSkillLevel(skill.name) + preview < maxLevel then
					local cost = self:nextSkillCost(champion, skill, 1)

					local requirements = true
					if skill.onCheckRestrictions then
						local rval = skill.onCheckRestrictions(objectToProxy(champion), skill, champion:getSkillLevel(skill.name) + (champion.skillPreview[skill.name] or 0) + 1)
						requirements = rval
						if rval == nil then requirements = true end
					end

					if champion:getSkillPoints() >= cost and requirements then
						-- spend points
						champion.skillPreview[skill.name] = (champion.skillPreview[skill.name] or 0) + 1
						champion:addSkillPoints(-cost)
						soundSystem:playSound2D("click_down")
					end
				end
			end
		end

		if #skills > 16 then
			gui:endScrollArea()
		end
	end

	gui:drawText("Unused skill points: "..champion:getSkillPoints(), x + 20, y + 305, FontType.PalatinoSmallScaled)

	local cnt = 0
	for _,amount in pairs(champion.skillPreview) do
		cnt = cnt + amount
	end

	local enabled = cnt > 0

	-- accept
	local image = iff(enabled, GuiItem.ButtonAccept, GuiItem.ButtonAcceptDisabled)
	local hover = iff(enabled, GuiItem.ButtonAcceptHover, nil)
	if gui:button("skill_accept", image, x + 280, y + 283, hover) and enabled then
		for skill,amount in pairs(champion.skillPreview) do
			champion:trainSkill(skill, amount, false)
			champion:addData("skillsLearned", amount)
		end
		champion.skillPreview = {}
		soundSystem:playSound2D("click_down")
	end

	-- clear
	local image = iff(enabled, GuiItem.ButtonClear, GuiItem.ButtonClearDisabled)
	local hover = iff(enabled, GuiItem.ButtonClearHover, nil)
	if gui:button("skill_clear", image, x + 405, y + 283, hover) and enabled then
		for _,amount in pairs(champion.skillPreview) do
			champion:addSkillPoints(amount)
		end
		champion.skillPreview = {}
		soundSystem:playSound2D("click_down")
	end

	if party:isHookRegistered("onDrawSkills") then
		party:callHook("onDrawSkills", gui:createCustomGuiContext(), objectToProxy(self.champion))
	end
end

function CharSheet:nextSkillCost(champion, skill, offset)
	local pointsCost = 1
	local skillLevel = champion:getSkillLevel(skill.name) + ((champion.skillPreview and champion.skillPreview[skill.name]) or 0)
	skillLevel = skillLevel + offset
	if skill.pointsCost and type(skill.pointsCost) == "table" then
		pointsCost = skill.pointsCost[ math.min(skillLevel, #skill.pointsCost+1) ] or 1
	elseif type(skill.pointsCost) == "number" then
		pointsCost = skill.pointsCost
	end
	if pointsCost == 0 then
		assert(skill.pointsCost > 0, "skill cost can't be 0")
	end
	return pointsCost
end

-- Traits tab
-- All this is here for is to fix how small the hover area for traits is
function CharSheet:traitsTab(x, y)
	local champion = self.champion
	
	gui:drawGuiItem(GuiItem.TraitsTab, x, y)

	-- collect traits	
	local traits = {}
	traits[#traits+1] = champion.race.name
	traits[#traits+1] = champion.class.name
	-- systemLog:write(champion.race.name)
	-- systemLog:write(champion.class.name)
	for i=1,#champion.traits do
		local tr = Skill.getTrait(champion.traits[i])
		-- systemLog:write(champion.traits[i])
		if tr and not tr.hidden then
			traits[#traits+1] = champion.traits[i]
		end
	end

	local x = x + 58
	local y = y + 59
	local width = 520 - 32 + 4
	local height = 335
	local numRows = math.ceil(#traits/2)
	--gui:drawRect(x, y, width, height)

	local docHeight = numRows*60 + 20
	self.traitScroll = gui:beginScrollArea("charsheet_traits_area", x, y, width, height, self.traitScroll or 0, docHeight, 60*2, "vertical")

	-- smooth scroll
	local oldScroll = self.traitScrollSmoothed
	self.traitScroll,self.traitScrollSmoothed = gui:smoothScroll(self.traitScroll, self.traitScrollSmoothed)
	local scrolling = oldScroll ~= self.traitScrollSmoothed

	local x = x + 10
	local y = y + 10 - math.floor(self.traitScrollSmoothed)
	for i=1,#traits do
		local col = (i-1) % 2
		local row = math.floor((i-1) / 2)

		local x = x + col * 250
		local y = y + row * 60

		local skill = Skill.getTrait(traits[i])
		gui:drawSkillIcon(skill, x+2, y+2)

		local font = FontType.PalatinoSmallScaled
		gui:drawText(skill.uiName, x + 60, y + 32, font)

		if not scrolling then
			gui:buttonLogic(skill.name, x, y + 5, 228, 48, 0, skill) -- hover area made bigger
		end
	end

	gui:endScrollArea()

	if party:isHookRegistered("onDrawTraits") then
		party:callHook("onDrawTraits", gui:createCustomGuiContext(), objectToProxy(self.champion))
	end
end