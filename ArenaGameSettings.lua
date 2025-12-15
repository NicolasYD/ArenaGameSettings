-- Load libraries
local ArenaGameSettings = LibStub("AceAddon-3.0"):NewAddon("ArenaGameSettings", "AceEvent-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

-- Local variables to track state
local lastInstanceType

-- Table containing the CVars modified by this addon
local cvarToKey = {
    Sound_MasterVolume = "MasterVolume",
    Sound_MusicVolume = "MusicVolume",
    Sound_SFXVolume = "SFXVolume",
    Sound_AmbienceVolume = "AmbienceVolume",
    Sound_DialogVolume = "DialogVolume",
    Sound_GameplaySFX = "GameplaySFX",
    Sound_PingVolume = "PingVolume",
}

-- Minimap button
local minimapDataObject = LDB:NewDataObject("ArenaGameSettings", {
    type = "launcher",
    icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
    OnClick = function(_, button)
        if button == "LeftButton" then
            ArenaGameSettings:OpenOptions()
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("ArenaGameSettings")
        tooltip:AddLine("Left-click: Open options", 1, 1, 1)
    end,
})


-- Function to update CVars based on instance type
function ArenaGameSettings:UpdateSettings()
    local settings = self.db.global
    local inInstance, instanceType = IsInInstance()

    -- Only update CVars when the instance type changes
    if instanceType ~= lastInstanceType then
        lastInstanceType = instanceType

        if instanceType == "arena" then
            for cvar, key in pairs(cvarToKey) do
                C_CVar.SetCVar(cvar, settings.arena[key] or tonumber(C_CVar.GetCVar(cvar)))
            end

        elseif instanceType ~= "arena" then
            for cvar, key in pairs(cvarToKey) do
                C_CVar.SetCVar(cvar, settings.outside[key] or tonumber(C_CVar.GetCVar(cvar)))
            end
        end
    end

    -- Always show framerate
    if FramerateFrame and FramerateFrame.Show and not FramerateFrame:IsShown() then
        FramerateFrame:Show()
    end
end

function ArenaGameSettings:SaveCurrentCVarsToDB()
    local settings = self.db.global
    local inInstance, instanceType = IsInInstance()

    if instanceType ~= "arena" then
        for cvar, key in pairs(cvarToKey) do
            settings.outside[key] = tonumber(C_CVar.GetCVar(cvar))
        end
    end
end

-- Open options panel
function ArenaGameSettings:OpenOptions()
	ACD:Open("ArenaGameSettings")

	-- Clamp the options window to the screen
    local frame = ACD.OpenFrames["ArenaGameSettings"]
    if frame and frame.frame then
        frame.frame:SetClampedToScreen(true)
        frame.frame:SetMovable(true)
        frame.frame:SetUserPlaced(true)
    end
end

-- Event handler when player enters the world or changes zones
function ArenaGameSettings:PLAYER_ENTERING_WORLD()
    self:UpdateSettings()
end

-- Event handler for entering/leaving instances
function ArenaGameSettings:ZONE_CHANGED_NEW_AREA()
    self:UpdateSettings()
end

-- Event handler when a CVar is changed
function ArenaGameSettings:CVAR_UPDATE(event, cvar, value)
    local settings = self.db.global
    local inInstance, instanceType = IsInInstance()
    local key = cvarToKey[cvar]

    if key then
        if instanceType == "arena" then
            settings.arena[key] = tonumber(C_CVar.GetCVar(cvar))
        elseif instanceType ~= "arena" then
            settings.outside[key] = tonumber(C_CVar.GetCVar(cvar))
        end
    end
end

function ArenaGameSettings:OnInitialize()
    -- Initialize internal state
    lastInstanceType = nil

    -- Set up saved variables
    self.db = LibStub("AceDB-3.0"):New("ArenaGameSettingsDB", {
        global = {
            minimap = {
                hide = false,
            },
            arena = {
                MusicVolume = 0.00,
                SFXVolume = 1.00,
                AmbienceVolume = 0.00,
                DialogVolume = 0.00,
                GameplaySFX = 1.00,
            },
            outside = {},
        },
    })

    -- Create options panel
    self:SetupOptions()

    -- Minimap button
    LDBIcon:Register("ArenaGameSettings", minimapDataObject, self.db.global.minimap)
end

-- Register events
function ArenaGameSettings:OnEnable()
    self:SaveCurrentCVarsToDB()

    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterEvent("CVAR_UPDATE")
end

-- Unregister events
function ArenaGameSettings:OnDisable()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
    self:UnregisterEvent("CVAR_UPDATE")
end

-- Create options panel
function ArenaGameSettings:SetupOptions()
    local options = {
        type = "group",
        name = "ArenaGameSettings",
        args = {
            header = {
                type = "header",
                name = "Arena Game Settings",
                order = 1,
            },
            minimap = {
                type = "toggle",
                name = "Show Minimap Button",
                get = function()
                    return not self.db.global.minimap.hide
                end,
                set = function(_, value)
                    self.db.global.minimap.hide = not value
                    if value then
                        LDBIcon:Show("ArenaGameSettings")
                    else
                        LDBIcon:Hide("ArenaGameSettings")
                    end
                end,
                order = 2,
            },
        },
    }

    AC:RegisterOptionsTable("ArenaGameSettings", options)
    ACD:AddToBlizOptions("ArenaGameSettings", "ArenaGameSettings")
end
