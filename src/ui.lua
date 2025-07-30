local _, ns = ...

-- UI module
ns.ui = {}

-- Auto-close functionality for copy dialog
local function SetupAutoClose(editBox, frame)
    if not ns.config.AUTO_CLOSE_DIALOG then
        return
    end

    -- Handle Ctrl+C detection and auto-close
    local function HandleCtrlC(_, key)
        if key == "C" and IsControlKeyDown() then
            -- Always ensure text is selected when Ctrl+C is pressed
            editBox:HighlightText()
            editBox:SetFocus()
            ns.utils.DebugPrint("Detected Ctrl+C combination - ensured text is selected")

            -- Small delay to ensure copy operation completes before closing
            C_Timer.After(0.1, function()
                if frame:IsShown() then
                    frame:Hide()
                    ns.utils.DebugPrint("Auto-closed dialog after Ctrl+C")
                end
            end)
        end
    end

    -- Set up keyboard event detection
    editBox:SetScript("OnKeyDown", HandleCtrlC)
    editBox:EnableKeyboard(true)
    editBox:SetScript("OnShow", function(self)
        self:SetFocus()
    end)
end

-- Get instruction text based on auto-close setting
local function GetInstructionText()
    if ns.config.AUTO_CLOSE_DIALOG then
        return "Press Ctrl+C to copy (auto-closes)"
    else
        return "Press Ctrl+C to copy, then press Enter or Escape to close"
    end
end

-- Show copy URL dialog
function ns.ui.ShowCopyURLDialog(text, providerName)
    if not text then return end

    local title = ns.config.DIALOG_TITLE
    if providerName then
        title = title .. " - " .. providerName
    end

    -- Create a simple frame to display the text
    local frame = CreateFrame("Frame", "PvPProfileCopyFrame", UIParent, "BasicFrameTemplateWithInset")
    frame:SetSize(500, 150)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

    -- Set high frame strata to appear above LFG windows
    frame:SetFrameStrata(ns.config.FRAME_STRATA)
    frame:SetFrameLevel(ns.config.FRAME_LEVEL)

    frame.title = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    frame.title:SetPoint("TOP", frame.TitleBg, "TOP", 0, -5)
    frame.title:SetText(title)

    local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
    editBox:SetSize(460, 30)
    editBox:SetPoint("CENTER", frame, "CENTER", 0, 10)
    editBox:SetText(text)
    editBox:SetAutoFocus(true)
    editBox:HighlightText()
    editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
    editBox:SetScript("OnEnterPressed", function() frame:Hide() end)

    -- Set up auto-close functionality (if enabled)
    SetupAutoClose(editBox, frame)

    local instruction = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    instruction:SetPoint("BOTTOM", frame, "BOTTOM", 0, 20)
    instruction:SetText(GetInstructionText())

    frame:Show()
end