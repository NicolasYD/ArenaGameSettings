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
        AutoPushSpellToActionBar = {
            name = "Auto Push Spell To Action Bar",
            rec = string.format("Recommended: |cFF00FF00%s|r", "Disabled"),
            desc = "Determines if spells are automatically pushed to the Action Bar.",
            type = "toggle",
            states = {
                ["0"] = "Disabled",
                ["1"] = "Enabled",
            },
            width = "full",
            order = 1,
        },
        cameraDistanceMaxZoomFactor = {
            name = "Camera Distance Max Zoom Factor",
            rec = string.format("Recommended Value: |cFF00FF00%s|r", "2.6"),
            desc = "Controls how far the camera can zoom out.\nHigher values allow a wider field of view.",
            type = "range",
            min = 1,
            max = 2.6,
            step = 0.1,
            format = "%.1f",
            width = "full",
            order = 2,
        },
        SpellQueueWindow = {
            name = "Spell Queue Window",
            rec = string.format("Recommended Value: Your average |cFF00FF00%s|r.", "latency + 100"),
            desc = "Sets how early you can pre-activate/queue a spell/ability. (In Milliseconds)",
            type = "range",
            min = 0,
            max = tonumber(GetCVarDefault("SpellQueueWindow")),
            step = 1,
            width = "full",
            order = 3,
        },
    },

    -- Audio Settings
    audio = {
        Sound_MasterVolume = {
            name = "Master Volume",
            desc = "Adjusts the master sound volume.",
            type = "range",
            min = 0,
            max = 1,
            step = 0.1,
            width = "full",
            order = 1,
        },
        Sound_MusicVolume = {
            name = "Music",
            rec = string.format("Recommended Value: |cFF00FF00%s|r", "0.0"),
            desc = "Adjusts the background music volume.",
            type = "range",
            min = 0,
            max = 1,
            step = 0.1,
            width = "full",
            order = 2,
        },
        Sound_SFXVolume = {
            name = "Effects",
            rec = string.format("Recommended Value: |cFF00FF00%s|r", "1.0"),
            desc = "Adjusts the sound effect volume.",
            type = "range",
            min = 0,
            max = 1,
            step = 0.1,
            width = "full",
            order = 3,
        },
        Sound_AmbienceVolume = {
            name = "Ambience",
            rec = string.format("Recommended Value: |cFF00FF00%s|r", "0.0"),
            desc = "Adjusts the ambient sound volume.",
            type = "range",
            min = 0,
            max = 1,
            step = 0.1,
            width = "full",
            order = 4,
        },
        Sound_DialogVolume = {
            name = "Dialog",
            rec = string.format("Recommended Value: |cFF00FF00%s|r", "0.0"),
            desc = "Adjusts the dialog sound volume.",
            type = "range",
            min = 0,
            max = 1,
            step = 0.1,
            width = "full",
            order = 5,
        },
        Sound_GameplaySFX = {
            name = "Gameplay Sound Effects",
            desc = "Adjusts the gameplay sound effects volume.",
            type = "range",
            min = 0,
            max = 1,
            step = 0.1,
            format = "%.1f",
            width = "full",
            order = 6,
        },
        Sound_PingVolume = {
            name = "Ping Sounds",
            desc = "Adjusts ping sounds volume.",
            type = "range",
            min = 0,
            max = 1,
            step = 0.1,
            width = "full",
            order = 7,
        },
    },

    -- Graphics Settings
    graphics = {
        graphicsShadowQuality = {
            name = "Shadow Quality",
            rec = string.format("Recommended: |cFF00FF00%s|r", "Fair"),
            desc = "Controls both the method and quality of shadows.",
            type = "select",
            values = {
                ["0"] = "Low",
                ["1"] = "Fair",
                ["2"] = "Good",
                ["3"] = "High",
                ["4"] = "Ultra",
                ["5"] = "Ultra High",
            },
            width = "full",
            order = 1,
        },
        graphicsLiquidDetail = {
            name = "Liquid Detail",
            -- rec = string.format("Recommended: |cFF00FF00%s|r", "Low"),
            desc = "Controls the rendering quality of liquid.",
            type = "select",
            values = {
                ["0"] = "Low",
                ["1"] = "Fair",
                ["2"] = "Good",
                ["3"] = "High",
            },
            width = "full",
            order = 2,
        },
        graphicsParticleDensity = {
            name = "Particle Density",
            -- rec = string.format("Recommended: |cFF00FF00%s|r", "Low"),
            desc = "Controls the number of particles used in effects caused by spells, fires etc.",
            type = "select",
            values = {
                ["0"] = "Disabled",
                ["1"] = "Low",
                ["2"] = "Fair",
                ["3"] = "Good",
                ["4"] = "High",
                ["5"] = "Ultra",
            },
            width = "full",
            order = 3,
        },
        graphicsSSAO = {
            name = "SSAO",
            -- rec = string.format("Recommended: |cFF00FF00%s|r", "Disabled"),
            desc = "Controls the rendering quality of advanced lighting effects.",
            type = "select",
            values = {
                ["0"] = "Disabled",
                ["1"] = "Low",
                ["2"] = "Good",
                ["3"] = "High",
                ["4"] = "Ultra",
            },
            width = "full",
            order = 4,
        },
        graphicsDepthEffects ={
            name = "Depth Effects",
            -- rec = string.format("Recommended: |cFF00FF00%s|r", "Disabled"),
            desc = "Controls the rendering of depth-based particle effects.",
            type = "select",
            values = {
                ["0"] = "Disabled",
                ["1"] = "Low",
                ["2"] = "Good",
                ["3"] = "High",
            },
            width = "full",
            order = 5,
        },
        graphicsComputeEffects = {
            name = "Compute Effects",
            rec = string.format("Recommended: |cFF00FF00%s|r", "Disabled"),
            desc = "Controls the quality of Compute-based effects such as Volumetric Fog and some particle effects.",
            type = "select",
            values = {
                ["0"] = "Disabled",
                ["1"] = "Low",
                ["2"] = "Good",
                ["3"] = "High",
                ["4"] = "Ultra",
            },
            width = "full",
            order = 6,
        },
        graphicsOutlineMode ={
            name = "Outline Mode",
            -- rec = string.format("Recommended: |cFF00FF00%s|r", "Disabled"),
            desc = "Controls whether the selection outline effect is allowed.",
            type = "select",
            values = {
                ["0"] = "Disabled",
                ["1"] = "Good",
                ["2"] = "High",
            },
            width = "full",
            order = 7,
        },
        graphicsTextureResolution = {
            name = "Texture Resolution",
            -- rec = string.format("Recommended: |cFF00FF00%s|r", "Low"),
            desc = "Controls the level of all texture detail.",
            type = "select",
            values = {
                ["0"] = "Low",
                ["1"] = "Fair",
                ["2"] = "High",
            },
            width = "full",
            order = 8,
        },
        graphicsSpellDensity = {
            name = "Spell Density",
            -- rec = string.format("Recommended: |cFF00FF00%s|r", "Essential"),
            desc = "Controls visibility of non-essential spells.",
            type = "select",
            values = {
                ["0"] = "Essential",
                ["1"] = "Reduced",
                ["2"] = "Everything",
            },
            width = "full",
            order = 9,
        },
        graphicsProjectedTextures = {
            name = "Projected Textures",
            rec = string.format("Recommended: |cFF00FF00%s|r", "Enabled"),
            desc = "Enables the projecting of textures to the environment.",
            type = "select",
            values = {
                ["0"] = "Disabled",
                ["1"] = "Enabled",
            },
            width = "full",
            order = 10,
        },
        graphicsViewDistance = {
            name = "View Distance",
            -- rec = string.format("Recommended: |cFF00FF00%s|r", "1"),
            desc = "View distance controls how far you can see.",
            type = "range",
            min = 1,
            max = 10,
            step = 1,
            startingIndex = 0,
            width = "full",
            order = 11,
        },
        graphicsEnvironmentDetail = {
            name = "Environment Detail",
            -- rec = string.format("Recommended: |cFF00FF00%s|r", "1"),
            desc = "Controls how far you can see objects.",
            type = "range",
            min = 1,
            max = 10,
            step = 1,
            startingIndex = 0,
            width = "full",
            order = 12,
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

    for category, cvars in pairs(cvarTable) do
        for cvar, info in pairs(cvars) do
            if category == "general" and settings and settings.general and settings.general[cvar] and settings.general[cvar] ~= GetCVar(cvar) then
                SetCVar(cvar, settings.general[cvar])
            elseif category ~= "general" and settings and settings[instanceType] and settings[instanceType][cvar] and settings[instanceType][cvar] ~= GetCVar(cvar) then
                if settings.addon.pveOptions and (instanceType == "party" or instanceType == "raid") or not (instanceType == "party" or instanceType == "raid") then
                    SetCVar(cvar, settings[instanceType][cvar])
                end
            end
        end
    end

    self:ShowFramerate()
end

-- Display the framerate
function ArenaGameSettings:ShowFramerate()
    local showFR = self.db.global.general.showFramerate
    if showFR and FramerateFrame and FramerateFrame.Show and not FramerateFrame:IsShown() then
        FramerateFrame:Show()
    elseif not showFR and FramerateFrame and FramerateFrame.Hide and FramerateFrame:IsShown() then
        FramerateFrame:Hide()
    end
end

-- Open/close options panel
function ArenaGameSettings:OpenOptions()
    local openFrame = ACD.OpenFrames["ArenaGameSettings"]

    if openFrame and openFrame.frame and openFrame.frame:IsShown() then
        -- Close options panel if already open
        ACD:Close("ArenaGameSettings")
    else
        -- Open options panel
        ACD:Open("ArenaGameSettings")

        -- Set options panel frame settings
        local frame = ACD.OpenFrames["ArenaGameSettings"]
        frame.frame:SetClampedToScreen(true)
    end
end

-- Delete saved variables and restore defaults
function ArenaGameSettings:RestoreDefaults()
    StaticPopupDialogs["AGS_RESTORE_DEFAULTS"] = {
        text = "Are you sure you want to restore the default settings?\n\n|cffff0000WARNING:|r\n\nAll settings will be permanently lost.\nYour UI will be reloaded.",
        button1 = "Yes",
        button2 = "No",
        OnAccept = function()
            ArenaGameSettingsDB = nil
		    ReloadUI()
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = false,
    }

    local popup = StaticPopup_Show("AGS_RESTORE_DEFAULTS")
    popup:SetFrameStrata("TOOLTIP")
end

-- Handle ingame slash commands
function ArenaGameSettings:SlashCommand(input)
    input = input:lower()

    if input == "reset" then
        ArenaGameSettings:RestoreDefaults()
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

    for category, cvars in pairs(cvarTable) do
        if cvars[cvar] then -- Check if the updated CVar exists in cvarTable to prevent other CVars to be written to the database
            if category == "general" and settings and settings.general and settings.general[cvar] then
                settings.general[cvar] = value
            elseif category ~= "general" and settings and settings[instanceType] and settings[instanceType][cvar] then
                settings[instanceType][cvar] = value
            end
        end
    end
end

function ArenaGameSettings:OnInitialize()
    -- Set up saved variables
    self.db = LibStub("AceDB-3.0"):New("ArenaGameSettingsDB", {
        global = {
            addon = {
                -- Addon Settings
                minimap = {
                    hide = false,
                    minimapPos = 15,
                },
                pveOptions = false,
            },

            general = {
                -- General Settings
                showFramerate = true,
                AutoPushSpellToActionBar = GetCVar("AutoPushSpellToActionBar"),
                cameraDistanceMaxZoomFactor = "2.6",
                SpellQueueWindow = GetCVar("SpellQueueWindow"),
            },

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
                graphicsShadowQuality = "1",
                graphicsLiquidDetail = GetCVar("graphicsLiquidDetail"),
                graphicsParticleDensity = GetCVar("graphicsParticleDensity"),
                graphicsSSAO = GetCVar("graphicsSSAO"),
                graphicsDepthEffects = GetCVar("graphicsDepthEffects"),
                graphicsComputeEffects = "0",
                graphicsOutlineMode = GetCVar("graphicsOutlineMode"),
                graphicsTextureResolution = GetCVar("graphicsTextureResolution"),
                graphicsSpellDensity = GetCVar("graphicsSpellDensity"),
                graphicsProjectedTextures = "1",
                graphicsViewDistance = GetCVar("graphicsViewDistance"),
                graphicsEnvironmentDetail = GetCVar("graphicsEnvironmentDetail"),
            },

            pvp = {
                -- Audio Settings
                Sound_MasterVolume = GetCVar("Sound_MasterVolume"),
                Sound_MusicVolume = GetCVar("Sound_MusicVolume"),
                Sound_SFXVolume = GetCVar("Sound_SFXVolume"),
                Sound_AmbienceVolume = GetCVar("Sound_AmbienceVolume"),
                Sound_DialogVolume = GetCVar("Sound_DialogVolume"),
                Sound_GameplaySFX = GetCVar("Sound_GameplaySFX"),
                Sound_PingVolume = GetCVar("Sound_PingVolume"),

                -- Graphics Settings
                graphicsShadowQuality = GetCVar("graphicsShadowQuality"),
                graphicsLiquidDetail = GetCVar("graphicsLiquidDetail"),
                graphicsParticleDensity = GetCVar("graphicsParticleDensity"),
                graphicsSSAO = GetCVar("graphicsSSAO"),
                graphicsDepthEffects = GetCVar("graphicsDepthEffects"),
                graphicsComputeEffects = GetCVar("graphicsComputeEffects"),
                graphicsOutlineMode = GetCVar("graphicsOutlineMode"),
                graphicsTextureResolution = GetCVar("graphicsTextureResolution"),
                graphicsSpellDensity = GetCVar("graphicsSpellDensity"),
                graphicsProjectedTextures = GetCVar("graphicsProjectedTextures"),
                graphicsViewDistance = GetCVar("graphicsViewDistance"),
                graphicsEnvironmentDetail = GetCVar("graphicsEnvironmentDetail"),
            },

            none = {
                -- Audio Settings
                Sound_MasterVolume = GetCVar("Sound_MasterVolume"),
                Sound_MusicVolume = GetCVar("Sound_MusicVolume"),
                Sound_SFXVolume = GetCVar("Sound_SFXVolume"),
                Sound_AmbienceVolume = GetCVar("Sound_AmbienceVolume"),
                Sound_DialogVolume = GetCVar("Sound_DialogVolume"),
                Sound_GameplaySFX = GetCVar("Sound_GameplaySFX"),
                Sound_PingVolume = GetCVar("Sound_PingVolume"),

                -- Graphics Settings
                graphicsShadowQuality = GetCVar("graphicsShadowQuality"),
                graphicsLiquidDetail = GetCVar("graphicsLiquidDetail"),
                graphicsParticleDensity = GetCVar("graphicsParticleDensity"),
                graphicsSSAO = GetCVar("graphicsSSAO"),
                graphicsDepthEffects = GetCVar("graphicsDepthEffects"),
                graphicsComputeEffects = GetCVar("graphicsComputeEffects"),
                graphicsOutlineMode = GetCVar("graphicsOutlineMode"),
                graphicsTextureResolution = GetCVar("graphicsTextureResolution"),
                graphicsSpellDensity = GetCVar("graphicsSpellDensity"),
                graphicsProjectedTextures = GetCVar("graphicsProjectedTextures"),
                graphicsViewDistance = GetCVar("graphicsViewDistance"),
                graphicsEnvironmentDetail = GetCVar("graphicsEnvironmentDetail"),
            },

            party = {
                -- Audio Settings
                Sound_MasterVolume = GetCVar("Sound_MasterVolume"),
                Sound_MusicVolume = GetCVar("Sound_MusicVolume"),
                Sound_SFXVolume = GetCVar("Sound_SFXVolume"),
                Sound_AmbienceVolume = GetCVar("Sound_AmbienceVolume"),
                Sound_DialogVolume = GetCVar("Sound_DialogVolume"),
                Sound_GameplaySFX = GetCVar("Sound_GameplaySFX"),
                Sound_PingVolume = GetCVar("Sound_PingVolume"),

                -- Graphics Settings
                graphicsShadowQuality = GetCVar("graphicsShadowQuality"),
                graphicsLiquidDetail = GetCVar("graphicsLiquidDetail"),
                graphicsParticleDensity = GetCVar("graphicsParticleDensity"),
                graphicsSSAO = GetCVar("graphicsSSAO"),
                graphicsDepthEffects = GetCVar("graphicsDepthEffects"),
                graphicsComputeEffects = GetCVar("graphicsComputeEffects"),
                graphicsOutlineMode = GetCVar("graphicsOutlineMode"),
                graphicsTextureResolution = GetCVar("graphicsTextureResolution"),
                graphicsSpellDensity = GetCVar("graphicsSpellDensity"),
                graphicsProjectedTextures = GetCVar("graphicsProjectedTextures"),
                graphicsViewDistance = GetCVar("graphicsViewDistance"),
                graphicsEnvironmentDetail = GetCVar("graphicsEnvironmentDetail"),
            },

            raid = {
                -- Audio Settings
                Sound_MasterVolume = GetCVar("Sound_MasterVolume"),
                Sound_MusicVolume = GetCVar("Sound_MusicVolume"),
                Sound_SFXVolume = GetCVar("Sound_SFXVolume"),
                Sound_AmbienceVolume = GetCVar("Sound_AmbienceVolume"),
                Sound_DialogVolume = GetCVar("Sound_DialogVolume"),
                Sound_GameplaySFX = GetCVar("Sound_GameplaySFX"),
                Sound_PingVolume = GetCVar("Sound_PingVolume"),

                -- Graphics Settings
                graphicsShadowQuality = GetCVar("graphicsShadowQuality"),
                graphicsLiquidDetail = GetCVar("graphicsLiquidDetail"),
                graphicsParticleDensity = GetCVar("graphicsParticleDensity"),
                graphicsSSAO = GetCVar("graphicsSSAO"),
                graphicsDepthEffects = GetCVar("graphicsDepthEffects"),
                graphicsComputeEffects = GetCVar("graphicsComputeEffects"),
                graphicsOutlineMode = GetCVar("graphicsOutlineMode"),
                graphicsTextureResolution = GetCVar("graphicsTextureResolution"),
                graphicsSpellDensity = GetCVar("graphicsSpellDensity"),
                graphicsProjectedTextures = GetCVar("graphicsProjectedTextures"),
                graphicsViewDistance = GetCVar("graphicsViewDistance"),
                graphicsEnvironmentDetail = GetCVar("graphicsEnvironmentDetail"),
            },
        },
    })

    -- Create options panel
    self:SetupOptions()

    -- Minimap button
    LDBIcon:Register("ArenaGameSettings", minimapDataObject, self.db.global.addon.minimap)

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
                        width = "full",
                        order = 2,
                        get = function()
                            return not self.db.global.addon.minimap.hide
                        end,
                        set = function(_, value)
                            self.db.global.addon.minimap.hide = not value
                            if value then
                                LDBIcon:Show("ArenaGameSettings")
                            else
                                LDBIcon:Hide("ArenaGameSettings")
                            end
                        end,
                    },
                    pveOptions = {
                        type = "toggle",
                        name = "PVE Options",
                        desc = "Enable separate settings for PVE instances.",
                        width = "full",
                        order = 3,
                        get = function()
                            return self.db.global.addon.pveOptions
                        end,
                        set = function(_, value)
                            self.db.global.addon.pveOptions = value
                        end,
                    },
                    dangerZone = {
						type = "group",
						name = "|cffff0000Danger Zone|r",
						inline = true,
                        width = "full",
						order = 4,
						args = {
							restoreDefaults = {
								type = "execute",
								name = "Restore Defaults",
								desc = "Delete all saved variables from this addon and start with an empty database.",
								order = 1,
								func = function()
									ArenaGameSettings:RestoreDefaults()
								end,
							},
						}
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
                            return self.db.global.general.showFramerate
                        end,
                        set = function(_, value)
                            self.db.global.general.showFramerate = value
                            self:ShowFramerate()
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
                    pvp = {
                        type = "group",
                        name = "Battleground",
                        order = 2,
                        args = {
                            header1 = {
                                type = "header",
                                name = "Audio Settings",
                                order = 1,
                            },
                        },
                    },
                    none = {
                        type = "group",
                        name = "Outside",
                        order = 3,
                        args = {
                            header1 = {
                                type = "header",
                                name = "Audio Settings",
                                order = 1,
                            },
                        },
                    },
                    party = {
                        type = "group",
                        name = "Dungeon",
                        order = 4,
                        hidden = function()
                            return not self.db.global.addon.pveOptions
                        end,
                        args = {
                            header1 = {
                                type = "header",
                                name = "Audio Settings",
                                order = 1,
                            },
                        },
                    },
                    raid = {
                        type = "group",
                        name = "Raid",
                        order = 5,
                        hidden = function()
                            return not self.db.global.addon.pveOptions
                        end,
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
                    pvp = {
                        type = "group",
                        name = "Battleground",
                        order = 2,
                        args = {
                            header1 = {
                                type = "header",
                                name = "Graphics Settings",
                                order = 1,
                            },
                        },
                    },
                    none = {
                        type = "group",
                        name = "Outside",
                        order = 3,
                        args = {
                            header1 = {
                                type = "header",
                                name = "Graphics Settings",
                                order = 1,
                            },
                        },
                    },
                    party = {
                        type = "group",
                        name = "Dungeon",
                        order = 4,
                        hidden = function()
                            return not self.db.global.addon.pveOptions
                        end,
                        args = {
                            header1 = {
                                type = "header",
                                name = "Graphics Settings",
                                order = 1,
                            },
                        },
                    },
                    raid = {
                        type = "group",
                        name = "Raid",
                        order = 5,
                        hidden = function()
                            return not self.db.global.addon.pveOptions
                        end,
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

    -- General Settings
    for cvar, info in pairs(cvarTable.general) do

        -- Ranges
        if info.type == "range" then
            options.args.general.args[cvar] = {
                type = "range",
                name = info.name,
                desc = function()
                    local default = GetCVarDefault(cvar)

                    return string.format(
                        "Default Value: |cFFFF0000%s|r%s\n\n%s",
                        string.format(info.format or "%s", default),
                        info.rec and ("\n" .. info.rec) or "",
                        info.desc or ""
                    )
                end,
                min = info.min,
                max = info.max,
                step = info.step,
                width = info.width or "",
                order = 2 + info.order,
                get = function()
                    return tonumber(self.db.global.general[cvar])
                end,
                set = function(_, value)
                    self.db.global.general[cvar] = tostring(value)
                    self:UpdateSettings()
                end,
            }
        end

        -- Toggles
        if info.type == "toggle" then
            options.args.general.args[cvar] = {
                type = "toggle",
                name = info.name,
                desc = function()
                    local default = GetCVarDefault(cvar)

                    if info.desc then
                        return string.format(
                            "Default: |cFFFF0000%s|r%s\n\n%s",
                            info.states and info.states[default] or default,
                            info.rec and ("\n" .. info.rec) or "",
                            info.desc or ""
                        )
                    end
                end,
                width = info.width or "",
                order = 2 + info.order,
                get = function()
                        return self.db.global.general[cvar] == "1"
                end,
                set = function(_, value)
                    self.db.global.general[cvar] = value and "1" or "0"
                    self:UpdateSettings()
                end,
            }
        end
    end

    -- Audio Settings
    for group, _ in pairs(options.args.audio.args) do
        for cvar, info in pairs(cvarTable.audio) do

            -- Ranges
            if info.type == "range" then
                options.args.audio.args[group].args[cvar] = {
                    type = "range",
                    name = info.name,
                    desc = function()
                        local default = GetCVarDefault(cvar)

                        if group == "arena" and info.desc then
                            return string.format(
                                "Default Value: |cFFFF0000%s|r%s\n\n%s",
                                string.format(info.format or "%s", default),
                                info.rec and ("\n" .. info.rec) or "",
                                info.desc or ""
                            )
                        else
                            return string.format(
                                "Default Value: |cFFFF0000%s|r\n\n%s",
                                string.format(info.format or "%s", default),
                                info.desc or ""
                            )
                        end
                    end,
                    min = info.min,
                    max = info.max,
                    step = info.step,
                    width = info.width or "",
                    order = 1 + info.order,
                    get = function()
                        return tonumber(self.db.global[group][cvar])
                    end,
                    set = function(_, value)
                        self.db.global[group][cvar] = tostring(value)
                        self:UpdateSettings()
                    end,
                }
            end
        end
    end

    -- Graphics Settings
    for group, _ in pairs(options.args.graphics.args) do
        for cvar, info in pairs(cvarTable.graphics) do

            -- Ranges
            if info.type == "range" then
                options.args.graphics.args[group].args[cvar] = {
                    type = "range",
                    name = info.name,
                    desc = function()
                        local default = GetCVarDefault(cvar)

                        if group == "arena" and info.desc then
                            return string.format(
                                "Default Value: |cFFFF0000%s|r%s\n\n%s",
                                string.format(info.format or "%s", default + (info.startingIndex and 1)),
                                info.rec and ("\n" .. info.rec) or "",
                                info.desc or ""
                            )
                        else
                            return string.format(
                                "Default Value: |cFFFF0000%s|r\n\n%s",
                                string.format(info.format or "%s", default + (info.startingIndex and 1)),
                                info.desc or ""
                            )
                        end
                    end,
                    min = info.min,
                    max = info.max,
                    step = info.step,
                    width = info.width or "",
                    order = 1 + info.order,
                    get = function()
                        return tonumber(self.db.global[group][cvar] + (info.startingIndex and 1))
                    end,
                    set = function(_, value)
                        self.db.global[group][cvar] = tostring(value - (info.startingIndex and 1))
                        self:UpdateSettings()
                    end,
                }
            end

            -- Selects
            if info.type == "select" then
                options.args.graphics.args[group].args[cvar] = {
                    type = "select",
                    name = info.name,
                    desc = function ()
                        local default_value = GetCVarDefault(cvar)
                        local default_text = info.values[default_value]
                        if group == "arena" then
                            return string.format(
                                "Default: |cFFFF0000%s|r%s\n\n%s",
                                default_text,
                                info.rec and ("\n" .. info.rec) or "",
                                info.desc or ""
                            )
                        else
                            return string.format(
                                "Default: |cFFFF0000%s|r\n\n%s",
                                default_text,
                                info.desc or ""
                            )
                        end
                    end,
                    values = info.values,
                    width = info.width or "",
                    order = 1 + info.order,
                    get = function()
                        return self.db.global[group][cvar]
                    end,
                    set = function(_, value)
                        self.db.global[group][cvar] = value
                        self:UpdateSettings()
                    end,
                }
            end
        end
    end

    AC:RegisterOptionsTable("ArenaGameSettings", options)
    ACD:SetDefaultSize("ArenaGameSettings", 500, 600)
    ACD:AddToBlizOptions("ArenaGameSettings", "ArenaGameSettings")
end
