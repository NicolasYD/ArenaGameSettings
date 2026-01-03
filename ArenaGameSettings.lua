-- Load libraries
local ArenaGameSettings = LibStub("AceAddon-3.0"):NewAddon("ArenaGameSettings", "AceEvent-3.0", "AceConsole-3.0")
local AC = LibStub("AceConfig-3.0")
local ACD = LibStub("AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")

-- Localize WoW API functions
local IsInInstance = IsInInstance
local GetCVar = C_CVar.GetCVar
local SetCVar = C_CVar.SetCVar
local GetCVarDefault = C_CVar.GetCVarDefault

-- Table containing the CVars modified by this addon
local cvarTable = {
    -- General Settings
    general = {
        SpellQueueWindow = {
            name = "Spell Queue Window",
            desc = string.format("Recommended Value: Your average |cFF00FF00%s|r", "latency + 100."),
            order = 1,
        },
    },

    -- Audio Settings
    audio = {
        Sound_MasterVolume = {
            name = "Master Volume",
            order = 1,
        },
        Sound_MusicVolume = {
            name = "Music",
            desc = string.format("Recommended Value: |cFF00FF00%.1f|r", 0),
            order = 2,
        },
        Sound_SFXVolume = {
            name = "Effects",
            desc = string.format("Recommended Value: |cFF00FF00%.1f|r", 1),
            order = 3,
        },
        Sound_AmbienceVolume = {
            name = "Ambience",
            desc = string.format("Recommended Value: |cFF00FF00%.1f|r", 0),
            order = 4,
        },
        Sound_DialogVolume = {
            name = "Dialog",
            desc = string.format("Recommended Value: |cFF00FF00%.1f|r", 0),
            order = 5,
        },
        Sound_GameplaySFX = {
            name = "Gameplay Sound Effects",
            order = 6,
        },
        Sound_PingVolume = {
            name = "Ping Sounds",
            order = 7,
        },
    },

    -- Graphics Settings
    graphics = {
        graphicsProjectedTextures ={
            name = "Projected Textures",
            desc = string.format("Recommended: |cFF00FF00%s|r", "Enabled"),
            order = 1,
        },
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
        tooltip:AddLine("Arena Game Settings")
        tooltip:AddLine("Left-Click to open options.", 1, 1, 1)
    end,
})


-- Function to update CVars based on instance type
function ArenaGameSettings:UpdateSettings()
    local settings = self.db.global
    local inInstance, instanceType = IsInInstance()

    -- Helper function to apply settings for arena and outside
    local function applySettings(category)
        if settings and settings.arena and instanceType == "arena" then
            for cvar, _ in pairs(cvarTable[category]) do
                if settings.arena[cvar] ~= GetCVar(cvar) then
                    SetCVar(cvar, settings.arena[cvar])
                end
            end
        elseif settings and settings.outside and instanceType ~= "arena" then
            for cvar, _ in pairs(cvarTable[category]) do
                if settings.outside[cvar] ~= GetCVar(cvar) then
                    SetCVar(cvar, settings.outside[cvar])
                end
            end
        end
    end

    -- General Settings
    if settings then
        for cvar, _ in pairs(cvarTable.general) do
            if settings[cvar] ~= GetCVar(cvar) then
                SetCVar(cvar, settings[cvar])
            end
        end
    end

    -- Audio Settings
    applySettings("audio")

    -- Graphics Settings
    applySettings("graphics")

    self:ShowFramerate()
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

    -- General Settings
    if settings and cvarTable.general[cvar] then
        settings[cvar] = GetCVar(cvar)
    end

    -- Audio Settings
    if settings and cvarTable.audio[cvar] then
        if settings.arena and instanceType == "arena" then
            settings.arena[cvar] = GetCVar(cvar)
        elseif settings.outside and instanceType ~= "arena" then
            settings.outside[cvar] = GetCVar(cvar)
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
            SpellQueueWindow = GetCVar("SpellQueueWindow"),
            arena = {
                -- Audio Settings
                Sound_MasterVolume = GetCVar("Sound_MasterVolume"),
                Sound_MusicVolume = "0",
                Sound_SFXVolume = "1",
                Sound_AmbienceVolume = "0",
                Sound_DialogVolume = "0",
                Sound_GameplaySFX = "1",
                Sound_PingVolume = GetCVar("Sound_PingVolume"),

                -- Graphics Settings
                graphicsProjectedTextures = "1",
            },
            outside = {
                -- Audio Settings
                Sound_MasterVolume = GetCVar("Sound_MasterVolume"),
                Sound_MusicVolume = GetCVar("Sound_MusicVolume"),
                Sound_SFXVolume = GetCVar("Sound_SFXVolume"),
                Sound_AmbienceVolume = GetCVar("Sound_AmbienceVolume"),
                Sound_DialogVolume = GetCVar("Sound_DialogVolume"),
                Sound_GameplaySFX = GetCVar("Sound_GameplaySFX"),
                Sound_PingVolume = GetCVar("Sound_PingVolume"),

                -- Graphics Settings
                graphicsProjectedTextures = GetCVar("graphicsProjectedTextures"),
            },
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
            addon = {
                type = "group",
                name = "AddOn",
                order = 1,
                args = {
                    header1 = {
                        type = "header",
                        name = "AddOn Settings",
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
                }
            },
            general = {
                type = "group",
                name = "General",
                order = 2,
                args = {
                    header1 = {
                        type = "header",
                        name = "General Settings",
                        order = 1,
                    },
                    framerate = {
                        type = "toggle",
                        name = "Framerate",
                        desc = "Show the framerate all the time.",
                        order = 2,
                        get = function()
                            return self.db.global.showFramerate
                        end,
                        set = function(_, value)
                            self.db.global.showFramerate = value
                            self:ShowFramerate()
                        end,
                    },
                    SpellQueueWindow = {
                        type = "range",
                        name = cvarTable.general["SpellQueueWindow"].name,
                        desc = function()
                            local default = GetCVarDefault("SpellQueueWindow")

                            return string.format(
                                "Default Value: |cFFFF0000%s|r\n%s",
                                string.format("%s", default),
                                cvarTable.general["SpellQueueWindow"].desc
                            )
                        end,
                        min = 0, max = tonumber(GetCVarDefault("SpellQueueWindow")), step = 1,
                        order = 3,
                        get = function()
                            return tonumber(self.db.global["SpellQueueWindow"])
                        end,
                        set = function(_, value)
                            self.db.global["SpellQueueWindow"] = tostring(value)
                            self:UpdateSettings()
                        end,
                    },
                },
            },
            audio = {
                type = "group",
                name = "Audio",
                order = 3,
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
            graphics = {
                type = "group",
                name = "Graphics",
                order = 4,
                childGroups = "tab",
                args = {
                    arena = {
                        type = "group",
                        name = "Arena",
                        order = 1,
                        args = {
                            header1 = {
                                type = "header",
                                name = "Graphics Settings",
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
                                name = "Graphics Settings",
                                order = 1,
                            },
                        },
                    },
                },
            },
        },
    }

    -- Audio Settings (sliders)
    for group, _ in pairs(options.args.audio.args) do
        for cvar, info in pairs(cvarTable.audio) do
            options.args.audio.args[group].args[cvar] = {
                type = "range",
                name = info.name,
                desc = function()
                    local default = GetCVarDefault(cvar)

                    if group == "arena" and info.desc then
                        return string.format(
                            "Default Value: |cFFFF0000%s|r\n%s",
                            string.format("%.1f", default),
                            info.desc
                        )
                    else
                        return string.format(
                            "Default Value: |cFFFF0000%s|r",
                            string.format("%.1f", default)
                        )
                    end
                end,
                min = 0, max = 1, step = 0.01,
                order = 1 + info.order,
                get = function()
                    if group == "arena" then
                        return tonumber(self.db.global.arena[cvar])
                    elseif group == "outside" then
                        return tonumber(self.db.global.outside[cvar])
                    end
                end,
                set = function(_, value)
                    if group == "arena" then
                        self.db.global.arena[cvar] = tostring(value)
                    elseif group == "outside" then
                        self.db.global.outside[cvar] = tostring(value)
                    end
                    self:UpdateSettings()
                end,
            }
        end
    end

    -- Graphics Settings (toggles)
    for group, _ in pairs(options.args.graphics.args) do
        for cvar, info in pairs(cvarTable.graphics) do
            options.args.graphics.args[group].args[cvar] = {
                type = "toggle",
                name = info.name,
                desc = function()

                    -- Helper function to return text for CVar value
                    local function translateDefaultValue(cvar_name)
                        local default = GetCVarDefault(cvar_name)
                        if default == "1" then
                            return "Enabled"
                        elseif default == "0" then
                            return "Disabled"
                        end
                        return default
                    end

                    local default = translateDefaultValue(cvar)

                    if group == "arena" and info.desc then
                        return string.format(
                            "Default: |cFFFF0000%s|r\n%s",
                            default,
                            info.desc
                        )
                    else
                        return string.format(
                            "Default: |cFFFF0000%s|r",
                            default
                        )
                    end
                end,
                order = 1 + info.order,
                get = function()
                    if group == "arena" then
                        return self.db.global.arena[cvar] == "1"
                    elseif group == "outside" then
                        return self.db.global.outside[cvar] == "1"
                    end
                end,
                set = function(_, value)
                    if group == "arena" then
                        self.db.global.arena[cvar] = value and "1" or "0"
                    elseif group == "outside" then
                        self.db.global.outside[cvar] = value and "1" or "0"
                    end
                    self:UpdateSettings()
                end,
            }
        end
    end

    AC:RegisterOptionsTable("ArenaGameSettings", options)
    ACD:AddToBlizOptions("ArenaGameSettings", "ArenaGameSettings")
end
