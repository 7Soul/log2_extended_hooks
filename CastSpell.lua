

function CastSpellComponent:start(champion, slot)
	local name = self.spell
	local item = champion:getItem(slot)
	if not name then console:warn("unknown wand spell"); return end
	
	-- find spell
	local spell = Spell.getSpell(name)
	if not spell then
		console:warn("Unknown spell: "..name)
		return
    end
    
    if self:checkCharges(champion) == false then return end

	-- use wand's power as spell skill
	--if not self.power then console:warn("wand power not set for "..weapon.go.arch.name) end
	local skill = (self.power or 0)
	local pos = party.go:getWorldPositionFast()
	local x,y = party.go.map:worldToMap(pos)	
	Spell.castSpell(spell, champion, x, y, party.go.facing, party.go.elevation, skill)

	local cooldown = (self.cooldown or 0) * champion:getCooldownWithAttack(item, nil, "spell")

	champion.cooldownTimer[1] = champion.cooldownTimer[1] + cooldown
	champion.cooldownTimer[2] = champion.cooldownTimer[2] + cooldown

	-- consume charges
    self:consumeCharges(champion)
	
	-- strenous activity consumes food
	champion:consumeFood(math.random(1,5))
end

-- Custom functions

function CastSpellComponent:checkCharges(champion)
    if self.charges == 0 then return false end
end

function CastSpellComponent:consumeCharges(champion)
    if self.charges then
        self.charges = self.charges - 1
        if self.charges < 1 then
            self:deplete()
        end
    end
end