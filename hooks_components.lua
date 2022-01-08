
CurrencyComponent = class(Component)
    .synthesizeProperty("doMerge")

CurrencyComponent.Currency = {
    { name = "cblooddrop_cap",	value = 1, conversion = 3 },
	{ name = "cetherweed",		value = 2, conversion = 5 },
	{ name = "ccrystal_flower",	value = 3, conversion = 10 },
}

function CurrencyComponent:init(go)
	self:super(go)
end

function CurrencyComponent:update()
	
end

-- Container
-- local oldUpdateInventory = ItemComponent.updateInventory
-- function ItemComponent:updateInventory()
--     oldUpdateInventory(self)
	
-- end

local oldChampionInsertItem = Champion.insertItem
function Champion:insertItem(slot, item)
    -- update currency
    if not item:hasTrait("currency") then return end
    local table = CurrencyComponent:getCurrencyByName(item)
    
    if not table then return end
    local value = table.value
    if item.count >= table.conversion then
        local newAmount = math.floor(item.count / table.conversion)
        local nextItem = CurrencyComponent:getCurrencyByValue(item, value + 1)
        if nextItem then
            item.count = item.count - (newAmount * table.conversion)
            local newItem = create(nextItem.name).item
            newItem.count = math.max(newAmount, 1)
            self:addToBackpack(newItem)
        end
    end
    if item.count <= 0 then
        return false
    end

    local container = item.go.inObject
    if container and container.containeritem then
        
    end

    return oldChampionInsertItem(self, slot, item)
end

function CurrencyComponent:convertCurrency(champion, slot)
    -- transform a monetary value into individual currency
end

function CurrencyComponent:getCurrencyByName(item)
    assert(item.__class == ItemComponent)
    assert(item:hasTrait("currency"))
    local table
    for _,t in ipairs(CurrencyComponent.Currency) do
        if t.name == item.go.arch.name then
            table = t
            break
        end
    end
    return table
end

function CurrencyComponent:getCurrencyByValue(item, value)
    assert(item.__class == ItemComponent)
    assert(item:hasTrait("currency"))
    local table
    for _,t in ipairs(CurrencyComponent.Currency) do
        if t.value == value then
            table = t
            break
        end
    end
    return table
end

-- Misc

-- local oldChampionAddToBackpack = Champion.addToBackpack
-- function Champion:addToBackpack(item, autoEquip)
-- 	assert(item.__class == ItemComponent)
--     if item then

--     end

-- 	return oldChampionAddToBackpack(self, item, autoEquip)
-- end