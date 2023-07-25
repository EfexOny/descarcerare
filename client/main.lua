
descarcerare = 0
lasthp = 0
currenthp = nil
verif = false

-- TRE SA SCOT

RegisterCommand('car', function(source, args)
    local vehicleName = args[1]

    RequestModel(vehicleName)
    while not HasModelLoaded(vehicleName) do
        Citizen.Wait(0)
    end

    local playerPed = PlayerPedId()
    local vehicle = CreateVehicle(GetHashKey(vehicleName), GetEntityCoords(playerPed), GetEntityHeading(playerPed), true, false)

    SetPedIntoVehicle(playerPed, vehicle, -1)

    local forwardVector = GetEntityForwardVector(playerPed)
    ApplyForceToEntity(vehicle, 1, forwardVector.x * 10.0, forwardVector.y * 10.0, forwardVector.z * 10.0, 0.0, 0.0, 0.0, true, true, true, true, true, true)
end)

Citizen.CreateThread(function()
    local ped = PlayerPedId()

    while true do 
        Wait(1)

        -- verif daca esti in masina
        local wtf = GetVehiclePedIsIn(ped, false)
        if wtf == 0 then
            lasthp = 0
        end

        if lasthp == 0 then
            local vehicul = GetVehiclePedIsIn(ped, false)
            local hp = GetVehicleBodyHealth(vehicul)
            lasthp = hp
        end

        if not verif then
            currenthp = GetVehicleBodyHealth(GetVehiclePedIsIn(ped, false))
                if lasthp ~= currenthp and lasthp - currenthp >= Config.mindamage then
                    print("ai nev de descarcerarre")
                    lasthp = currenthp
                    verif = true
                    descarcerare = 1
                end
            end
            if descarcerare == 1 then
                local ped = GetPlayerPed(-1)
                local vehicle = GetVehiclePedIsUsing(ped)
                FreezeEntityPosition(vehicle, true) -- disable moving
                DisableControlAction(0,75,true) -- disable f 
                local coord = GetEntityCoords(ped)
        end
    end
end)
-- Citizen.CreateThread(function()
--     while true do 
--         Wait(0) 
--         if descarcerare == 1 then
--             local ped = GetPlayerPed(-1)
--             local vehicle = GetVehiclePedIsUsing(ped)
--             FreezeEntityPosition(vehicle, true) -- disable moving
--             DisableControlAction(0,75,true) -- disable f 
--             local coord = GetEntityCoords(ped)
--             -- TriggerEvent("Ef:3D",coord.x,coord.y,coord.z,1,"Descarcerare")
--         end
--     end
-- end)

RegisterNetEvent("Ef:3D",function(x, y, z, scl_factor, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov * scl_factor
    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end)




function closestveh(coords)

    local ped = PlayerPedId()
    local vehicles = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestVehicle = -1
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)

        if closestDistance == -1 or closestDistance > distance then
            closestVehicle = vehicles[i]
            closestDistance = distance
        end
    end
    return closestVehicle, closestDistance
end



function itemuse()
    descarcerare = 0 
    verif = false
    local ped = GetPlayerPed(-1)
    local vehicle = GetVehiclePedIsUsing(ped)
    FreezeEntityPosition(vehicle, false) -- disable moving
    DisableControlAction(0,75,false) -- disable f 
end

function load(kkt)
    while not HasModelLoaded(kkt) do
        RequestModel(kkt)
        Citizen.Wait(0)
    end
end

function startanim()
    local animDict = "anim@scripted@player@mission@tunf_train_ig1_container_p1@male@"
    local animName = "action"
    
    load(Config.items[1])
    load(Config.items[2])

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    local veh = closestveh(coords)
    cord = GetEntityCoords(veh)

    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(0)
    end

    chainsaw(chainsaw)

    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1,1, 0, false, false, false)

    DeleteEntity()
end

function bag()
    local playerPed = GetPlayerPed(-1)
    local bagModel = GetHashKey(Config.items[2])
    RequestModel(bagModel)
    while not HasModelLoaded(bagModel) do
    Citizen.Wait(0)
    end
    local bagEntity = CreateObject(bagModel, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(bagEntity, playerPed, GetPedBoneIndex(playerPed, 24818), 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(bagModel)
end

function chainsaw()
    local playerPed = GetPlayerPed(-1)
    local bagModel = GetHashKey(Config.items[1])
    RequestModel(bagModel)
    while not HasModelLoaded(bagModel) do
        Citizen.Wait(0)
    end
    local chainsaw = CreateObject(bagModel, 0.0, 0.0, 0.0, true, true, false)
    AttachEntityToEntity(chainsaw, playerPed, GetPedBoneIndex(playerPed, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(bagModel)
end

function stopanim()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
end

RegisterCommand("startanim",function()
    startanim()
end)


RegisterCommand("stopanim",function()
    stopanim()
end)

RegisterCommand("item",function()
    itemuse()
end)

RegisterCommand("debug",function()
    print("last " .. lasthp)
    print("curr " .. currenthp)
    print("descarcerare " .. descarcerare)
 end)

RegisterCommand("wtf",function()
    
    
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)

    local veh = closestveh(coords)

    print(veh)
end)

RegisterNetEvent("ef:status",function()
    if(descarcerare)
        return true
    else
        return false
end)

