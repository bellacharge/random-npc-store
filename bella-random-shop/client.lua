local spawnedNPC = nil
local shopCoords = nil
local shopStock = {}

RegisterNetEvent("shop:spawnNPC")
AddEventHandler("shop:spawnNPC", function(coords, stock, pedModel)
    if spawnedNPC then
        DeleteEntity(spawnedNPC)
    end

    shopCoords = coords
    shopStock = stock

    RequestModel(GetHashKey(pedModel))
    while not HasModelLoaded(GetHashKey(pedModel)) do
        Wait(10)
    end

    spawnedNPC = CreatePed(GetHashKey(pedModel), coords.x, coords.y, coords.z, 0.0, false, true)
    SetEntityAsMissionEntity(spawnedNPC, true, true)
    SetPedCanRagdoll(spawnedNPC, false)

    print("👤 Shop NPC spawned at:", coords.x, coords.y, coords.z)
end)

RegisterNetEvent("shop:updateStock")
AddEventHandler("shop:updateStock", function(stock)
    shopStock = stock
    print("📦 Shop stock updated:", stock)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if shopCoords then
            local playerCoords = GetEntityCoords(PlayerPedId())
            local dist = #(playerCoords - vector3(shopCoords.x, shopCoords.y, shopCoords.z))

            if dist < 3.0 then
                DrawTxt("Press [E] to buy items", 0.5, 0.9)

                if IsControlJustReleased(0, 0xCEFD9220) then -- E Key
                    OpenShopMenu()
                end
            end
        end
    end
end)

function OpenShopMenu()
    local menu = {}
    for item, amount in pairs(shopStock) do
        table.insert(menu, {label = item .. " x" .. amount, item = item, amount = 1})
    end

    if #menu > 0 then
        -- Show menu (VORP UI or Native UI)
        TriggerEvent("vorpinputs:show", "Buy Item", "Enter quantity", function(result)
            local selectedItem = menu[result.index].item
            local selectedAmount = tonumber(result.input)
            if selectedAmount then
                TriggerServerEvent("shop:buyItem", selectedItem, selectedAmount)
            end
        end, menu)
    else
        TriggerEvent("vorp:TipBottom", "The shop is empty!", 3000)
    end
end

function DrawTxt(text, x, y)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end
