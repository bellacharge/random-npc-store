local VorpCore = {}
local VorpInv = {}
local Config = require("config")

TriggerEvent("getCore", function(core)
    VorpCore = core
end)

VorpInv = exports.vorp_inventory:vorp_inventoryApi()

local currentShop = nil

-- Function to select random items and quantities
local function generateStock()
    local stock = {}
    for _, item in pairs(Config.ItemPool) do
        local amount = math.random(0, item.max) -- Random quantity (can be 0)
        if amount > 0 then
            stock[item.name] = amount
        end
    end
    return stock
end

-- Function to create a new shop at a random location
local function spawnShop()
    local randomLocation = Config.ShopLocations[math.random(#Config.ShopLocations)]
    local stock = generateStock()

    -- Ensure shop has at least one item
    while next(stock) == nil do
        stock = generateStock()
    end

    currentShop = {location = randomLocation, stock = stock}
    TriggerClientEvent("shop:spawnNPC", -1, randomLocation, stock, Config.ShopPedModel) -- Notify clients
    print("📌 New shop spawned at:", randomLocation.x, randomLocation.y, randomLocation.z)
end

-- Function to check if shop is empty
local function checkStock()
    for _, qty in pairs(currentShop.stock) do
        if qty > 0 then
            return false
        end
    end
    return true
end

-- Buy item function
RegisterServerEvent("shop:buyItem")
AddEventHandler("shop:buyItem", function(item, amount)
    local _source = source
    local User = VorpCore.getUser(_source)
    local Character = User.getUsedCharacter

    if currentShop and currentShop.stock[item] and currentShop.stock[item] >= amount then
        if VorpInv.canCarryItem(_source, item, amount) then
            VorpInv.addItem(_source, item, amount)
            currentShop.stock[item] = currentShop.stock[item] - amount
            TriggerClientEvent("shop:updateStock", -1, currentShop.stock)

            if checkStock() then
                print("🛑 Shop is out of stock, moving...")
                Citizen.Wait(5000) -- Wait before relocating
                spawnShop()
            end
        else
            TriggerClientEvent("vorp:TipRight", _source, "You can't carry that much!", 3000)
        end
    else
        TriggerClientEvent("vorp:TipRight", _source, "Item not available!", 3000)
    end
end)

-- Initialize first shop
Citizen.CreateThread(function()
    spawnShop()
end)
