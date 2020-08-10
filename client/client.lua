ESX = nil
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
            if dist <= 5 then
                YMDrawText3D(coords[k].x, coords[k].y, coords[k].z, "Press ~y~[E]~w~ to ~y~sell your car", 0.4)
                if IsControlJustReleased(1, 38) then
                    print('sellage')
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
function sellCar()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped) then
        local vehicle = GetVehiclePedIsIn( ped, false )
        randomThing = math.random(2)
        if randomThing == 2 then
            DeleteGivenVehicle(vehicle)
            notification("You have been ~r~scammed!~w~ The buyer drove off with the car!")
        else
            DeleteGivenVehicle(vehicle)
            TriggerServerEvent('esx_sellcar:payMoney')
        end
    else
        notification('~r~You are not in a vehicle!')
    end
end
function notification(msg)
    SetNotificationTextEntry("STRING")
	AddTextComponentString(msg)
	DrawNotification(false, false)
end