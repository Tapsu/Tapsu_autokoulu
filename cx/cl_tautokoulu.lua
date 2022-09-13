ESX = nil
local testType, Ajoneuvo, AjoneuvoHP, Pos = nil, nil, nil, nil
local Aktiivisena, display = false, false
local VaadittuKM = 0.0
local Virheet = 0

CreateThread(function()
  while ESX == nil do
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
    Wait(50)
  end
end)

CreateThread(function()
  while true do
    Wait(0)
    local Ply = PlayerPedId()
    local PlyCoords = GetEntityCoords(Ply)
    local isInMarker, s, currentZone = false, true, nil
    local distance = #(PlyCoords - Config.Autokoulu)
    if ( distance < 5 ) then
      s = false
      DrawMarker(2, Config.Autokoulu, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.2, 228, 99, 8, 100, false, true, 2, nil, nil, true)
      if distance < 2.0 then
        Draw3DText(vector3(Config.Autokoulu), "~r~E ~w~Asioidaksesi", 0.35)
        isInMarker, currentZone = true, 'Autokoulu'
      end
    end
    distance = #(PlyCoords - Config.A_Palautus)
    if ( distance < 15.0 ) then
      if ( Aktiivisena ) then
        if ( IsPedInAnyVehicle(Ply, false) ) then
          s = false
          DrawMarker(36, Config.A_Palautus, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 255, 0, 0, 100, false, true, 2, nil, nil, true)
          if ( distance < 3.0 ) then
            isInMarker, currentZone = true, 'Palautus'
          end
        end
      end
    end
    if ( isInMarker and not hasAlreadyEnteredMarker) or (isInMarker and lastZone ~= currentZone ) then
      hasAlreadyEnteredMarker, lastZone = true, currentZone
      TriggerEvent('tapsu_autokoulu:hasEnteredMarker', currentZone)
    end
    if ( not isInMarker and hasAlreadyEnteredMarker ) then
      hasAlreadyEnteredMarker = false
      TriggerEvent('tapsu_autokoulu:hasExitedMarker')
    end
    if ( s ) then
      Wait(500)
    end
  end
end)

AddEventHandler('tapsu_autokoulu:hasEnteredMarker', function(zone)
  if ( zone == 'Autokoulu' ) then
    currentAction = 'AKouluMenu'
  elseif ( zone == 'Palautus' ) then
    currentAction = 'autokoulu_palautus'
  end
end)

AddEventHandler('tapsu_autokoulu:hasExitedMarker', function()
	ESX.UI.Menu.CloseAll()
	currentAction = nil
end)

CreateThread(function()
  while true do
    Wait(0)
    if ( currentAction ) then
      if ( IsControlJustReleased(0, 38) and GetLastInputMethod(0) ) then
        if ( currentAction == 'AKouluMenu' ) then
          ESX.UI.Menu.CloseAll()
          AutokouluMenu()
        elseif ( currentAction == 'autokoulu_palautus' ) then
          ESX.UI.Menu.CloseAll()
          LopetaInssi()
        end
        currentAction = nil
      end
    else
      Wait(500)
    end
  end
end)

local function AloitaInssi(type)
  local Ply = PlayerPedId()
  local model
  if ( type == 'drive_bike' ) then
    model = Config.Moottoripyora
  elseif ( type == 'drive' ) then
    model = Config.Henkiloauto
  elseif ( type == 'drive_truck' ) then
    model = Config.Rekka
  end
  testType = type
  ESX.TriggerServerCallback('tapsu_autokoulu:Maksu', function (maksettu)
    if ( maksettu ) then
      ESX.Game.SpawnVehicle(model, Config.A_Spawn, Config.A_S_Heading, function(vehicle)
          rekkari = math.random(100, 999)
          SetVehicleNumberPlateText(vehicle, "TAPSU"..rekkari) 
          SetVehicleColours(vehicle, 12, 12)
          AjoneuvoHP = GetEntityHealth(vehicle)
          Ajoneuvo = vehicle
          Aktiivisena = true
          Pos = GetEntityCoords(vehicle)
          Virheet = 0
          VaadittuKM = 0
          TaskWarpPedIntoVehicle(Ply, vehicle, -1)
      end)
    else
      ESX.ShowNotification('Sinulla ei ole tarpeeksi käteistä')
    end
  end, Config.InssiMaksu, type)
end

LopetaInssi = function()
  if ( VaadittuKM < Config.A_Matka ) then
    Aktiivisena = false
    AjoneuvoHP = nil
    Virheet = 0
    Pos = nil
    VaadittuKM = 0
    testType = nil
    ESX.Game.DeleteVehicle(Ajoneuvo)
    Ajoneuvo = nil
    ESX.ShowNotification('Hylätty')
  else
    TriggerServerEvent('tapsu_autokoulu:addLicense', testType)
    ESX.ShowNotification('Sinulle on myönnetty ' ..testType .. ' kortti')
    Aktiivisena = false
    AjoneuvoHP = nil
    Virheet = 0
    Pos = nil
    VaadittuKM = 0
    testType = nil
    ESX.Game.DeleteVehicle(Ajoneuvo)
    Ajoneuvo = nil
  end
end

InssiHylatty = function()
  Aktiivisena = false
  AjoneuvoHP = nil
  Virheet = 0
  Pos = nil
  VaadittuKM = 0
  Ajoneuvo = nil
end

CreateThread(function()
  while true do
    if Aktiivisena then
      if IsPedInAnyVehicle(PlayerPedId(), false) then
        if GetVehiclePedIsIn(PlayerPedId(), false) ~= Ajoneuvo then
        InssiHylatty()
        ESX.ShowNotification('HYLÄTTY, olet väärässä ajoneuvossa!')
        end
      end
    end
    Wait(500)
  end
end)

CreateThread(function()
  while true do
    local s = 2000
    if ( Aktiivisena ) then
      if ( VaadittuKM < Config.A_Matka ) then
        s = 500
        local newCoords = GetEntityCoords(Ajoneuvo)
        local distance = GetDistanceBetweenCoords(Pos, newCoords, false)
        Pos = newCoords
        VaadittuKM = VaadittuKM + distance
        if ( VaadittuKM > Config.A_Matka ) then
          ESX.ShowNotification('Palauta ajoneuvo')
        end
      end
    end
    Wait(s)
  end
end)

CreateThread(function()
  while true do
    local s = 500
    if ( Aktiivisena ) then
      s = 0
      local hash1, hash2 = GetStreetNameAtCoord(GetEntityCoords(PlayerPedId()), Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
      local street2 = GetStreetNameFromHashKey(hash2)
      local speed = GetEntitySpeed(Ajoneuvo) * 3.6
      
      if ( string.sub(street2, -3) == 'Fwy' or string.sub(street2, -7) == 'Freeway' ) then
        if ( speed > Config.MotariNopeus+5 ) then
          Virheet = Virheet + 1
          ESX.ShowNotification('Varoitus, ajoit liian kovaa: '..round(speed)..' / 140 km/h! Virheet:' .. Virheet .. ' / ' .. Config.A_Virheet)
          Wait(2000)
        end
      else
        if ( speed > Config.Taajamaa+5 ) then
          Virheet = Virheet + 1
          ESX.ShowNotification('Varoitus, ajoit liian kovaa: '..round(speed)..' / 80 km/h! Virheet:' .. Virheet .. ' / ' .. Config.A_Virheet)
          Wait(2000)
        end
      end
      local health = GetEntityHealth(Ajoneuvo)
      if ( health < AjoneuvoHP ) then
        Virheet = Virheet + 1
        ESX.ShowNotification('Varoitus, vahingoitit ajoneuvoa' .. Virheet .. ' / ' .. Config.A_Virheet)
        AjoneuvoHP = health
        Wait(2000)
      end
      if ( Virheet >= Config.A_Virheet ) then
        ESX.ShowNotification('HYLÄTTY, koska teit liian monta virhettä!')
        InssiHylatty()
      end
    end
    Wait(s)
  end
end)

CreateThread(function()
  while true do
    local sleep = 500
    if ( Aktiivisena ) then
      sleep = 0
      SetTextFont(4)
      SetTextProportional(0)
      SetTextScale(0.6, 0.6)
      SetTextColour(228, 99, 8, 1000)
      SetTextDropshadow(0, 0, 0, 1000)
      SetTextEntry("STRING")
      AddTextComponentString(string.format('%.1f', math.ceil(VaadittuKM)/1000) .. 'km / ' .. string.format('%.1f', Config.A_Matka/1000) .. 'km')
      DrawText(0.45, 0.95)
    end
    Wait(sleep)
  end
end)

CreateThread(function()
  local akoulu = AddBlipForCoord(Config.Autokoulu)
  SetBlipSprite(akoulu, 498)
	SetBlipScale(akoulu, 0.6)
	SetBlipColour(akoulu, 42)
	SetBlipAsShortRange(akoulu, true)
  SetBlipDisplay(akoulu, 4)
	BeginTextCommandSetBlipName('STRING')
	AddTextComponentSubstringPlayerName('Autokoulu')
	EndTextCommandSetBlipName(akoulu)
end)

AutokouluMenu = function()
  SetDisplay(not display)
  if ( display ) then
    DisableControlAction(0, 1, display)
    DisableControlAction(0, 2, display)
    DisableControlAction(0, 142, display)
    DisableControlAction(0, 18, display)
    DisableControlAction(0, 322, display)
    DisableControlAction(0, 106, display)
  end
end

SetDisplay = function(bool)
  ESX.TriggerServerCallback('tapsu_autokoulu:GetLicense', function (licenses)
    local Ajokortit = {}
    for i=1, #licenses, 1 do
      Ajokortit[licenses[i].type] = true
    end
    SetNuiFocus(bool, bool)
    SendNUIMessage({UI = bool, T = Ajokortit['dmv'], A = Ajokortit['drive_bike'], B = Ajokortit['drive'], C = Ajokortit['drive_truck'],} )
  end)
end

Draw3DText = function(coords, text, scale)
	local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
	SetTextScale(scale, scale)
	SetTextOutline()
	SetTextDropShadow()
	SetTextDropshadow(2, 0, 0, 0, 255)
	SetTextFont(4)
	SetTextProportional(1)
	SetTextEntry('STRING')
	SetTextCentre(1)
	SetTextColour(255, 255, 255, 215)
	AddTextComponentString(text)
	DrawText(x, y)
    local factor = (string.len(text)) / 400
    DrawRect(x, y+0.012, 0.015+ factor, 0.03, 0, 0, 0, 0)
end

round = function(num)
  return tonumber(string.format("%.0f", num))
end

RegisterNUICallback('Sulje', function()
  SetDisplay(false)
end)

RegisterNUICallback('Teoriakunnossa', function()
  TriggerServerEvent('tapsu_autokoulu:addLicense', 'dmv')
end)

RegisterNUICallback('Ajokoe', function(data)
  AloitaInssi(data.type)
end)

RegisterNUICallback('TeoriaMaksu', function(data, cb)
  ESX.TriggerServerCallback('tapsu_autokoulu:Maksu', function(maksettu)
    if ( maksettu ) then
      cb(true)
    else
      cb(false)
      ESX.ShowNotification('Sinulla ei ole tarpeeksi käteistä')
    end
  end, Config.TeoriaMaksu)
end)

AddEventHandler('esx:onPlayerDeath', function(data)
  Aktiivisena = false
  AjoneuvoHP = nil
  Virheet = 0
  Pos = nil
  VaadittuKM = 0
  Ajoneuvo = nil
end)