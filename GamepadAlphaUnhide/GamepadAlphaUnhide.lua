local addon = CreateFrame("Frame")
local attempted = false
local pending = false
local originalPoints

local function message(text)
    print("Gamepad Alpha Unhide: " .. text)
end

local function state(name, frame)
    if not frame then
        message(name .. " is unavailable")
        return
    end
    message(string.format("%s shown=%s visible=%s alpha=%.2f effective=%.2f",
        name, tostring(frame:IsShown()), tostring(frame:IsVisible()),
        frame:GetAlpha(), frame:GetEffectiveAlpha()))
end

local function position()
    local bar = _G.GamepadMainActionBarFrame
    if not bar then
        message("bar anchor unavailable")
        return
    end
    local point, relative, relativePoint, x, y = bar:GetPoint(1)
    local relativeName = relative and relative.GetName and relative:GetName() or relative
    message(string.format("bar anchor=%s to %s %s %+g,%+g",
        tostring(point), tostring(relativeName), tostring(relativePoint), x or 0, y or 0))
end

local function capturePoints(frame)
    local points = {}
    for index = 1, frame:GetNumPoints() do
        points[index] = { frame:GetPoint(index) }
    end
    return points
end

local function applyPoints(frame, points)
    frame:ClearAllPoints()
    for _, point in ipairs(points) do
        frame:SetPoint(unpack(point))
    end
end

local function centerBar()
    local bar = _G.GamepadMainActionBarFrame
    if not bar then
        message("Gamepad Action Bar has not loaded")
        return false
    end
    local prior = capturePoints(bar)
    local ok, err = pcall(function()
        bar:ClearAllPoints()
        bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 110)
    end)
    if not ok then
        pcall(applyPoints, bar, prior)
        message("position change failed: " .. tostring(err))
        return false
    end
    if not originalPoints then originalPoints = prior end
    position()
    return true
end

local function status()
    state("bar", _G.GamepadMainActionBarFrame)
    state("page", _G.GamepadMainActionBarFramePageUnit)
    position()
    message("character position override=" .. tostring(
        GamepadAlphaUnhideDB and GamepadAlphaUnhideDB.center or false))
end

local function restore()
    if GetCVar("InputDeviceInterfaceStyle") ~= "1" then
        message("Gamepad UI is disabled; no change made")
        return
    end
    if InCombatLockdown() then
        pending = true
        message("In combat; visibility check deferred until combat ends")
        return
    end

    local bar = _G.GamepadMainActionBarFrame
    if not bar then
        message("Gamepad Action Bar has not loaded")
        return
    end

    message("before")
    status()
    for _, entry in ipairs({ { "bar", bar },
                              { "page", _G.GamepadMainActionBarFramePageUnit } }) do
        local name, frame = entry[1], entry[2]
        if frame then
            if frame:GetAlpha() <= 0.01 then
                local ok, err = pcall(frame.SetAlpha, frame, 1)
                if not ok then message(name .. " alpha change failed: " .. tostring(err)) end
            end
            if not frame:IsShown() then
                local ok, err = pcall(frame.Show, frame)
                if not ok then message(name .. " show failed: " .. tostring(err)) end
            end
        end
    end
    if GamepadAlphaUnhideDB and GamepadAlphaUnhideDB.center then
        centerBar()
    end
    message("after")
    status()
end

local function center()
    if GetCVar("InputDeviceInterfaceStyle") ~= "1" then
        message("Gamepad UI is disabled; no change made")
        return
    end
    if InCombatLockdown() then
        message("In combat; retry /gpau center afterward")
        return
    end
    restore()
    if centerBar() then
        GamepadAlphaUnhideDB = GamepadAlphaUnhideDB or {}
        GamepadAlphaUnhideDB.center = true
        message("bottom-center position saved for this character")
    end
end

local function clear()
    if InCombatLockdown() then
        message("In combat; retry /gpau clear afterward")
        return
    end
    local bar = _G.GamepadMainActionBarFrame
    if bar and originalPoints then
        local currentPoints = capturePoints(bar)
        local ok, err = pcall(applyPoints, bar, originalPoints)
        if not ok then
            pcall(applyPoints, bar, currentPoints)
            message("anchor restore failed: " .. tostring(err))
            return
        end
    end
    if GamepadAlphaUnhideDB then GamepadAlphaUnhideDB.center = nil end
    originalPoints = nil
    message("character position override cleared")
    position()
end

addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:RegisterEvent("PLAYER_REGEN_ENABLED")
addon:RegisterEvent("ADDON_LOADED")
addon:SetScript("OnEvent", function(_, event, name)
    if event == "PLAYER_REGEN_ENABLED" then
        if pending then
            pending = false
            restore()
        end
    elseif not attempted and (event == "PLAYER_ENTERING_WORLD" or
                              (event == "ADDON_LOADED" and name == "Blizzard_GamepadActionBars")) then
        if _G.GamepadMainActionBarFrame then
            attempted = true
            restore()
        elseif event == "PLAYER_ENTERING_WORLD" then
            message("Gamepad Action Bar is unavailable at login; use /gpau show later")
        end
    end
end)

SLASH_GAMEPADALPHAUNHIDE1 = "/gpau"
SlashCmdList.GAMEPADALPHAUNHIDE = function(input)
    input = (input or ""):lower():match("^%s*(.-)%s*$")
    if input == "show" then
        restore()
    elseif input == "center" then
        center()
    elseif input == "clear" then
        clear()
    else
        status()
    end
end
