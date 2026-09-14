local GGH = {}
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalizationService = game:GetService("LocalizationService")

local function GetGuiParent()
    local ok, hui = pcall(function() return gethui() end)
    if ok and hui then return hui end
    return CoreGui
end


    local function MakeTranslatable(textObj)
        if textObj:IsA("TextLabel") or textObj:IsA("TextButton") or textObj:IsA("TextBox") then
            textObj.AutoLocalize = true
            pcall(function() textObj.RichText = false end)
        end
        return textObj
    end


    local function Corner(p,r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 8)
    c.Parent = p
    return c
end

local function Stroke(p,color,thick)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(40,40,50)
    s.Thickness = thick or 1
    s.Parent = p
    return s
end

local function AddTextStroke(txtObj)
    if not txtObj then return end
    local st = Instance.new("UIStroke", txtObj)
    st.Color = Color3.fromRGB(0,0,0)
    st.Thickness = 1.1
    st.Transparency = 0.4
    st.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
    st.LineJoinMode = Enum.LineJoinMode.Round
    return st
end

local function AddBlackBorder(frame, thick, trans)
    if not frame then return end
    local s = Instance.new("UIStroke", frame)
    s.Color = Color3.fromRGB(0,0,0)
    s.Thickness = thick or 1
    s.Transparency = trans or 0.6
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end


local function Tween(o,props,dur)
    TweenService:Create(o, TweenInfo.new(dur or 0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), props):Play()
end

-- ===== نظام منع الخروج من الشاشة - نفس طريقة الزر العائم =====
local function ClampFrameToScreen(frame, gui)
    if not frame or not gui then return end
    local viewport = gui.AbsoluteSize
    if viewport.X <= 10 or viewport.Y <= 10 then return end
    local fSize = frame.AbsoluteSize
    if fSize.X <= 0 then return end
    local fPos = frame.Position
    local newX, newY
    if fPos.X.Scale == 0 and fPos.Y.Scale == 0 then
        newX = math.clamp(fPos.X.Offset, 0, viewport.X - fSize.X)
        newY = math.clamp(fPos.Y.Offset, 0, viewport.Y - fSize.Y)
        frame.Position = UDim2.fromOffset(newX, newY)
    else
        -- للـ Scale نحول لـ Offset مع Clamp
        local absX = fPos.X.Scale * viewport.X + fPos.X.Offset
        local absY = fPos.Y.Scale * viewport.Y + fPos.Y.Offset
        absX = math.clamp(absX, 0, viewport.X - fSize.X)
        absY = math.clamp(absY, 0, viewport.Y - fSize.Y)
        frame.Position = UDim2.fromOffset(absX, absY)
    end
end

local function GetSafePickerPosition(anchorBtn, pickerSize, screenGui)
    local vp = screenGui.AbsoluteSize
    local btnPos = anchorBtn.AbsolutePosition
    local btnSize = anchorBtn.AbsoluteSize
    local pW, pH = pickerSize.X, pickerSize.Y
    local x = btnPos.X + btnSize.X + 10
    local y = btnPos.Y
    if x + pW > vp.X - 5 then x = btnPos.X - pW - 10 end
    if y + pH > vp.Y - 5 then y = vp.Y - pH - 10 end
    x = math.clamp(x, 5, vp.X - pW - 5)
    y = math.clamp(y, 5, vp.Y - pH - 5)
    return UDim2.fromOffset(x, y)
end

return {
    GetGuiParent = GetGuiParent,
    MakeTranslatable = MakeTranslatable,
    Corner = Corner,
    Stroke = Stroke,
    AddTextStroke = AddTextStroke,
    AddBlackBorder = AddBlackBorder,
    Tween = Tween,
    ClampFrameToScreen = ClampFrameToScreen,
    GetSafePickerPosition = GetSafePickerPosition,
    TweenService = TweenService,
    UserInputService = UserInputService,
    CoreGui = CoreGui,
    GGH = GGH
}
