TeleportMenu = TeleportMenu or {}

-- local scrollable = true
local posX, posY = 450, 0

function HasExpansionDungeons(xpac)
    for _, expansions in ipairs(TeleportData["Pathways"]) do
        if expansions["Expansion"] == xpac then
            for _, dungeon in ipairs(expansions["Dungeons"]) do
                if C_Spell.DoesSpellExist(dungeon["Spell"]) then
                    return true
                end
            end
        end
    end
end

function HasExpansionRaids(xpac)
    for _, expansions in ipairs(TeleportData["Pathways"]) do
        if expansions["Expansion"] == xpac then
            for _, raid in ipairs(expansions["Raids"]) do
                if C_Spell.DoesSpellExist(raid["Spell"]) then
                    return true
                end
            end
        end
    end
end

function HasAnyDungeons()
    for _, expansion in ipairs(TeleportData["Pathways"]) do
        if expansion["Dungeons"] then
            for _, dungeon in ipairs(expansion["Dungeons"]) do
                if C_Spell.DoesSpellExist(dungeon["Spell"]) then
                    return true
                end
            end
        end
    end
end

function HasAnyRaids()
    for _, expansion in ipairs(TeleportData["Pathways"]) do
        if expansion["Raids"] then
            for _, raid in ipairs(expansion["Raids"]) do
                if C_Spell.DoesSpellExist(raid["Spell"]) then
                    return true
                end
            end
        end
    end
end

function HasCurrentSeasonDungeons()
    for _, dungeonName in ipairs(TeleportData["Current Season"]["Dungeons"]) do
        for _, expansions in ipairs(TeleportData["Pathways"]) do
            if expansions["Dungeons"] then
                for _, dungeon in ipairs(expansions["Dungeons"]) do
                    if dungeon["Name"] == dungeonName then
                        if C_Spell.DoesSpellExist(dungeon["Spell"]) then
                            return true
                        end
                    end
                end
            end
        end
    end
end

function HasCurrentSeasonRaids()
    for _, raidName in ipairs(TeleportData["Current Season"]["Raids"]) do
        for _, expansions in ipairs(TeleportData["Pathways"]) do
            if expansions["Raids"] then
                for _, raid in ipairs(expansions["Raids"]) do
                    if raid["Name"] == raidName then
                        if C_Spell.DoesSpellExist(raid["Spell"]) then
                            return true
                        end
                    end
                end
            end
        end
    end
end

function ExpansionHasRaids(category)
    for _, expansions in ipairs(TeleportData["Pathways"]) do
        if expansions["Expansion"] == category then
            if expansions["Raids"] then
                return true
            end
        end
    end
end

-- takes itemID or itemName
function HasItem(item)
    return C_Item.GetItemCount(item) > 0
end

function CreateSpellButton(menu, btnName, spellName)
    local btnFrame = menu:CreateTemplate("SecureActionButtonTemplate")
    btnFrame:AddInitializer(function(btn, desc, menu)
        btn:SetText(btnName)
        btn:GetFontString():SetPoint("LEFT", 0, 0)
        local width = btn:GetFontString():GetStringWidth() - 20
        local height = 20
        btn:SetSize(width, height)
        btn:SetNormalFontObject("GameFontNormal")
        btn:SetHighlightFontObject("GameFontHighlight")
        -- btn:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
        -- btn:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
        -- btn:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
        -- btn:SetDisabledTexture("Interface/Buttons/UI-Panel-Button-Disabled")
        btn:SetAttribute("type", "macro")
        btn:SetAttribute("macrotext", "/cast " .. spellName)
        btn:RegisterForClicks("AnyUp", "AnyDown")
    end)
end

local Dropdown = CreateFrame("DropdownButton", nil, UIParent, "WowStyle1DropdownTemplate")
Dropdown:SetDefaultText("Teleports")
Dropdown:SetPoint("BOTTOMLEFT", posX, posY)
Dropdown:SetMovable(true)
Dropdown:EnableMouse(true)
Dropdown:RegisterForDrag("LeftButton")
Dropdown:SetScript("OnDragStart", Dropdown.StartMoving)
Dropdown:SetScript("OnDragStop", Dropdown.StopMovingOrSizing)
Dropdown:SetClampedToScreen(true)

-- on Dropdown mouseover, hide any current tooltips
Dropdown:SetScript("OnEnter", function(self)
    GameTooltip:Hide()
end)

Dropdown:SetupMenu(function(dropdown, rootDescription)
    ----- HEARTHSTONE -----
    CreateSpellButton(rootDescription, "Hearthstone", "Greatfather Winter's Hearthstone")
    CreateSpellButton(rootDescription, "Stone Hearth", "Stone of the Hearth")

    ----- DUNGEONS -----
    if HasAnyDungeons() then
        local dungeons = rootDescription:CreateButton("Dungeons")

        if HasCurrentSeasonDungeons() then
            local current = dungeons:CreateButton("Current Season")
            for _, dungeonName in ipairs(TeleportData["Current Season"]["Dungeons"]) do
                for _, expansions in ipairs(TeleportData["Pathways"]) do
                    if expansions["Dungeons"] then
                        for _, dungeon in ipairs(expansions["Dungeons"]) do
                            if dungeon["Name"] == dungeonName then
                                if C_Spell.DoesSpellExist(dungeon["Spell"]) then
                                    CreateSpellButton(current, dungeon["Name"], dungeon["Spell"])
                                end
                            end
                        end
                    end
                end
            end
            dungeons:CreateDivider()
        end

        for _, expansions in ipairs(TeleportData["Pathways"]) do
            if expansions["Dungeons"] then
                if HasExpansionDungeons(expansions["Expansion"]) then
                    local xpac = dungeons:CreateButton(expansions["Expansion"])
                    for _, dungeon in ipairs(expansions["Dungeons"]) do
                        if C_Spell.DoesSpellExist(dungeon["Spell"]) then
                            CreateSpellButton(xpac, dungeon["Name"], dungeon["Spell"])
                        end
                    end
                end
            end
        end
    end

    ----- RAIDS -----
    if HasAnyRaids() then
        local raids = rootDescription:CreateButton("Raids")
        if HasCurrentSeasonRaids() then
            local current = raids:CreateButton("Current Season")
            for _, raidName in ipairs(TeleportData["Current Season"]["Raids"]) do
                for _, expansions in ipairs(TeleportData["Pathways"]) do
                    if expansions["Raids"] then
                        for _, raid in ipairs(expansions["Raids"]) do
                            if raid["Name"] == raidName then
                                if C_Spell.DoesSpellExist(raid["Spell"]) then
                                    CreateSpellButton(current, raid["Name"], raid["Spell"])
                                end
                            end
                        end
                    end
                end
            end
            raids:CreateDivider()
        end

        for _, expansions in ipairs(TeleportData["Pathways"]) do
            if expansions["Raids"] then
                if HasExpansionRaids(expansions["Expansion"]) then
                    local xpac = raids:CreateButton(expansions["Expansion"])
                    for _, raid in ipairs(expansions["Raids"]) do
                        if C_Spell.DoesSpellExist(raid["Spell"]) then
                            CreateSpellButton(xpac, raid["Name"], raid["Spell"])
                        end
                    end
                end
            end
        end
    end

    ----- OTHER -----
    local other = rootDescription:CreateButton("Other")
    CreateSpellButton(other, "Garrison", "Garrison Hearthstone")
    CreateSpellButton(other, "Dalaran", "Dalaran Hearthstone")
    CreateSpellButton(other, "Blackrock Depths", "Direbrew's Remote")
    CreateSpellButton(other, "Stormsong Valley", "Lucky Tortollan Charm")
end)

function TeleportMenuMiniButtonClick()
    print("Mini button")
end
