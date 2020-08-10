ESX = nil
selling = false
aboutToSell = false
checking = false
scammed = false
sold = false
npcGone = false
Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)
Citizen.CreateThread(function()
    local coords = Config.sellLocations
    while true do
        Citizen.Wait(0)
        local playerped = GetPlayerPed(-1)
        local playercoords = GetEntityCoords(playerped)
        for k in pairs(coords) do
            local dist = Vdist(playercoords.x, playercoords.y, playercoords.z, coords[k].x, coords[k].y, coords[k].z)
            if dist <= 2 then
                YMDrawText3D(coords[k].x, coords[k].y, coords[k].z, "Press ~y~[E]~w~ to ~y~sell your car", 0.4)
                if IsControlJustReleased(1, 38) then
                    sellCar()
                end
            end
        end
    end
end)

function YMDrawText3D(x,y,z, text, scale)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(scale, scale)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end
function DeleteGivenVehicle(veh)
    SetEntityAsMissionEntity( veh, true, true )
    DeleteVehicle(veh)
end
function spawnPed()
    npcGone = false
    npc = CreatePed(4, 0xA1435105, 330.788, -1241.389, 30.585, 213.47, false, true)
    SetEntityHeading(npc, 213.47)
	SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    Citizen.Wait(2000)
    FreezeEntityPosition(npc, true)
    return npc
end
Citizen.CreateThread(function()
    RequestModel(GetHashKey("a_m_y_business_03"))
    spawnPed()
    while not HasModelLoaded(GetHashKey("a_m_y_business_03")) do
        Wait(0)
    end
    RequestAnimDict("missfbi3_party_d")
    RequestAnimDict("missheistdockssetup1")
    RequestAnimDict("mp_common")
    while (not HasAnimDictLoaded("missfbi3_party_d")) do Wait(0) end
    while (not HasAnimDictLoaded("missheistdockssetup1")) do Wait(0) end
    while (not HasAnimDictLoaded("mp_common")) do Wait(0) end
    while true do
        if aboutToSell then
            TaskPlayAnim(npc,"missheistdockssetup1","beckon",1.0,-1.0, 11000, 0, 1, true, true, true)
            aboutToSell = false
        end
        if selling then
            Wait(2000)
            TaskPlayAnim(npc,"missfbi3_party_d","stand_talk_loop_a_male2",1.0,-1.0, 11000, 0, 1, true, true, true)
            FreezeEntityPosition(npc, false)
            selling = false
        end
        if checking then
            TaskEnterVehicle(npc, vehicleSold, -1, -1, 1.0, 1, 0)
            checking = false
        end
        if scammed then
            TaskVehicleDriveToCoord(npc, vehicleSold, 341.978, -1315.701, 32.112, 30.00, 1, GetHashKey(vehicleSold), 786468, 1.0, true)
            Wait(20000)
            DeleteGivenVehicle(vehicleSold)
            SetEntityAsNoLongerNeeded(npc)
            spawnPed()
            scammed = false
        end
        if sold then
            sold = false
            local pCoords = GetEntityCoords(PlayerPedId())
            local pHeading = GetEntityHeading(PlayerPedId())
            TaskLeaveVehicle(npc, vehicleSold, 0)
            Citizen.Wait(2000)
            TaskGoStraightToCoord(npc, pCoords.x - 0.3, pCoords.y, pCoords.z, 3, -1, pHeading, 0.1)
            Citizen.Wait(1000)
            TaskPlayAnim(npc,"mp_common","givetake1_a",1.0,-1.0, 11000, 0, 1, true, true, true)
            TriggerServerEvent('esx_sellcar:payMoney')
            Citizen.Wait(5000)
            TaskEnterVehicle(npc, vehicleSold, -1, -1, 1.0, 1, 0)
            TaskVehicleDriveToCoord(npc, vehicleSold, 341.978, -1315.701, 32.112, 15.00, 1, GetHashKey(vehicleSold), 786468, 1.0, true)
            Wait(20000)
            DeleteGivenVehicle(vehicleSold)
            SetEntityAsNoLongerNeeded(npc)
            spawnPed()
            npcGone = true
        end
        Citizen.Wait(0)
    end
end)
function sellCar()
    local ped = PlayerPedId()
    local pped = GetPlayerPed(-1)
    if IsPedInAnyVehicle(ped) then
        aboutToSell = true
        vehicleSold = GetVehiclePedIsIn( ped, false )
        local randomThing = math.random(2)
        TaskLeaveVehicle(ped, vehicleSold, 0)
        Wait(2000)
        TaskGoStraightToCoord(pped, 331.47, -1242.368, 30.585, 3, -1, 26.31, 0.1)
        local pid = PlayerPedId()
        Wait(3000)
        RequestAnimDict("missfbi3_party_d")
        while (not HasAnimDictLoaded("missfbi3_party_d")) do Wait(0) end
        TaskPlayAnim(pid,"missfbi3_party_d","stand_talk_loop_a_male1",1.0,-1.0, 11000, 0, 1, true, true, true)
        selling = true
        TriggerEvent("mythic_progbar:client:progress", {
            name = "selling_car",
            duration = 10000,
            label = "Bargaining...",
            useWhileDead = false,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }
        }, function(status)
            if not status then
                selling = false
                checking = true
                TriggerEvent("mythic_progbar:client:progress", {
                    name = "checking_car",
                    duration = 10000,
                    label = "Ped checking out car...",
                    useWhileDead = false,
                    canCancel = true,
                    controlDisables = {
                        disableMovement = true,
                        disableCarMovement = true,
                        disableMouse = false,
                        disableCombat = true,
                    }
                }, function(status)
                    if not status then
                        if randomThing == 2 then
                            scammed = true
                            notification("You have been ~r~scammed!~w~ The buyer drove off with the car!")
                        else
                            sold = true
                            Citizen.Wait(5000)
                            secondRandom = math.random(2)
                            if secondRandom then
                                Wait(7500)
                                notification('~r~The car was reported as illegally sold! Run!')
                                SetPlayerWantedLevel(PlayerId(), 2, false)
                                SetPlayerWantedLevelNow(PlayerId(), false)
                            end
                        end
                    end
                end)
            end
        end)
    else
        if not IsPedInAnyVehicle(ped) then
            notification('~r~You are not in a vehicle!')
        end
    end
end
function notification(msg)
    SetNotificationTextEntry("STRING")
	AddTextComponentString(msg)
	DrawNotification(false, false)
end