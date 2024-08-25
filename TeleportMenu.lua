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

function HasAnyOther()
    local hasTypes = {
        ["Items"] = false,
        ["Equips"] = false,
        ["Toys"] = false
    }

    for typ, data in pairs(TeleportData["Other"]) do
        for _, item in ipairs(data) do
            if typ == "Items" or typ == "Equips" then
                if HasItem(item["Name"]) then
                    if typ == "Items" then
                        hasTypes["Items"] = true
                    elseif typ == "Equips" then
                        hasTypes["Equips"] = true
                    end
                end
            elseif typ == "Toys" then
                if HasToy(item["ItemID"]) then
                    hasTypes["Toys"] = true
                end
            end
        end
    end

    return hasTypes
end

function HasAnyEngineering()
    return true
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

-- seems to take spell ID or name
function HasSpell(spell)
    return C_Spell.DoesSpellExist(spell)
end

-- take item id
function HasToy(itemID)
    return PlayerHasToy(itemID)
end

function GetHearthstone()
    if (HasItem(TeleportData["Hearthstones"]["Hearthstone"])) then
        return "Hearthstone"
    else
        for name, id in pairs(TeleportData["Hearthstones"]) do
            if (PlayerHasToy(id)) then
                return name
            end
        end
    end

    return "No Stone Found"
end

function GetItemCooldown(itemID)
    local start, duration, enable = C_Item.GetItemCooldown(itemID)

    if enable then
        local remaining = duration - (GetTime() - start)
        remaining = math.floor(remaining + 0.5)
        return remaining
    end

    return 0
end

function GetSpellCooldown(spell)
    --
end

function ConvertSecondsToString(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local seconds = math.floor(seconds % 60)

    local timeString = ""

    if hours > 0 then
        timeString = timeString .. hours .. "h "
    end

    if minutes > 0 then
        timeString = timeString .. minutes .. "m "
    end

    if seconds > 0 then
        timeString = timeString .. seconds .. "s"
    end

    return timeString
end

function CreateTeleButton(menu, btnType, btnName, spellName)
    local btnFrame = menu:CreateTemplate("SecureActionButtonTemplate")
    btnFrame:AddInitializer(function(btn, desc, menu)
        btn:SetText(btnName)
        btn:GetFontString():SetPoint("LEFT", 0, 0)
        btn:SetNormalFontObject("GameFontNormal")
        btn:SetHighlightFontObject("GameFontHighlight")

        local cooldown = 0
        if btnType ~= "Spell" then
            cooldown = GetItemCooldown(spellName)
        end

        if cooldown > 0 then
            btn:SetText(btnName .. " (" .. ConvertSecondsToString(cooldown) .. ")")
            btn:GetFontString():SetTextColor(0.5, 0.5, 0.5)
        else
            -- set default bronze color
            btn:GetFontString():SetTextColor(1, 0.82, 0)
        end

        -- btn:SetNormalTexture("Interface/Buttons/UI-Panel-Button-Up")
        -- btn:SetHighlightTexture("Interface/Buttons/UI-Panel-Button-Highlight")
        -- btn:SetPushedTexture("Interface/Buttons/UI-Panel-Button-Down")
        -- btn:SetDisabledTexture("Interface/Buttons/UI-Panel-Button-Disabled")

        btn:SetAttribute("type", "macro")
        btn:SetAttribute("macrotext", "/cast " .. spellName)
        btn:RegisterForClicks("AnyUp", "AnyDown")
        local width = btn:GetFontString():GetStringWidth() - 20
        local height = 20
        btn:SetSize(width, height)
    end)
end

function CreateHearthstoneButton(menu)
    local hearthstone = GetHearthstone()
    if (hearthstone == "No Stone Found") then return end
    local cooldown = GetItemCooldown(hearthstone)

    local btnFrame = menu:CreateTemplate("SecureActionButtonTemplate")
    btnFrame:AddInitializer(function(btn, desc, menu)
        btn:SetText("Hearthstone")
        btn:GetFontString():SetPoint("LEFT", 0, 0)
        btn:SetNormalFontObject("GameFontNormal")
        btn:SetHighlightFontObject("GameFontHighlight")

        if cooldown > 0 then
            btn:SetText("Hearthstone (" .. ConvertSecondsToString(cooldown) .. ")")
            btn:GetFontString():SetTextColor(0.5, 0.5, 0.5)
        else
            -- set default bronze color
            btn:GetFontString():SetTextColor(1, 0.82, 0)
        end

        btn:SetAttribute("type", "macro")
        btn:SetAttribute("macrotext", "/cast " .. hearthstone)
        btn:RegisterForClicks("AnyUp", "AnyDown")
        local width = btn:GetFontString():GetStringWidth() - 20
        local height = 20
        btn:SetSize(width, height)
    end)
end

function BuildMenu(dropdown, rootDescription)
    ----- TEST FUNCTIONS -----
    GetItemCooldown(140192)

    ----- HEARTHSTONE -----
    CreateHearthstoneButton(rootDescription)
    if (PlayerHasToy(212337)) then CreateTeleButton(rootDescription, "Spell", "Stone Hearth", "Stone of the Hearth") end

    if HasAnyDungeons() or HasAnyRaids() then
        rootDescription:CreateDivider()
    end

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
                                    CreateTeleButton(current, "Spell", dungeon["Name"], dungeon["Spell"])
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
                            CreateTeleButton(xpac, "Spell", dungeon["Name"], dungeon["Spell"])
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
                                    CreateTeleButton(current, "Spell", raid["Name"], raid["Spell"])
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
                            CreateTeleButton(xpac, "Spell", raid["Name"], raid["Spell"])
                        end
                    end
                end
            end
        end
    end

    ----- OTHER -----
    local hasOtherTypes = HasAnyOther()
    local hasAnyOtherType = false
    local numOtherTypes = 0

    for _, val in pairs(hasOtherTypes) do
        if val then
            hasAnyOtherType = true
            numOtherTypes = numOtherTypes + 1
        end
    end

    if hasAnyOtherType then
        rootDescription:CreateDivider()
        local other = rootDescription:CreateButton("Other")

        for typ, data in pairs(TeleportData["Other"]) do
            for _, item in ipairs(data) do
                if hasOtherTypes[typ] then
                    if HasItem(item["ItemID"]) or HasToy(item["ItemID"]) then
                        CreateTeleButton(other, typ, item["Location"], item["Name"])
                    end
                end
            end

            if numOtherTypes > 1 then
                other:CreateDivider()
                numOtherTypes = numOtherTypes - 1
            end
        end
    end

    ----- MAGE -----
    if (UnitClass("player") == "Mage") then
        rootDescription:CreateDivider()
        local teleports = rootDescription:CreateButton("Teleports")
        local portals = rootDescription:CreateButton("Portals")

        for _, spell in ipairs(TeleportData["ClassPorts"]["Mage"]["Teleports"]) do
            if (HasSpell(spell["Spell"])) then
                CreateTeleButton(teleports, "Spell", spell["Location"], spell["Spell"])
            end
        end

        for _, spell in ipairs(TeleportData["ClassPorts"]["Mage"]["Portals"]) do
            if (HasSpell(spell["Spell"])) then
                CreateTeleButton(portals, "Spell", spell["Location"], spell["Spell"])
            end
        end
    end

    ----- ENGINEERING -----
    if (HasSpell("Engineering") and HasAnyEngineering()) then
        -- we want to make sure the player has at least 1 teleport toy and meets its requirements to use before displaying divider/button
        -- GetProfessions() - returns spell tab indices of current professions
        -- GetProfessionInfo(index) - returns profession details: name, icon, skillLevel, ...
        rootDescription:CreateDivider()
        local engineering = rootDescription:CreateButton("Engineering")

        for skill, toy in ipairs(TeleportData["Engineering"]) do
            if (HasSpell(skill)) then
                -- TODO: get player's skill level and check if it's >= SkillReq
            end
        end
    end
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

Dropdown:SetupMenu(BuildMenu)



-- function TeleportMenuMiniButtonClick(data)
--     print("Mini button")
-- end
