-- Load libraries
local ArenaGameSettings = LibStub("AceAddon-3.0"):NewAddon("ArenaGameSettings", "AceEvent-3.0", "AceConsole-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

-- Localize WoW API functions
local GetCVar = C_CVar.GetCVar
local SetCVar = C_CVar.SetCVar

-- Table containing the CVars modified by this addon
local cvarTable = {
    Sound_MasterVolume = {
        key = "MasterVolume",
        name = "Master Volume",
        default = 1,
        order = 1
    },
    Sound_MusicVolume = {
        key = "MusicVolume",
        name = "Music",
        default = 0.4,
        recommended = 0,
        order = 2
    },
    Sound_SFXVolume = {
        key = "SFXVolume",
        name = "Effects",
        default = 1,
        recommended = 1,
        order = 3
    },
    Sound_AmbienceVolume = {
        key = "AmbienceVolume",
        name = "Ambience",
        default = 0.6,
        recommended = 0,
        order = 4
    },
    Sound_DialogVolume = {
        key = "DialogVolume",
        name = "Dialog",
        default = 1,
        recommended = 0,
        order = 5
    },
    Sound_GameplaySFX = {
        key = "GameplaySFX",
        name = "Gameplay Sound Effects",
        default = 1,
        order = 6
    },
    Sound_PingVolume = {
        key = "PingVolume",
        name = "Ping Sounds",
        default = 1,
        order = 7
    },
}

-- Minimap button
local minimapDataObject = LDB:NewDataObject("ArenaGameSettings", {
    type = "launcher",
    icon = "Interface\\Icons\\Achievement_Featsofstrength_Gladiator_08",
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

    if instanceType == "arena" then
        for cvar, info in pairs(cvarTable) do
            C_CVar.SetCVar(cvar, settings.arena[info.key] or tonumber(C_CVar.GetCVar(cvar)))
        end
    elseif instanceType ~= "arena" then
        for cvar, info in pairs(cvarTable) do
            C_CVar.SetCVar(cvar, settings.outside[info.key] or tonumber(C_CVar.GetCVar(cvar)))
        end
    end

    self:ShowFramerate()
end

function ArenaGameSettings:SaveCurrentCVarsToDB()
    local settings = self.db.global
    local inInstance, instanceType = IsInInstance()

    if instanceType ~= "arena" then
        for cvar, info in pairs(cvarTable) do
            settings.outside[info.key] = tonumber(C_CVar.GetCVar(cvar))
        end
    end
end

-- Display the framerate
function ArenaGameSettings:ShowFramerate()
    local showFR = self.db.global.showFramerate
    if showFR and FramerateFrame and FramerateFrame.Show and not FramerateFrame:IsShown() then
        FramerateFrame:Show()
    elseif not showFR and FramerateFrame and FramerateFrame.Hide and FramerateFrame:IsShown() then
        FramerateFrame:Hide()
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

-- Handle ingame slash commands
function ArenaGameSettings:SlashCommand(input)
    input = input:lower()

    if input == "reset" then
        self.db:ResetDB()
        ACR:NotifyChange("ArenaGameSettings")
        print("ArenaGameSettings: settings reset.")
    else
        self:OpenOptions()
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
    local info = cvarTable[cvar]

    if info and info.key then
        if instanceType == "arena" then
            settings.arena[info.key] = tonumber(C_CVar.GetCVar(cvar))
        elseif instanceType ~= "arena" then
            settings.outside[info.key] = tonumber(C_CVar.GetCVar(cvar))
        end
    end
end

function ArenaGameSettings:OnInitialize()
    -- Set up saved variables
    self.db = LibStub("AceDB-3.0"):New("ArenaGameSettingsDB", {
        global = {
            minimap = {
                hide = false,
                minimapPos = 15,
            },
            showFramerate = true,
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

    -- Slash command
    self:RegisterChatCommand("ags", "SlashCommand")
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
        name = "Arena Game Settings",
        args = {
            general = {
                type = "group",
                name = "General",
                order = 1,
                args = {
                    header1 = {
                        type = "header",
                        name = "General Settings",
                        order = 1,
                    },
                    minimap = {
                        type = "toggle",
                        name = "Minimap Button",
                        desc = "Show the minimap button.",
                        order = 2,
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
                    },
                    framerate = {
                        type = "toggle",
                        name = "Framerate",
                        desc = "Show the framerate all the time.",
                        order = 3,
                        get = function()
                            return self.db.global.showFramerate
                        end,
                        set = function(_, value)
                            self.db.global.showFramerate = value
                            self:ShowFramerate()
                        end,
                    },
                },
            },
            audio = {
                type = "group",
                name = "Audio",
                order = 2,
                childGroups = "tab",
                args = {
                    arena = {
                        type = "group",
                        name = "Arena",
                        order = 1,
                        args = {
                            header1 = {
                                type = "header",
                                name = "Audio Settings",
                                order = 1,
                            },
                        },
                    },
                    outside = {
                        type = "group",
                        name = "Outside",
                        order = 2,
                        args = {
                            header1 = {
                                type = "header",
                                name = "Audio Settings",
                                order = 1,
                            },
                        },
                    },
                },
            },
        },
    }
    
    for group, _ in pairs(options.args.audio.args) do
        for cvar, info in pairs(cvarTable) do
            local inInstance, instanceType = IsInInstance()

            options.args.audio.args[group].args[info.key] = {
                type = "range",
                name = info.name,
                desc = function()
                    if group == "arena" and info and info.default and info.recommended then
                        return string.format(
                            "Default Value: |cFFFF0000%s|r\nRecommended Value: |cFF00FF00%s|r",
                            info.default,
                            info.recommended
                        )
                    elseif info and info.default then
                        return string.format(
                            "Default Value: |cFFFF0000%s|r",
                            info.default
                        )
                    end
                end,
                min = 0, max = 1, step = 0.01,
                order = 1 + info.order,
                get = function()
                    if group == "arena" then
                        return self.db.global.arena[info.key] or tonumber(C_CVar.GetCVar(cvar))
                    elseif group == "outside" then
                        return self.db.global.outside[info.key] or tonumber(C_CVar.GetCVar(cvar))
                    end
                end,
                set = function(_, value)
                    if group == "arena" then
                        self.db.global.arena[info.key] = value
                    elseif group == "outside" then
                        self.db.global.outside[info.key] = value
                    end
                    self:UpdateSettings()
                end,
            }
        end
    end

    AC:RegisterOptionsTable("ArenaGameSettings", options)
    ACD:AddToBlizOptions("ArenaGameSettings", "ArenaGameSettings")
end
