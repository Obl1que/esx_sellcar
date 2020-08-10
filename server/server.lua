  
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterNetEvent('esx_sellcar:payMoney')
AddEventHandler('esx_sellcar:payMoney', function()
    xPlayer = ESX.GetPlayerFromId(source)
    payout = math.floor(math.random(6000, 23000) / Config.taxrate)
    if Config.isIllegal then
        xPlayer.addAccountMoney('black_money', payout)
        TriggerClientEvent('esx:showNotification', source, '~g~Sold car.~w~ You got $'..payout..' in black money for it')
    elseif not Config.isIllegal then
        xPlayer.addMoney(payout)
        TriggerClientEvent('esx:showNotification', source, '~g~Sold car.~w~ You got $'..payout..' for it')
    end
end)