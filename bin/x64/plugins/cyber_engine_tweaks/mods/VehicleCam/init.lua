local settings = {
vehicleFOV = 60.0,
bikeFOV = 60.0,
vehicleCombatFOV = 60.0
}

local GameUI = require('GameUI')
local GameSettings = require('GameSettings')
local MainFOV = 0.0
local lang = ""


registerForEvent("onInit", function()
  lang = NameToString(GameSettings.Get("/language/OnScreen"))
  SetupLanguageListener()
  LoadSettings()
  MainFOV = GameSettings.Get("/graphics/basic/FieldOfView")
  createSettingsMenu()
  if not (TweakDB:GetFlat("fppCameraParamSets.Vehicle.fov") == settings.vehicleFOV and TweakDB:GetFlat("fppCameraParamSets.VehiclePassenger.fov") == settings.vehicleFOV and TweakDB:GetFlat("fppCameraParamSets.DriverCombat.fov") == settings.vehicleCombatFOV and TweakDB:GetFlat("fppCameraParamSets.Bike.fov") == settings.bikeFOV) then 
    TweakDB:SetFlat("fppCameraParamSets.Vehicle.fov", settings.vehicleFOV)
    TweakDB:SetFlat("fppCameraParamSets.Bike.fov", settings.bikeFOV)
    TweakDB:SetFlat("fppCameraParamSets.VehiclePassenger.fov", settings.vehicleFOV)
    TweakDB:SetFlat("fppCameraParamSets.DriverCombat.fov", settings.vehicleCombatFOV)   
  end
  GameUI.Observe(function(state)
    if state.isMenu or state.isMainMenu then 
      TweakDB:SetFlat("fppCameraParamSets.Vehicle.fov", settings.vehicleFOV)
      TweakDB:SetFlat("fppCameraParamSets.Bike.fov", settings.vehicleFOV)
      TweakDB:SetFlat("fppCameraParamSets.VehiclePassenger.fov", settings.vehicleFOV)
      TweakDB:SetFlat("fppCameraParamSets.DriverCombat.fov", settings.vehicleCombatFOV)
    end
    if state.isLoading then 
      TweakDB:SetFlat("fppCameraParamSets.Vehicle.fov", settings.vehicleFOV)
      TweakDB:SetFlat("fppCameraParamSets.Bike.fov", settings.vehicleFOV)
      TweakDB:SetFlat("fppCameraParamSets.VehiclePassenger.fov", settings.vehicleFOV)
      TweakDB:SetFlat("fppCameraParamSets.DriverCombat.fov", settings.vehicleCombatFOV)
    end  
  end)
end)

function SetupLanguageListener()
  GameUI.Listen("MenuNav", function(state)
      if state.lastSubmenu ~= nil and state.lastSubmenu == "Settings" then
          local newLang = NameToString(GameSettings.Get("/language/OnScreen"))
          if lang ~= newLang then
              lang = newLang
              createSettingsMenu()
          end
          SaveSettings()
      end
  end)
end

function LoadSettings()
  local file = io.open('settings.json', 'r')
  if file ~= nil then
    local contents = file:read("*a")
    local validJson, savedSettings = pcall(function() return json.decode(contents) end)
    file:close()

    if validJson then
      for key, _ in pairs(settings) do
        if savedSettings[key] ~= nil then
          settings[key] = savedSettings[key]
        end
      end
    end
  end
end
  
function SaveSettings()
  local validJson, contents = pcall(function() return json.encode(settings) end)

  if validJson and contents ~= nil then
    local file = io.open("settings.json", "w+")
    file:write(contents)
    file:close()
  end
end

function createSettingsMenu()
  local nativeSettings = GetMod("nativeSettings")

  if not nativeSettings then -- Make sure the mod is installed
      print("ERROR: Native Settings mod was not found!")
      return
  end

  if not nativeSettings.pathExists("/ZEO_VEHFOV") then 
      nativeSettings.addTab("/ZEO_VEHFOV", "Vehicle FOV Adjuster")
  end

  nativeSettings.addRangeFloat("/ZEO_VEHFOV","Car FOV", "The field of view when driving a car or truck, or as a passenger. (RELOAD SAVE AFTER CHANGING TO APPLY)", 60.0, 120.0, 5.0, "%.1f", settings.vehicleFOV, 70.0, function(value)
      settings.vehicleFOV = value
  end)

  nativeSettings.addRangeFloat("/ZEO_VEHFOV","Bike FOV", "The field of view when driving a motorbike. (RELOAD SAVE AFTER CHANGING TO APPLY)", 60.0, 120.0, 5.0, "%.1f", settings.bikeFOV, 70.0, function(value)
    settings.bikeFOV = value
end)

  nativeSettings.addRangeFloat("/ZEO_VEHFOV","Vehicle Combat FOV", "The field of view when entering vehicle combat as a driver. (RELOAD SAVE AFTER CHANGING TO APPLY)", 60.0, 120.0, 5.0, "%.1f", settings.vehicleCombatFOV, 70.0, function(value)
      settings.vehicleCombatFOV = value
  end)
end