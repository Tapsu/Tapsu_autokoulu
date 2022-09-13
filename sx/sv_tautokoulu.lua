ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('tapsu_autokoulu:Maksu', function(source, cb, amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if ( xPlayer.getMoney() >= amount ) then
		xPlayer.removeMoney(amount)
		cb(true)
	else
		cb(false)
	end
end)

ESX.RegisterServerCallback('tapsu_autokoulu:GetLicense', function(source, cb)
	TriggerEvent('esx_license:getLicenses', source, function(licenses)
    cb(licenses)
  end)
end)

RegisterNetEvent('tapsu_autokoulu:addLicense')
AddEventHandler('tapsu_autokoulu:addLicense', function(type)
	TriggerEvent('esx_license:addLicense', source, type, function()
	end)
end)