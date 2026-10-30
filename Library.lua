--!nocheck
--[[
    GGH - standalone Roblox (Luau) UI library
    Author: AM_BRCR7
    Usage:
        local Library = loadstring(game:HttpGet("<raw Library.lua URL>"))()
        local Window  = Library:CreateWindow({ Title = "My Script" })

    No external downloads are performed at runtime. Optional executor
    functions (writefile / getcustomasset / gethui) are used when present
    and every code path degrades gracefully when they are not.
]]

local Nova
do
    local success, localization2 = pcall(function()
        local function isActive()
            local localization2 = {
                Version = "1.0.0",
                Windows = {},
                Conns = {},
                tr = function(argument)
                    return argument
                end,
                trace = function(argument)
                    local success, result = pcall(getgenv)
                    if success then
                        if result then
                            if result.GGH_TRACE then
                                if appendfile then
                                    pcall(
                                        appendfile,
                                        "GGH/ggh_trace.txt",
                                        string.format("%.3f %s\n", os.clock(), tostring(argument))
                                    )
                                end
                            end
                        end
                    end
                end,
            }
            local players, tweenService = game:GetService("Players"), game:GetService("TweenService")
            local userInputService = game:GetService("UserInputService")
            local runService, textService = game:GetService("RunService"), game:GetService("TextService")
            local httpService, lighting, localPlayer =
                game:GetService("HttpService"), game:GetService("Lighting"), players.LocalPlayer
            localization2.Services = {
                Players = players,
                TweenService = tweenService,
                UserInputService = userInputService,
                RunService = runService,
                TextService = textService,
                HttpService = httpService,
                Lighting = lighting,
            }
            do
                local u = {}
                localization2.U = u
                local entries, entries2 = {}, {}
                u.newReg = function()
                    local entries3 = {}
                    table.insert(entries, entries3)
                    return entries3
                end
                local function handleAction(argument, argument2)
                    local parent = argument.Parent
                    if parent == nil then
                        return false
                    end
                    local entry = argument2[parent]
                    if entry == nil then
                        entry = argument:FindFirstAncestorWhichIsA("ScreenGui") ~= nil
                        argument2[parent] = entry
                    else
                    end
                    return entry
                end
                u.sweep = function()
                    local entries3 = {}
                    for unused, item in ipairs(entries) do
                        for key in pairs(item) do
                            entries3[#entries3 + 1] = key
                            entries3[#entries3 + 1] = item
                        end
                    end
                    local entries4, now = {}, (os.clock())
                    for index = 1, #entries3, 2 do
                        local entry, entry2 = entries3[index], entries3[index + 1]
                        if entry2[entry] ~= nil then
                            local success, result = pcall(handleAction, entry, entries4)
                            if success and result then
                                entries2[entry] = nil
                            elseif entries2[entry] then
                                entry2[entry] = nil
                                entries2[entry] = nil
                            else
                                entries2[entry] = true
                            end
                        end
                        if os.clock() - now > 0.001 then
                            task.wait()
                            now = os.clock()
                            entries4 = {}
                        else
                        end
                    end
                end
                u.regCount = function()
                    local counter = 0
                    for unused, item in ipairs(entries) do
                        for unused in pairs(item) do
                            counter += 1
                        end
                    end
                    return counter
                end
                u.startSweep = function()
                    if u.sweeping then
                        return
                    end
                    u.sweeping = true
                    task.spawn(function()
                        while true do
                            task.wait(15)
                            local enabled = false
                            for unused, item in ipairs(localization2.Windows) do
                                enabled = if item.Destroyed then enabled else true
                            end
                            u.sweep()
                            if not enabled then
                                u.sweeping = false
                                return
                            end
                        end
                    end)
                end
                u.textReg = u.newReg()
                u.cornerReg = u.newReg()
                u.radiusMult = 1
                u.textScale = 1
                local entries3 = { TextLabel = true, TextButton = true, TextBox = true }
                u.new = function(argument, fontFace, size)
                    local parent = Instance.new(argument)
                    local parent2
                    for key, item in pairs(fontFace or {}) do
                        if key == "Parent" then
                            parent2 = item
                        else
                            parent[key] = item
                        end
                    end
                    for unused, item in ipairs(size or {}) do
                        item.Parent = parent
                    end
                    if entries3[argument] then
                        fontFace, size = parent.FontFace, parent.TextSize
                        u.textReg[parent] = { weight = fontFace.Weight, style = fontFace.Style, size = size }
                        if u.textScale ~= 1 then
                            parent.TextSize = math.max(8, math.floor(size * u.textScale + 0.5))
                        end
                    elseif argument == "UICorner" then
                        local cornerRadius = parent.CornerRadius
                        u.cornerReg[parent] = cornerRadius
                        if u.radiusMult ~= 1 then
                            if cornerRadius.Scale == 0 then
                                parent.CornerRadius =
                                    UDim.new(0, math.floor(cornerRadius.Offset * u.radiusMult + 0.5))
                            end
                        end
                    end
                    if parent2 then
                        parent.Parent = parent2
                    end
                    return parent
                end
                u.setTextSize = function(argument, size)
                    local entry = u.textReg[argument]
                    if entry then
                        entry.size = size
                    end
                    argument.TextSize = math.max(8, math.floor(size * u.textScale + 0.5))
                end
                u.corner = function(parent, argument)
                    return u.new(
                        "UICorner",
                        {
                            CornerRadius = typeof(argument) == "UDim" and argument or UDim.new(0, argument or 8),
                            Parent = parent,
                        }
                    )
                end
                u.radiusOne = function(argument)
                    local entry = u.cornerReg[argument]
                    if entry then
                        if entry.Scale == 0 then
                            argument.CornerRadius = UDim.new(0, math.floor(entry.Offset * u.radiusMult + 0.5))
                        end
                    end
                end
                u.setRadius = function(argument)
                    u.radiusMult = math.clamp(argument, 0, 2)
                    localization2.Refresh.run("radius", u.radiusOne, function()
                        for key in pairs(u.cornerReg) do
                            if key.Parent then
                                u.radiusOne(key)
                            end
                        end
                    end)
                end
                u.stroke = function(parent, argument, argument2, argument3, argument4)
                    return u.new(
                        "UIStroke",
                        {
                            Color = argument or Color3.new(1, 1, 1),
                            Thickness = argument2 or 1,
                            Transparency = argument3 or 0,
                            ApplyStrokeMode = argument4 or Enum.ApplyStrokeMode.Border,
                            Parent = parent,
                        }
                    )
                end
                u.pad = function(parent, argument, argument2, argument3, argument4)
                    return u.new(
                        "UIPadding",
                        {
                            PaddingTop = UDim.new(0, argument or 0),
                            PaddingRight = UDim.new(0, argument2 or argument or 0),
                            PaddingBottom = UDim.new(0, argument3 or argument or 0),
                            PaddingLeft = UDim.new(0, argument4 or argument2 or argument or 0),
                            Parent = parent,
                        }
                    )
                end
                u.list = function(parent, argument, argument2, argument3, argument4)
                    return u.new(
                        "UIListLayout",
                        {
                            Padding = UDim.new(0, argument or 0),
                            FillDirection = argument2 or Enum.FillDirection.Vertical,
                            HorizontalAlignment = argument3 or Enum.HorizontalAlignment.Left,
                            VerticalAlignment = argument4 or Enum.VerticalAlignment.Top,
                            SortOrder = Enum.SortOrder.LayoutOrder,
                            Parent = parent,
                        }
                    )
                end
                u.shadow = function(parent, argument, argument2, argument3, argument4)
                    local success, result = pcall(function()
                        return u.new(
                            "UIShadow",
                            {
                                Color = Color3.new(0, 0, 0),
                                Transparency = argument or 0.5,
                                BlurRadius = UDim.new(0, argument2 or 12),
                                Offset = UDim2.fromOffset(0, argument3 or 2),
                                Spread = UDim2.fromOffset(argument4 or 0, argument4 or 0),
                                Parent = parent,
                            }
                        )
                    end)
                    return success and result or nil
                end
                u.clamp = function(argument, argument2, argument3)
                    if argument < argument2 then
                        return argument2
                    end
                    if argument > argument3 then
                        return argument3
                    end
                    return argument
                end
                u.round = function(argument, argument2)
                    local calculatedValue = 10 ^ (argument2 or 0)
                    return math.floor(argument * calculatedValue + 0.5) / calculatedValue
                end
                u.fmt = function(argument, calculatedValue)
                    calculatedValue = calculatedValue or 0
                    if calculatedValue <= 0 then
                        return tostring(math.floor(argument + 0.5))
                    end
                    return string.format("%." .. calculatedValue .. "f", argument)
                end
                u.textWidth = function(argument, font, size)
                    local success, result = pcall(function()
                        local getTextBoundsParams = Instance.new("GetTextBoundsParams")
                        getTextBoundsParams.Text = tostring(argument)
                        getTextBoundsParams.Font = font
                        getTextBoundsParams.Size = size
                        getTextBoundsParams.Width = 10000
                        return textService:GetTextBoundsAsync(getTextBoundsParams)
                    end)
                    if success then
                        if result then
                            return result.X
                        end
                    end
                    return #tostring(argument) * size * 0.5
                end
                u.connect = function(signal, argument, argument2)
                    local connection = signal:Connect(argument)
                    table.insert(argument2 or localization2.Conns, connection)
                    return connection
                end
                u.hostGui = function()
                    local coreGui
                    pcall(function()
                        if gethui then
                            coreGui = gethui()
                        end
                    end)
                    if typeof(coreGui) ~= "Instance" then
                        pcall(function()
                            coreGui = game:GetService("CoreGui")
                        end)
                        local success = pcall(function()
                            local folder = Instance.new("Folder")
                            folder.Parent = coreGui
                            folder:Destroy()
                        end)
                        if success then
                        else
                            coreGui = nil
                        end
                    else
                    end
                    if typeof(coreGui) ~= "Instance" then
                        coreGui = localPlayer:WaitForChild("PlayerGui")
                    else
                    end
                    return coreGui
                end
                u.protect = function(argument)
                    pcall(function()
                        if syn then
                            if syn.protect_gui then
                                syn.protect_gui(argument)
                            end
                        end
                    end)
                    pcall(function()
                        if protectgui then
                            protectgui(argument)
                        end
                    end)
                end
                u.lighten = function(argument, argument2)
                    local toHSVResult, toHSVResult2, toHSVResult3 = argument:ToHSV()
                    return Color3.fromHSV(
                        toHSVResult,
                        math.max(0, toHSVResult2 - argument2 * 0.35),
                        math.min(1, toHSVResult3 + argument2)
                    )
                end
                u.darken = function(argument, argument2)
                    local toHSVResult, toHSVResult2, toHSVResult3 = argument:ToHSV()
                    return Color3.fromHSV(toHSVResult, toHSVResult2, math.max(0, toHSVResult3 - argument2))
                end
                u.mouse = function()
                    return userInputService:GetMouseLocation() - game:GetService("GuiService"):GetGuiInset()
                end
                u.leave = function(userInputService2, argument)
                    local connection = userInputService2.MouseLeave:Connect(argument)
                    local function handleAction2(argument2)
                        if argument2.UserInputType == Enum.UserInputType.Touch then
                            task.delay(0.12, argument)
                        end
                    end
                    userInputService2.InputEnded:Connect(handleAction2)
                    return connection
                end
                u.isClick = function(argument)
                    return argument.UserInputType == Enum.UserInputType.MouseButton1
                        or argument.UserInputType == Enum.UserInputType.Touch
                end
                u.isMove = function(argument)
                    return argument.UserInputType == Enum.UserInputType.MouseMovement
                        or argument.UserInputType == Enum.UserInputType.Touch
                end
                u.sameMove = function(argument, argument2)
                    if argument2 then
                        if argument2.UserInputType == Enum.UserInputType.Touch then
                            return argument == argument2
                        end
                    end
                    if argument2 then
                        return argument.UserInputType == Enum.UserInputType.MouseMovement
                    end
                    return u.isMove(argument)
                end
                u.sameEnd = function(argument, argument2)
                    if argument2 then
                        if argument2.UserInputType == Enum.UserInputType.Touch then
                            return argument == argument2
                        end
                    end
                    return u.isClick(argument)
                end
                u.at = function(argument)
                    if argument then
                        if argument.UserInputType == Enum.UserInputType.Touch then
                            return Vector2.new(argument.Position.X, argument.Position.Y)
                        end
                    end
                    return u.mouse()
                end
            end
            do
                local motion = {}
                localization2.Motion = motion
                local u = localization2.U
                motion.Presets = {
                    Quick = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    Base = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    Slow = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                    Pop = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                    PopSmall = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                    Exit = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In),
                    Linear = TweenInfo.new(0.2, Enum.EasingStyle.Linear),
                    Spin = TweenInfo.new(1.2, Enum.EasingStyle.Quint, Enum.EasingDirection.InOut, -1),
                }
                motion.enabled = true
                motion.tween = function(argument, argument2, argument3)
                    if typeof(argument) ~= "Instance" then
                        return nil
                    end
                    argument2 = if type(argument2) == "string"
                        then motion.Presets[argument2] or motion.Presets.Base
                        else argument2
                    if not motion.enabled then
                        for key, item in pairs(argument3) do
                            pcall(function()
                                argument[key] = item
                            end)
                        end
                        return nil
                    end
                    local success, result = pcall(tweenService.Create, tweenService, argument, argument2, argument3)
                    if success then
                        if result then
                            result:Play()
                            return result
                        end
                    end
                    for key, item in pairs(argument3) do
                        pcall(function()
                            argument[key] = item
                        end)
                    end
                    return nil
                end
                motion.ripple = function(parent, tweenInstance, easingDirection)
                    if motion.enabled then
                        if typeof(parent) ~= "Instance" then
                            return
                        end
                    else
                        return
                    end
                    local absolutePosition, new = parent.AbsolutePosition, parent.AbsoluteSize
                    local point = new / 2
                    if easingDirection then
                        local mouseResult = u.mouse()
                        point = Vector2.new(
                            u.clamp(mouseResult.X - absolutePosition.X, 0, new.X),
                            u.clamp(mouseResult.Y - absolutePosition.Y, 0, new.Y)
                        )
                    else
                    end
                    local calculatedValue, l =
                        math.max(new.X, new.Y) * 1.6,
                        u.new(
                            "Frame",
                            {
                                Name = "Ripple",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = UDim2.fromOffset(point.X, point.Y),
                                Size = UDim2.fromOffset(4, 4),
                                BackgroundColor3 = tweenInstance or Color3.new(1, 1, 1),
                                BackgroundTransparency = 0.8,
                                ZIndex = parent.ZIndex + 5,
                                Parent = parent,
                            }
                        )
                    u.corner(l, UDim.new(1, 0))
                    tweenInstance, new, absolutePosition = motion.tween, TweenInfo.new, Enum
                    parent, easingDirection = absolutePosition.EasingStyle.Quad, Enum.EasingDirection
                    local value, entries = new(0.45, parent, easingDirection.Out), {}
                    entries.Size, entries.BackgroundTransparency =
                        UDim2.fromOffset(calculatedValue, calculatedValue), 1
                    tweenInstance(l, value, entries)
                    task.delay(0.5, function()
                        l:Destroy()
                    end)
                end
            end
            do
                local refresh = { gen = 0, names = {}, full = {}, busy = 0, budget = 0.003 }
                localization2.Refresh = refresh
                local function isActive2()
                    local entries = {}
                    for unused, item in ipairs(localization2.Windows or {}) do
                        if not item.Destroyed then
                            if item.Gui then
                                if item.Gui.Parent then
                                    entries[#entries + 1] = item.Gui
                                end
                            end
                        end
                    end
                    return entries
                end
                refresh.run = function(argument, callback, isActive3)
                    refresh.gen = refresh.gen + 1
                    refresh.names[argument] = (refresh.names[argument] or 0) + 1
                    local entry = refresh.names[argument]
                    local value = isActive2()
                    if #value == 0 then
                        if isActive3 then
                            isActive3()
                        end
                        return
                    end
                    refresh.busy = refresh.busy + 1
                    task.spawn(function()
                        local now = os.clock()
                        for instances, item in ipairs(value) do
                            instances = item:GetDescendants()
                            for index = 1, #instances, 1 do
                                if refresh.names[argument] ~= entry then
                                    refresh.busy = refresh.busy - 1
                                    return
                                end
                                callback(instances[index])
                                if index % 40 == 0 then
                                    if os.clock() - now > refresh.budget then
                                        task.wait()
                                        now = os.clock()
                                    else
                                    end
                                else
                                end
                            end
                        end
                        refresh.busy = refresh.busy - 1
                    end)
                end
                refresh.sync = function(argument)
                    if not argument then
                        return
                    end
                    local instances = argument:GetDescendants()
                    instances[#instances + 1] = argument
                    for unused, callback in ipairs(refresh.full) do
                        for index = 1, #instances, 1 do
                            callback(instances[index])
                        end
                    end
                end
            end
            do
                local theme = {}
                theme.registry = localization2.U.newReg()
                theme.listeners = {}
                localization2.Theme = theme
                theme.Presets = {
                    Crimson = Color3.fromHex("d64458"),
                    Ember = Color3.fromHex("ff7a3d"),
                    Gold = Color3.fromHex("f5b94a"),
                    Mint = Color3.fromHex("3ddc97"),
                    Ocean = Color3.fromHex("3d9bff"),
                    Violet = Color3.fromHex("8b6cff"),
                    Rose = Color3.fromHex("ff5fa2"),
                    Ice = Color3.fromHex("7fe0ff"),
                }
                theme.tokens = {
                    Background = Color3.fromHex("0c0d10"),
                    Sidebar = Color3.fromHex("0f1014"),
                    Surface = Color3.fromHex("14161b"),
                    Surface2 = Color3.fromHex("1b1e25"),
                    Elevated = Color3.fromHex("22252d"),
                    Line = Color3.fromHex("1f2229"),
                    Text = Color3.fromHex("eceef3"),
                    Muted = Color3.fromHex("8a8f9e"),
                    Faint = Color3.fromHex("575c69"),
                    Accent = theme.Presets.Crimson,
                    OnAccent = Color3.fromHex("ffffff"),
                    Success = Color3.fromHex("3ddc97"),
                    Warning = Color3.fromHex("f5b94a"),
                    Danger = Color3.fromHex("f0506e"),
                    Glass = Color3.fromHex("ffffff"),
                }
                local function resolve(callback)
                    if typeof(callback) == "Color3" then
                        return callback
                    end
                    if type(callback) == "function" then
                        return callback(theme.tokens)
                    end
                    return theme.tokens[callback] or theme.tokens.Text
                end
                theme.resolve = resolve
                theme.bind = function(argument, argument2, argument3)
                    if typeof(argument) ~= "Instance" then
                        return argument
                    end
                    local entries = theme.registry[argument]
                    if entries then
                    else
                        entries = {}
                        theme.registry[argument] = entries
                    end
                    entries[argument2] = argument3
                    pcall(function()
                        argument[argument2] = resolve(argument3)
                    end)
                    return argument
                end
                local function applyOne(argument, callback)
                    local entry = theme.registry[argument]
                    if not entry then
                        return
                    end
                    for key, item in pairs(entry) do
                        if if callback then callback(item) else not callback then
                            local success, result = pcall(resolve, item)
                            if success then
                                if result ~= nil then
                                    pcall(function()
                                        argument[key] = result
                                    end)
                                end
                            end
                        end
                    end
                end
                theme.applyOne = applyOne
                local function callback(argument, argument2)
                    localization2.Refresh.run("theme:" .. tostring(argument2 or "all"), function(argument3)
                        applyOne(argument3, argument)
                    end, function()
                        for key in pairs(theme.registry) do
                            if key.Parent then
                                applyOne(key, argument)
                            end
                        end
                    end)
                end
                theme.set = function(argument, argument2)
                    if typeof(argument2) ~= "Color3" then
                        return
                    end
                    theme.tokens[argument] = argument2
                    callback(function(argument3)
                        return argument3 == argument or type(argument3) == "function"
                    end, "one:" .. tostring(argument))
                    for unused, item in ipairs(theme.listeners) do
                        pcall(item, argument, argument2)
                    end
                end
                theme.setMany = function(argument)
                    for key, item in pairs(argument) do
                        if typeof(item) == "Color3" then
                            theme.tokens[key] = item
                        end
                    end
                    local entries = {}
                    for key in pairs(argument) do
                        entries[#entries + 1] = tostring(key)
                    end
                    table.sort(entries)
                    callback(function(argument2)
                        return type(argument2) == "function"
                            or type(argument2) == "string" and argument[argument2] ~= nil
                    end, "many:" .. table.concat(entries, ","))
                    for unused, item in ipairs(theme.listeners) do
                        for key, item2 in pairs(argument) do
                            pcall(item, key, item2)
                        end
                    end
                end
                theme.Bases = {
                    {
                        "Midnight",
                        {
                            Background = "0c0d10",
                            Sidebar = "0f1014",
                            Surface = "14161b",
                            Surface2 = "1b1e25",
                            Elevated = "22252d",
                            Line = "1f2229",
                            Text = "eceef3",
                            Muted = "8a8f9e",
                            Faint = "575c69",
                        },
                    },
                    {
                        "Graphite",
                        {
                            Background = "111214",
                            Sidebar = "141517",
                            Surface = "1a1b1e",
                            Surface2 = "232427",
                            Elevated = "2b2d31",
                            Line = "2a2c30",
                            Text = "f0f1f3",
                            Muted = "9a9da4",
                            Faint = "62656c",
                        },
                    },
                    {
                        "Amoled",
                        {
                            Background = "000000",
                            Sidebar = "040405",
                            Surface = "0b0c0e",
                            Surface2 = "111216",
                            Elevated = "181a1f",
                            Line = "16181c",
                            Text = "f2f3f6",
                            Muted = "8f94a1",
                            Faint = "545965",
                        },
                    },
                    {
                        "Deep Sea",
                        {
                            Background = "090d13",
                            Sidebar = "0b1119",
                            Surface = "101823",
                            Surface2 = "162131",
                            Elevated = "1d2b3e",
                            Line = "1a2433",
                            Text = "e8eef8",
                            Muted = "8794ab",
                            Faint = "55627a",
                        },
                    },
                    {
                        "Plum",
                        {
                            Background = "0e0b12",
                            Sidebar = "110d16",
                            Surface = "17121d",
                            Surface2 = "1f1927",
                            Elevated = "271f32",
                            Line = "221b2b",
                            Text = "efe9f6",
                            Muted = "9a8fa8",
                            Faint = "625870",
                        },
                    },
                    {
                        "Forest",
                        {
                            Background = "0b0f0d",
                            Sidebar = "0d1210",
                            Surface = "121815",
                            Surface2 = "19211d",
                            Elevated = "202a25",
                            Line = "1c241f",
                            Text = "e9f0ec",
                            Muted = "8a9a92",
                            Faint = "56645d",
                        },
                    },
                    {
                        "Halloween",
                        {
                            Background = "0d0b0a",
                            Sidebar = "100e0c",
                            Surface = "161311",
                            Surface2 = "1e1a17",
                            Elevated = "27221e",
                            Line = "241f1b",
                            Text = "f5eee6",
                            Muted = "a39a90",
                            Faint = "675e55",
                        },
                    },
                }
                theme.base = "Midnight"
                theme.setBase = function(base)
                    for key, item in ipairs(theme.Bases) do
                        if item[1] == base then
                            key = {}
                            for key2, item2 in pairs(item[2]) do
                                key[key2] = Color3.fromHex(item2)
                            end
                            theme.setMany(key)
                            theme.base = base
                            return true
                        end
                    end
                    return false
                end
                theme.panelFrom = function(argument)
                    local toHSVResult, toHSVResult2, toHSVResult3 = argument:ToHSV()
                    local minimumValue = math.min(toHSVResult2, 0.9)
                    local clampedValue = math.clamp(toHSVResult3, 0.025, 0.3)
                    local function callback(argument, argument2)
                        return Color3.fromHSV(
                            toHSVResult,
                            math.clamp(minimumValue * (argument2 or 1), 0, 1),
                            math.clamp(clampedValue + argument, 0, 1)
                        )
                    end
                    return {
                        Background = callback(0),
                        Sidebar = callback(0.014),
                        Surface = callback(0.042),
                        Surface2 = callback(0.08, 0.92),
                        Elevated = callback(0.112, 0.86),
                        Line = callback(0.096, 0.9),
                        Text = Color3.fromHSV(toHSVResult, minimumValue * 0.07, 0.95),
                        Muted = Color3.fromHSV(toHSVResult, minimumValue * 0.16, 0.62),
                        Faint = Color3.fromHSV(toHSVResult, minimumValue * 0.18, 0.41),
                    }
                end
                theme.onChange = function(argument)
                    table.insert(theme.listeners, argument)
                end
                theme.accentSoft = function(argument)
                    return function(argument2)
                        return argument2.Surface2:Lerp(argument2.Accent, argument)
                    end
                end
            end
            do
                local font = {}
                localization2.Font = font
                local u = localization2.U
                font.Families = {
                    { "Builder Sans", "BuilderSans" },
                    { "Montserrat", "Montserrat" },
                    { "Nunito", "Nunito" },
                    { "Roboto", "Roboto" },
                    { "Ubuntu", "Ubuntu" },
                    { "Titillium Web", "TitilliumWeb" },
                    { "Josefin Sans", "JosefinSans" },
                    { "Jura", "Jura" },
                    { "Source Sans", "SourceSansPro" },
                    { "Oswald", "Oswald" },
                    { "Roboto Mono", "RobotoMono" },
                    { "Michroma", "Michroma" },
                }
                font.name = "Builder Sans"
                font.id = "BuilderSans"
                local entries = {}
                local function callback(argument)
                    return "rbxasset://fonts/families/" .. argument .. ".json"
                end
                font.get = function(calculatedValue, calculatedValue2)
                    calculatedValue, calculatedValue2 =
                        calculatedValue or Enum.FontWeight.Medium, calculatedValue2 or Enum.FontStyle.Normal
                    local calculatedValue3 = font.id .. "|" .. calculatedValue.Name .. "|" .. calculatedValue2.Name
                    if not entries[calculatedValue3] then
                        local success, result =
                            pcall(Font.new, callback(font.id), calculatedValue, calculatedValue2)
                        entries[calculatedValue3] = success and result or Font.fromEnum(Enum.Font.GothamMedium)
                    end
                    return entries[calculatedValue3]
                end
                font.Regular = function()
                    return font.get(Enum.FontWeight.Regular)
                end
                font.Medium = function()
                    return font.get(Enum.FontWeight.Medium)
                end
                font.Semi = function()
                    return font.get(Enum.FontWeight.SemiBold)
                end
                font.Bold = function()
                    return font.get(Enum.FontWeight.Bold)
                end
                font.Heavy = function()
                    return font.get(Enum.FontWeight.ExtraBold)
                end
                font.fontOne = function(argument)
                    local entry = u.textReg[argument]
                    if entry then
                        pcall(function()
                            argument.FontFace = font.get(entry.weight, entry.style)
                        end)
                    end
                end
                font.sizeOne = function(argument)
                    local entry = u.textReg[argument]
                    if entry then
                        pcall(function()
                            argument.TextSize = math.max(8, math.floor(entry.size * u.textScale + 0.5))
                        end)
                    end
                end
                font.setFamily = function(argument)
                    for unused, item in ipairs(font.Families) do
                        if item[1] == argument or item[2] == argument then
                            font.name, font.id = item[1], item[2]
                            localization2.Refresh.run("font", font.fontOne, function()
                                for key in pairs(u.textReg) do
                                    if key.Parent then
                                        font.fontOne(key)
                                    end
                                end
                            end)
                            return true
                        end
                    end
                    return false
                end
                font.setScale = function(argument)
                    u.textScale = math.clamp(argument, 0.8, 1.3)
                    localization2.Refresh.run("textsize", font.sizeOne, function()
                        for key in pairs(u.textReg) do
                            if key.Parent then
                                font.sizeOne(key)
                            end
                        end
                    end)
                end
            end
            do
                local icons = { module = nil, tried = false, waiting = {} }
                localization2.Icons = icons
                local entries = { "rbxassetid://104502745253902", "rbxassetid://89421818506275" }
                local point, entries2 =
                    Vector2.new(24, 24),
                    {
                        ["trash-2"] = "trash",
                        gear = "settings",
                        grid = "grid-3x3",
                        ["person-running"] = "footprints",
                        ["alert-triangle"] = "triangle-alert",
                        ["alert-circle"] = "circle-alert",
                        ["check-circle"] = "circle-check",
                        ["check-circle-2"] = "circle-check-big",
                        ["x-circle"] = "circle-x",
                        ["help-circle"] = "circle-question-mark",
                        ["more-horizontal"] = "ellipsis",
                        ["more-vertical"] = "ellipsis-vertical",
                        edit = "pencil",
                        ["edit-2"] = "pencil",
                        ["edit-3"] = "pencil-line",
                        home = "house",
                        unlock = "lock-open",
                        ["bar-chart"] = "chart-bar",
                        ["bar-chart-2"] = "chart-bar",
                        ["loader-2"] = "loader-circle",
                        sliders = "sliders-horizontal",
                        filter = "funnel",
                        ["wand-2"] = "wand-sparkles",
                        ["play-circle"] = "circle-play",
                        ["pause-circle"] = "circle-pause",
                        ["stop-circle"] = "circle-stop",
                        ["user-circle"] = "circle-user",
                        ["plus-circle"] = "circle-plus",
                        ["minus-circle"] = "circle-minus",
                        ["pie-chart"] = "chart-pie",
                        ["line-chart"] = "chart-line",
                        ["shield-close"] = "shield-x",
                        ["sort-asc"] = "arrow-up-narrow-wide",
                        ["sort-desc"] = "arrow-down-wide-narrow",
                        verified = "badge-check",
                        ["file-warning"] = "file-exclamation-point",
                    }
                icons.load = function()
                    if icons.module then
                        return icons.module
                    end
                    icons.tried = true
                    local entries3 = {}
                    for key, item in
                        ipairs(
                            string.split(
                                "align-vertical-distribute-center,chevron-down,list-restart,table-cells-split,gavel,dna-off,refresh-ccw-dot,venus,bean,circle-question-mark,folder-code,bolt,heater,feather,align-horizontal-distribute-center,grip-vertical,pill-bottle,person-standing,badge-swiss-franc,between-horizontal-end,file-braces-corner,rotate-cw,house-plus,bus-front,shield-ellipsis,between-vertical-end,globe-lock,tags,concierge-bell,bookmark-minus,plant-pot,file-down,picture-in-picture,messages-square,scissors,file-check-corner,phone-call,anchor,hand-helping,text-wrap,birdhouse,wifi-off,cloud-alert,message-square,cloud-download,folder-plus,cctv-off,notebook-dot,mirror-round,user-round,pointer,between-horizontal-start,chevrons-up-down,brush,message-circle-more,parentheses,book-up-2,flame,chevrons-up,square-dashed,square-mouse-pointer,superscript,signal,wifi-cog,hexagon,navigation-2-off,eye-off,arrows-up-from-line,file-code-corner,square-centerline-dashed-horizontal,panels-right-bottom,scaling,hash,arrow-left-from-line,ship,ticket-percent,calendar-clock,x,non-binary,voicemail,presentation,tree-palm,badge,captions-off,align-vertical-justify-center,download,mouse-right,lens-convex,shrimp-off,focus,diamond-percent,arrow-big-up,volume-x,mouse-pointer-click,face-slightly-smiling-plus,hard-drive,grid-2x2-x,package-minus,cloud,pipette,corner-left-down,badge-cent,cloud-lightning,user-round-pen,arrow-left-to-line,book-open-text,monitor-cloud,parking-meter,cat,heart-handshake,dam,trees,ham,circle-pause,chess-king,bean-off,clef-alto,separator-horizontal,ambulance,globe-code,citrus,phone-missed,calendar-off,chart-column,battery-medium,square-minus,star-check,decimals-arrow-left,folder-output,menu,bangladeshi-taka,image-down,terminal,building-complex-plus,circle-dot-dashed,medal,cake-slice,git-graph,armchair,tickets,qr-code,copy,goal,book-bookmark,trending-down,creative-commons,layers-arrow-down,ev-charger,user-star,road,nfc,align-center-horizontal,car,notebook-tabs,ear,videotape,sun-moon,chart-scatter,podium,toolbox,calendar,calendar-cog,gallery-horizontal,clipboard-x,list-sort-ascending,book-open,circle-pile,rectangle-ellipsis,badge-plus,badge-info,file-headphone,bow-arrow,clipboard-pen-line,user-round-key,folder-search,utensils-crossed,arrow-up,arrow-up-from-dot,align-vertical-justify-start,layers-minus,pause,shrub,flag,biceps-flexed,align-horizontal-distribute-end,donut,calendar-plus-2,move-vertical,file-pen-line,badge-russian-ruble,radius,pilcrow,corner-left-up,georgian-lari,cable,book-user,square-arrow-down,circle-plus,view,cctv,circle-arrow-left,square-off,octagon-alert,panel-bottom-dashed,book-a,align-end-vertical,thumbs-up,globe,rabbit,layers-plus,door-stairwell,banknote-arrow-down,message-square-off,dice-4,message-circle-x,folder-x,message-circle-warning,map,move,arrow-up-left,award,arrow-down-wide-narrow,unfold-horizontal,lens-concave,zoom-out,motorbike,music-4,zoom-in,shield-x,file-volume,disc-3,file-signal,columns-4,archive-x,zodiac-virgo,square-dashed-kanban,mouse-pointer-2,clock-arrow-up,clock-fading,pencil-sparkles,library-big,vegan,star-plus,file-check,clef-bass,message-circle-plus,user-key,credit-card-plus,zodiac-pisces,fast-forward,user-pen,chess-knight,wifi-pen,files,send-to-back,alarm-clock,microscope,zodiac-libra,zodiac-leo,zodiac-gemini,shopping-basket,send,smartphone,square-dashed-bottom,zodiac-aries,zodiac-aquarius,land-plot,wind-arrow-down,germ-off,brush-cleaning,skip-back,x-line-top,book-audio,octagon-minus,file-scan,cupcake,midi-port,message-square-dashed,shield-check,worm,chevrons-left,workflow,umbrella,skip-forward,clipboard-copy,map-pin-off,arrow-up-from-line,circle-chevron-up,wine-off,wine,circle-small,align-vertical-space-between,lamp-desk,circle-arrow-up,zap,beaker,timeline,panel-left-right-dashed,wifi-sync,paintbrush,sliders-vertical,broccoli,wifi-high,wifi,chevron-up,triangles-centerline-dashed-horizontal,whistle,pen-tool,database-check,wheat-off,form,pencil-ruler,dna,arrow-big-down-dash,chart-area,bug-off,wheat,weight-tilde,card-sim,weight,server-crash,map-pin-search,flask-round,eye-dashed,webcam-off,ellipse,spell-check,webcam,waypoints,popcorn,blocks,waves-vertical,layer-arrow-up,microchip,waves-ladder,badge-minus,cloud-sun,circle,shield-alert,waves-horizontal,phone-incoming,map-minus,waves-arrow-down,watch,separator-vertical,washing-machine,heart-minus,scan-square,ampersands,wand-sparkles,user-search,magnet,fence,wallpaper,square-user-round,wallet-minimal,wallet-cards,sunrise,strikethrough,calendar-days,folder-bookmark,wallet,banknote-arrow-up,layout-arrow-right,vote,dollar-sign,message-square-quote,volume-off,ruler-dimension-line,volume-1,list-minus,cloud-hail,volume,eye-closed,app-window-mac,volleyball,ellipsis,copy-check,clock-arrow-right,satellite,bookmark-plus,virus,folder-key,coffee,circle-power,ligature,hourglass,tickets-plane,folder-git,video,bomb,layers-2,battery-full,sparkle,line-dot-bottom-vertical,chart-gantt,folder-tree,command,badge-dollar-sign,align-start-vertical,briefcase-conveyor-belt,message-circle-question-mark,vibrate,bluetooth-off,venus-and-mars,square-square,cannabis,equal-approximately-not,book,grip-horizontal,circle-minus,audio-waveform,moon-star,arrow-down-narrow-wide,ghost,database-backup,wand,receipt-turkish-lira,vector-polygon,calendar-minus-2,copy-minus,vault,folder-input,book-image,badge-x,mouse-left,tag-plus,shirt,van,server-off,move-up,message-circle-dashed,utensils,plug-2,users-round,chess-rook,brackets,calendar-heart,list-ordered,users,star-x,mic-off,user-x,arrow-big-left,square-split-horizontal,triangle-alert,user-round-x,clover,sun-snow,sofa,user-round-search,handbag,funnel-x,map-pin,clock-2,calendar-fold,fish-off,baby,database-x,fold-vertical,user-round-group,hop,face-angry,user-round-cog,cigarette,calendar-chevrons-right,user-round-check,user-round-arrow-left,diamond-plus,refrigerator,file-chart-column,triangle-dashed,git-pull-request-closed,badge-check,user-minus,user-lock,layers-arrow-up,plug-zap,heading-4,chess-queen,graduation-cap,grid-3x2,zodiac-sagittarius,square-dashed-x-corner,square-dashed-bottom-code,clock-7,ethernet-port,scan-text,user-group,shower-head,equal-not,user-cog,move-down,clock-arrow-down,ticket-slash,ruler,settings-2,user,circle-user-round,usb-c-port,layers,list-filter,map-pin-check,egg-off,upload,cog,dog,unplug,swords,spotlight,panel-right-dashed,signal-zero,paper-bag,truck-electric,unlink,check-line,university,bubbles,bot,chart-bar-increasing,ungroup,playing-card,air-vent,unfold-vertical,dot,ice-cream-cone,mouth,file-symlink,clipboard-paste,chevron-last,book-heart,undo-2,circle-parking,globe-check,cloud-check,panel-left,circle-chevron-right,undo,underline,squares-unite,arrow-down-up,git-fork,forward,brain-circuit,between-vertical-start,database,panel-right,umbrella-off,type-outline,flower,log-out,git-branch-plus,clipboard-minus,file-text,trending-up,fire-extinguisher,fan,table-rows-split,milk-off,tv-minimal,cloud-upload,banknote,turntable,message-circle-dashed-check,drumstick,turkish-lira,calendar-search,tube-lotion,line-dot-top-vertical,bell-ring,circle-chevron-left,truck,arrow-down,arrow-up-down,folder-dot,trophy,case-lower,whole-word,monitor,disc-2,trending-up-down,folder-cog,user-shield,triangle,tv-minimal-play,circle-stop,align-vertical-space-around,switch-camera,tree-deciduous,square-chart-gantt,arrow-big-down,circle-parking-off,calendar-x-2,user-plus,move-diagonal-2,bandage,gallery-horizontal-end,panel-top-dashed,transgender,chess-bishop,tram-front,train-front-tunnel,train-front,refresh-cw-off,audio-lines,traffic-cone,tractor,toothbrush,tower-control,rocket,fish,ear-off,touchpad-off,save-check,touchpad,torus,printer,megaphone-off,tornado,arrow-big-right,section,file-clock,toothbrush-sparkles,toy-brick,square-chevron-down,dice-1,drill,app-window,robot-vacuum,hand-metal,tool-case,spell-check-2,toilet,squirrel,list-plus,toggle-left,rotate-ccw-key,timer-reset,chart-pie,paw-print,timer,copy-slash,wind,ticket-x,layout-panel-left,moon,circle-percent,ticket-minus,circle-arrow-out-down-right,square-x,italic,chart-column-increasing,layout-freeform,step-forward,message-square-diff,a-arrow-down,broom-sparkles,sticker,tic-tac-toe,move-left,thermometer-sun,thermometer-snowflake,thermometer,theater,import,badge-turkish-lira,square-terminal,file-music,logs,beef,faucet,file-user,text-quote,square-radical,lightbulb,image-upscale,book-type,text-cursor-input,signpost-big,text-cursor,cloudy,helicopter,square-percent,text-align-justify,navigation-off,arrow-left,car-taxi-front,text-align-end,mouth-off,chevrons-right-left,text-align-center,test-tubes,test-tube-diagonal,brick-wall-fire,square-stack,tent,square-dimensions,face-slightly-smiling,align-end-horizontal,layer-arrow-down,equal,megaphone,calendar-x,telescope,ice-cream-bowl,egg,tangent,save-off,ship-cargo,circle-pound-sterling,video-off,japanese-yen,tally-3,tag,tally-1,library,file-terminal,circle-chevron-down,accessibility,route,square-library,amphora,hourglass-cog,tally-2,tablets,tablet-smartphone,building-complex,remove-formatting,sheet,circle-check-big,table-properties,table-of-contents,map-pinned,corner-down-left,circuit-board,table-columns-split,table-cells-merge,table-2,table,folder-open-dot,book-dashed,syringe,lasso,bluetooth,tree-pine,receipt-indian-rupee,swiss-franc,shield-plus,sunset,sun-medium,sun-dim,can-soda,flask-conical,power,funnel,square-star,folder-sync,monitor-pc,zodiac-ophiuchus,subscript,stretch-vertical,arrow-up-narrow-wide,fishing-hook,stretch-horizontal,maximize-2,stone,frame,calendar-arrow-down,clock-12,star-minus,heart,sticky-note-x,images,lollipop,book-text,chart-no-axes-column-increasing,lamp-floor,file-plus-corner,image,equal-approximately,badge-euro,bike,angle,gap-vertical,sticky-note-check,sticky-note,stethoscope,step-back,star-off,option,banknote-check,scroll-text,server-plus,repeat,star,stamp,toggle-right,file-x,ferris-wheel,camera-off,squircle,search-slash,repeat-off,squares-exclude,square-user,group,square-text,battery,mic-audio-lines,tent-tree,square-split-vertical,rectangle-horizontal,spade,square-slash,screen-share-off,bitcoin,square-scissors,battery-plus,database-search,square-round-corner,file-diff,joystick,square-plus,square-play,spline-pointer,square-pilcrow,axis-3d,square-pi,message-square-share,binoculars,square-pause,calendar-range,square-parking,rose,euro,mail-minus,square-m,square-kanban,square-function,pyramid,clipboard-pen,bottle-wine,alarm-clock-off,square-equal,list,square-dot,square-arrow-right,dome,badge-pound-sterling,bookmark-check,square-divide,wrench-off,shopping-bag,a-arrow-up,clock-check,shrink,chevrons-down,vibrate-off,face-grinning,zodiac-cancer,square-code,file-code,square-chevron-up,carton-off,credit-card-reader,paintbrush-vertical,cassette-tape,battery-low,square-chevron-left,receipt-japanese-yen,signpost,snail,calendar-arrow-up,landmark,fish-symbol,trash-off,loader,bold,dice-2,file-type,clipboard-clock,beer,lectern,square-centerline-dashed-vertical,square-bottom-dashed-scissors,square-bookmark,binary,move-diagonal,square-asterisk,door-closed,square-arrow-up-right,layout-template,rows-4,piano,square-arrow-right-exit,bookmark-off,hand-heart,square-arrow-right-enter,scan-qr-code,message-square-check,square-arrow-out-up-right,square-arrow-out-up-left,monitor-play,brain,square-arrow-out-down-left,server-cog,square-arrow-down-right,key,clock-11,gap-horizontal,ticket-plus,arrow-up-0-1,bell-electric,square,heading,book-open-check,panel-top-close,lasso-select,sprout,spray-can,sport-shoe,shield-off,bus,search-alert,audio-lines-x,chart-no-axes-gantt,file-spreadsheet,percent,clipboard-list,speech,contact-round,speaker,keyboard-off,sparkles,file-badge,battery-warning,mail-question-mark,arrow-down-from-line,briefcase,biohazard,rectangle-circle,braces,scale-3d,panel-top-bottom-dashed,mail-x,square-dashed-mouse-pointer,square-sparkles,lock-open,file-play,pizza,list-indent-decrease,arrow-up-wide-narrow,soup,clock-5,solar-panel,rotate-ccw,align-horizontal-justify-center,soap-dispenser-droplet,antenna,memory-stick,scan-eye,snowflake,square-check,heart-plus,smartphone-nfc,map-pin-minus-inside,git-merge,gallery-vertical-end,square-dashed-plus,hand-coins,zodiac-capricorn,wifi-low,sliders-horizontal,clock,file-pen,git-compare-arrows,cloud-sun-rain,align-horizontal-justify-start,power-off,mail-badge,skull,calendar-plus,siren,arrow-down-z-a,bath,signature,unlink-2,signal-medium,shopping-cart-minus,folder-check,signal-low,book-key,ribbon,microwave,calculator,gallery-vertical,sigma,shuffle,square-dashed-text,map-pin-pen,move-up-left,shrimp,folder-heart,hard-drive-upload,monitor-speaker,shopping-cart-plus,arrow-up-a-z,package,square-dashed-top-solid,ship-wheel,shield-user,shield-question-mark,swatch-book,receipt-cent,spool,folder-archive,folder-symlink,can,ban,message-square-x,paint-roller,git-pull-request-draft,archive,shield-lock,shield-keyhole,shield-half,circle-slash-2,shield-cog-corner,cake,cloud-rain,chart-bar,shield-cog,wrench,shield-ban,shield,shelving-unit,flag-triangle-right,shell,gamepad-directional,bell,share,shapes,music-3,chart-bar-big,user-check,proportions,settings,plane,webhook-off,carrot,square-arrow-left,file-cog,circle-dashed,server,send-horizontal,search-x,germ,squares-subtract,search-code,dices,split,list-sort-descending,search,forklift,scroll,alarm-clock-minus,heart-x,eraser,square-sigma,screen-share,bluetooth-connected,rotate-ccw-square,chart-no-axes-column,cannabis-off,folder-kanban,lighthouse,mars-stroke,roller-coaster,school,scan-search,file-box,pickaxe,paint-bucket,glass-water,mic,glasses,piggy-bank,scan-face,cuboid,cloud-off,check-check,activity,axe,plane-takeoff,scan-box,cloud-rain-wind,scan-barcode,scan,copy-x,file-axis-3d,radical,chart-column-decreasing,play-off,bug-play,align-vertical-distribute-start,save-plus,waves-arrow-up,tally-5,headset,save,saudi-riyal,circle-divide,satellite-dish,sandwich,salad,life-buoy,sailboat,external-link,volume-2,battery-charging,russian-ruble,square-arrow-up-left,brick-wall-shield,footprints,rows-3,building,rows-2,router,route-off,tag-x,book-alert,link-2,astroid,bell-minus,image-up,closed-caption,drum,arrow-up-z-a,sun,rotate-cw-fading-clock,rotate-cw-clock,file-key,rotate-ccw-clock,rotate-3d,scissors-line-dashed,house-wifi,robot-arm,rewind,ticket-check,combine,reply,replace-all,mountain,mars,picture-in-picture-2,radio-off,flower-2,replace,squares-intersect,repeat-2,repeat-1,keyboard-music,star-half,playing-cards-fan,code-xml,pencil-line,mails,brain-cog,tablet,regex,pi,trash,book-down,hdmi-port,trailer,case-upper,circle-fading-arrow-up,refresh-cw,croissant,phone,computer,barcode,pin,redo,bed,circle-arrow-right,divide,grape,rectangle-vertical,party-popper,file-chart-pie,rectangle-goggles,file-x-corner,dice-6,receipt-swiss-franc,blender,receipt-russian-ruble,zap-off,square-check-big,receipt-euro,receipt,ratio,laptop-minimal,rat,rainbow,map-pin-minus,omega,chart-spline,message-square-more,radio-receiver,chart-candlestick,radio,arrow-down-a-z,radiation,radar,move-horizontal,file-sliders,quote,square-exclamation-point,cup-soda,puzzle,projector,sword,printer-check,map-pin-x,earth,slice,dice-3,milk,mouse-pointer-ban,crown,circle-slash,circle-star,rotate-cw-square,atom,package-x,bed-double,pound-sterling,circle-dot,file-exclamation-point,hand-fist,message-circle-code,folder-git-2,message-square-code,popsicle,towel-rack,layout-grid,arrow-big-left-dash,plus,dumbbell,plug,playing-cards,houses,scale,play,flashlight,panel-top-open,plane-landing,pin-off,notebook,redo-2,pill,square-menu,pilcrow-left,monitor-smartphone,laptop,scan-line,clock-4,square-arrow-up,book-minus,file-question-mark,chevrons-left-right,phone-off,save-pen,arrow-down-to-line,phone-forwarded,refresh-ccw,venetian-mask,calendar-check-2,phi,spline,banknote-x,git-pull-request-create-arrow,pentagon,circle-check,pencil-off,caravan,pen-off,pen-line,hand-platter,pc-case,timer-off,arrow-big-right-dash,bed-single,parasol,paperclip,backpack,calendar-minus,panels-left-bottom,panel-top,panel-right-open,mic-signal,arrow-down-right,panel-right-close,letters,wifi-zero,panel-left-open,panel-left-dashed,map-pin-plus,hard-drive-download,image-off,panel-bottom-close,panel-bottom,panda,engine,square-chevron-right,mail-search,package-search,bone-fracture,package-plus,package-open,crop,package-2,lambda,ampersand,ad,shopping-cart,align-vertical-justify-end,origami,alarm-smoke,orbit,file-input,clock-8,hand-grab,cloud-cog,blend,hd,radio-tower,list-tree,droplet,line-squiggle,eye,octagon-pause,square-dashed-x,banana,gpu,message-square-heart,nut-off,circle-equal,face-slightly-frowning,nut,notepad-text-dashed,notepad-text,text-initial,arrow-up-right,maximize,leafy-green,message-square-dot,file-chart-line,columns-3-cog,newspaper,network,minimize-2,nepali-rupee,navigation-2,cone,navigation,file-image,music-2,palette,barrel,gallery-thumbnails,move-up-right,cpu,move-right,thumbs-down,merge,hamburger,move-down-right,hat-glasses,code,move-down-left,move-3d,mail-check,mouse-pointer,carton,mouse-off,kanban,bone,apple,rocking-chair,bot-off,circle-arrow-out-down-left,database-arrow-down,folder,circle-arrow-out-up-left,mop,cable-car,arrow-down-left,square-activity,message-square-text,cigarette-off,monitor-up,message-circle,circle-arrow-out-up-right,car-battery,monitor-stop,fold-horizontal,shovel,calendar-1,cloud-moon,square-arrow-out-down-right,monitor-pause,clock-plus,circle-euro,cloud-snow,anvil,arrow-big-up-dash,monitor-off,log-in,monitor-dot,monitor-cog,monitor-check,list-checks,chevrons-down-up,clipboard-plus,circle-x,list-end,minus,list-collapse,chevrons-right,audio-lines-off,message-square-reply,corner-down-right,milestone,summary,lamp-wall-down,mic-vocal,layout-arrow-down,ellipsis-vertical,globe-off,square-stop,arrow-up-1-0,align-horizontal-justify-end,scan-heart,align-vertical-distribute-end,heart-crack,airplay,case-sensitive,messages-circle,message-square-warning,monitor-x,bell-check,database-minus,square-pen,message-square-plus,message-square-lock,dice-5,octagon,ticket,folder-lock,message-circle-off,briefcase-plus,bookmark,message-circle-heart,utility-pole,message-circle-check,chart-bar-decreasing,database-plus,calendar-sync,funnel-plus,store,circle-arrow-down,notebook-pen,egg-fried,compass,keyboard,corner-right-up,map-pin-x-inside,printer-3d,user-round-plus,panel-left-close,crosshair,pilcrow-right,user-round-minus,mailbox,indian-rupee,mail-plus,mail-pen,bell-off,mail-clock,mouse-pointer-2-off,drone,slash,credit-card-x,aperture,arrow-right-left,mail,vector-square,circle-gauge,circle-alert,check,text-search,arrow-down-to-dot,monitor-down,lock-keyhole-open,chef-hat,lock-keyhole,lock,file-archive,signal-high,inbox,locate-fixed,locate,image-play,align-horizontal-space-between,loader-pinwheel,calendar-check,database-zap,droplets,loader-circle,broom,corner-right-down,layout-list,file-search,list-video,alarm-clock-plus,circle-dollar-sign,usb,house,receipt-pound-sterling,list-music,list-indent-increase,id-card,mouse,minimize,list-clock,list-chevrons-up-down,galaxy,list-chevrons-down-up,book-x,mirror-rectangular,list-check,link-2-off,link,headphone-off,asterisk,line-style,octagon-x,languages,line-dot-right-horizontal,alarm-clock-check,guitar,dock,beer-off,scooter,square-parking-off,notebook-text,arrow-right-to-line,clef-treble,tally-4,zodiac-taurus,leaf,door-open,flag-triangle-left,grid-3x3,file,layout-panel-top,pocket-knife,book-copy,castle,car-front,clock-alert,reply-all,cloud-moon-rain,clipboard-type,layout-dashboard,list-todo,printer-x,bird,list-start,lamp-wall-up,a-large-small,lamp-ceiling,lamp,map-plus,key-square,file-chart-column-increasing,kayak,database-arrow-up,arrow-right-from-line,flame-kindling,square-power,iv-bag,bring-to-front,iteration-cw,iteration-ccw,bell-plus,inspection-panel,info,infinity,folders,mail-warning,image-plus,image-minus,id-card-lanyard,bridge,chart-line,file-lock,cast,circle-fading-plus,clock-10,undo-dot,target,list-filter-plus,house-plug,drama,house-heart,baseline,martini,contrast,hotel,candy-off,hospital,book-check,heart-off,book-lock,highlighter,briefcase-medical,calendars,text-align-start,heart-pulse,hop-off,warehouse,sticky-notes,drafting-compass,save-all,file-braces,heading-6,heading-5,heading-3,heading-2,fishing-rod,book-headphones,credit-card,heading-1,haze,hard-hat,shredder,panel-bottom-open,door-closed-package,eject,credit-card-check,balloon,map-pin-plus-inside,bookmark-x,badge-question-mark,pen,hand,candy-cane,hammer,grip,gamepad-2,file-type-corner,grid-2x2-check,grid-2x2,globe-x,shield-minus,circle-off,dessert,eclipse,church,git-pull-request-create,cylinder,badge-japanese-yen,columns-3,receipt-text,git-merge-conflict,git-compare,git-commit-vertical,git-commit-horizontal,file-output,disc-album,circle-ellipsis,arrow-down-0-1,captions,git-branch,gift,philippine-peso,badge-alert,gem,folder-pen,cross,gauge,chevron-right,sticky-note-minus,square-arrow-down-left,share-2,gamepad,fullscreen,fuel,folder-up,folder-search-2,folder-root,chess-pawn,folder-open,briefcase-business,folder-minus,message-circle-reply,cloud-sync,triangle-right,folder-clock,folder-closed,mop-sparkles,type,webhook,flask-conical-off,align-horizontal-distribute-start,flashlight-off,flag-off,pointer-off,turtle,camera,fingerprint-pattern,film,git-pull-request,bluetooth-searching,arrow-up-to-line,squircle-dashed,clock-3,badge-percent,face-expressionless,file-video-camera,file-up,grid-2x2-plus,file-stack,box,file-search-corner,clock-1,file-heart,house-cog,space,file-minus-corner,file-minus,file-digit,corner-up-left,clock-6,zodiac-scorpio,key-round,headphones,tv,factory,face-neutral,rss,expand,at-sign,map-pin-check-inside,sticky-note-off,music,handshake,earth-lock,circle-user,copy-plus,droplet-off,virus-off,line-dot-left-horizontal,disc,diff,search-check,clipboard-check,columns-2,diamond-minus,clipboard,align-center-vertical,diameter,delete,club,cloud-fog,mosque,currency,map-pin-house,package-check,chevron-first,pencil,boxes,list-x,copyright,copyleft,corner-up-right,cookie,clock-arrow-left,container,contact,badge-indian-rupee,construction,redo-dot,component,align-start-horizontal,chart-column-stacked,file-plus,git-pull-request-arrow,coins,decimals-arrow-right,bell-dot,folder-down,cloud-drizzle,cloud-backup,align-horizontal-space-around,door-closed-locked,clock-9,diamond,blinds,clapperboard,circle-play,book-search,git-branch-minus,circle-dashed-check,recycle,mountain-snow,luggage,chevrons-left-right-ellipsis,bot-message-square,phone-outgoing,smartphone-charging,chevron-left,train-track,cherry,chart-bar-stacked,sticky-note-plus,chart-no-axes-column-decreasing,chart-network,chart-column-big,chart-no-axes-combined,metronome,triangles-centerline-dashed-vertical,arrow-down-1-0,credit-card-minus,candy,arrow-left-right,lightbulb-off,panels-top-left,beef-off,locate-off,bug,test-tube,brick-wall,cooking-pot,boom-box,book-up,book-plus,laptop-minimal-check,mail-open,park,baggage-claim,variable,arrow-right,archive-restore",
                                ","
                            )
                        )
                    do
                        entries3[item] = key
                    end
                    local splitResult = string.split(
                        "1,175,0;1,650,0;1,850,250;2,150,0;1,250,700;1,600,225;1,575,800;2,225,225;1,50,350;1,675,25;1,500,425;1,50,400;1,75,925;1,825,50;1,50,75;1,175,800;1,375,925;1,850,450;1,325,50;1,100,325;1,650,225;1,950,475;1,725,300;1,425,125;1,650,850;1,50,375;1,550,425;2,50,125;1,25,725;1,300,200;1,825,500;1,300,575;1,500,800;1,950,225;1,525,925;1,500,375;1,775,525;1,100,100;1,900,100;2,200,50;1,325,125;2,100,400;1,175,550;1,175,975;1,75,650;1,100,825;1,225,375;1,525,700;1,500,675;2,225,200;1,500,825;1,75,350;1,325,325;1,50,475;1,775,375;1,600,675;1,450,50;1,900,25;1,300,350;1,775,900;1,775,925;2,50,50;1,750,800;2,175,325;1,25,975;1,750,475;1,250,600;1,250,75;1,425,450;1,925,725;1,725,550;1,875,575;1,650,350;1,100,175;1,800,725;2,250,25;1,100,450;2,225,300;1,550,675;2,0,450;1,350,975;2,25,300;1,250,125;1,50,525;1,100,75;1,275,550;1,525,675;1,775,300;1,550,975;1,700,225;1,150,650;1,150,100;2,375,100;1,575,625;1,75,775;1,700,300;1,300,675;1,775,475;1,475,275;1,950,375;1,350,425;1,250,100;1,750,0;2,325,100;1,50,225;1,75,400;1,450,725;1,550,725;1,250,350;1,250,750;1,575,225;2,350,0;1,75,900;1,125,550;1,100,525;1,75,325;1,350,350;1,650,825;1,200,0;1,575,400;1,400,300;1,700,600;1,525,50;1,550,75;1,200,200;1,800,900;1,950,875;1,300,500;1,150,775;1,950,200;1,100,275;1,525,500;2,0,200;1,500,50;1,425,250;1,200,925;1,325,225;1,875,100;1,75,150;2,100,175;1,775,575;1,475,300;1,450,525;1,375,100;2,325,25;1,175,600;1,300,750;1,375,475;2,150,275;1,750,650;1,575,650;1,0,100;1,550,50;1,475,750;1,850,0;2,100,350;2,50,25;1,300,325;1,550,775;2,200,100;1,325,250;1,75,475;1,500,450;1,25,675;1,825,275;1,50,425;1,75,600;1,775,600;1,25,325;1,125,225;1,250,625;1,50,450;1,125,575;2,375,50;1,25,900;2,25,400;1,275,50;1,125,175;1,50,125;1,250,800;1,500,775;1,925,625;1,0,900;1,0,425;1,25,100;1,450,375;1,500,75;1,900,325;1,0,875;1,350,25;1,525,825;1,400,900;1,325,450;1,200,750;1,350,200;1,400,100;1,950,675;1,25,650;2,75,375;1,200,400;1,150,500;1,750,950;1,300,925;1,450,800;1,450,25;1,75,50;2,50,200;1,475,500;1,725,625;1,225,825;1,325,500;1,75,300;1,375,775;1,0,800;1,625,525;1,875,75;1,650,500;1,350,775;1,875,350;1,75,225;1,25,300;1,175,100;2,50,325;1,800,275;2,250,300;1,775,425;1,800,425;2,275,275;1,900,625;1,400,500;1,700,125;1,700,200;1,175,575;1,125,100;2,300,250;1,950,725;1,625,575;1,325,400;1,275,450;1,950,350;1,725,350;2,300,150;1,850,975;1,475,400;1,325,375;1,725,425;2,150,250;1,100,675;2,400,150;1,875,0;2,75,325;1,75,550;2,75,425;1,300,600;1,700,775;1,50,50;1,750,425;2,450,100;2,475,75;2,50,475;1,725,800;1,675,800;1,825,750;1,975,700;2,125,400;2,150,375;1,575,475;2,450,75;1,175,775;1,75,450;1,625,925;2,250,275;1,400,75;1,275,950;1,775,125;1,650,150;1,700,475;1,525,625;1,725,775;2,325,200;1,400,250;2,350,175;2,175,200;1,600,950;1,225,475;1,600,525;1,100,200;1,550,125;2,400,125;2,375,150;1,600,100;1,0,175;1,700,350;1,0,650;2,175,350;1,100,300;2,75,200;1,300,950;2,50,450;1,550,700;1,900,675;1,150,375;2,150,350;2,475,50;1,525,125;2,150,200;2,225,275;1,375,900;1,475,325;2,275,225;1,750,200;1,975,325;1,575,250;1,50,175;1,175,425;1,0,525;2,250,250;2,325,175;1,500,100;2,300,200;1,575,900;1,500,625;1,775,150;1,275,575;2,425,75;1,650,200;1,875,725;2,400,100;2,450,50;1,475,850;1,200,250;2,475,25;1,350,700;1,775,400;2,0,475;1,75,275;1,550,200;1,450,250;1,775,725;2,25,450;1,725,575;1,750,375;2,75,400;2,100,375;1,625,850;2,125,350;1,225,775;1,650,800;1,150,50;2,200,275;2,200,225;1,250,850;1,800,75;2,225,250;1,875,900;2,275,200;2,300,175;2,100,0;2,0,25;1,50,500;1,600,325;2,250,225;1,50,325;1,150,900;2,325,150;1,500,325;1,325,825;2,400,75;1,750,675;2,450,25;1,950,150;1,0,725;2,350,125;1,300,550;1,225,0;2,475,0;1,600,250;1,600,175;1,350,375;1,575,850;1,250,250;2,25,425;1,275,650;1,325,425;1,700,0;1,650,425;1,825,200;2,125,150;1,375,550;2,125,325;1,25,425;1,325,725;1,250,150;1,600,975;1,550,525;1,525,100;1,925,25;1,125,625;1,200,150;1,0,150;1,275,250;1,700,450;2,175,275;1,150,300;2,250,200;1,800,950;1,75,500;1,550,300;1,350,150;1,200,775;1,225,450;1,50,275;1,900,300;1,0,250;1,125,825;1,500,300;2,175,300;1,850,525;2,350,100;1,575,0;1,575,200;2,375,75;1,325,600;1,200,275;1,275,100;1,700,500;2,125,50;1,775,750;2,425,25;1,550,925;1,925,300;1,825,325;2,0,425;1,675,650;2,75,350;1,0,625;1,500,25;1,0,550;1,900,200;2,50,375;1,975,875;1,875,300;2,125,300;1,250,0;1,850,900;2,250,100;2,250,175;1,425,325;2,25,50;1,725,850;2,275,150;1,800,200;1,600,350;1,425,700;1,625,100;1,25,525;1,200,700;1,325,25;1,375,425;1,650,275;2,400,25;1,925,100;1,200,650;2,425,0;1,225,425;1,125,425;2,0,400;2,25,375;1,125,675;1,475,900;1,575,300;2,225,125;1,775,200;1,225,125;2,100,300;2,125,275;1,275,775;1,650,675;1,450,550;1,25,600;1,400,575;1,250,725;2,375,175;1,825,850;1,675,975;1,500,225;1,425,425;1,625,825;2,175,225;1,600,925;1,500,350;2,200,200;1,300,900;1,400,325;2,200,75;1,725,700;1,975,525;2,100,325;1,525,175;2,275,125;1,200,850;1,125,950;1,700,425;1,725,125;2,300,100;1,300,450;1,525,300;2,325,75;2,75,50;1,725,875;1,950,325;1,775,775;1,675,600;2,75,275;2,350,50;1,225,400;2,400,0;1,25,500;1,100,400;1,100,500;2,0,375;1,750,575;1,75,0;2,25,350;1,300,525;1,600,425;1,450,750;1,600,300;1,150,550;1,600,50;1,225,250;2,125,250;1,150,525;1,600,375;1,125,600;1,275,975;1,575,100;2,75,300;2,150,225;1,900,900;1,200,75;1,900,75;1,725,225;1,475,50;1,25,400;1,325,475;1,900,375;2,200,175;2,250,125;1,725,200;1,350,750;1,50,900;1,175,525;1,550,350;2,275,75;1,225,675;1,0,850;2,50,100;1,650,525;2,300,75;1,500,250;1,400,0;2,375,0;1,850,300;1,50,775;2,0,350;1,425,150;2,25,325;1,475,600;1,150,275;1,600,75;2,50,300;1,125,150;1,150,150;1,450,475;2,100,250;1,400,200;2,200,300;1,925,275;1,725,100;2,300,50;1,475,450;2,175,250;2,175,175;2,325,50;1,550,150;1,25,150;2,125,0;2,50,275;1,875,775;1,25,200;1,175,500;1,375,200;2,50,350;1,400,800;1,125,250;1,525,425;1,825,450;2,125,200;1,125,500;2,150,175;2,225,100;2,200,125;1,525,850;1,75,250;2,275,50;2,300,25;2,150,150;2,0,300;1,675,725;1,150,750;1,0,825;2,75,225;1,500,925;2,50,250;2,100,200;1,900,450;1,175,950;2,125,175;1,200,50;1,750,725;1,450,425;2,175,125;2,325,0;1,800,850;1,75,725;1,200,625;1,200,25;1,700,700;1,875,125;2,225,75;1,900,700;2,250,50;1,825,975;1,875,225;2,300,0;1,525,875;2,25,250;1,325,300;1,475,800;2,0,275;1,525,250;2,425,100;2,175,100;1,950,125;1,875,325;1,100,575;2,275,0;1,100,550;1,825,950;1,150,875;1,600,25;1,100,950;1,900,950;1,500,650;1,0,0;1,125,400;1,975,900;2,25,225;1,250,950;2,125,125;2,150,100;2,100,150;2,175,75;1,300,725;1,300,75;1,925,850;1,50,825;1,325,775;1,375,50;1,850,25;1,450,450;2,250,0;1,750,975;1,600,475;1,375,650;1,475,25;2,50,175;1,700,850;2,25,200;1,450,300;1,50,950;1,900,825;2,100,125;1,700,525;1,25,250;1,575,25;2,125,100;1,475,725;1,375,275;2,150,75;2,175,50;2,225,0;1,400,125;1,775,975;2,25,175;1,750,925;1,50,800;1,100,25;1,375,675;1,475,375;1,150,975;1,350,225;2,75,125;1,625,400;1,700,150;2,125,75;1,475,950;1,850,675;1,0,675;2,150,300;1,50,975;2,200,0;2,75,100;2,25,150;1,700,375;1,575,325;1,625,50;1,50,0;1,900,525;1,875,825;1,125,75;1,850,175;2,0,175;2,150,25;2,0,150;1,475,75;1,425,950;1,850,650;1,675,0;2,75,75;2,100,50;1,400,725;1,400,375;1,425,275;2,125,25;2,0,125;2,25,100;2,25,125;1,200,725;1,300,175;2,50,75;1,400,650;1,100,350;2,0,325;1,375,975;2,0,100;1,975,550;2,75,25;2,75,0;2,0,50;1,225,350;1,800,125;1,375,950;1,575,375;1,975,800;1,950,0;1,300,875;2,425,125;2,50,0;2,25,0;1,50,250;1,125,775;2,0,0;1,250,875;1,950,975;1,700,250;1,225,325;1,650,75;1,900,925;1,100,900;1,950,950;1,325,700;1,300,800;1,500,0;1,425,200;1,675,375;1,850,50;1,350,675;1,525,325;1,175,175;1,450,0;1,75,125;1,300,650;1,950,925;1,925,975;1,875,975;1,925,925;1,875,950;1,900,350;1,25,350;1,950,525;1,525,950;1,925,475;1,950,900;1,975,850;2,275,25;1,350,550;1,775,100;1,275,300;1,850,950;1,825,650;1,950,450;1,975,825;1,850,925;1,125,850;1,900,875;1,125,275;1,900,275;2,50,150;1,825,925;1,725,650;1,625,950;1,900,850;1,475,975;1,300,150;1,950,800;1,175,225;1,400,400;1,975,775;1,350,525;1,975,75;1,800,925;1,825,900;1,850,750;1,850,875;1,350,0;1,875,850;1,275,875;1,400,50;1,950,775;1,450,125;1,975,750;1,600,800;1,400,450;1,150,950;1,850,850;1,900,800;1,925,775;1,800,550;1,100,600;1,75,425;1,100,0;1,975,725;1,650,450;1,700,975;1,750,875;1,475,350;1,0,350;1,325,175;1,725,950;2,300,225;1,750,775;1,25,0;1,300,425;1,950,600;1,475,175;2,200,250;1,150,700;2,100,425;1,700,950;1,400,475;1,725,925;1,450,150;1,75,700;1,575,675;1,325,275;1,225,175;1,775,875;1,975,400;1,675,875;1,800,775;1,200,350;1,550,500;1,175,725;2,100,225;1,575,525;1,75,375;1,50,750;1,500,400;1,250,450;1,325,100;1,825,250;1,900,750;1,950,700;1,975,675;1,425,25;1,375,825;1,650,975;1,375,450;1,700,925;1,900,175;1,800,625;1,575,725;1,775,850;1,275,225;1,925,75;1,800,825;1,700,750;1,575,575;1,825,800;1,850,775;1,275,900;1,425,100;1,900,725;1,600,875;1,975,650;1,850,200;1,675,50;1,325,625;2,225,50;1,225,75;1,250,175;1,800,975;1,375,625;1,100,375;1,850,425;1,425,625;1,675,925;1,700,900;1,750,850;1,525,975;1,400,150;1,900,575;1,100,225;1,350,275;1,650,250;1,875,425;1,200,500;1,925,675;1,750,25;1,950,650;1,800,250;1,975,625;1,700,175;1,150,250;1,925,200;1,50,200;1,200,325;1,375,75;1,800,575;1,525,0;1,925,525;1,875,400;1,850,275;1,925,750;1,875,875;1,425,675;1,875,25;1,925,400;1,100,975;1,325,0;1,675,900;1,550,175;1,700,875;1,475,925;1,150,0;1,750,825;1,50,150;1,975,175;1,800,650;1,775,800;1,825,825;1,175,825;1,850,725;1,650,475;1,825,150;1,450,500;1,900,775;1,0,975;2,75,450;2,125,375;1,925,650;1,225,500;1,900,0;1,950,25;1,575,175;1,100,50;1,400,925;1,225,875;1,575,975;1,475,100;1,650,900;1,150,125;1,300,100;1,725,825;2,375,25;1,800,750;1,700,825;1,575,350;1,825,725;1,175,300;1,775,625;1,725,450;1,275,275;1,425,525;1,875,675;1,900,650;1,875,800;1,575,550;1,975,250;1,975,575;1,350,575;1,725,275;1,225,950;1,675,850;1,175,125;1,650,600;1,850,825;1,825,700;1,925,600;1,950,575;2,25,75;1,425,925;1,775,825;1,625,300;1,0,925;1,200,375;1,175,200;1,200,950;1,600,650;1,700,275;1,100,125;1,575,925;1,600,900;1,625,875;1,650,50;1,700,800;1,300,250;1,625,125;1,50,550;1,675,825;2,275,250;1,750,750;1,875,650;1,800,700;1,25,875;1,825,675;1,375,575;1,125,300;1,875,625;1,925,575;1,825,400;1,150,450;2,225,175;1,850,500;1,950,550;1,850,475;2,375,125;1,475,125;1,925,700;1,375,500;1,500,175;1,500,975;1,725,750;1,800,675;1,150,800;1,925,875;1,850,625;1,775,50;1,800,800;1,800,300;1,775,700;1,775,175;1,925,550;1,0,75;1,125,875;1,450,400;1,925,825;1,975,500;1,175,275;1,500,900;1,400,225;1,100,475;1,300,625;1,575,500;1,325,800;1,625,775;1,575,875;1,675,775;1,675,200;1,550,750;1,625,625;1,650,325;1,800,375;1,625,350;1,475,825;1,775,675;1,700,100;1,675,75;1,250,375;1,25,25;1,0,325;1,875,450;1,825,625;1,650,100;1,850,600;1,600,850;1,500,275;1,725,150;1,650,700;1,625,0;1,800,525;1,550,0;1,125,50;1,975,475;2,50,425;2,150,50;1,300,700;1,950,500;1,550,875;1,475,200;1,600,825;1,625,800;1,650,775;1,675,400;1,675,750;1,325,525;2,425,50;1,275,125;1,700,725;1,725,900;1,375,150;1,800,150;1,825,600;1,450,100;1,850,575;1,875,550;1,925,500;2,100,75;1,425,50;1,375,700;1,200,125;1,225,200;1,400,625;1,200,525;1,75,750;1,300,25;2,0,75;1,425,975;1,450,950;1,150,725;1,550,850;1,575,825;1,550,900;1,700,325;1,725,675;1,800,600;2,0,250;1,150,600;1,825,575;1,900,500;1,725,475;1,300,825;1,525,775;1,625,725;1,750,175;1,875,525;1,950,850;1,975,425;1,400,975;1,825,225;1,925,900;1,725,600;1,375,375;1,325,950;1,775,350;1,450,75;2,175,0;1,450,925;1,600,700;2,75,250;1,275,200;1,550,450;2,250,75;1,350,250;1,300,375;1,500,875;1,0,775;1,625,675;1,50,700;1,375,25;1,975,350;1,600,775;1,425,0;1,25,625;1,625,200;1,375,600;1,700,675;1,525,750;1,525,350;1,750,625;1,375,525;1,800,25;1,900,475;1,250,200;1,925,450;2,200,325;1,850,800;1,400,950;1,825,550;1,450,900;1,475,575;1,475,875;1,500,850;1,625,500;1,925,325;1,275,350;1,400,750;1,600,750;1,25,575;1,550,800;1,75,175;1,675,675;1,700,650;1,275,925;1,675,225;1,750,600;1,950,750;1,675,125;1,825,525;1,875,475;2,100,25;1,950,400;1,450,675;1,800,50;1,950,625;1,25,775;1,625,550;1,600,600;1,725,75;1,625,75;1,575,125;1,975,450;1,150,175;1,675,575;1,25,375;1,425,900;1,400,275;1,275,600;1,975,25;1,875,275;1,400,525;1,550,600;1,450,875;2,25,275;1,75,975;1,0,225;1,600,725;1,25,800;1,625,700;1,700,625;1,650,375;1,900,550;1,775,550;1,850,75;1,800,475;1,900,425;1,325,975;1,425,800;1,650,725;1,350,950;1,825,875;1,450,850;1,250,925;1,450,600;1,725,725;1,575,150;1,675,950;1,125,350;1,800,100;1,425,225;1,675,625;1,450,975;1,225,50;1,750,550;1,550,825;2,275,175;1,175,375;1,825,475;1,825,775;1,0,375;1,750,225;1,900,400;1,650,25;1,300,975;1,525,75;1,400,875;1,425,850;1,850,150;1,450,825;2,50,225;1,225,25;1,0,400;1,625,650;1,650,625;1,300,50;1,550,25;1,750,525;1,775,500;1,925,350;1,850,325;1,275,0;1,975,300;1,750,325;2,25,475;1,325,925;1,350,900;1,525,600;1,750,250;1,475,550;1,475,775;1,400,850;1,500,750;1,575,275;1,750,900;1,900,225;1,700,550;1,0,450;1,725,525;1,750,500;1,800,0;1,825,425;1,750,300;1,175,25;1,0,50;1,650,875;1,75,100;1,850,400;1,25,75;1,875,375;1,175,700;1,475,250;1,950,50;1,100,625;1,275,175;1,575,425;1,575,775;1,725,375;1,125,700;1,450,625;1,225,625;1,250,975;1,800,875;1,150,225;1,425,550;1,450,700;1,350,875;1,350,325;1,100,750;1,325,900;1,400,825;1,375,850;2,0,225;1,25,275;1,225,900;1,850,225;1,475,675;1,550,325;1,225,525;1,600,625;1,625,600;1,600,575;1,650,575;1,725,500;1,0,750;1,675,550;1,200,675;1,850,375;1,525,725;1,350,50;1,475,475;1,950,275;1,200,575;1,225,975;2,75,175;1,925,225;1,50,925;1,325,875;1,625,375;1,350,400;1,350,850;1,425,775;1,200,900;1,550,650;1,425,175;1,675,525;1,950,100;1,475,0;1,175,50;1,650,750;1,125,375;1,125,525;1,550,250;1,850,100;1,75,575;1,825,375;1,375,175;1,25,225;1,650,950;1,250,900;1,250,400;1,975,225;1,600,550;1,50,600;1,0,575;1,200,975;1,675,250;1,625,900;1,250,300;1,700,50;1,875,750;1,325,850;1,250,475;1,325,350;1,600,150;1,25,175;1,175,75;1,350,825;1,375,725;1,400,775;1,425,750;1,475,700;1,300,775;1,500,150;1,75,625;1,475,225;1,175,900;1,550,625;1,200,875;1,350,300;1,125,200;1,300,850;1,375,400;1,675,500;2,25,25;1,650,400;1,825,350;1,175,875;1,625,225;1,525,450;1,950,825;1,200,100;1,125,25;1,750,700;1,150,25;1,275,725;1,50,25;1,375,225;1,975,200;1,225,925;1,950,250;1,300,125;1,450,350;1,925,800;1,350,800;1,425,725;1,825,0;1,950,300;2,150,125;1,250,675;1,750,400;1,225,300;1,200,300;1,800,350;2,450,0;1,900,250;1,125,475;1,425,375;1,400,175;1,625,325;1,975,975;1,175,475;1,500,725;1,750,100;1,100,650;1,775,275;1,275,500;1,475,650;1,975,375;2,300,125;1,375,875;1,750,50;1,425,875;2,350,75;1,800,325;1,250,775;1,950,175;1,975,150;1,200,225;1,175,925;1,650,550;1,175,650;1,975,600;1,50,725;1,0,200;1,300,0;1,825,300;2,325,125;1,250,425;1,200,450;1,200,425;2,225,25;1,250,25;1,375,800;1,475,625;1,175,450;1,450,650;1,400,700;1,750,125;1,850,700;1,275,750;1,550,550;1,500,600;1,450,575;1,50,100;1,600,500;1,150,400;1,350,450;1,100,725;1,625,475;1,100,425;1,300,475;1,975,100;1,725,175;1,700,400;1,75,25;1,450,225;2,250,150;1,675,350;1,950,425;1,925,175;1,975,125;1,550,475;1,500,700;1,575,600;1,225,850;1,250,825;1,550,400;1,275,800;1,375,125;1,525,650;1,325,750;1,400,675;1,350,725;1,350,650;1,225,100;1,425,650;1,975,275;1,525,525;1,500,575;1,25,50;1,100,875;1,550,275;1,350,75;1,500,950;1,725,975;1,450,775;1,275,25;1,300,400;2,175,25;2,325,225;1,875,200;1,350,475;1,50,850;1,225,750;1,325,575;1,925,150;1,575,750;1,325,150;1,275,325;1,600,0;1,425,300;1,850,550;1,725,25;1,50,650;1,125,925;1,750,350;1,925,425;1,350,100;1,775,325;1,625,425;1,0,25;1,725,325;1,600,450;1,375,750;1,875,175;1,600,275;1,925,125;1,525,275;1,0,275;1,925,0;1,775,950;1,75,950;1,175,350;1,100,925;1,125,900;1,175,250;1,175,850;1,200,825;1,225,800;1,825,125;1,875,250;1,425,600;1,500,525;1,575,450;1,325,200;1,500,125;1,125,750;1,300,300;1,275,400;1,700,25;2,100,275;2,100,100;1,150,925;1,750,275;1,225,600;1,775,250;1,325,75;1,275,850;1,675,100;1,875,150;1,150,425;1,900,125;1,350,125;1,200,800;1,150,325;1,975,50;1,250,275;1,300,275;2,75,150;1,150,850;1,950,75;2,150,325;1,975,950;1,250,575;1,525,900;1,625,250;1,400,600;1,425,575;1,475,525;1,500,500;1,100,800;1,250,225;1,25,750;1,525,475;1,600,400;1,675,325;1,575,950;1,425,825;1,400,425;1,675,175;1,150,625;1,200,175;1,550,575;1,225,275;1,375,0;1,350,925;1,825,175;1,175,400;1,25,950;1,150,825;1,400,550;1,525,375;1,350,625;1,275,700;1,500,475;1,550,950;1,200,475;1,225,575;1,775,75;1,275,375;1,725,250;1,600,200;1,100,250;1,200,550;1,875,500;1,850,125;1,925,50;1,975,0;1,0,950;1,25,850;1,675,150;1,375,300;1,125,125;1,25,550;1,25,925;1,100,850;1,800,500;1,275,75;1,225,725;1,125,800;1,775,25;1,275,675;1,550,100;1,925,950;1,625,975;1,900,600;1,350,600;1,650,300;1,675,275;1,900,50;1,50,875;1,75,850;1,50,575;1,175,750;1,300,225;1,225,700;1,675,475;1,525,225;2,200,150;1,550,375;1,525,400;1,850,350;2,225,150;2,350,150;1,825,100;1,0,125;1,875,50;1,75,825;1,525,800;2,350,25;1,250,325;1,250,650;1,275,625;1,675,300;1,125,325;1,0,300;1,875,925;1,600,125;1,50,300;1,175,675;1,425,475;1,475,425;1,325,650;1,625,275;1,25,475;1,750,150;1,725,0;1,225,650;1,800,225;1,650,925;1,100,775;1,75,800;1,325,550;1,250,525;1,525,200;2,350,200;1,900,150;1,325,675;2,275,100;1,25,825;1,125,725;1,775,650;1,350,500;1,175,150;1,725,400;1,900,975;1,775,450;1,775,225;1,825,25;1,500,200;1,550,225;1,150,675;2,50,400;1,525,550;1,650,175;1,750,75;1,875,600;1,275,425;1,250,500;1,175,625;1,0,700;1,125,0;1,200,600;1,250,550;1,400,350;1,25,700;1,800,400;1,625,175;1,675,450;1,800,450;1,625,25;1,925,375;1,0,500;1,675,425;1,425,350;1,450,325;1,225,550;1,650,125;1,375,350;1,700,75;1,725,50;1,150,200;1,775,0;1,625,750;1,75,675;1,25,125;1,575,50;1,825,75;1,800,175;1,275,475;1,275,525;1,275,150;1,425,500;1,50,675;1,150,575;1,75,75;1,425,400;1,450,275;1,100,700;1,225,225;1,375,325;1,50,625;1,0,475;1,75,875;1,525,150;1,675,700;1,750,450;1,275,825;1,450,200;1,150,350;1,650,650;1,875,700;1,575,75;2,175,150;1,150,475;1,75,525;1,975,925;1,450,175;1,475,150;1,0,600;1,375,250;1,925,250;2,125,225;1,100,150;1,125,650;1,125,450;1,75,200;1,625,450;1,700,575;1,400,25;1,525,575;1,525,25;2,200,25;1,350,175;1,625,150;1,175,325;1,425,75;1,25,450;1,500,550;1,125,975;1,575,700;1,225,150;2,400,50;1,250,50;1,150,75",
                        ";"
                    )
                    icons.module = {
                        GetAsset = function(iconName)
                            local splitResult2 = entries3[iconName] or entries3[entries2[iconName] or ""]
                            local calculatedValue = splitResult2 and splitResult[splitResult2]
                            if not calculatedValue then
                                return nil
                            end
                            splitResult2 = string.split(calculatedValue, ",")
                            return {
                                IconName = iconName,
                                Url = entries[tonumber(splitResult2[1])],
                                ImageRectSize = point,
                                ImageRectOffset = Vector2.new(tonumber(splitResult2[2]), tonumber(splitResult2[3])),
                            }
                        end,
                    }
                    local waiting = icons.waiting
                    icons.waiting = {}
                    for unused, item in ipairs(waiting) do
                        pcall(item)
                    end
                    return icons.module
                end
                icons.resolve = function(argument)
                    if argument then
                        if argument == "" then
                            return nil
                        end
                    else
                        return nil
                    end
                    if type(argument) == "number" or tostring(argument):match("^%d+$") then
                        return {
                            Url = "rbxassetid://" .. tostring(argument),
                            ImageRectOffset = Vector2.zero,
                            ImageRectSize = Vector2.zero,
                        }
                    end
                    if tostring(argument):match("^rbx") then
                        return { Url = tostring(argument), ImageRectOffset = Vector2.zero, ImageRectSize = Vector2.zero }
                    end
                    if not icons.module then
                        icons.load()
                    end
                    if not icons.module then
                        return nil
                    end
                    local success, result = pcall(icons.module.GetAsset, argument)
                    if success then
                        if type(result) == "table" then
                            return result
                        end
                    end
                    return nil
                end
                icons.apply = function(argument, argument2)
                    if typeof(argument) ~= "Instance" then
                        return
                    end
                    local function isActive2()
                        local resolveResult = icons.resolve(argument2)
                        if resolveResult then
                            argument.Image = resolveResult.Url
                            argument.ImageRectOffset = resolveResult.ImageRectOffset or Vector2.zero
                            argument.ImageRectSize = resolveResult.ImageRectSize or Vector2.zero
                            argument.Visible = true
                        end
                    end
                    if not icons.module then
                        icons.load()
                    end
                    isActive2()
                end
            end
            do
                local sound = { volume = 0.5, enabled = true, cache = {}, folder = "GGH/nova" }
                localization2.Sound = sound
                local function callback(argument)
                    if argument < -1 then
                        return -1
                    end
                    if argument > 1 then
                        return 1
                    end
                    return argument
                end
                local function callback2(argument)
                    local count = #argument
                    local entries, createResult =
                        {
                            "RIFF",
                            string.pack("<I4", 36 + count * 2),
                            "WAVE",
                            "fmt ",
                            string.pack("<I4I2I2I4I4I2I2", 16, 1, 1, 22050, 44100, 2, 16),
                            "data",
                            string.pack("<I4", count * 2),
                        },
                        table.create(count)
                    for index = 1, count, 1 do
                        local roundedValue = math.floor(callback(argument[index]) * 32767)
                        createResult[index] = string.pack("<i2", roundedValue)
                    end
                    return table.concat(entries) .. table.concat(createResult)
                end
                local function callback3(argument)
                    local dur = argument.dur
                    local roundedValue = math.floor(22050 * dur)
                    local createResult, entries = table.create(roundedValue), {}
                    for index = 1, roundedValue, 1 do
                        local calculatedValue = (index - 1) / 22050
                        local calculatedValue2, counter = calculatedValue / dur, 0
                        for key, item in ipairs(argument.tones) do
                            local calculatedValue3 = item.f0
                                + (item.f1 - item.f0) * math.min(1, calculatedValue2 / (item.glide or 1))
                            entries[key] = (entries[key] or 0) + 6.283185307179586 * calculatedValue3 / 22050
                            calculatedValue3 = math.exp(-calculatedValue * (item.decay or 30))
                                * math.min(1, calculatedValue / (item.attack or 0.002))
                            calculatedValue3 = if item.start
                                then if calculatedValue < item.start then 0 else calculatedValue3
                                else calculatedValue3
                            calculatedValue3 = if item.start
                                then if calculatedValue >= item.start
                                    then math.exp(-(calculatedValue - item.start) * (item.decay or 30)) * math.min(
                                        1,
                                        (calculatedValue - item.start) / (item.attack or 0.002)
                                    )
                                    else calculatedValue3
                                else calculatedValue3
                            counter += math.sin(entries[key]) * calculatedValue3 * (item.amp or 0.5)
                        end
                        createResult[index] = if argument.noise
                            then counter + (math.random() * 2 - 1) * argument.noise * math.exp(
                                -calculatedValue * 90
                            )
                            else counter
                    end
                    return createResult
                end
                sound.specs =
                    {
                        click = {
                            dur = 0.07,
                            tones = { { f0 = 1900, f1 = 1300, decay = 70, amp = 0.55 }, {
                                f0 = 3800,
                                f1 = 2600,
                                decay = 120,
                                amp = 0.18,
                            } },
                            noise = 0.05,
                        },
                        hover = { dur = 0.035, tones = { { f0 = 2600, f1 = 2400, decay = 160, amp = 0.22 } } },
                        on = {
                            dur = 0.12,
                            tones = {
                                { f0 = 880, f1 = 880, decay = 40, amp = 0.4 },
                                { f0 = 1320, f1 = 1320, decay = 40, amp = 0.4, start = 0.045 },
                            },
                        },
                        off = {
                            dur = 0.12,
                            tones = {
                                { f0 = 1320, f1 = 1320, decay = 40, amp = 0.35 },
                                { f0 = 880, f1 = 880, decay = 40, amp = 0.35, start = 0.045 },
                            },
                        },
                        open = {
                            dur = 0.22,
                            tones = {
                                { f0 = 520, f1 = 980, glide = 0.5, decay = 16, amp = 0.35 },
                                { f0 = 1040, f1 = 1960, glide = 0.5, decay = 22, amp = 0.12 },
                            },
                        },
                        close = { dur = 0.18, tones = { { f0 = 980, f1 = 520, glide = 0.6, decay = 20, amp = 0.3 } } },
                        notify = {
                            dur = 0.45,
                            tones = {
                                { f0 = 1175, f1 = 1175, decay = 9, amp = 0.3 },
                                { f0 = 1568, f1 = 1568, decay = 9, amp = 0.28, start = 0.09 },
                            },
                        },
                        tick = { dur = 0.025, tones = { { f0 = 3200, f1 = 3000, decay = 220, amp = 0.16 } } },
                    }
                sound.asset = function(argument)
                    if sound.cache[argument] ~= nil then
                        return sound.cache[argument]
                    end
                    sound.cache[argument] = false
                    local success, result = pcall(function()
                        if writefile then
                            if not getcustomasset then
                                return nil
                            end
                        else
                            return nil
                        end
                        if isfolder then
                            if makefolder then
                                if not (isfolder("GGH")) then
                                    makefolder("GGH")
                                end
                                if not (isfolder(sound.folder)) then
                                    makefolder(sound.folder)
                                end
                            end
                        end
                        local calculatedValue = sound.folder .. "/" .. argument .. ".wav"
                        if not (isfile and isfile(calculatedValue)) then
                            writefile(calculatedValue, callback2(callback3(sound.specs[argument])))
                        end
                        return getcustomasset(calculatedValue)
                    end)
                    if success then
                        if result then
                            sound.cache[argument] = result
                        end
                    end
                    return sound.cache[argument]
                end
                sound.play = function(parent, argument)
                    if sound.enabled then
                        if sound.volume <= 0 then
                            return
                        end
                    else
                        return
                    end
                    local soundId = sound.asset(parent)
                    if not soundId then
                        return
                    end
                    parent = sound.host
                    if not parent then
                        return
                    end
                    local sound2 = Instance.new("Sound")
                    sound2.SoundId = soundId
                    sound2.Volume = sound.volume * (argument or 1)
                    sound2.Parent = parent
                    sound2:Play()
                    task.delay(1, function()
                        sound2:Destroy()
                    end)
                end
                sound.preload = function()
                    task.spawn(function()
                        for key in pairs(sound.specs) do
                            pcall(sound.asset, key)
                        end
                    end)
                end
            end
            do
                local store = {}
                localization2.Store = store
                local httpService2 = localization2.Services.HttpService
                store.new = function(path)
                    local entries = { path = path, data = {}, dirty = false }
                    pcall(function()
                        if path then
                            if isfile then
                                if readfile then
                                    if isfile(path) then
                                        local data = httpService2:JSONDecode(readfile(path))
                                        if type(data) == "table" then
                                            entries.data = data
                                        end
                                    end
                                end
                            end
                        end
                    end)
                    entries.get = function(argument, argument2)
                        local entry = entries.data[argument]
                        if entry == nil then
                            return argument2
                        end
                        return entry
                    end
                    entries.set = function(argument, argument2)
                        if entries.data[argument] == argument2 then
                            return
                        end
                        entries.data[argument] = argument2
                        entries.save()
                    end
                    entries.save = function()
                        if entries.dirty then
                            return
                        end
                        entries.dirty = true
                        task.delay(0.6, function()
                            entries.dirty = false
                            pcall(function()
                                if path then
                                    if not writefile then
                                        return
                                    end
                                else
                                    return
                                end
                                if isfolder then
                                    if makefolder then
                                        if not (isfolder("GGH")) then
                                            makefolder("GGH")
                                        end
                                        if not (isfolder("GGH/nova")) then
                                            makefolder("GGH/nova")
                                        end
                                    end
                                end
                                writefile(path, httpService2:JSONEncode(entries.data))
                            end)
                        end)
                    end
                    return entries
                end
            end
            runService = localization2.Refresh
            table.insert(runService.full, function(argument)
                localization2.Theme.applyOne(argument)
            end)
            table.insert(runService.full, localization2.U.radiusOne)
            table.insert(runService.full, localization2.Font.fontOne)
            table.insert(runService.full, localization2.Font.sizeOne)
            do
                local tex = { cache = {}, folder = "GGH/nova/tex", version = "v7" }
                localization2.Tex = tex
                local createResult
                local function callback(argument)
                    if not createResult then
                        createResult = table.create(256)
                        for index = 0, 255, 1 do
                            local value = index
                            for unused = 1, 8, 1 do
                                value = if bit32.band(value, 1) == 1
                                    then bit32.bxor(3988292384, bit32.rshift(value, 1))
                                    else bit32.rshift(value, 1)
                            end
                            createResult[index] = value
                        end
                    end
                    local fromstringResult = buffer.fromstring(argument)
                    local calculatedValue, counter = buffer.len(fromstringResult) - 1, 4294967295
                    for index = 0, calculatedValue, 1 do
                        local bxor, value = bit32.bxor, createResult
                        counter = (
                            bxor(
                                value[bit32.band(bit32.bxor(counter, buffer.readu8(fromstringResult, index)), 255)],
                                bit32.rshift(counter, 8)
                            )
                        )
                    end
                    return bit32.bxor(counter, 4294967295)
                end
                local function callback2(argument, argument2)
                    return string.pack(">I4", #argument2)
                        .. argument
                        .. argument2
                        .. string.pack(">I4", callback(argument .. argument2))
                end
                tex.encode = function(argument, argument2, callback)
                    local entries = argument * 4 + 1
                    local createResult, counter = buffer.create(entries * argument2), 0
                    for index = 0, argument2 - 1, 1 do
                        buffer.writeu8(createResult, counter, 0)
                        counter += 1
                        for index2 = 0, argument - 1, 1 do
                            local value, value2, value3, value4 = callback(index2, index)
                            buffer.writeu8(createResult, counter, math.clamp(math.floor(value + 0.5), 0, 255))
                            buffer.writeu8(createResult, counter + 1, math.clamp(math.floor(value2 + 0.5), 0, 255))
                            buffer.writeu8(createResult, counter + 2, math.clamp(math.floor(value3 + 0.5), 0, 255))
                            buffer.writeu8(createResult, counter + 3, math.clamp(math.floor(value4 + 0.5), 0, 255))
                            counter += 4
                        end
                    end
                    local lenResult, calculatedValue, calculatedValue2 = buffer.len(createResult), 1, 0
                    for index = 0, lenResult - 1, 1 do
                        calculatedValue = (calculatedValue + buffer.readu8(createResult, index)) % 65521
                        calculatedValue2 = (calculatedValue2 + calculatedValue) % 65521
                    end
                    entries, callback = { "x\001" }, 0
                    while callback < lenResult do
                        local minimumValue = math.min(65535, lenResult - callback)
                        local calculatedValue3 = callback + minimumValue >= lenResult and 1 or 0
                        table.insert(
                            entries,
                            string.char(calculatedValue3)
                                .. string.pack("<I2I2", minimumValue, bit32.bxor(minimumValue, 65535))
                        )
                        table.insert(entries, buffer.readstring(createResult, callback, minimumValue))
                        callback += minimumValue
                    end
                    table.insert(entries, string.pack(">I4", calculatedValue2 * 65536 + calculatedValue))
                    return "\137PNG\013\010\026\010"
                        .. callback2("IHDR", string.pack(">I4I4", argument, argument2) .. "\008\006\000\000\000")
                        .. callback2("IDAT", table.concat(entries))
                        .. callback2("IEND", "")
                end
                local function callback3(argument, argument2, argument3)
                    local clampedValue = math.clamp((argument3 - argument) / (argument2 - argument), 0, 1)
                    return clampedValue * clampedValue * (3 - 2 * clampedValue)
                end
                local function callback2(
                    maximumValue,
                    maximumValue2,
                    argument,
                    argument2,
                    argument3,
                    argument4,
                    argument5
                )
                    local calculatedValue, calculatedValue2 =
                        math.abs(maximumValue - argument) - (argument3 - argument5),
                        math.abs(maximumValue2 - argument2) - (argument4 - argument5)
                    maximumValue2, maximumValue = math.max(calculatedValue, 0), math.max(calculatedValue2, 0)
                    return math.sqrt(maximumValue2 * maximumValue2 + maximumValue * maximumValue)
                        + math.min(math.max(calculatedValue, calculatedValue2), 0)
                        - argument5
                end
                local function callback(argument)
                    return math.clamp(0.5 - argument, 0, 1)
                end
                local function callback4(argument, argument2, argument3)
                    local calculatedValue = math.sin(argument * 127.1 + argument2 * 311.7 + argument3 * 74.7)
                        * 43758.5453
                    return calculatedValue - math.floor(calculatedValue)
                end
                local function callback5(argument)
                    return function(argument2, argument3)
                        local counter = 0
                        for unused, item in ipairs(argument) do
                            local calculatedValue, calculatedValue2 =
                                (argument2 - item[1]) / item[3], (argument3 - item[2]) / item[4]
                            counter += item[5] * math.exp(
                                -(calculatedValue * calculatedValue + calculatedValue2 * calculatedValue2)
                            )
                        end
                        return counter
                    end
                end
                tex.specs = {
                    grain = {
                        w = 128,
                        h = 128,
                        tile = true,
                        px = function()
                            return function(argument, argument2)
                                local calculatedValue = callback4(argument, argument2, 3.3) * 0.7
                                    + callback4(argument * 0.5, argument2 * 0.5, 9.1) * 0.3
                                return 255, 255, 255, calculatedValue * calculatedValue * 64
                            end
                        end,
                    },
                    glow = {
                        w = 256,
                        h = 256,
                        px = function()
                            return function(argument, argument2)
                                local sqrtResult =
                                    math.sqrt(((argument + 0.5) / 128 - 1) ^ 2 + ((argument2 + 0.5) / 128 - 1) ^ 2)
                                return 255, 255, 255, math.max(0, 1 - sqrtResult) ^ 2.3 * 255
                            end
                        end,
                    },
                    vignette = {
                        w = 256,
                        h = 256,
                        px = function()
                            return function(argument, argument2)
                                local calculatedValue, calculatedValue2 =
                                    (argument + 0.5) / 128 - 1, (argument2 + 0.5) / 128 - 1
                                return 0,
                                    0,
                                    0,
                                    callback3(
                                        0.45,
                                        1.35,
                                        (
                                            math.sqrt(
                                                calculatedValue * calculatedValue * 0.8
                                                    + calculatedValue2 * calculatedValue2
                                            )
                                        )
                                    ) * 255
                            end
                        end,
                    },
                    knob = {
                        w = 128,
                        h = 128,
                        px = function()
                            return function(sqrtResult, argument)
                                local calculatedValue, maximumValue = sqrtResult + 0.5 - 64, argument + 0.5 - 64
                                sqrtResult =
                                    math.sqrt(calculatedValue * calculatedValue + maximumValue * maximumValue)
                                local clampedValue, minimumValue, calculatedValue2, calculatedValue3 =
                                    math.clamp(63 - sqrtResult + 0.5, 0, 1),
                                    (1 - 0.2 * ((maximumValue + 63) / 126)) * (1 - 0.14 * math.clamp(
                                        (sqrtResult - 52) / 11,
                                        0,
                                        1
                                    )),
                                    (calculatedValue + 14) / 34,
                                    (maximumValue + 30) / 22
                                maximumValue = math.max(
                                    0,
                                    1 - (calculatedValue2 * calculatedValue2 + calculatedValue3 * calculatedValue3)
                                )
                                minimumValue = math.min(1, minimumValue + 0.1 * maximumValue ^ 1.5)
                                return 255 * minimumValue,
                                    255 * minimumValue,
                                    255 * minimumValue,
                                    255 * clampedValue
                            end
                        end,
                    },
                    pillfill = {
                        w = 96,
                        h = 48,
                        px = function()
                            return function(argument, argument2)
                                return 255,
                                    255,
                                    255,
                                    255 * callback(callback2(argument + 0.5, argument2 + 0.5, 48, 24, 48, 24, 24))
                            end
                        end,
                    },
                    trackshade = {
                        w = 96,
                        h = 48,
                        px = function()
                            return function(calculatedValue, calculatedValue2)
                                local clampedValue, clampedValue2 = calculatedValue + 0.5, calculatedValue2 + 0.5
                                calculatedValue = callback2(clampedValue, clampedValue2, 48, 24, 48, 24, 24)
                                local value, value2, calculatedValue3 =
                                    -calculatedValue, callback(calculatedValue), clampedValue2 / 48
                                clampedValue = math.clamp(1.15 - 1.6 * calculatedValue3, 0, 1)
                                clampedValue2 = 0.55 * (1 - callback3(0, 11, value)) * clampedValue
                                    + 0.16 * (1 - callback3(0, 5, value))
                                clampedValue2 = math.clamp(clampedValue2, 0, 0.7)
                                calculatedValue = 0.1
                                    * (1 - callback3(0, 5, value))
                                    * math.clamp((calculatedValue3 - 0.5) * 3, 0, 1)
                                clampedValue = clampedValue2 + calculatedValue * (1 - clampedValue2)
                                calculatedValue2 = clampedValue > 0
                                        and 255 * calculatedValue * (1 - clampedValue2) / clampedValue
                                    or 0
                                return calculatedValue2,
                                    calculatedValue2,
                                    calculatedValue2,
                                    255 * clampedValue * value2
                            end
                        end,
                    },
                    dots = {
                        w = 24,
                        h = 24,
                        tile = true,
                        px = function()
                            return function(argument, argument2)
                                local sqrtResult = math.sqrt((argument + 0.5 - 12) ^ 2 + (argument2 + 0.5 - 12) ^ 2)
                                return 255, 255, 255, 255 * math.clamp(1.25 - sqrtResult, 0, 1)
                            end
                        end,
                    },
                    grid = {
                        w = 40,
                        h = 40,
                        tile = true,
                        px = function()
                            return function(argument, argument2)
                                local calculatedValue = (argument == 0 or argument2 == 0) and 1 or 0
                                return 255,
                                    255,
                                    255,
                                    255 * (if argument == 0
                                        then if argument2 == 0 then 1 else calculatedValue
                                        else calculatedValue)
                            end
                        end,
                    },
                    diag = {
                        w = 20,
                        h = 20,
                        tile = true,
                        px = function()
                            return function(argument, argument2)
                                local calculatedValue = (argument + argument2) % 10 / 10
                                return 255,
                                    255,
                                    255,
                                    255 * (1 - callback3(0.12, 0.3, math.abs(calculatedValue - 0.06) * 2))
                            end
                        end,
                    },
                    crosses = {
                        w = 32,
                        h = 32,
                        tile = true,
                        px = function()
                            return function(argument, argument2)
                                local numberValue, numberValue2 =
                                    math.abs(argument + 0.5 - 16), math.abs(argument2 + 0.5 - 16)
                                return 255,
                                    255,
                                    255,
                                    (
                                        numberValue < 0.9 and numberValue2 < 4.2
                                        or numberValue2 < 0.9 and numberValue < 4.2
                                    )
                                            and 255
                                        or 0
                            end
                        end,
                    },
                    scan = {
                        w = 4,
                        h = 4,
                        tile = true,
                        px = function()
                            return function(unused, argument)
                                return 255, 255, 255, argument == 0 and 255 or 0
                            end
                        end,
                    },
                    stripes = {
                        w = 32,
                        h = 32,
                        tile = true,
                        px = function()
                            return function(argument, argument2)
                                local calculatedValue = math.sin(
                                    (argument + argument2) / 16 * 3.141592653589793 * 2
                                ) * 0.5 + 0.5
                                return 255, 255, 255, 255 * calculatedValue * calculatedValue
                            end
                        end,
                    },
                    checker = {
                        w = 16,
                        h = 16,
                        tile = true,
                        px = function()
                            return function(argument, argument2)
                                local calculatedValue = (math.floor(argument / 8) + math.floor(
                                            argument2 / 8
                                        )) % 2 == 0
                                        and 74
                                    or 52
                                return calculatedValue, calculatedValue, calculatedValue + 4, 255
                            end
                        end,
                    },
                    meshA = {
                        w = 256,
                        h = 160,
                        px = function()
                            local callback6 = callback5({
                                { 0.12, 0.18, 0.42, 0.55, 1 },
                                { 0.62, 0.05, 0.32, 0.4, 0.6 },
                                { 0.88, 0.72, 0.4, 0.55, 0.9 },
                                { 0.35, 0.95, 0.5, 0.35, 0.55 },
                            })
                            return function(argument, calculatedValue)
                                local clampedValue, calculatedValue2, calculatedValue3 =
                                    math.clamp(
                                        callback6((argument + 0.5) / 256, (calculatedValue + 0.5) / 160),
                                        0,
                                        1
                                    ),
                                    (argument + 0.5) / 256,
                                    (calculatedValue + 0.5) / 160
                                calculatedValue = callback3(0, 0.2, calculatedValue2)
                                    * callback3(0, 0.2, 1 - calculatedValue2)
                                    * callback3(0, 0.2, calculatedValue3)
                                    * callback3(0, 0.2, 1 - calculatedValue3)
                                return 255, 255, 255, 255 * clampedValue ^ 1.15 * calculatedValue
                            end
                        end,
                    },
                    meshB = {
                        w = 256,
                        h = 160,
                        px = function()
                            local callback6 = callback5({
                                { 0.85, 0.15, 0.36, 0.5, 0.95 },
                                { 0.2, 0.85, 0.45, 0.5, 0.85 },
                                { 0.55, 0.5, 0.3, 0.3, 0.35 },
                            })
                            return function(argument, calculatedValue)
                                local clampedValue, calculatedValue2, calculatedValue3 =
                                    math.clamp(
                                        callback6((argument + 0.5) / 256, (calculatedValue + 0.5) / 160),
                                        0,
                                        1
                                    ),
                                    (argument + 0.5) / 256,
                                    (calculatedValue + 0.5) / 160
                                calculatedValue = callback3(0, 0.2, calculatedValue2)
                                    * callback3(0, 0.2, 1 - calculatedValue2)
                                    * callback3(0, 0.2, calculatedValue3)
                                    * callback3(0, 0.2, 1 - calculatedValue3)
                                return 255, 255, 255, 255 * clampedValue ^ 1.15 * calculatedValue
                            end
                        end,
                    },
                    shadow9 = {
                        w = 96,
                        h = 96,
                        slice = Rect.new(40, 40, 56, 56),
                        px = function()
                            return function(argument, argument2)
                                local value = callback2(argument + 0.5, argument2 + 0.5, 48, 48, 16, 16, 10)
                                return 0, 0, 0, 255 * (1 / (1 + math.exp(value / 4.6))) * 0.9
                            end
                        end,
                    },
                }
                local buckets, kinds =
                    { 3, 5, 7, 9, 12, 15, 19, 24, 30, 38 }, { rim9 = 14, gloss9 = 14, tile9 = 15, plate9 = 14 }
                tex.buckets = buckets
                tex.kinds = kinds
                tex.tracked = localization2.U.newReg()
                local function callback4(argument, argument2)
                    local calculatedValue = argument2 + 4
                    local w = math.max(64, 2 * calculatedValue + 24)
                    local calculatedValue2 = w / 2
                    local calculatedValue3 = w / 64
                    local px = if argument == "rim9"
                        then function()
                            return function(argument3, argument4)
                                local calculatedValue4, calculatedValue5 = argument3 + 0.5, argument4 + 0.5
                                argument4 = callback2(
                                    calculatedValue4,
                                    calculatedValue5,
                                    calculatedValue2,
                                    calculatedValue2,
                                    calculatedValue2 - 0.6,
                                    calculatedValue2 - 0.6,
                                    argument2
                                )
                                local clampedValue, calculatedValue6, calculatedValue7 =
                                    math.clamp(1 - math.abs(argument4 + 0.5) / 1.05, 0, 1),
                                    0.95 - 0.86 * callback3(0, w, calculatedValue5),
                                    0.75
                                        + 0.25
                                            * (1 - math.abs(calculatedValue4 - calculatedValue2) / calculatedValue2)
                                return 255, 255, 255, 255 * clampedValue * calculatedValue6 * calculatedValue7
                            end
                        end
                        else if argument == "gloss9"
                            then function()
                                return function(argument3, argument4)
                                    local calculatedValue4, calculatedValue5 = argument3 + 0.5, argument4 + 0.5
                                    argument4 = callback2(
                                        calculatedValue4,
                                        calculatedValue5,
                                        calculatedValue2,
                                        calculatedValue2,
                                        calculatedValue2,
                                        calculatedValue2,
                                        argument2
                                    )
                                    local value, calculatedValue6, calculatedValue4 =
                                        callback(argument4),
                                        1 - callback3(0, 34 * calculatedValue3, calculatedValue5),
                                        (1 - callback3(0, 2.4, -argument4)) * (1 - callback3(
                                            0,
                                            34 * calculatedValue3,
                                            calculatedValue5
                                        ))
                                    return 255,
                                        255,
                                        255,
                                        255 * (0.2 * calculatedValue6 + 0.16 * calculatedValue4) * value
                                end
                            end
                            else if argument == "tile9"
                                then function()
                                    return function(argument3, argument)
                                        local calculatedValue3, calculatedValue4 = argument3 + 0.5, argument + 0.5
                                        argument = callback2(
                                            calculatedValue3,
                                            calculatedValue4,
                                            calculatedValue2,
                                            calculatedValue2,
                                            calculatedValue2,
                                            calculatedValue2,
                                            argument2
                                        )
                                        argument3, calculatedValue3 =
                                            callback(argument), 1 - 0.24 * callback3(0, w, calculatedValue4)
                                        calculatedValue3 = math.min(
                                            1,
                                            calculatedValue3 + 0.16 * (1 - callback3(0, 3.2, calculatedValue4))
                                        ) * (1 - 0.1 * (1 - callback3(
                                            0,
                                            3,
                                            -argument
                                        )) * callback3(
                                            w * 0.47,
                                            w,
                                            calculatedValue4
                                        ))
                                        return 255 * calculatedValue3,
                                            255 * calculatedValue3,
                                            255 * calculatedValue3,
                                            255 * argument3
                                    end
                                end
                                else function()
                                    return function(calculatedValue4, argument)
                                        local calculatedValue3, calculatedValue5 =
                                            calculatedValue4 + 0.5, argument + 0.5
                                        argument, calculatedValue4 =
                                            callback(
                                                (
                                                    callback2(
                                                        calculatedValue3,
                                                        calculatedValue5,
                                                        calculatedValue2,
                                                        calculatedValue2,
                                                        calculatedValue2,
                                                        calculatedValue2,
                                                        argument2
                                                    )
                                                )
                                            ),
                                            1 - 0.1 * callback3(0, w, calculatedValue5)
                                        return 255 * calculatedValue4,
                                            255 * calculatedValue4,
                                            255 * calculatedValue4,
                                            255 * argument
                                    end
                                end
                    return {
                        w = w,
                        h = w,
                        slice = Rect.new(
                            calculatedValue,
                            calculatedValue,
                            w - calculatedValue,
                            w - calculatedValue
                        ),
                        px = px,
                    }
                end
                tex.resolve = function(argument, numberValue)
                    local calculatedValue, huge, entry =
                        numberValue * localization2.U.radiusMult, math.huge, buckets[1]
                    for unused, item in ipairs(buckets) do
                        numberValue = math.abs(math.log(math.max(calculatedValue, 0.5) / item))
                        if numberValue < huge then
                            huge, entry = numberValue, item
                        else
                        end
                    end
                    return argument .. "@" .. entry, math.max(calculatedValue / entry, 0.3)
                end
                tex.cleanup = function()
                    pcall(function()
                        if listfiles then
                            if delfile then
                                if isfolder then
                                    if not (isfolder(tex.folder)) then
                                        return
                                    end
                                else
                                    return
                                end
                            else
                                return
                            end
                        else
                            return
                        end
                        for key, item in ipairs(listfiles(tex.folder)) do
                            if item:match("_v%d+%.png$") then
                                key = "_" .. tex.version .. "%.png$"
                                if not (item:match(key)) then
                                    pcall(delfile, item)
                                end
                            end
                        end
                    end)
                end
                tex.get = function(argument)
                    local entry = tex.cache[argument]
                    if entry ~= nil then
                        return entry or nil
                    end
                    tex.cache[argument] = false
                    local entry2, entry = tex.specs[argument]
                    if entry2 then
                        entry = entry2
                    else
                        local matchResult, matchResult2 = string.match(argument, "^(%a+%d)@(%d+)$")
                        if matchResult then
                            if kinds[matchResult] then
                                local value = callback4(matchResult, tonumber(matchResult2))
                                tex.specs[argument] = value
                                entry2 = value
                            else
                            end
                        else
                        end
                        entry = entry2
                    end
                    if not entry then
                        return nil
                    end
                    local success, result = pcall(function()
                        if writefile then
                            if getcustomasset then
                                if not buffer then
                                    return nil
                                end
                            else
                                return nil
                            end
                        else
                            return nil
                        end
                        if isfolder then
                            if makefolder then
                                if not (isfolder("GGH")) then
                                    makefolder("GGH")
                                end
                                if not (isfolder("GGH/nova")) then
                                    makefolder("GGH/nova")
                                end
                                if not (isfolder(tex.folder)) then
                                    makefolder(tex.folder)
                                end
                            end
                        end
                        local calculatedValue = tex.folder
                            .. "/"
                            .. string.gsub(argument, "@", "_r")
                            .. "_"
                            .. tex.version
                            .. ".png"
                        if not (isfile and isfile(calculatedValue)) then
                            writefile(calculatedValue, tex.encode(entry.w, entry.h, entry.px()))
                        end
                        return getcustomasset(calculatedValue)
                    end)
                    if success then
                        if result then
                            tex.cache[argument] = result
                        end
                    end
                    return tex.cache[argument] or nil
                end
                tex.image = function(parent, argument, calculatedValue)
                    calculatedValue = calculatedValue or {}
                    local kind, base, calculatedValue2, resolveResult = kinds[argument] and argument or nil
                    if kind then
                        base = kinds[kind] * (calculatedValue.SliceScale or 0.5)
                        base, resolveResult, calculatedValue2 = base, tex.resolve(kind, base)
                    else
                        resolveResult = argument
                    end
                    local image = tex.get(resolveResult)
                    if not image then
                        return nil
                    end
                    local entry, imageLabel = tex.specs[resolveResult], Instance.new("ImageLabel")
                    imageLabel.Name = calculatedValue.Name or "Tex_" .. argument
                    imageLabel.BackgroundTransparency = 1
                    imageLabel.BorderSizePixel = 0
                    imageLabel.Image = image
                    if entry.slice then
                        imageLabel.ScaleType = Enum.ScaleType.Slice
                        imageLabel.SliceCenter = entry.slice
                        imageLabel.SliceScale = calculatedValue2 or calculatedValue.SliceScale or 0.5
                    elseif entry.tile then
                        imageLabel.ScaleType = Enum.ScaleType.Tile
                        imageLabel.TileSize = UDim2.fromOffset(entry.w, entry.h)
                    end
                    for key, item in pairs(calculatedValue) do
                        if key ~= "Name" then
                            if key ~= "SliceScale" then
                                if key ~= "Parent" then
                                    imageLabel[key] = item
                                end
                            end
                        end
                    end
                    imageLabel.Parent = parent
                    if kind then
                        tex.tracked[imageLabel] = { kind = kind, base = base }
                    end
                    return imageLabel
                end
                tex.retarget = function(argument)
                    local entry = tex.tracked[argument]
                    if not entry then
                        return
                    end
                    local resolveResult, sliceScale = tex.resolve(entry.kind, entry.base)
                    local image, entry = tex.get(resolveResult), tex.specs[resolveResult]
                    if image then
                        if entry then
                            argument.Image = image
                            argument.SliceCenter = entry.slice
                            argument.SliceScale = sliceScale
                        end
                    end
                end
                tex.setRadius = function()
                    localization2.Refresh.run("texradius", tex.retarget, function()
                        for key in pairs(tex.tracked) do
                            tex.retarget(key)
                        end
                    end)
                end
                table.insert(localization2.Refresh.full, tex.retarget)
                tex.preload = function()
                    if tex.preloading then
                        return
                    end
                    tex.preloading = true
                    tex.cleanup()
                    task.spawn(function()
                        for key in pairs(tex.specs) do
                            pcall(tex.get, key)
                            task.wait()
                        end
                        for key in pairs(kinds) do
                            for unused, item in ipairs(buckets) do
                                pcall(tex.get, key .. "@" .. item)
                                task.wait()
                            end
                        end
                    end)
                end
            end
            do
                local u = localization2.U
                local motion = localization2.Motion
                local theme = localization2.Theme
                local font = localization2.Font
                local icons = localization2.Icons
                local sound = localization2.Sound
                local tex = localization2.Tex
                local createInstance = u.new
                local tweenInstance = motion.tween
                local bindTheme = theme.bind
                local userInputService = localization2.Services.UserInputService
                local runService, index = localization2.Services.RunService, {}
                index.__index = index
                localization2.WindowClass = index
                index.HEADER = 64
                index.BackgroundStyles =
                    { "Aurora", "Grid", "Dots", "Diagonal", "Crosses", "Scanlines", "Noise", "Plain" }
                index.HalloweenAccent = "ff7a1a"
                index.HalloweenEmber = Color3.fromRGB(150, 46, 14)
                index.HalloweenArt = {
                    pattern = "",
                    web = "",
                    flock = "",
                    bat = "",
                    pumpkin = "",
                    moon = "",
                    sheet = "",
                    pumpkinA = "",
                    pumpkinB = "",
                    witchMoon = "",
                    spider = "",
                    fog = "",
                }
                local function label(argument)
                    local value = createInstance(
                        "TextLabel",
                        {
                            BackgroundTransparency = 1,
                            FontFace = argument.Font or font.Medium(),
                            TextSize = argument.Size or 14,
                            Text = argument.Text or "",
                            TextXAlignment = argument.AlignX or Enum.TextXAlignment.Left,
                            TextYAlignment = argument.AlignY or Enum.TextYAlignment.Center,
                            TextTruncate = argument.Truncate and Enum.TextTruncate.AtEnd or Enum.TextTruncate.None,
                            TextWrapped = argument.Wrap or false,
                            RichText = argument.Rich or false,
                            Size = argument.Box or UDim2.new(1, 0, 0, 18),
                            Position = argument.Pos or UDim2.new(),
                            AnchorPoint = argument.Anchor or Vector2.zero,
                            AutomaticSize = argument.Auto or Enum.AutomaticSize.None,
                            ZIndex = argument.Z or 1,
                            Name = argument.Name or "Label",
                            Parent = argument.Parent,
                        }
                    )
                    bindTheme(value, "TextColor3", argument.Color or "Text")
                    return value
                end
                localization2.label = label
                local function icon(argument)
                    local value = createInstance(
                        "ImageLabel",
                        {
                            BackgroundTransparency = 1,
                            Size = UDim2.fromOffset(argument.Size or 18, argument.Size or 18),
                            Position = argument.Pos or UDim2.new(),
                            AnchorPoint = argument.Anchor or Vector2.zero,
                            Visible = false,
                            ZIndex = argument.Z or 1,
                            Name = argument.Name or "Icon",
                            Parent = argument.Parent,
                        }
                    )
                    bindTheme(value, "ImageColor3", argument.Color or "Text")
                    icons.apply(value, argument.Icon)
                    return value
                end
                localization2.icon = icon
                localization2.tile = function(parent, argument)
                    local imageResult = tex.image(
                        parent,
                        argument.Tex or "tile9",
                        {
                            Name = argument.Name or "Tile",
                            Size = argument.Size or UDim2.fromOffset(30, 30),
                            Position = argument.Pos or UDim2.new(),
                            AnchorPoint = argument.Anchor or Vector2.zero,
                            SliceScale = argument.SliceScale or 0.5,
                            ImageTransparency = argument.Alpha or 0,
                            ZIndex = argument.Z or 1,
                        }
                    )
                    if imageResult then
                        bindTheme(imageResult, "ImageColor3", argument.Color or "Accent")
                        return imageResult, true
                    end
                    imageResult = createInstance(
                        "Frame",
                        {
                            Name = argument.Name or "Tile",
                            Size = argument.Size or UDim2.fromOffset(30, 30),
                            Position = argument.Pos or UDim2.new(),
                            AnchorPoint = argument.Anchor or Vector2.zero,
                            BorderSizePixel = 0,
                            BackgroundTransparency = argument.Alpha or 0,
                            ZIndex = argument.Z or 1,
                            Parent = parent,
                        }
                    )
                    u.corner(imageResult, argument.Radius or math.floor(15 * (argument.SliceScale or 0.5) + 0.5))
                    bindTheme(imageResult, "BackgroundColor3", argument.Color or "Accent")
                    return imageResult, false
                end
                localization2.CreateWindow = function(win, calculatedValue)
                    calculatedValue = calculatedValue or {}
                    local setmetatableResult = setmetatable({}, index)
                    setmetatableResult.Tabs = {}
                    setmetatableResult.TabList = {}
                    setmetatableResult.Groups = {}
                    setmetatableResult.Conns = {}
                    setmetatableResult.Popups = {}
                    setmetatableResult.Floats = {}
                    setmetatableResult.Key = calculatedValue.Key or Enum.KeyCode.RightControl
                    setmetatableResult.Size = calculatedValue.Size or Vector2.new(860, 620)
                    setmetatableResult.MinSize = calculatedValue.MinSize or Vector2.new(660, 420)
                    setmetatableResult.IsOpen = false
                    setmetatableResult.FloatZ = 10
                    setmetatableResult.Initial =
                        tostring(calculatedValue.Initial or string.sub(calculatedValue.Title or "N", 1, 1))
                    setmetatableResult.LogoAsset, setmetatableResult.LogoGlow =
                        calculatedValue.Logo, calculatedValue.LogoGlow
                    table.insert(localization2.Windows, setmetatableResult)
                    u.startSweep()
                    win = calculatedValue.GuiName or "GGH"
                    local state =
                        localization2.Store.new(calculatedValue.StateFile or "GGH/nova/ui_" .. win .. ".json")
                    setmetatableResult.State = state
                    setmetatableResult.StateDefaults = type(calculatedValue.StateDefaults) == "table"
                            and calculatedValue.StateDefaults
                        or nil
                    if type(calculatedValue.StateDefaults) == "table" then
                        local httpService = localization2.Services.HttpService
                        for key, item in pairs(calculatedValue.StateDefaults) do
                            if state.data[key] == nil then
                                if type(item) == "table" then
                                    local success, result = pcall(function()
                                        local packedValues = packValues(httpService:JSONEncode(item))
                                        return httpService:JSONDecode(unpackTuple(packedValues))
                                    end)
                                    state.data[key] = success and result or item
                                else
                                    state.data[key] = item
                                end
                            end
                        end
                    end
                    local gui = state.get("size", nil)
                    if type(gui) == "table" then
                        if tonumber(gui[1]) then
                            if tonumber(gui[2]) then
                                setmetatableResult.Size = Vector2.new(
                                    math.max(setmetatableResult.MinSize.X, tonumber(gui[1])),
                                    math.max(setmetatableResult.MinSize.Y, tonumber(gui[2]))
                                )
                            end
                        end
                    end
                    local getResult = state.get("accent", nil)
                    if type(getResult) == "string" then
                        pcall(function()
                            theme.set("Accent", Color3.fromHex(getResult))
                        end)
                    elseif calculatedValue.Accent then
                        theme.set("Accent", calculatedValue.Accent)
                    end
                    gui = state.get("base", calculatedValue.Base or "Midnight")
                    if gui ~= "Midnight" then
                        theme.setBase(gui)
                    end
                    gui = state.get("panel", nil)
                    if type(gui) == "string" then
                        local success, result = pcall(Color3.fromHex, gui)
                        if success then
                            if typeof(result) == "Color3" then
                                setmetatableResult.PanelColor = result
                                theme.setMany(theme.panelFrom(result))
                                theme.base = "Custom"
                            end
                        end
                    end
                    u.setRadius(tonumber(state.get("radius", calculatedValue.Radius or 1)) or 1)
                    font.setFamily(state.get("font", calculatedValue.Font or "Builder Sans"))
                    font.setScale(tonumber(state.get("textScale", 1)) or 1)
                    sound.enabled = state.get("sounds", true) ~= false
                    sound.volume = tonumber(state.get("volume", 0.5)) or 0.5
                    motion.enabled = state.get("motion", true) ~= false
                    setmetatableResult.DefaultScale = math.clamp(tonumber(calculatedValue.Scale) or 1, 0.6, 1.5)
                    setmetatableResult.UserScale = math.clamp(
                        tonumber(state.get("scale", setmetatableResult.DefaultScale))
                            or setmetatableResult.DefaultScale,
                        0.6,
                        1.5
                    )
                    setmetatableResult.BlurEnabled = state.get("blur", calculatedValue.Blur == true) == true
                    setmetatableResult.BgStyle = state.get("bgStyle", calculatedValue.Background or "Aurora")
                    if setmetatableResult.BgStyle == "Halloween" then
                        setmetatableResult.BgStyle = "Aurora"
                    end
                    setmetatableResult.CardStyle = state.get("cardStyle", calculatedValue.CardStyle or "Glass")
                    setmetatableResult.BgIntensity = math.clamp(tonumber(state.get("bgIntensity", 1)) or 1, 0, 1.5)
                    setmetatableResult.Opacity = math.clamp(tonumber(state.get("opacity", 1)) or 1, 0.5, 1)
                    setmetatableResult.TooltipsOn = state.get("tooltips", true) ~= false
                    setmetatableResult.LauncherOn = state.get("launcher", calculatedValue.Launcher ~= false)
                        ~= false
                    setmetatableResult.BaseSize = setmetatableResult.Size
                    setmetatableResult.AutoFit = state.get("autoFit", calculatedValue.AutoFit ~= false) ~= false
                    setmetatableResult.ScaleHooks = {}
                    setmetatableResult.ScreenFactor = 1
                    setmetatableResult.OverlayScale = 1
                    local enabled = false
                    pcall(function()
                        enabled = getgenv().NOVA_FORCE_TOUCH == true
                    end)
                    gui = enabled or userInputService.TouchEnabled and not userInputService.KeyboardEnabled
                    setmetatableResult.IsTouch = gui
                    if setmetatableResult.IsTouch then
                        setmetatableResult.LauncherOn = true
                    end
                    gui = state.get("touchSize", nil)
                    if setmetatableResult.IsTouch then
                        if type(gui) == "table" then
                            if tonumber(gui[1]) then
                                if tonumber(gui[2]) then
                                    setmetatableResult.TouchSize = Vector2.new(tonumber(gui[1]), tonumber(gui[2]))
                                end
                            end
                        end
                    end
                    icons.load()
                    sound.preload()
                    tex.preload()
                    gui = createInstance(
                        "ScreenGui",
                        {
                            Name = win,
                            IgnoreGuiInset = true,
                            ResetOnSpawn = false,
                            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
                            DisplayOrder = 999999,
                        }
                    )
                    u.protect(gui)
                    gui.Parent = calculatedValue.Parent or u.hostGui()
                    setmetatableResult.Gui = gui
                    local root = createInstance(
                        "ScreenGui",
                        { Name = win .. "_Parked", Enabled = false, ResetOnSpawn = false }
                    )
                    u.protect(root)
                    root.Parent = gui.Parent
                    setmetatableResult.Parking = root
                    sound.host = gui
                    win, root =
                        UDim2.fromScale(0.5, 0.5),
                        state.get(setmetatableResult.IsTouch and "touchPos" or "winPos", nil)
                    win = if type(root) == "table"
                        then if tonumber(root[1])
                            then if tonumber(root[2])
                                then UDim2.new(
                                    0.5,
                                    math.floor(tonumber(root[1])),
                                    0.5,
                                    math.floor(tonumber(root[2]))
                                )
                                else win
                            else win
                        else win
                    root = createInstance(
                        "Frame",
                        {
                            Name = "Root",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = win,
                            Size = UDim2.fromOffset(setmetatableResult.Size.X, setmetatableResult.Size.Y),
                            BackgroundTransparency = 1,
                            Visible = false,
                            ZIndex = 1,
                            Parent = gui,
                        }
                    )
                    setmetatableResult.Root = root
                    setmetatableResult.Scale = createInstance("UIScale", { Parent = root })
                    setmetatableResult.WindowShadow = tex.image(
                        root,
                        "shadow9",
                        {
                            Name = "WindowShadow",
                            Position = UDim2.fromOffset(-40, -30),
                            Size = UDim2.new(1, 80, 1, 90),
                            SliceScale = 1.2,
                            ImageTransparency = 0.45,
                            ZIndex = 0,
                        }
                    )
                    win = createInstance(
                        "CanvasGroup",
                        {
                            Name = "Window",
                            Size = UDim2.fromScale(1, 1),
                            BorderSizePixel = 0,
                            GroupTransparency = 1,
                            BackgroundTransparency = 1 - setmetatableResult.Opacity,
                            ZIndex = 1,
                            Parent = root,
                        }
                    )
                    bindTheme(win, "BackgroundColor3", "Background")
                    u.corner(win, 14)
                    setmetatableResult.Win = win
                    setmetatableResult:_buildBackdrop()
                    setmetatableResult:_buildSidebar(calculatedValue)
                    root = setmetatableResult.SidebarWidth
                    local main = createInstance(
                        "Frame",
                        {
                            Name = "Main",
                            Position = UDim2.fromOffset(root, 0),
                            Size = UDim2.new(1, -root, 1, 0),
                            BackgroundTransparency = 1,
                            ZIndex = 1,
                            Parent = win,
                        }
                    )
                    setmetatableResult.Main = main
                    root = createInstance(
                        "Frame",
                        { Name = "Header", Size = UDim2.new(1, 0, 0, 64), BackgroundTransparency = 1, Parent = main }
                    )
                    setmetatableResult.Header = root
                    setmetatableResult.HeaderTitle = label({
                        Parent = root,
                        Text = "",
                        Font = font.Bold(),
                        Size = 21,
                        Pos = UDim2.fromOffset(24, 13),
                        Box = UDim2.new(1, -110, 0, 26),
                        Truncate = true,
                    })
                    setmetatableResult.HeaderDesc = label({
                        Parent = root,
                        Text = "",
                        Font = font.Medium(),
                        Size = 12,
                        Pos = UDim2.fromOffset(24, 39),
                        Box = UDim2.new(1, -110, 0, 14),
                        Color = "Muted",
                        Truncate = true,
                    })
                    local parent = createInstance(
                        "Frame",
                        {
                            Name = "Line",
                            Position = UDim2.fromOffset(20, 63),
                            Size = UDim2.new(1, -40, 0, 1),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 0.88,
                            Parent = root,
                        }
                    )
                    bindTheme(parent, "BackgroundColor3", "Glass")
                    createInstance(
                        "UIGradient",
                        {
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 1),
                                NumberSequenceKeypoint.new(0.15, 0),
                                NumberSequenceKeypoint.new(0.85, 0),
                                NumberSequenceKeypoint.new(1, 1),
                            }),
                            Parent = parent,
                        }
                    )
                    setmetatableResult:_buildClose(root)
                    setmetatableResult.Body = createInstance(
                        "Frame",
                        {
                            Name = "Body",
                            Position = UDim2.fromOffset(0, 64),
                            Size = UDim2.new(1, 0, 1, -64),
                            BackgroundTransparency = 1,
                            ClipsDescendants = true,
                            Parent = main,
                        }
                    )
                    main = createInstance(
                        "TextButton",
                        {
                            Name = "Resize",
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            AnchorPoint = Vector2.new(1, 1),
                            Position = UDim2.new(1, -5, 1, -5),
                            Size = UDim2.fromOffset(18, 18),
                            ZIndex = 40,
                            Parent = win,
                        }
                    )
                    for index2 = 0, 2, 1 do
                        for index3 = 0, 2 - index2, 1 do
                            parent = createInstance(
                                "Frame",
                                {
                                    Size = UDim2.fromOffset(2, 2),
                                    Position = UDim2.fromOffset(13 - index2 * 4, 13 - index3 * 4),
                                    BorderSizePixel = 0,
                                    ZIndex = 40,
                                    Parent = main,
                                }
                            )
                            bindTheme(parent, "BackgroundColor3", "Faint")
                            u.corner(parent, UDim.new(1, 0))
                        end
                    end
                    parent = tex.image(
                        win,
                        "rim9",
                        { Name = "WindowRim", Size = UDim2.fromScale(1, 1), SliceScale = 1, ImageTransparency = 0.55, ZIndex = 45 }
                    )
                    if parent then
                        bindTheme(parent, "ImageColor3", "Glass")
                    end
                    setmetatableResult.FloatLayer = createInstance(
                        "Frame",
                        {
                            Name = "Floats",
                            BackgroundTransparency = 1,
                            Size = UDim2.fromScale(1, 1),
                            ZIndex = 5,
                            Visible = true,
                            Parent = gui,
                        }
                    )
                    setmetatableResult.FloatScale =
                        createInstance("UIScale", { Parent = setmetatableResult.FloatLayer })
                    setmetatableResult.PopLayer = createInstance(
                        "Frame",
                        { Name = "Popups", BackgroundTransparency = 1, Size = UDim2.fromScale(1, 1), ZIndex = 20, Parent = gui }
                    )
                    setmetatableResult.PopScale =
                        createInstance("UIScale", { Parent = setmetatableResult.PopLayer })
                    setmetatableResult.Overlay = setmetatableResult.PopLayer
                    win = createInstance(
                        "TextButton",
                        {
                            Name = "Catcher",
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            Size = UDim2.fromScale(1, 1),
                            Visible = false,
                            ZIndex = 1,
                            Parent = setmetatableResult.PopLayer,
                        }
                    )
                    local function getResult()
                        setmetatableResult:ClosePopups()
                    end
                    win.MouseButton1Click:Connect(getResult)
                    local function handleAction()
                        setmetatableResult:ClosePopups()
                    end
                    win.MouseButton2Click:Connect(handleAction)
                    setmetatableResult.Catcher = win
                    setmetatableResult:_drag(root)
                    setmetatableResult:_drag(setmetatableResult.BrandFrame)
                    setmetatableResult:_resize(main)
                    if setmetatableResult.IsTouch then
                        main.Size = UDim2.fromOffset(30, 30)
                        main.Position = UDim2.new(1, -4, 1, -4)
                        main.BackgroundTransparency = 0.35
                        bindTheme(main, "BackgroundColor3", "Elevated")
                        u.corner(main, 9)
                        for unused, instance in ipairs(main:GetChildren()) do
                            if instance:IsA("Frame") then
                                instance.Size = UDim2.fromOffset(3, 3)
                                instance.Position =
                                    UDim2.fromOffset(instance.Position.X.Offset + 8, instance.Position.Y.Offset + 8)
                                bindTheme(instance, "BackgroundColor3", "Text")
                            end
                        end
                    end
                    win = createInstance(
                        "Frame",
                        {
                            Name = "Toasts",
                            AnchorPoint = Vector2.new(1, 1),
                            Position = UDim2.new(1, -18, 1, -20),
                            Size = UDim2.new(0, 300, 1, -40),
                            BackgroundTransparency = 1,
                            ZIndex = 30,
                            Parent = gui,
                        }
                    )
                    setmetatableResult.ToastScale = createInstance("UIScale", { Parent = win })
                    setmetatableResult.Toasts = win
                    setmetatableResult.ToastList = {}
                    local tip = createInstance(
                        "Frame",
                        {
                            Name = "Tooltip",
                            Size = UDim2.fromOffset(10, 28),
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0,
                            Visible = false,
                            ZIndex = 200,
                            Parent = gui,
                        }
                    )
                    bindTheme(tip, "BackgroundColor3", "Elevated")
                    u.corner(tip, 8)
                    parent = tex.image(
                        tip,
                        "rim9",
                        {
                            Position = UDim2.fromOffset(-11, 0),
                            Size = UDim2.new(1, 22, 1, 0),
                            SliceScale = 0.57,
                            ImageTransparency = 0.5,
                            ZIndex = 201,
                        }
                    )
                    if parent then
                        bindTheme(parent, "ImageColor3", "Glass")
                    else
                        bindTheme(u.stroke(tip, Color3.new(1, 1, 1), 1, 0.88), "Color", "Glass")
                    end
                    u.pad(tip, 0, 11, 0, 11)
                    setmetatableResult.TipLabel = label({
                        Parent = tip,
                        Text = "",
                        Font = font.Medium(),
                        Size = 12,
                        Box = UDim2.new(0, 0, 1, 0),
                        Auto = Enum.AutomaticSize.X,
                        Z = 202,
                        Color = "Text",
                    })
                    setmetatableResult.Tip = tip
                    local value = createInstance("UIScale", { Parent = tip })
                    setmetatableResult:OnScreenScale(function(scale)
                        if not tip.Parent then
                            return false
                        end
                        value.Scale = scale
                    end)
                    setmetatableResult:_launcher(calculatedValue)
                    setmetatableResult:_input()
                    setmetatableResult:_autoScale()
                    pcall(function()
                        setmetatableResult:_buildDecor()
                    end)
                    setmetatableResult:_applyBackground()
                    theme.onChange(function(argument)
                        if
                            argument == "Accent"
                            and setmetatableResult.CardStyle == "Tinted"
                            and not setmetatableResult.Destroyed
                        then
                            for unused, item in ipairs(setmetatableResult.TabList) do
                                for unused, item2 in ipairs(item.Sections) do
                                    pcall(function()
                                        setmetatableResult:_applyCardStyle(item2)
                                    end)
                                end
                            end
                        end
                    end)
                    if setmetatableResult._initCards then
                        setmetatableResult:_initCards()
                    end
                    getResult = state.get("menuKey", nil)
                    if type(getResult) == "string" then
                        if Enum.KeyCode[getResult] then
                            setmetatableResult.Key = Enum.KeyCode[getResult]
                        end
                    end
                    setmetatableResult:_syncFooter()
                    if setmetatableResult.SetWatermark then
                        if state.get("watermark", false) == true then
                            setmetatableResult:SetWatermark(true)
                        end
                    end
                    if setmetatableResult.SetKeybindList then
                        if state.get("keybindList", setmetatableResult.IsTouch == true) == true then
                            setmetatableResult:SetKeybindList(true)
                        end
                    end
                    return setmetatableResult
                end
                index._buildBackdrop = function(argument)
                    local parent = argument.Win
                    local backdrop = createInstance(
                        "Frame",
                        { Name = "Backdrop", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 0, Parent = parent }
                    )
                    argument.Backdrop = backdrop
                    local bgLayers = {}
                    bgLayers.meshA = tex.image(
                        backdrop,
                        "meshA",
                        {
                            Name = "MeshA",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.25, 0.18),
                            Size = UDim2.fromScale(1.5, 1.5),
                            ImageTransparency = 0.84,
                            ZIndex = 0,
                        }
                    )
                    if bgLayers.meshA then
                        bindTheme(bgLayers.meshA, "ImageColor3", "Accent")
                    end
                    bgLayers.meshB = tex.image(
                        backdrop,
                        "meshB",
                        {
                            Name = "MeshB",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.85, 0.9),
                            Size = UDim2.fromScale(1.4, 1.4),
                            ImageTransparency = 0.9,
                            ZIndex = 0,
                        }
                    )
                    if bgLayers.meshB then
                        bindTheme(bgLayers.meshB, "ImageColor3", function(argument2)
                            local accent, fromRGBResult = argument2.Accent, Color3.fromRGB(80, 110, 255)
                            return accent:Lerp(fromRGBResult, 0.55)
                        end)
                    end
                    bgLayers.auraA = tex.image(
                        backdrop,
                        "glow",
                        {
                            Name = "AuraA",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromOffset(60, 10),
                            Size = UDim2.fromOffset(640, 540),
                            ImageTransparency = 0.84,
                            ZIndex = 0,
                        }
                    )
                    if bgLayers.auraA then
                        bindTheme(bgLayers.auraA, "ImageColor3", "Accent")
                    end
                    bgLayers.auraB = tex.image(
                        backdrop,
                        "glow",
                        {
                            Name = "AuraB",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.new(1, 40, 1, 60),
                            Size = UDim2.fromOffset(660, 480),
                            ImageTransparency = 0.9,
                            ZIndex = 0,
                        }
                    )
                    if bgLayers.auraB then
                        bindTheme(bgLayers.auraB, "ImageColor3", function(argument2)
                            return argument.BgStyle == "Halloween" and index.HalloweenEmber or argument2.Accent
                        end)
                    end
                    bgLayers.pattern = createInstance(
                        "ImageLabel",
                        {
                            Name = "Pattern",
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            Size = UDim2.fromScale(1, 1),
                            ImageTransparency = 1,
                            ZIndex = 0,
                            Parent = backdrop,
                        }
                    )
                    bindTheme(bgLayers.pattern, "ImageColor3", function(argument2)
                        return argument.BgStyle == "Halloween" and Color3.new(1, 1, 1) or argument2.Glass
                    end)
                    bgLayers.hwMoon = createInstance(
                        "ImageLabel",
                        {
                            Name = "HwMoon",
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.new(1, -96, 0, 92),
                            Size = UDim2.fromOffset(250, 250),
                            Image = index.HalloweenArt.moon,
                            ImageColor3 = Color3.fromRGB(255, 186, 120),
                            ImageTransparency = 1,
                            Visible = false,
                            ZIndex = 0,
                            Parent = backdrop,
                        }
                    )
                    bgLayers.hwWeb = createInstance(
                        "ImageLabel",
                        {
                            Name = "HwWeb",
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            AnchorPoint = Vector2.new(1, 0),
                            Position = UDim2.fromScale(1, 0),
                            Size = UDim2.fromOffset(200, 200),
                            Image = index.HalloweenArt.web,
                            ImageTransparency = 1,
                            Visible = false,
                            ZIndex = 0,
                            Parent = backdrop,
                        }
                    )
                    bgLayers.hwWeb2 = createInstance(
                        "ImageLabel",
                        {
                            Name = "HwWeb2",
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            AnchorPoint = Vector2.new(1, 1),
                            Position = UDim2.fromScale(1, 1),
                            Size = UDim2.fromOffset(140, 140),
                            Rotation = 90,
                            Image = index.HalloweenArt.web,
                            ImageTransparency = 1,
                            Visible = false,
                            ZIndex = 0,
                            Parent = backdrop,
                        }
                    )
                    bgLayers.hwBats = {}
                    for index2 = 1, 3, 1 do
                        bgLayers.hwBats[index2] = createInstance(
                            "ImageLabel",
                            {
                                Name = "HwBat" .. index2,
                                BackgroundTransparency = 1,
                                BorderSizePixel = 0,
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = UDim2.fromOffset(-200, 60),
                                Size = UDim2.fromOffset(62 - index2 * 10, 62 - index2 * 10),
                                Image = index.HalloweenArt.sheet,
                                ImageRectSize = Vector2.new(105, 105),
                                ImageColor3 = Color3.fromRGB(8, 6, 6),
                                ImageTransparency = 1,
                                Visible = false,
                                ZIndex = 0,
                                Parent = backdrop,
                            }
                        )
                    end
                    bgLayers.vignette = tex.image(
                        backdrop,
                        "vignette",
                        { Name = "Vignette", Size = UDim2.fromScale(1, 1), ImageTransparency = 0.3, ZIndex = 0 }
                    )
                    bgLayers.grain = tex.image(
                        backdrop,
                        "grain",
                        { Name = "Grain", Size = UDim2.fromScale(1, 1), ImageTransparency = 0.82, ZIndex = 0 }
                    )
                    argument.BgLayers = bgLayers
                    task.spawn(function()
                        local counter, calculatedValue = 0, 6
                        while not argument.Destroyed do
                            task.wait(0.08)
                            local calculatedValue2 = argument.BgStyle == "Halloween"
                            if
                                argument.IsOpen
                                and motion.enabled
                                and (argument.BgStyle == "Aurora" or calculatedValue2)
                            then
                                counter += 0.08
                                if bgLayers.auraA then
                                    bgLayers.auraA.Position = UDim2.fromOffset(
                                        60 + math.sin(counter * 0.35) * 34,
                                        10 + math.cos(counter * 0.27) * 22
                                    )
                                end
                                if bgLayers.auraB then
                                    bgLayers.auraB.Position = UDim2.new(
                                        1,
                                        40 + math.cos(counter * 0.22) * 38,
                                        1,
                                        60 + math.sin(counter * 0.31) * 24
                                    )
                                end
                                if bgLayers.meshA then
                                    bgLayers.meshA.Position = UDim2.fromScale(
                                        0.25 + math.sin(counter * 0.11) * 0.06,
                                        0.18 + math.cos(counter * 0.09) * 0.05
                                    )
                                end
                                if bgLayers.meshB then
                                    bgLayers.meshB.Position = UDim2.fromScale(
                                        0.85 + math.cos(counter * 0.1) * 0.06,
                                        0.9 + math.sin(counter * 0.12) * 0.05
                                    )
                                end
                                if calculatedValue2 and bgLayers.hwBats and counter >= calculatedValue then
                                    calculatedValue = counter + 16 + math.random() * 12
                                    local maximumValue = math.max(argument.Scale.Scale, 0.05)
                                    local calculatedValue3, calculatedValue =
                                        backdrop.AbsoluteSize.X / maximumValue,
                                        backdrop.AbsoluteSize.Y / maximumValue
                                    local calculatedValue2, calculatedValue4 =
                                        40 + math.random() * math.max(calculatedValue * 0.3, 1), math.random() < 0.5
                                    local now = os.clock()
                                    for key, item in ipairs(bgLayers.hwBats) do
                                        calculatedValue, maximumValue =
                                            (key - 1) * 22 + math.random() * 10, (key - 1) * 46
                                        item.ImageRectSize = Vector2.new(calculatedValue4 and 105 or -105, 105)
                                        item.Position = UDim2.fromOffset(
                                            calculatedValue4 and -80 - maximumValue
                                                or calculatedValue3 + 80 + maximumValue,
                                            calculatedValue2 + calculatedValue
                                        )
                                        item.Rotation = calculatedValue4 and -8 or 8
                                        item.ImageTransparency = 0.3
                                        item.Visible = true
                                        local new, easingStyle = TweenInfo.new, Enum.EasingStyle
                                        local value, entries = new(7.5, easingStyle.Linear), {}
                                        entries.Position = UDim2.fromOffset(
                                            calculatedValue4 and calculatedValue3 + 80 + maximumValue
                                                or -80 - maximumValue,
                                            calculatedValue2 + calculatedValue - 50 - math.random() * 30
                                        )
                                        tweenInstance(item, value, entries)
                                    end
                                    if argument.HwFlap then
                                        pcall(function()
                                            argument.HwFlap:Disconnect()
                                        end)
                                    end
                                    argument.HwFlap = runService.RenderStepped:Connect(function()
                                        local calculatedValue5 = os.clock() - now
                                        if
                                            calculatedValue5 > 7.8
                                            or argument.Destroyed
                                            or argument.BgStyle ~= "Halloween"
                                        then
                                            if argument.HwFlap then
                                                argument.HwFlap:Disconnect()
                                                argument.HwFlap = nil
                                            end
                                            for unused, item in ipairs(bgLayers.hwBats) do
                                                item.Visible = false
                                            end
                                            return
                                        end
                                        for key, item in ipairs(bgLayers.hwBats) do
                                            local calculatedValue2 = math.floor(
                                                calculatedValue5 * (15 + key * 2) + key * 5
                                            ) % 16
                                            item.ImageRectOffset = Vector2.new(
                                                calculatedValue2 % 4 * 105 + (calculatedValue4 and 0 or 105),
                                                math.floor(calculatedValue2 / 4) * 105
                                            )
                                        end
                                    end)
                                else
                                end
                            else
                            end
                        end
                    end)
                end
                index._buildDecor = function(argument)
                    -- Seasonal decoration (moon, pumpkins, web, bats) removed.
                    argument.HwDecor = nil
                    do
                        return
                    end
                    local halloweenArt, hwDecor = index.HalloweenArt, { bats = {} }
                    local image = tex.get("glow") or ""
                    local function callback(argument2, parent)
                        argument2.BackgroundTransparency = 1
                        argument2.BorderSizePixel = 0
                        argument2.Parent = parent
                        return createInstance("ImageLabel", argument2)
                    end
                    hwDecor.back = createInstance(
                        "Frame",
                        {
                            Name = "HwBack",
                            BackgroundTransparency = 1,
                            Size = UDim2.fromScale(1, 1),
                            ZIndex = 0,
                            Visible = false,
                            Parent = argument.Backdrop,
                        }
                    )
                    hwDecor.web = callback(
                        {
                            Name = "Web",
                            AnchorPoint = Vector2.new(1, 0),
                            Position = UDim2.fromScale(1, 0),
                            Size = UDim2.fromOffset(128, 128),
                            Image = halloweenArt.web,
                            ImageTransparency = 0.5,
                        },
                        hwDecor.back
                    )
                    hwDecor.moonGlow = callback(
                        {
                            Name = "MoonGlow",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.new(1, -178, 0, 33),
                            Size = UDim2.fromOffset(120, 120),
                            Image = image,
                            ImageColor3 = Color3.fromRGB(255, 214, 130),
                            ImageTransparency = 0.8,
                        },
                        hwDecor.back
                    )
                    hwDecor.moon = callback(
                        {
                            Name = "Moon",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.new(1, -178, 0, 33),
                            Size = UDim2.fromOffset(46, 46),
                            Image = halloweenArt.witchMoon,
                            ImageTransparency = 0.08,
                        },
                        hwDecor.back
                    )
                    hwDecor.bats[1] = callback(
                        {
                            Name = "MoonBat",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Size = UDim2.fromOffset(20, 20),
                            Image = halloweenArt.sheet,
                            ImageRectSize = Vector2.new(105, 105),
                            ImageColor3 = Color3.fromRGB(10, 6, 6),
                        },
                        hwDecor.back
                    )
                    hwDecor.side = createInstance(
                        "Frame",
                        {
                            Name = "HwSide",
                            BackgroundTransparency = 1,
                            Size = UDim2.fromScale(1, 1),
                            ZIndex = 5,
                            Visible = false,
                            Parent = argument.Footer or argument.Backdrop,
                        }
                    )
                    hwDecor.pkGlow = callback(
                        {
                            Name = "PumpkinGlow",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.new(0, 76, 0.5, 0),
                            Size = UDim2.fromOffset(96, 64),
                            Image = image,
                            ImageColor3 = Color3.fromRGB(255, 118, 24),
                            ImageTransparency = 0.66,
                            ZIndex = 5,
                        },
                        hwDecor.side
                    )
                    hwDecor.pkA = callback(
                        {
                            Name = "PumpkinA",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.new(0, 68, 0.5, 0),
                            Size = UDim2.fromOffset(28, 28),
                            Image = halloweenArt.pumpkinA,
                            ZIndex = 6,
                        },
                        hwDecor.side
                    )
                    hwDecor.pkB = callback(
                        {
                            Name = "PumpkinB",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.new(0, 92, 0.5, 2),
                            Size = UDim2.fromOffset(30, 30),
                            Image = halloweenArt.pumpkinB,
                            ZIndex = 6,
                        },
                        hwDecor.side
                    )
                    argument.HwDecor = hwDecor
                    local enabled = false
                    hwDecor.start = function()
                        if enabled then
                            return
                        end
                        enabled = true
                        local moonGlow, new, enum = hwDecor.moonGlow, TweenInfo.new, Enum
                        local sine, easingDirection = enum.EasingStyle.Sine, Enum.EasingDirection
                        local value, entries =
                            new(3.4, sine, easingDirection.InOut, -1, true), { ImageTransparency = 0.88 }
                        entries.Size = UDim2.fromOffset(104, 104)
                        tweenInstance(moonGlow, value, entries)
                    end
                    local now, calculatedValue, calculatedValue2 = os.clock(), 0.66, 0.7
                    argument.HwDecorConn = runService.RenderStepped:Connect(function(entry)
                        if argument.Destroyed then
                            if argument.HwDecorConn then
                                argument.HwDecorConn:Disconnect()
                                argument.HwDecorConn = nil
                            end
                            return
                        end
                        if argument.IsOpen then
                            if not hwDecor.back.Visible then
                                return
                            end
                        else
                            return
                        end
                        local visible = not argument.SidebarCollapsed
                        if hwDecor.side.Visible ~= visible then
                            hwDecor.side.Visible = visible
                        end
                        if not motion.enabled then
                            return
                        end
                        local calculatedValue3, clampedValue = os.clock() - now, math.clamp(entry * 12, 0, 1)
                        local calculatedValue4, calculatedValue5, calculatedValue6 =
                            math.noise(calculatedValue3 * 2.7, 0.31) + math.noise(calculatedValue3 * 7.3, 1.7) * 0.4,
                            math.noise(calculatedValue3 * 2.3, 4.2) + math.noise(calculatedValue3 * 6.1, 2.9) * 0.4,
                            calculatedValue
                        calculatedValue = calculatedValue6
                            + (0.62 - calculatedValue4 * 0.2 - calculatedValue) * clampedValue
                        entry = calculatedValue2
                        calculatedValue2 = entry
                            + (0.68 - calculatedValue5 * 0.18 - calculatedValue2) * clampedValue
                        hwDecor.pkGlow.ImageTransparency = math.clamp(calculatedValue, 0.4, 0.9)
                        entry, calculatedValue4 = hwDecor.bats[1], calculatedValue3 * 0.9
                        calculatedValue5 = -math.sin(calculatedValue4) < 0
                        entry.Position = UDim2.new(
                            1,
                            -178 + math.cos(calculatedValue4) * 40,
                            0,
                            30 + math.sin(calculatedValue4) * 12
                        )
                        entry.ImageRectSize = Vector2.new(calculatedValue5 and -105 or 105, 105)
                        calculatedValue6 = math.floor(calculatedValue3 * 18) % 16
                        entry.ImageRectOffset = Vector2.new(
                            calculatedValue6 % 4 * 105 + (calculatedValue5 and 105 or 0),
                            math.floor(calculatedValue6 / 4) * 105
                        )
                    end)
                end
                local entries = {
                    Grid = { tex = "grid", alpha = 0.955 },
                    Dots = { tex = "dots", alpha = 0.9 },
                    Diagonal = { tex = "diag", alpha = 0.965 },
                    Crosses = { tex = "crosses", alpha = 0.93 },
                    Scanlines = { tex = "scan", alpha = 0.955 },
                }
                index._applyBackground = function(argument)
                    local bgLayers = argument.BgLayers
                    if not bgLayers then
                        return
                    end
                    local bgStyle, bgIntensity = argument.BgStyle, argument.BgIntensity
                    local function callback(argument2)
                        return math.clamp(1 - (1 - argument2) * bgIntensity, 0, 1)
                    end
                    local visible = bgStyle == "Halloween"
                    local hwDecor = bgStyle == "Aurora" or visible
                    if bgLayers.meshA then
                        bgLayers.meshA.ImageTransparency = callback(hwDecor and 0.84 or 0.965)
                    end
                    if bgLayers.meshB then
                        bgLayers.meshB.ImageTransparency = callback(hwDecor and 0.9 or 0.975)
                    end
                    if visible then
                        if bgLayers.meshA then
                            bgLayers.meshA.ImageTransparency = callback(0.965)
                        end
                        if bgLayers.meshB then
                            bgLayers.meshB.ImageTransparency = callback(0.98)
                        end
                    end
                    if bgLayers.auraA then
                        local auraA, calculatedValue = bgLayers.auraA, hwDecor and (visible and 0.93 or 0.84)
                        auraA.ImageTransparency = callback(calculatedValue or 0.9)
                    end
                    if bgLayers.auraB then
                        local auraB, calculatedValue = bgLayers.auraB, hwDecor and (visible and 0.92 or 0.9)
                        auraB.ImageTransparency = callback(calculatedValue or 0.94)
                        bgLayers.auraB.ImageColor3 = visible and index.HalloweenEmber or theme.tokens.Accent
                    end
                    if argument.HwDrift then
                        pcall(function()
                            argument.HwDrift:Cancel()
                        end)
                        argument.HwDrift = nil
                    end
                    if bgLayers.hwMoon then
                        bgLayers.hwMoon.Visible = false
                    end
                    if bgLayers.hwWeb then
                        bgLayers.hwWeb.Visible = false
                    end
                    if bgLayers.hwWeb2 then
                        bgLayers.hwWeb2.Visible = false
                    end
                    hwDecor = argument.HwDecor
                    if hwDecor then
                        hwDecor.back.Visible = visible
                        hwDecor.side.Visible = visible and not argument.SidebarCollapsed
                        if visible then
                            if hwDecor.start then
                                hwDecor.start()
                            end
                        end
                    end
                    if bgLayers.hwBats and not visible then
                        for unused, item in ipairs(bgLayers.hwBats) do
                            item.Visible = false
                        end
                    end
                    hwDecor = entries[bgStyle]
                    if visible then
                        bgLayers.pattern.ImageTransparency = 1
                    elseif hwDecor then
                        bgLayers.pattern.Size = UDim2.fromScale(1, 1)
                        bgLayers.pattern.Position = UDim2.fromOffset(0, 0)
                        bgLayers.pattern.ImageColor3 = theme.tokens.Glass or bgLayers.pattern.ImageColor3
                        local image = tex.get(hwDecor.tex)
                        if image then
                            bgLayers.pattern.Image = image
                            bgLayers.pattern.ScaleType = Enum.ScaleType.Tile
                            local entry = tex.specs[hwDecor.tex]
                            bgLayers.pattern.TileSize = UDim2.fromOffset(entry.w, entry.h)
                            bgLayers.pattern.ImageTransparency = callback(hwDecor.alpha)
                        end
                    else
                        bgLayers.pattern.ImageTransparency = 1
                    end
                    if bgLayers.grain then
                        bgLayers.grain.ImageTransparency = callback(bgStyle == "Noise" and 0.55 or 0.82)
                    end
                end
                index.SetBackground = function(argument, bgStyle)
                    localization2.trace("SetBackground")
                    for unused, item in ipairs(index.BackgroundStyles) do
                        if item == bgStyle then
                            argument.BgStyle = bgStyle
                            argument.State.set("bgStyle", bgStyle)
                            argument:_applyBackground()
                            return
                        end
                    end
                end
                index.SetBackgroundIntensity = function(argument, argument2)
                    localization2.trace("SetBackgroundIntensity")
                    argument.BgIntensity = math.clamp(tonumber(argument2) or 1, 0, 1.5)
                    argument.State.set("bgIntensity", argument.BgIntensity)
                    argument:_applyBackground()
                end
                index.SetOpacity = function(argument, argument2)
                    localization2.trace("SetOpacity")
                    argument.Opacity = math.clamp(tonumber(argument2) or 1, 0.5, 1)
                    argument.State.set("opacity", argument.Opacity)
                    argument.Win.BackgroundTransparency = 1 - argument.Opacity
                    if argument.Sidebar then
                        argument.Sidebar.BackgroundTransparency = 0.3 + (1 - argument.Opacity) * 0.7
                    end
                end
                index.SetCornerRadius = function(argument, clampedValue)
                    localization2.trace("SetCornerRadius")
                    clampedValue = math.clamp(tonumber(clampedValue) or 1, 0, 2)
                    argument.State.set("radius", clampedValue)
                    u.setRadius(clampedValue)
                    tex.setRadius()
                end
                index.SetFont = function(argument, argument2)
                    localization2.trace("SetFont")
                    if font.setFamily(argument2) then
                        argument.State.set("font", font.name)
                    end
                end
                index.SetTextScale = function(argument, clampedValue)
                    localization2.trace("SetTextScale")
                    clampedValue = math.clamp(tonumber(clampedValue) or 1, 0.8, 1.3)
                    argument.State.set("textScale", clampedValue)
                    font.setScale(clampedValue)
                end
                index.SetSounds = function(argument, argument2)
                    sound.enabled = argument2 and true or false
                    argument.State.set("sounds", sound.enabled)
                end
                index.SetVolume = function(argument, argument2)
                    sound.volume = math.clamp(tonumber(argument2) or 0.5, 0, 1)
                    argument.State.set("volume", sound.volume)
                end
                index.SetMotion = function(argument, argument2)
                    motion.enabled = argument2 and true or false
                    argument.State.set("motion", motion.enabled)
                end
                index.SetTooltips = function(argument, argument2)
                    argument.TooltipsOn = argument2 and true or false
                    argument.State.set("tooltips", argument.TooltipsOn)
                    if not argument.TooltipsOn then
                        argument:HideTip()
                    end
                end
                index.SetLauncher = function(argument, argument2)
                    argument.LauncherOn = (argument2 or argument.IsTouch) and true or false
                    argument.State.set("launcher", argument.LauncherOn)
                    if argument.Launcher then
                        argument.Launcher.Visible = argument.LauncherOn
                            and not (argument.IsTouch and argument.IsOpen)
                    end
                end
                index.SetAccent = function(argument, argument2)
                    localization2.trace("SetAccent")
                    if typeof(argument2) ~= "Color3" then
                        return
                    end
                    theme.set("Accent", argument2)
                    argument.State.set("accent", argument2:ToHex())
                end
                index._syncFooter = function(argument)
                    local text = localization2.keyName and localization2.keyName(argument.Key) or argument.Key.Name
                    if argument.FooterKey then
                        argument.FooterKey.Text = text
                    end
                    if argument.LauncherParts then
                        if argument.LauncherParts.key then
                            argument.LauncherParts.key.Text = text
                        end
                    end
                    if argument.SidebarCollapsed then
                        if argument.FooterText then
                            argument.FooterText.TextTransparency = 1
                            argument.FooterChip.AnchorPoint = Vector2.new(0.5, 0.5)
                            argument.FooterChip.Position = UDim2.new(0.5, 0, 0.5, 1)
                        end
                    end
                end
                index.SetBase = function(argument, argument2)
                    localization2.trace("SetBase")
                    if theme.setBase(argument2) then
                        argument.State.set("base", argument2)
                        argument.State.set("panel", nil)
                        argument.PanelColor = nil
                    end
                end
                index.IsHalloween = function(argument)
                    return false
                end
                index.SetHalloween = function(argument, argument2)
                    localization2.trace("SetHalloween")
                    local state = argument.State
                    if argument2 then
                        if not (argument:IsHalloween()) then
                            state.set(
                                "preHw",
                                {
                                    base = theme.base ~= "Halloween" and theme.base or nil,
                                    panel = argument.PanelColor and argument.PanelColor:ToHex() or nil,
                                    accent = theme.tokens.Accent and theme.tokens.Accent:ToHex() or nil,
                                    bgStyle = argument.BgStyle ~= "Halloween" and argument.BgStyle or nil,
                                }
                            )
                        end
                        argument:SetBase("Halloween")
                        argument:SetAccent(Color3.fromHex(index.HalloweenAccent))
                        argument:SetBackground("Halloween")
                    else
                        local getResult = state.get("preHw", nil)
                        local value
                        if type(getResult) ~= "table" then
                            getResult = argument.HalloweenFallback or {}
                            value = getResult
                        else
                            value = getResult
                        end
                        if value.base then
                            if value.base ~= "Custom" then
                                if value.base ~= "Halloween" then
                                    argument:SetBase(value.base)
                                else
                                    argument:SetBase("Midnight")
                                end
                            else
                                argument:SetBase("Midnight")
                            end
                        else
                            argument:SetBase("Midnight")
                        end
                        if value.panel then
                            pcall(function()
                                argument:SetPanelColor(Color3.fromHex(value.panel))
                            end)
                        end
                        if value.accent then
                            pcall(function()
                                argument:SetAccent(Color3.fromHex(value.accent))
                            end)
                        end
                        argument:SetBackground(
                            value.bgStyle and value.bgStyle ~= "Halloween" and value.bgStyle or "Aurora"
                        )
                    end
                    state.set("hwOn", argument2 and true or false)
                    if argument.AppearanceRefs then
                        pcall(function()
                            argument:SyncAppearance()
                        end)
                    end
                end
                index.SetPanelColor = function(argument, panelColor)
                    localization2.trace("SetPanelColor")
                    if typeof(panelColor) ~= "Color3" then
                        return
                    end
                    argument.PanelColor = panelColor
                    argument.State.set("panel", panelColor:ToHex())
                    theme.base = "Custom"
                    if argument._panelQueued then
                        return
                    end
                    argument._panelQueued = true
                    task.delay(0.06, function()
                        argument._panelQueued = false
                        if argument.PanelColor then
                            if not argument.Destroyed then
                                theme.setMany(theme.panelFrom(argument.PanelColor))
                                theme.base = "Custom"
                            end
                        end
                    end)
                end
                index.OnKeyChanged = function(argument, argument2)
                    argument.KeyListeners = argument.KeyListeners or {}
                    table.insert(argument.KeyListeners, argument2)
                end
                index.SetKey = function(argument, key)
                    if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
                        argument.Key = key
                        argument.State.set("menuKey", key.Name)
                        argument:_syncFooter()
                        for unused, item in ipairs(argument.KeyListeners or {}) do
                            task.spawn(pcall, item, key)
                        end
                    end
                end
                index.SetTitle = function(argument, text, text2)
                    if text then
                        argument.TitleLabel.Text = text
                    end
                    if text2 then
                        argument.SubtitleLabel.Text = text2
                    end
                end
                index.ResetAppearance = function(argument)
                    local entries = {
                        "accent",
                        "radius",
                        "font",
                        "textScale",
                        "scale",
                        "autoFit",
                        "blur",
                        "bgStyle",
                        "bgIntensity",
                        "opacity",
                        "tooltips",
                        "launcher",
                        "base",
                        "cardStyle",
                        "density",
                        "watermark",
                        "keybindList",
                        "sidebarWidth",
                        "panel",
                    }
                    for unused, item in ipairs(entries) do
                        argument.State.data[item] = nil
                    end
                    argument.State.save()
                    argument.PanelColor = nil
                    local stateDefaults = argument.StateDefaults
                    if type(stateDefaults) == "table" then
                        if stateDefaults.base then
                            argument:SetBase(stateDefaults.base)
                        end
                        if stateDefaults.panel then
                            pcall(function()
                                argument:SetPanelColor(Color3.fromHex(stateDefaults.panel))
                            end)
                        end
                        if stateDefaults.accent then
                            pcall(function()
                                argument:SetAccent(Color3.fromHex(stateDefaults.accent))
                            end)
                        end
                        argument:SetCornerRadius(tonumber(stateDefaults.radius) or 1)
                        if stateDefaults.font then
                            argument:SetFont(stateDefaults.font)
                        end
                        argument:SetTextScale(tonumber(stateDefaults.textScale) or 1)
                        argument:SetScale(tonumber(stateDefaults.scale) or argument.DefaultScale)
                        argument:SetAutoFit(stateDefaults.autoFit ~= false)
                        argument:SetBlur(stateDefaults.blur == true)
                        if stateDefaults.bgStyle then
                            argument:SetBackground(stateDefaults.bgStyle)
                        end
                        argument:SetBackgroundIntensity(tonumber(stateDefaults.bgIntensity) or 1)
                        if stateDefaults.cardStyle then
                            argument:SetCardStyle(stateDefaults.cardStyle)
                        end
                        if stateDefaults.density then
                            argument:SetDensity(stateDefaults.density)
                        end
                        argument:SetSidebarWidth(
                            tonumber(stateDefaults.sidebarWidth) or argument.DefaultSidebarWidth
                        )
                        argument:SetOpacity(tonumber(stateDefaults.opacity) or 1)
                        if stateDefaults.groupLabels ~= nil then
                            if argument.SetGroupLabels then
                                argument:SetGroupLabels(stateDefaults.groupLabels)
                            end
                        end
                        if argument.SetTooltips then
                            argument:SetTooltips(stateDefaults.tooltips ~= false)
                        end
                        if stateDefaults.launcher ~= nil then
                            if argument.SetLauncher then
                                argument:SetLauncher(stateDefaults.launcher)
                            end
                        end
                        argument.State.save()
                        if argument.OnReset then
                            pcall(argument.OnReset)
                        end
                        return
                    end
                    theme.setBase("Midnight")
                    theme.set("Accent", theme.Presets.Crimson)
                    argument:SetCornerRadius(1)
                    argument:SetFont("Builder Sans")
                    argument:SetTextScale(1)
                    argument:SetScale(argument.DefaultScale)
                    argument:SetAutoFit(true)
                    argument:SetBlur(false)
                    argument:SetBackground("Aurora")
                    argument:SetBackgroundIntensity(1)
                    argument:SetCardStyle("Glass")
                    argument:SetDensity("Comfortable")
                    argument:SetSidebarWidth(argument.DefaultSidebarWidth)
                    argument:SetOpacity(1)
                    argument.State.data.accent = nil
                    argument.State.data.radius = nil
                    argument.State.data.font = nil
                    argument.State.data.textScale = nil
                    argument.State.data.scale = nil
                    argument.State.data.blur = nil
                    argument.State.data.bgStyle = nil
                    argument.State.data.bgIntensity = nil
                    argument.State.data.opacity = nil
                    argument.State.save()
                    if argument.OnReset then
                        pcall(argument.OnReset)
                    end
                end
                index._buildClose = function(argument, parent)
                    local closeButton = createInstance(
                        "TextButton",
                        {
                            Name = "Close",
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            AnchorPoint = Vector2.new(1, 0.5),
                            Position = UDim2.new(1, -20, 0, 31),
                            Size = UDim2.fromOffset(34, 34),
                            ZIndex = 5,
                            Parent = parent,
                        }
                    )
                    local value = createInstance("UIScale", { Parent = closeButton })
                    local imageResult = tex.image(
                        closeButton,
                        "glow",
                        {
                            Name = "Glow",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(84, 84),
                            ImageTransparency = 1,
                            ZIndex = 4,
                        }
                    )
                    if imageResult then
                        bindTheme(imageResult, "ImageColor3", "Danger")
                    end
                    local tileResult, tileResult2 = localization2.tile(
                        closeButton,
                        { Name = "Face", Size = UDim2.fromScale(1, 1), Color = "Elevated", Alpha = 0.05, SliceScale = 0.6, Z = 5 }
                    )
                    parent = tex.image(
                        closeButton,
                        "rim9",
                        { Name = "Rim", Size = UDim2.fromScale(1, 1), SliceScale = 0.64, ImageTransparency = 0.72, ZIndex = 7 }
                    )
                    if parent then
                        bindTheme(parent, "ImageColor3", "Glass")
                    end
                    local value2 = icon({
                        Parent = closeButton,
                        Icon = "x",
                        Size = 16,
                        Pos = UDim2.fromScale(0.5, 0.5),
                        Anchor = Vector2.new(0.5, 0.5),
                        Color = "Muted",
                        Z = 8,
                    })
                    local calculatedValue = tileResult2 and "ImageColor3" or "BackgroundColor3"
                    local function handleAction()
                        tweenInstance(tileResult, "Quick", { [calculatedValue] = theme.resolve("Danger") })
                        tweenInstance(value2, "Quick", { ImageColor3 = Color3.new(1, 1, 1) })
                        if imageResult then
                            tweenInstance(imageResult, "Quick", { ImageTransparency = 0.72 })
                        end
                        tweenInstance(value, "Quick", { Scale = 1.06 })
                        sound.play("hover", 0.6)
                        argument:ShowTip("Close")
                    end
                    closeButton.MouseEnter:Connect(handleAction)
                    u.leave(closeButton, function()
                        tweenInstance(tileResult, "Quick", { [calculatedValue] = theme.resolve("Elevated") })
                        tweenInstance(value2, "Quick", { ImageColor3 = theme.resolve("Muted") })
                        if imageResult then
                            tweenInstance(imageResult, "Quick", { ImageTransparency = 1 })
                        end
                        tweenInstance(value, "Quick", { Scale = 1 })
                        argument:HideTip()
                    end)
                    local function handleAction2()
                        tweenInstance(value, "Quick", { Scale = 0.9 })
                    end
                    closeButton.MouseButton1Down:Connect(handleAction2)
                    local function handleAction()
                        tweenInstance(value, "PopSmall", { Scale = 1.06 })
                    end
                    closeButton.MouseButton1Up:Connect(handleAction)
                    local function handleAction2()
                        sound.play("click")
                        argument:HideTip()
                        argument:Close()
                    end
                    closeButton.MouseButton1Click:Connect(handleAction2)
                    argument.CloseButton = closeButton
                    if argument.IsTouch then
                        closeButton.Size = UDim2.fromOffset(42, 42)
                        closeButton.Position = UDim2.new(1, -16, 0, 31)
                        value2.Size = UDim2.fromOffset(19, 19)
                        if imageResult then
                            imageResult.Size = UDim2.fromOffset(70, 70)
                        end
                        handleAction2 = createInstance(
                            "TextButton",
                            {
                                Name = "HitPad",
                                Text = "",
                                AutoButtonColor = false,
                                BackgroundTransparency = 1,
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromOffset(56, 56),
                                ZIndex = 9,
                                Parent = closeButton,
                            }
                        )
                        local function handleAction()
                            tweenInstance(value, "Quick", { Scale = 0.9 })
                        end
                        handleAction2.MouseButton1Down:Connect(handleAction)
                        local function handleAction3()
                            tweenInstance(value, "PopSmall", { Scale = 1 })
                        end
                        handleAction2.MouseButton1Up:Connect(handleAction3)
                        local function handleAction()
                            sound.play("click")
                            argument:HideTip()
                            argument:Close()
                        end
                        handleAction2.MouseButton1Click:Connect(handleAction)
                    end
                    theme.onChange(function(argument2)
                        if argument2 == "Elevated" or argument2 == "Danger" then
                            pcall(function()
                                tileResult[calculatedValue] = theme.resolve("Elevated")
                            end)
                        end
                    end)
                end
                index.AddHeaderButton = function(argument, argument2)
                    local calculatedValue = argument2 or {}
                    local parent = argument.CloseButton and argument.CloseButton.Parent
                    if not parent then
                        return nil
                    end
                    argument.HeaderButtons = argument.HeaderButtons or {}
                    local roundedValue, isTouch = #argument.HeaderButtons + 1, argument.IsTouch
                    local imageResult = isTouch and 42 or 34
                    local calculatedValue2, calculatedValue3, imageColor =
                        imageResult + 8, isTouch and 16 or 20, calculatedValue.HoverColor or theme.resolve("Accent")
                    local parent2 = createInstance(
                        "TextButton",
                        {
                            Name = calculatedValue.Name or "HeaderButton",
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            AnchorPoint = Vector2.new(1, 0.5),
                            Position = UDim2.new(1, -(calculatedValue3 + calculatedValue2 * roundedValue), 0, 31),
                            Size = UDim2.fromOffset(imageResult, imageResult),
                            ZIndex = 5,
                            Parent = parent,
                        }
                    )
                    local value = createInstance("UIScale", { Parent = parent2 })
                    local imageResult2 = tex.image(
                        parent2,
                        "glow",
                        {
                            Name = "Glow",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(isTouch and 70 or 84, isTouch and 70 or 84),
                            ImageTransparency = 1,
                            ZIndex = 4,
                        }
                    )
                    if imageResult2 then
                        imageResult2.ImageColor3 = imageColor
                    end
                    local tileResult, tileResult2 = localization2.tile(
                        parent2,
                        { Name = "Face", Size = UDim2.fromScale(1, 1), Color = "Elevated", Alpha = 0.05, SliceScale = 0.6, Z = 5 }
                    )
                    imageResult = tex.image(
                        parent2,
                        "rim9",
                        { Name = "Rim", Size = UDim2.fromScale(1, 1), SliceScale = 0.64, ImageTransparency = 0.72, ZIndex = 7 }
                    )
                    if imageResult then
                        bindTheme(imageResult, "ImageColor3", "Glass")
                    end
                    local value2, value3
                    if calculatedValue.Image then
                        parent, roundedValue =
                            calculatedValue.ImageSize and calculatedValue.ImageSize.X or 18,
                            calculatedValue.ImageSize and calculatedValue.ImageSize.Y or 14
                        if isTouch then
                            parent, roundedValue =
                                (math.floor(parent * 1.2 + 0.5)), math.floor(roundedValue * 1.2 + 0.5)
                        else
                        end
                        value2 = createInstance(
                            "ImageLabel",
                            {
                                Name = "Icon",
                                BackgroundTransparency = 1,
                                Image = calculatedValue.Image,
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromOffset(parent, roundedValue),
                                ScaleType = Enum.ScaleType.Fit,
                                ImageColor3 = theme.resolve("Muted"),
                                ZIndex = 8,
                                Parent = parent2,
                            }
                        )
                        value3 = value2
                    else
                        value2 = icon({
                            Parent = parent2,
                            Icon = calculatedValue.Icon or "circle",
                            Size = isTouch and 19 or 16,
                            Pos = UDim2.fromScale(0.5, 0.5),
                            Anchor = Vector2.new(0.5, 0.5),
                            Color = "Muted",
                            Z = 8,
                        })
                        value3 = value2
                    end
                    local calculatedValue2, enabled = tileResult2 and "ImageColor3" or "BackgroundColor3", false
                    parent2.MouseEnter:Connect(function()
                        enabled = true
                        tweenInstance(tileResult, "Quick", { [calculatedValue2] = imageColor })
                        tweenInstance(value3, "Quick", { ImageColor3 = Color3.new(1, 1, 1) })
                        if imageResult2 then
                            tweenInstance(imageResult2, "Quick", { ImageTransparency = 0.72 })
                        end
                        tweenInstance(value, "Quick", { Scale = 1.06 })
                        sound.play("hover", 0.6)
                        if calculatedValue.Tip then
                            argument:ShowTip(calculatedValue.Tip)
                        end
                    end)
                    u.leave(parent2, function()
                        enabled = false
                        tweenInstance(tileResult, "Quick", { [calculatedValue2] = theme.resolve("Elevated") })
                        tweenInstance(value3, "Quick", { ImageColor3 = theme.resolve("Muted") })
                        if imageResult2 then
                            tweenInstance(imageResult2, "Quick", { ImageTransparency = 1 })
                        end
                        tweenInstance(value, "Quick", { Scale = 1 })
                        argument:HideTip()
                    end)
                    local function handleAction()
                        tweenInstance(value, "Quick", { Scale = 0.9 })
                    end
                    parent2.MouseButton1Down:Connect(handleAction)
                    local function handleAction2()
                        tweenInstance(value, "PopSmall", { Scale = 1.06 })
                    end
                    parent2.MouseButton1Up:Connect(handleAction2)
                    local function handleAction()
                        sound.play("click")
                        argument:HideTip()
                        if calculatedValue.Callback then
                            task.spawn(calculatedValue.Callback)
                        end
                    end
                    parent2.MouseButton1Click:Connect(handleAction)
                    theme.onChange(function(argument2)
                        if enabled then
                            return
                        end
                        if argument2 == "Elevated" or argument2 == "Muted" then
                            pcall(function()
                                tileResult[calculatedValue2] = theme.resolve("Elevated")
                                value3.ImageColor3 = theme.resolve("Muted")
                            end)
                        end
                    end)
                    table.insert(argument.HeaderButtons, parent2)
                    return parent2
                end
                index._drag = function(argument, argument2)
                    if typeof(argument2) ~= "Instance" then
                        return
                    end
                    local enabled, value, value2, value3
                    argument2.InputBegan:Connect(function(argument3)
                        if not (u.isClick(argument3)) then
                            return
                        end
                        local position, position2
                        position, position2, enabled = argument3.Position, argument.Root.Position, true
                        value, value2, value3 = position, position2, argument3
                        local connection
                        connection = argument3.Changed:Connect(function()
                            if argument3.UserInputState == Enum.UserInputState.End then
                                enabled = false
                                connection:Disconnect()
                                argument:_savePos()
                            end
                        end)
                    end)
                    u.connect(userInputService.InputChanged, function(argument3)
                        if enabled then
                            if u.sameMove(argument3, value3) then
                                local calculatedValue = argument3.Position - value
                                argument.Root.Position = UDim2.new(
                                    value2.X.Scale,
                                    value2.X.Offset + calculatedValue.X,
                                    value2.Y.Scale,
                                    value2.Y.Offset + calculatedValue.Y
                                )
                            end
                        end
                    end, argument.Conns)
                end
                index._savePos = function(argument)
                    if argument.State then
                        if not argument.Root then
                            return
                        end
                    else
                        return
                    end
                    local position = argument.Root.Position
                    if math.abs(position.X.Scale - 0.5) > 0.001 then
                        return
                    elseif math.abs(position.Y.Scale - 0.5) > 0.001 then
                        return
                    end
                    pcall(
                        argument.State.set,
                        argument.IsTouch and "touchPos" or "winPos",
                        { math.floor(position.X.Offset + 0.5), math.floor(position.Y.Offset + 0.5) }
                    )
                end
                index._resize = function(argument, argument2)
                    local enabled, value, value2, value3, value4
                    argument2.InputBegan:Connect(function(argument3)
                        if not (u.isClick(argument3)) then
                            return
                        end
                        local position, calculatedValue, position2 =
                            argument3.Position,
                            argument.Root.AbsoluteSize / math.max(argument.Scale.Scale, 0.1),
                            argument.Root.Position
                        enabled, value, value2, value3, value4 =
                            true, position, calculatedValue, position2, argument3
                        local connection
                        connection = argument3.Changed:Connect(function()
                            if argument3.UserInputState == Enum.UserInputState.End then
                                enabled = false
                                connection:Disconnect()
                                if argument.IsTouch then
                                    argument.TouchSize = argument.Size
                                    if argument.State then
                                        pcall(
                                            argument.State.set,
                                            "touchSize",
                                            { math.floor(argument.Size.X + 0.5), math.floor(argument.Size.Y + 0.5) }
                                        )
                                    end
                                elseif argument.State then
                                    pcall(
                                        argument.State.set,
                                        "size",
                                        { math.floor(argument.Size.X + 0.5), math.floor(argument.Size.Y + 0.5) }
                                    )
                                end
                                argument:_savePos()
                            end
                        end)
                    end)
                    u.connect(userInputService.InputChanged, function(argument3)
                        if enabled then
                            if u.sameMove(argument3, value4) then
                                local point, x, y =
                                    (argument3.Position - value) / math.max(argument.Scale.Scale, 0.1),
                                    argument.MinSize.X,
                                    argument.MinSize.Y
                                if argument.IsTouch then
                                    local camera = workspace.CurrentCamera
                                    local calculatedValue, maximumValue =
                                        camera and camera.ViewportSize or Vector2.new(1280, 720),
                                        math.max(argument.Scale.Scale, 0.1)
                                    point, x, y =
                                        (Vector2.new(
                                            math.min(point.X, (calculatedValue.X - 16) / maximumValue - value2.X),
                                            math.min(point.Y, (calculatedValue.Y - 16) / maximumValue - value2.Y)
                                        )),
                                        360,
                                        240
                                else
                                end
                                local maximumValue, maximumValue2 =
                                    math.max(x, value2.X + point.X), math.max(y, value2.Y + point.Y)
                                argument.Size = Vector2.new(maximumValue, maximumValue2)
                                argument.Root.Size = UDim2.fromOffset(maximumValue, maximumValue2)
                                local scale = argument.Scale.Scale
                                argument.Root.Position = UDim2.new(
                                    value3.X.Scale,
                                    value3.X.Offset + (maximumValue - value2.X) * scale / 2,
                                    value3.Y.Scale,
                                    value3.Y.Offset + (maximumValue2 - value2.Y) * scale / 2
                                )
                            end
                        end
                    end, argument.Conns)
                end
                index._syncLayers = function(argument)
                    local scale, callback, entries =
                        math.max((argument.AutoScale or 1) * argument.UserScale, 0.1),
                        ipairs,
                        { { argument.FloatLayer, argument.FloatScale }, { argument.PopLayer, argument.PopScale } }
                    for unused, item in callback(entries) do
                        item[2].Scale = scale
                        item[1].Size = UDim2.fromScale(1 / scale, 1 / scale)
                    end
                end
                localization2.screenFactor = function(calculatedValue)
                    if calculatedValue then
                    else
                        local camera = workspace.CurrentCamera
                        calculatedValue = camera and camera.ViewportSize or Vector2.new(1920, 1000)
                    end
                    local minimumValue = math.min(calculatedValue.X / 1920, calculatedValue.Y / 1000)
                    minimumValue = if math.abs(minimumValue - 1) < 0.04 then 1 else minimumValue
                    return u.clamp(minimumValue, 0.5, 1.3)
                end
                index._placeOnScreen = function(calculatedValue, calculatedValue2)
                    local camera = workspace.CurrentCamera
                    local calculatedValue3 = camera and camera.ViewportSize or Vector2.new(1280, 720)
                    calculatedValue2 = calculatedValue2 or calculatedValue.Root.Position
                    camera = (calculatedValue.AutoScale or 1) * calculatedValue.UserScale
                    local calculatedValue4, calculatedValue5, calculatedValue6 =
                        Vector2.new(calculatedValue.Root.Size.X.Offset, calculatedValue.Root.Size.Y.Offset) * camera,
                        calculatedValue2.X.Scale * calculatedValue3.X + calculatedValue2.X.Offset,
                        calculatedValue2.Y.Scale * calculatedValue3.Y + calculatedValue2.Y.Offset
                    local calculatedValue7, calculatedValue8, counter =
                        calculatedValue4.X / 2, calculatedValue4.Y / 2, 8
                    camera, calculatedValue =
                        calculatedValue4.X + 16 >= calculatedValue3.X and calculatedValue3.X / 2 or math.clamp(
                            calculatedValue5,
                            calculatedValue7 + counter,
                            calculatedValue3.X - calculatedValue7 - counter
                        ),
                        calculatedValue4.Y + 16 >= calculatedValue3.Y and calculatedValue3.Y / 2 or math.clamp(
                            calculatedValue6,
                            calculatedValue8 + counter,
                            calculatedValue3.Y - calculatedValue8 - counter
                        )
                    if math.abs(camera - calculatedValue5) < 0.5 then
                        if math.abs(calculatedValue - calculatedValue6) < 0.5 then
                            return calculatedValue2
                        end
                    end
                    return UDim2.new(
                        calculatedValue2.X.Scale,
                        math.floor(calculatedValue2.X.Offset + (camera - calculatedValue5) + 0.5),
                        calculatedValue2.Y.Scale,
                        math.floor(calculatedValue2.Y.Offset + (calculatedValue - calculatedValue6) + 0.5)
                    )
                end
                index.OnScreenScale = function(argument, argument2)
                    table.insert(argument.ScaleHooks, argument2)
                    local camera = workspace.CurrentCamera
                    local success, result = pcall(
                        argument2,
                        argument.OverlayScale or 1,
                        camera and camera.ViewportSize or Vector2.new(1280, 720)
                    )
                    if success then
                        if result == false then
                            camera = table.find(argument.ScaleHooks, argument2)
                            if camera then
                                table.remove(argument.ScaleHooks, camera)
                            end
                        end
                    end
                end
                index.SetAutoFit = function(argument, argument2)
                    localization2.trace("SetAutoFit")
                    argument.AutoFit = argument2 and true or false
                    argument.State.set("autoFit", argument.AutoFit)
                    if not argument.AutoFit then
                        if not argument.IsTouch then
                            argument.Root.Size = UDim2.fromOffset(argument.Size.X, argument.Size.Y)
                        end
                    end
                    if argument._applyScale then
                        argument._applyScale(true)
                    end
                end
                index._autoScale = function(argument)
                    local camera = workspace.CurrentCamera
                    local function applyScale(calculatedValue)
                        calculatedValue = camera and camera.ViewportSize or Vector2.new(1280, 720)
                        local position = argument.AutoFit and localization2.screenFactor(calculatedValue) or 1
                        argument.ScreenFactor = position
                        argument.OverlayScale = argument.AutoFit and u.clamp(position, 0.6, 1.2) or 1
                        if argument.IsTouch then
                            local clampedValue = u.clamp((calculatedValue.Y - 16) / 440, 0.55, 1)
                            local clampedValue2 = u.clamp(
                                clampedValue * argument.UserScale / math.max(argument.DefaultScale or 1, 0.1),
                                0.45,
                                1.3
                            )
                            local roundedValue, roundedValue2, touchSize, roundedValue3, roundedValue4 =
                                math.floor(math.min(argument.BaseSize.X, (calculatedValue.X - 16) / clampedValue2)),
                                math.floor(math.min(argument.BaseSize.Y, (calculatedValue.Y - 16) / clampedValue2)),
                                argument.TouchSize
                            if touchSize then
                                roundedValue3, roundedValue4 =
                                    math.floor(u.clamp(touchSize.X, math.min(360, roundedValue), roundedValue)),
                                    math.floor(u.clamp(touchSize.Y, math.min(240, roundedValue2), roundedValue2))
                            else
                                roundedValue3, roundedValue4 =
                                    math.min(roundedValue, math.floor(calculatedValue.X * 0.72 / clampedValue2)),
                                    math.min(roundedValue2, math.floor(calculatedValue.Y * 0.86 / clampedValue2))
                            end
                            if argument.Size.X ~= roundedValue3 or argument.Size.Y ~= roundedValue4 then
                                argument.Size = Vector2.new(roundedValue3, roundedValue4)
                                argument.Root.Size = UDim2.fromOffset(roundedValue3, roundedValue4)
                            end
                            argument.AutoScale = clampedValue2 / math.max(argument.UserScale, 0.1)
                        elseif argument.AutoFit then
                            local maximumValue = math.max(argument.UserScale, 0.1)
                            local maximumValue2, calculatedValue2, calculatedValue3, x, y =
                                math.max(maximumValue * position, math.min(0.6, maximumValue)),
                                calculatedValue.X - 24,
                                calculatedValue.Y - 24,
                                argument.Size.X,
                                argument.Size.Y
                            x, y =
                                math.max(
                                    math.min(argument.MinSize.X, x),
                                    math.min(x, math.floor(calculatedValue2 / maximumValue2))
                                ),
                                math.max(
                                    math.min(argument.MinSize.Y, y),
                                    math.min(y, math.floor(calculatedValue3 / maximumValue2))
                                )
                            local minimumValue, size =
                                math.min(
                                    1,
                                    calculatedValue2 / (x * maximumValue2),
                                    calculatedValue3 / (y * maximumValue2)
                                ),
                                UDim2.fromOffset(x, y)
                            if argument.Root.Size ~= size then
                                argument.Root.Size = size
                            end
                            argument.AutoScale = u.clamp(maximumValue2 * minimumValue, 0.3, 1.8) / maximumValue
                        else
                            local minimumValue = math.min(
                                1,
                                (calculatedValue.X - 30) / argument.Size.X,
                                (calculatedValue.Y - 30) / argument.Size.Y
                            )
                            argument.AutoScale = u.clamp(minimumValue, 0.45, 1)
                        end
                        argument.Scale.Scale = argument.AutoScale * argument.UserScale
                        argument.ToastScale.Scale =
                            u.clamp(math.min(argument.OverlayScale, calculatedValue.X / 900), 0.55, 1.2)
                        argument:_syncLayers()
                        if not argument.Scaling then
                            if not argument.HomePos then
                                position = argument:_placeOnScreen(argument.Root.Position)
                                if position ~= argument.Root.Position then
                                    argument.Root.Position = position
                                end
                            end
                        end
                        for index2 = #argument.ScaleHooks, 1, -1 do
                            local success, result =
                                pcall(argument.ScaleHooks[index2], argument.OverlayScale, calculatedValue)
                            if success then
                                if result == false then
                                    table.remove(argument.ScaleHooks, index2)
                                end
                            end
                        end
                    end
                    applyScale()
                    if camera then
                        u.connect(camera:GetPropertyChangedSignal("ViewportSize"), applyScale, argument.Conns)
                    end
                    argument._applyScale = applyScale
                end
                index.SetScale = function(argument, argument2)
                    localization2.trace("SetScale")
                    argument.UserScale = u.clamp(tonumber(argument2) or 1, 0.6, 1.5)
                    argument.State.set("scale", argument.UserScale)
                    if argument._applyScale then
                        argument._applyScale(true)
                    end
                end
                index._launcher = function(uiPage, key)
                    local state = uiPage.State
                    local glow, fromOffsetResult = state.get("launcherPos", nil), UDim2.fromOffset(16, 70)
                    local launcher = createInstance(
                        "TextButton",
                        {
                            Name = "Launcher",
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            Position = if type(glow) == "table"
                                then if tonumber(glow[1])
                                    then if tonumber(glow[2])
                                        then UDim2.fromOffset(glow[1], glow[2])
                                        else fromOffsetResult
                                    else fromOffsetResult
                                else fromOffsetResult,
                            Size = UDim2.fromOffset(150, 42),
                            Visible = uiPage.LauncherOn,
                            ZIndex = 25,
                            Parent = uiPage.Gui,
                        }
                    )
                    local scale = createInstance("UIScale", { Parent = launcher })
                    uiPage.LauncherBase = 1
                    local shadow = tex.image(
                        launcher,
                        "shadow9",
                        {
                            Name = "Shadow",
                            Position = UDim2.fromOffset(-22, -14),
                            Size = UDim2.new(1, 44, 1, 46),
                            SliceScale = 1,
                            ImageTransparency = 0.5,
                            ZIndex = 24,
                        }
                    )
                    local card = createInstance(
                        "Frame",
                        {
                            Name = "Card",
                            Size = UDim2.new(0, 0, 1, 0),
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0,
                            BackgroundTransparency = 0.04,
                            ZIndex = 26,
                            Parent = launcher,
                        }
                    )
                    bindTheme(card, "BackgroundColor3", "Surface")
                    u.corner(card, 14)
                    createInstance(
                        "UIGradient",
                        {
                            Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(206, 208, 216)),
                            Rotation = 90,
                            Parent = card,
                        }
                    )
                    glow = tex.image(
                        card,
                        "glow",
                        {
                            Name = "Glow",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.new(0, 22, 0.5, 0),
                            Size = UDim2.fromOffset(120, 90),
                            ImageTransparency = 0.85,
                            ZIndex = 26,
                        }
                    )
                    if glow then
                        if key.Logo then
                            if key.LogoGlow then
                                glow.ImageColor3 = key.LogoGlow
                            else
                                bindTheme(glow, "ImageColor3", "Accent")
                            end
                        else
                            bindTheme(glow, "ImageColor3", "Accent")
                        end
                    end
                    local parent, orb = tex.image, { Name = "Gloss" }
                    orb.Size, orb.SliceScale, orb.ImageTransparency, orb.ZIndex =
                        UDim2.fromScale(1, 1), 0.79, 0.9, 27
                    parent(card, "gloss9", orb)
                    local rim = tex.image(
                        card,
                        "rim9",
                        { Name = "Rim", Size = UDim2.fromScale(1, 1), SliceScale = 0.79, ImageTransparency = 0.45, ZIndex = 34 }
                    )
                    if rim then
                        bindTheme(rim, "ImageColor3", "Glass")
                    else
                        bindTheme(u.stroke(card, Color3.new(1, 1, 1), 1, 0.85), "Color", "Glass")
                    end
                    parent = createInstance(
                        "Frame",
                        {
                            Name = "Row",
                            Size = UDim2.new(0, 0, 1, 0),
                            AutomaticSize = Enum.AutomaticSize.X,
                            BackgroundTransparency = 1,
                            ZIndex = 28,
                            Parent = card,
                        }
                    )
                    u.pad(parent, 0, 7, 0, 6)
                    u.list(
                        parent,
                        9,
                        Enum.FillDirection.Horizontal,
                        Enum.HorizontalAlignment.Left,
                        Enum.VerticalAlignment.Center
                    )
                    orb = createInstance(
                        "Frame",
                        {
                            Name = "Logo",
                            Size = UDim2.fromOffset(30, 30),
                            BackgroundTransparency = 1,
                            LayoutOrder = 1,
                            ZIndex = 28,
                            Parent = parent,
                        }
                    )
                    if key.Logo then
                        createInstance(
                            "ImageLabel",
                            {
                                Name = "Mark",
                                BackgroundTransparency = 1,
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromOffset(34, 34),
                                Image = key.Logo,
                                ScaleType = Enum.ScaleType.Fit,
                                ZIndex = 29,
                                Parent = orb,
                            }
                        )
                    else
                        local tile, instanceOptions = localization2.tile, { Name = "Face" }
                        instanceOptions.Size, instanceOptions.Color, instanceOptions.SliceScale, instanceOptions.Z =
                            UDim2.fromScale(1, 1), "Accent", 0.5, 28
                        tile(orb, instanceOptions)
                        label({
                            Parent = orb,
                            Text = tostring(key.Initial or string.sub(key.Title or "N", 1, 1)),
                            Font = font.Heavy(),
                            Size = 15,
                            Box = UDim2.fromScale(1, 1),
                            AlignX = Enum.TextXAlignment.Center,
                            Color = "OnAccent",
                            Z = 30,
                        })
                    end
                    local value = label({
                        Parent = parent,
                        Text = tostring(key.Title or "GGH"),
                        Font = font.Bold(),
                        Size = 14,
                        Box = UDim2.new(0, 0, 1, 0),
                        Auto = Enum.AutomaticSize.X,
                        Z = 29,
                        Name = "Title",
                    })
                    value.LayoutOrder = 2
                    key = nil
                    if uiPage.IsTouch then
                    else
                        orb = createInstance(
                            "Frame",
                            {
                                Name = "Key",
                                Size = UDim2.fromOffset(0, 20),
                                AutomaticSize = Enum.AutomaticSize.X,
                                BorderSizePixel = 0,
                                BackgroundTransparency = 0.45,
                                LayoutOrder = 3,
                                ZIndex = 29,
                                Parent = parent,
                            }
                        )
                        bindTheme(orb, "BackgroundColor3", "Elevated")
                        u.corner(orb, 6)
                        u.pad(orb, 0, 7, 0, 7)
                        bindTheme(u.stroke(orb, Color3.new(1, 1, 1), 1, 0.88), "Color", "Glass")
                        key = label({
                            Parent = orb,
                            Text = localization2.keyName and localization2.keyName(uiPage.Key) or uiPage.Key.Name,
                            Font = font.Semi(),
                            Size = 11,
                            Box = UDim2.new(0, 0, 1, 0),
                            Auto = Enum.AutomaticSize.X,
                            Color = "Muted",
                            Z = 30,
                        })
                    end
                    orb = createInstance(
                        "Frame",
                        {
                            Name = "Orb",
                            Size = UDim2.fromOffset(28, 28),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 0.35,
                            LayoutOrder = 4,
                            ZIndex = 29,
                            Parent = parent,
                        }
                    )
                    bindTheme(orb, "BackgroundColor3", "Elevated")
                    u.corner(orb, UDim.new(1, 0))
                    parent = u.stroke(orb, Color3.new(1, 1, 1), 1, 0.85)
                    bindTheme(parent, "Color", "Glass")
                    local chev = icon({
                        Parent = orb,
                        Icon = "chevron-down",
                        Size = 15,
                        Pos = UDim2.fromScale(0.5, 0.5),
                        Anchor = Vector2.new(0.5, 0.5),
                        Color = "Muted",
                        Z = 30,
                    })
                    uiPage.LauncherParts = {
                        btn = launcher,
                        card = card,
                        orb = orb,
                        orbStroke = parent,
                        chev = chev,
                        glow = glow,
                        rim = rim,
                        key = key,
                        scale = scale,
                        shadow = shadow,
                    }
                    local function handleAction()
                        local maximumValue = math.max(scale.Scale, 0.1)
                        local roundedValue = math.ceil(card.AbsoluteSize.X / maximumValue)
                        if roundedValue > 0 then
                            if launcher.Size.X.Offset ~= roundedValue then
                                launcher.Size = UDim2.fromOffset(roundedValue, 42)
                            end
                        end
                    end
                    card:GetPropertyChangedSignal("AbsoluteSize"):Connect(handleAction)
                    task.defer(handleAction)
                    local tweenInfo = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local tweenInfo2, enabled, enabled2, value2, value3, value4 =
                        TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), false, false
                    launcher.InputBegan:Connect(function(argument)
                        if not (u.isClick(argument)) then
                            return
                        end
                        local position, position2
                        position, position2, enabled2, enabled = argument.Position, launcher.Position, true, false
                        value2, value3, value4 = position, position2, argument
                        tweenInstance(scale, tweenInfo, { Scale = uiPage.LauncherBase * 0.95 })
                    end)
                    u.connect(userInputService.InputChanged, function(argument)
                        if enabled2 then
                            if u.sameMove(argument, value4) then
                                local calculatedValue = argument.Position - value2
                                if calculatedValue.Magnitude > 6 then
                                    enabled = true
                                end
                                if enabled then
                                    local launcherAreaResult = uiPage:_launcherArea()
                                    local clampedValue, clampedValue2 =
                                        math.clamp(
                                            value3.X.Offset + calculatedValue.X,
                                            4,
                                            math.max(4, launcherAreaResult.X - launcher.AbsoluteSize.X - 4)
                                        ),
                                        math.clamp(
                                            value3.Y.Offset + calculatedValue.Y,
                                            4,
                                            math.max(4, launcherAreaResult.Y - launcher.AbsoluteSize.Y - 4)
                                        )
                                    launcher.Position = UDim2.fromOffset(clampedValue, clampedValue2)
                                end
                            end
                        end
                    end, uiPage.Conns)
                    u.connect(userInputService.InputEnded, function(argument)
                        if enabled2 then
                            if u.sameEnd(argument, value4) then
                                enabled2 = false
                                tweenInstance(scale, tweenInfo2, { Scale = uiPage.LauncherBase })
                                if enabled then
                                    state.set(
                                        "launcherPos",
                                        {
                                            math.floor(launcher.Position.X.Offset),
                                            math.floor(launcher.Position.Y.Offset),
                                        }
                                    )
                                else
                                    sound.play("click")
                                    uiPage:Toggle()
                                end
                            end
                        end
                    end, uiPage.Conns)
                    launcher.MouseEnter:Connect(function()
                        if rim then
                            tweenInstance(rim, "Quick", { ImageTransparency = 0.2 })
                        end
                        if shadow then
                            tweenInstance(shadow, "Quick", { ImageTransparency = 0.35 })
                        end
                        if not enabled2 then
                            tweenInstance(scale, "Quick", { Scale = uiPage.LauncherBase * 1.03 })
                        end
                        localization2.paint(value, "TextColor3", "Text", "Quick")
                        if not uiPage.IsOpen then
                            localization2.paint(chev, "ImageColor3", "Text", "Quick")
                        end
                    end)
                    u.leave(launcher, function()
                        if rim then
                            tweenInstance(rim, "Quick", { ImageTransparency = 0.45 })
                        end
                        if shadow then
                            tweenInstance(shadow, "Quick", { ImageTransparency = 0.5 })
                        end
                        if not enabled2 then
                            tweenInstance(scale, tweenInfo2, { Scale = uiPage.LauncherBase })
                        end
                        if not uiPage.IsOpen then
                            localization2.paint(chev, "ImageColor3", "Muted", "Quick")
                        end
                    end)
                    uiPage.Launcher = launcher
                    uiPage:OnScreenScale(function(scale2)
                        if not launcher.Parent then
                            return false
                        end
                        uiPage.LauncherBase = scale2
                        if not enabled2 then
                            scale.Scale = scale2
                        end
                        task.defer(function()
                            pcall(uiPage._clampLauncher, uiPage)
                        end)
                    end)
                    uiPage:_launcherState(false, true)
                    u.connect(uiPage.Gui:GetPropertyChangedSignal("AbsoluteSize"), function()
                        task.defer(function()
                            pcall(uiPage._clampLauncher, uiPage)
                        end)
                    end, uiPage.Conns)
                    task.spawn(function()
                        task.wait(1)
                        while launcher.Parent and not uiPage.Destroyed do
                            pcall(uiPage._clampLauncher, uiPage)
                            if uiPage.IsTouch then
                                if not uiPage.IsOpen then
                                    if not launcher.Visible then
                                        launcher.Visible = true
                                    end
                                end
                            end
                            task.wait(2)
                        end
                    end)
                end
                index._launcherArea = function(camera)
                    local calculatedValue = camera.Gui and camera.Gui.AbsoluteSize
                    if
                        (if calculatedValue then calculatedValue.X < 120 else not calculatedValue)
                        or calculatedValue.Y < 120
                    then
                        camera = workspace.CurrentCamera
                        calculatedValue = camera and camera.ViewportSize or Vector2.new(1280, 720)
                    else
                    end
                    return calculatedValue
                end
                index._clampLauncher = function(argument)
                    local launcher = argument.Launcher
                    if launcher then
                        if not launcher.Parent then
                            return
                        end
                    else
                        return
                    end
                    local launcherAreaResult = argument:_launcherArea()
                    if launcherAreaResult.X < 120 then
                        return
                    elseif launcherAreaResult.Y < 120 then
                        return
                    end
                    local x, y = launcher.AbsoluteSize.X, launcher.AbsoluteSize.Y
                    if x < 1 then
                        local counter, counter2 = 150, 42
                        x, y = counter, counter2
                    else
                        if y < 1 then
                            local counter, counter2 = 150, 42
                            x, y = counter, counter2
                        else
                        end
                    end
                    local position = launcher.Position
                    local roundedValue =
                        math.floor(math.clamp(position.X.Offset, 4, math.max(4, launcherAreaResult.X - x - 4)))
                    local roundedValue2 =
                        math.floor(math.clamp(position.Y.Offset, 4, math.max(4, launcherAreaResult.Y - y - 4)))
                    if
                        roundedValue ~= position.X.Offset
                        or roundedValue2 ~= position.Y.Offset
                        or position.X.Scale ~= 0
                        or position.Y.Scale ~= 0
                    then
                        launcher.Position = UDim2.fromOffset(roundedValue, roundedValue2)
                        pcall(function()
                            argument.State.set("launcherPos", { roundedValue, roundedValue2 })
                        end)
                    end
                end
                index._launcherState = function(glow, argument, entries)
                    local launcherParts = glow.LauncherParts
                    if not launcherParts then
                        return
                    end
                    local calculatedValue, chev, orb =
                        entries and TweenInfo.new(0) or TweenInfo.new(
                            0.35,
                            Enum.EasingStyle.Quint,
                            Enum.EasingDirection.Out
                        ),
                        launcherParts.chev,
                        {}
                    orb.Rotation = argument and 180 or 0
                    tweenInstance(chev, calculatedValue, orb)
                    localization2.paint(
                        launcherParts.chev,
                        "ImageColor3",
                        argument and "Accent" or "Muted",
                        calculatedValue
                    )
                    localization2.paint(
                        launcherParts.orb,
                        "BackgroundColor3",
                        argument and "Accent" or "Elevated",
                        calculatedValue
                    )
                    orb, chev = launcherParts.orb, {}
                    chev.BackgroundTransparency = argument and 0.8 or 0.35
                    tweenInstance(orb, calculatedValue, chev)
                    localization2.paint(
                        launcherParts.orbStroke,
                        "Color",
                        argument and "Accent" or "Glass",
                        calculatedValue
                    )
                    orb, entries = launcherParts.orbStroke, {}
                    entries.Transparency = argument and 0.45 or 0.85
                    tweenInstance(orb, calculatedValue, entries)
                    if launcherParts.glow then
                        glow, chev = launcherParts.glow, {}
                        chev.ImageTransparency = argument and 0.62 or 0.85
                        tweenInstance(glow, calculatedValue, chev)
                    end
                end
                index._input = function(uiPage)
                    u.connect(userInputService.InputBegan, function(argument)
                        if uiPage.Destroyed then
                            return
                        elseif uiPage.Listening then
                            return
                        end
                        if argument.KeyCode == uiPage.Key then
                            if uiPage.Key ~= Enum.KeyCode.Unknown then
                                if userInputService:GetFocusedTextBox() then
                                    return
                                end
                                uiPage:Toggle()
                            end
                        end
                    end, uiPage.Conns)
                    u.connect(localization2.Services.RunService.RenderStepped, function()
                        if not uiPage.Tip.Visible then
                            return
                        end
                        local getMouseLocationResult, viewportSize, absoluteSize =
                            userInputService:GetMouseLocation(),
                            workspace.CurrentCamera.ViewportSize,
                            uiPage.Tip.AbsoluteSize
                        local minimumValue, minimumValue2 =
                            math.min(getMouseLocationResult.X + 14, viewportSize.X - absoluteSize.X - 6),
                            math.min(getMouseLocationResult.Y + 18, viewportSize.Y - absoluteSize.Y - 6)
                        uiPage.Tip.Position = UDim2.fromOffset(minimumValue, minimumValue2)
                    end, uiPage.Conns)
                end
                index.ShowTip = function(argument, argument2)
                    if not argument2 or argument2 == "" then
                        return
                    elseif argument.TooltipsOn then
                        if argument.IsTouch then
                            return
                        end
                    else
                        return
                    end
                    argument.TipToken = (argument.TipToken or 0) + 1
                    local tipToken = argument.TipToken
                    task.delay(0.35, function()
                        if argument.TipToken ~= tipToken then
                            return
                        elseif argument.Destroyed then
                            return
                        end
                        argument.TipLabel.Text = localization2.tr(argument2)
                        argument.Tip.Visible = true
                        argument.Tip.BackgroundTransparency = 1
                        argument.TipLabel.TextTransparency = 1
                        tweenInstance(argument.Tip, "Quick", { BackgroundTransparency = 0 })
                        tweenInstance(argument.TipLabel, "Quick", { TextTransparency = 0 })
                    end)
                end
                index.HideTip = function(argument)
                    argument.TipToken = (argument.TipToken or 0) + 1
                    argument.Tip.Visible = false
                end
                index._acrylicStep = function(argument)
                    local acrylicPart, acrylicMesh, parent =
                        argument.AcrylicPart, argument.AcrylicMesh, workspace.CurrentCamera
                    if acrylicPart then
                        if acrylicMesh then
                            if not parent then
                                return
                            end
                        else
                            return
                        end
                    else
                        return
                    end
                    if acrylicPart.Parent ~= parent then
                        acrylicPart.Parent = parent
                    end
                    local root = argument.Root
                    local absolutePosition, absoluteSize = root.AbsolutePosition, root.AbsoluteSize
                    if root.Visible then
                        if absoluteSize.X < 8 then
                            acrylicMesh.Scale = Vector3.zero
                            return
                        elseif absoluteSize.Y < 8 then
                            acrylicMesh.Scale = Vector3.zero
                            return
                        end
                    else
                        acrylicMesh.Scale = Vector3.zero
                        return
                    end
                    local calculatedValue, zero =
                        math.floor(14 * (u.radiusMult or 1) * math.max(argument.Scale.Scale, 0.1) * 0.3 + 0.5) + 2,
                        Vector2.zero
                    if argument.Gui then
                        if not argument.Gui.IgnoreGuiInset then
                            pcall(function()
                                zero = game:GetService("GuiService"):GetGuiInset()
                            end)
                        end
                    end
                    local viewportSize = parent.ViewportSize
                    local transform = parent.CFrame
                    local tanResult = math.tan(math.rad(parent.FieldOfView) * 0.5)
                    local calculatedValue2 = tanResult * viewportSize.X / math.max(viewportSize.Y, 1)
                    local function callback(calculatedValue3, argument2)
                        local calculatedValue4, calculatedValue5 =
                            (calculatedValue3 + zero.X) / math.max(viewportSize.X, 1) * 2 - 1,
                            1 - (argument2 + zero.Y) / math.max(viewportSize.Y, 1) * 2
                        calculatedValue3 = Vector3.new(
                            calculatedValue4 * calculatedValue2,
                            calculatedValue5 * tanResult,
                            -1
                        ) * 0.001
                        return transform:PointToWorldSpace(calculatedValue3)
                    end
                    root, argument, parent =
                        callback(absolutePosition.X + calculatedValue, absolutePosition.Y + calculatedValue),
                        callback(
                            absolutePosition.X + absoluteSize.X - calculatedValue,
                            absolutePosition.Y + calculatedValue
                        ),
                        callback(
                            absolutePosition.X + absoluteSize.X - calculatedValue,
                            absolutePosition.Y + absoluteSize.Y - calculatedValue
                        )
                    acrylicPart.CFrame = CFrame.fromMatrix(
                        (root + parent) / 2,
                        transform.XVector.Unit,
                        transform.YVector.Unit,
                        transform.ZVector.Unit
                    )
                    acrylicMesh.Scale = Vector3.new((argument - root).Magnitude, (argument - parent).Magnitude, 0)
                end
                index._blur = function(argument, argument2)
                    local runService2 = localization2.Services.RunService
                    argument.AcrylicToken = (argument.AcrylicToken or 0) + 1
                    local acrylicToken = argument.AcrylicToken
                    if argument2 then
                        if argument.BlurEnabled then
                            if not argument.Destroyed then
                                local parent = workspace.CurrentCamera
                                if not parent then
                                    return
                                end
                                if not (argument.AcrylicDof and argument.AcrylicDof.Parent) then
                                    argument.AcrylicDof = createInstance(
                                        "DepthOfFieldEffect",
                                        {
                                            Name = "GGHDepth",
                                            FarIntensity = 0,
                                            FocusDistance = 51.6,
                                            InFocusRadius = 50,
                                            NearIntensity = 0,
                                            Parent = localization2.Services.Lighting,
                                        }
                                    )
                                end
                                if not (argument.AcrylicPart and argument.AcrylicPart.Parent) then
                                    local novaGlass = Instance.new("Part")
                                    novaGlass.Name = "GGHGlass"
                                    novaGlass.Material = Enum.Material.Glass
                                    novaGlass.Transparency = 0.98
                                    novaGlass.Color = Color3.new(0, 0, 0)
                                    novaGlass.Anchored = true
                                    novaGlass.CanCollide = false
                                    novaGlass.CanQuery = false
                                    novaGlass.CanTouch = false
                                    novaGlass.CastShadow = false
                                    novaGlass.Size = Vector3.new(1, 1, 0)
                                    local specialMesh = Instance.new("SpecialMesh")
                                    specialMesh.MeshType = Enum.MeshType.Brick
                                    specialMesh.Scale = Vector3.zero
                                    specialMesh.Parent = novaGlass
                                    novaGlass.Parent = parent
                                    argument.AcrylicPart = novaGlass
                                    argument.AcrylicMesh = specialMesh
                                end
                                if not argument.AcrylicBound then
                                    argument.AcrylicBound = "GGHAcrylic_"
                                        .. tostring(argument.Gui and argument.Gui.Name or "GGH")
                                    pcall(function()
                                        runService2:UnbindFromRenderStep(argument.AcrylicBound)
                                    end)
                                    local acrylicBound, renderPriority = argument.AcrylicBound, Enum.RenderPriority
                                    local value, handleAction =
                                        renderPriority.Camera.Value, function()
                                            argument:_acrylicStep()
                                        end
                                    runService2:BindToRenderStep(acrylicBound, value + 1, handleAction)
                                end
                                tweenInstance(argument.AcrylicDof, "Slow", { NearIntensity = 1 })
                                return
                            end
                        end
                    end
                    if argument.AcrylicDof then
                        tweenInstance(argument.AcrylicDof, "Quick", { NearIntensity = 0 })
                    end
                    local function isActive2()
                        if argument.AcrylicToken ~= acrylicToken then
                            return
                        end
                        if argument.AcrylicBound then
                            local acrylicBound = argument.AcrylicBound
                            argument.AcrylicBound = nil
                            pcall(function()
                                runService2:UnbindFromRenderStep(acrylicBound)
                            end)
                        end
                        if argument.AcrylicPart then
                            pcall(function()
                                argument.AcrylicPart:Destroy()
                            end)
                            argument.AcrylicPart = nil
                            argument.AcrylicMesh = nil
                        end
                        if argument.AcrylicDof then
                            pcall(function()
                                argument.AcrylicDof:Destroy()
                            end)
                            argument.AcrylicDof = nil
                        end
                    end
                    if argument.Destroyed then
                        isActive2()
                    else
                        task.delay(0.22, isActive2)
                    end
                end
                index.SetBlur = function(argument, argument2)
                    localization2.trace("SetBlur")
                    argument.BlurEnabled = argument2 and true or false
                    argument.State.set("blur", argument.BlurEnabled)
                    if argument.IsOpen then
                        argument:_blur(argument.BlurEnabled)
                    end
                end
                local tweenInfo = TweenInfo.new(0.44, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                local tweenInfo2 = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
                local tweenInfo3 = TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tweenInfo4 = TweenInfo.new(0.26, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                index._launcherPoint = function(argument)
                    local launcher = argument.Launcher
                    if launcher then
                        if launcher.Visible then
                            if launcher.Parent then
                                if not motion.enabled then
                                    return nil
                                end
                            else
                                return nil
                            end
                        else
                            return nil
                        end
                    else
                        return nil
                    end
                    local calculatedValue = launcher.AbsolutePosition
                        + launcher.AbsoluteSize / 2
                        - argument.Gui.AbsolutePosition
                    return UDim2.fromOffset(math.floor(calculatedValue.X), math.floor(calculatedValue.Y))
                end
                index._scalingDefer = function(argument, argument2)
                    argument.ScaleDeferred = argument.ScaleDeferred or {}
                    argument.ScaleDeferred[argument2] = true
                end
                index._endScaling = function(argument)
                    argument.Scaling = false
                    local scaleDeferred = argument.ScaleDeferred
                    argument.ScaleDeferred = nil
                    if scaleDeferred then
                        for key in pairs(scaleDeferred) do
                            pcall(key)
                        end
                    end
                end
                index._stopGenie = function(argument)
                    local entries = { "GeniePos", "GenieScale" }
                    for unused, item in ipairs(entries) do
                        if argument[item] then
                            pcall(function()
                                argument[item]:Cancel()
                            end)
                            argument[item] = nil
                        end
                    end
                end
                index.Open = function(argument)
                    localization2.trace("Open")
                    if argument.Destroyed then
                        return
                    elseif argument.IsOpen then
                        return
                    end
                    argument.IsOpen = true
                    argument.OpenToken = (argument.OpenToken or 0) + 1
                    local openToken = argument.OpenToken
                    argument:_stopGenie()
                    local position = argument:_placeOnScreen(argument.HomePos or argument.Root.Position)
                    argument.HomePos = nil
                    argument.Root.Position = position
                    local position2 = argument.GenieAnim and argument:_launcherPoint() or nil
                    if argument.IsTouch then
                        if argument.Launcher then
                            argument.Launcher.Visible = false
                        end
                    end
                    local scale = argument.AutoScale * argument.UserScale
                    argument.Win.GroupTransparency = 1
                    if position2 then
                        argument.Scaling = true
                        argument.Root.Position = position2
                        argument.Scale.Scale = scale * 0.12
                        argument:_syncLayers()
                        argument.Root.Visible = true
                        argument.FloatLayer.Visible = true
                        argument.GeniePos = tweenInstance(argument.Root, tweenInfo, { Position = position })
                        argument.GenieScale = tweenInstance(argument.Scale, tweenInfo, { Scale = scale })
                        tweenInstance(argument.Win, tweenInfo3, { GroupTransparency = 0 })
                        task.delay(tweenInfo.Time + 0.03, function()
                            if argument.OpenToken == openToken then
                                argument:_endScaling()
                            end
                        end)
                    else
                        argument:_endScaling()
                        argument.Scale.Scale = scale
                        argument:_syncLayers()
                        argument.Root.Visible = true
                        argument.FloatLayer.Visible = true
                        tweenInstance(argument.Win, tweenInfo3, { GroupTransparency = 0 })
                    end
                    if argument.WindowShadow then
                        argument.WindowShadow.ImageTransparency = 1
                        tweenInstance(argument.WindowShadow, "Slow", { ImageTransparency = 0.45 })
                    end
                    argument:_blur(true)
                    argument:_launcherState(true)
                    sound.play("open")
                    if not argument.Current then
                        if argument.TabList[1] then
                            argument:SelectTab(argument.TabList[1])
                        end
                    end
                    task.defer(function()
                        argument:_layoutTabs(false)
                    end)
                end
                index.Close = function(argument)
                    localization2.trace("Close")
                    if argument.Destroyed then
                        return
                    elseif not argument.IsOpen then
                        return
                    end
                    argument.IsOpen = false
                    argument.OpenToken = (argument.OpenToken or 0) + 1
                    local openToken = argument.OpenToken
                    argument:ClosePopups()
                    argument:HideTip()
                    argument:_stopGenie()
                    if argument.Launcher then
                        argument.Launcher.Visible = argument.LauncherOn
                    end
                    local scale = argument.AutoScale * argument.UserScale
                    local position, calculatedValue = argument.GenieAnim and argument:_launcherPoint() or nil, 0.2
                    if position then
                        argument.Scaling = true
                        argument.HomePos = argument.Root.Position
                        argument.GeniePos = tweenInstance(argument.Root, tweenInfo2, { Position = position })
                        argument.GenieScale = tweenInstance(argument.Scale, tweenInfo2, { Scale = scale * 0.12 })
                        tweenInstance(argument.Win, tweenInfo4, { GroupTransparency = 1 })
                        calculatedValue = tweenInfo2.Time + 0.03
                        local launcherParts = argument.LauncherParts
                        if launcherParts then
                            task.delay(0.24, function()
                                if argument.OpenToken ~= openToken then
                                    return
                                end
                                local scale2, new, enum = launcherParts.scale, TweenInfo.new, Enum
                                local quad, easingDirection = enum.EasingStyle.Quad, Enum.EasingDirection
                                local value, entries = new(0.12, quad, easingDirection.Out), {}
                                entries.Scale = argument.LauncherBase * 1.08
                                tweenInstance(scale2, value, entries)
                                task.delay(0.12, function()
                                    tweenInstance(
                                        launcherParts.scale,
                                        TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                                        { Scale = argument.LauncherBase }
                                    )
                                end)
                            end)
                        end
                    else
                        tweenInstance(argument.Win, "Exit", { GroupTransparency = 1 })
                    end
                    if argument.WindowShadow then
                        tweenInstance(argument.WindowShadow, "Exit", { ImageTransparency = 1 })
                    end
                    argument:_blur(false)
                    argument:_launcherState(false)
                    sound.play("close")
                    task.delay(calculatedValue, function()
                        if argument.IsOpen then
                            return
                        elseif argument.OpenToken ~= openToken then
                            return
                        end
                        argument:_stopGenie()
                        argument.Root.Visible = false
                        if argument.HomePos then
                            argument.Root.Position = argument.HomePos
                            argument.HomePos = nil
                        end
                        argument.Scale.Scale = scale
                        task.defer(function()
                            if not argument.IsOpen then
                                if argument.OpenToken == openToken then
                                    argument:_endScaling()
                                end
                            end
                        end)
                    end)
                end
                index.RegistryCount = function(unused)
                    return u.regCount()
                end
                index.Toggle = function(argument)
                    if argument.IsOpen then
                        argument:Close()
                    else
                        argument:Open()
                    end
                end
                index.Destroy = function(argument)
                    if argument.Destroyed then
                        return
                    end
                    argument.Destroyed = true
                    argument:_blur(false)
                    for unused, item in ipairs(argument.Conns) do
                        pcall(function()
                            item:Disconnect()
                        end)
                    end
                    pcall(function()
                        argument.Gui:Destroy()
                    end)
                    pcall(function()
                        argument.Parking:Destroy()
                    end)
                    if argument.OnDestroy then
                        pcall(argument.OnDestroy)
                    end
                end
                index.ClosePopups = function(argument)
                    for unused, item in ipairs(argument.Popups) do
                        pcall(item.close)
                    end
                    argument.Popups = {}
                    argument.Catcher.Visible = false
                end
                index.OpenPopup = function(argument, argument2)
                    localization2.trace("OpenPopup")
                    argument:ClosePopups()
                    table.insert(argument.Popups, argument2)
                    argument.Catcher.Visible = true
                end
                index.PointerOverUI = function(argument)
                    if argument.Destroyed then
                        return false
                    end
                    local mouseResult = u.mouse()
                    local function callback(argument2)
                        if argument2 then
                            if not argument2.Visible then
                                return false
                            end
                        else
                            return false
                        end
                        local absolutePosition, absoluteSize = argument2.AbsolutePosition, argument2.AbsoluteSize
                        return mouseResult.X >= absolutePosition.X
                            and mouseResult.X <= absolutePosition.X + absoluteSize.X
                            and mouseResult.Y >= absolutePosition.Y
                            and mouseResult.Y <= absolutePosition.Y + absoluteSize.Y
                    end
                    if argument.IsOpen then
                        if callback(argument.Root) then
                            return true
                        end
                    end
                    local callback2, entries = ipairs, { argument.FloatLayer, argument.PopLayer }
                    for unused, item in callback2(entries) do
                        for unused, instance in ipairs(item:GetChildren()) do
                            if instance:IsA("GuiObject") then
                                if callback(instance) then
                                    return true
                                end
                            end
                        end
                    end
                    if callback(argument.KeybindFrame) then
                        return true
                    elseif callback(argument.WatermarkFrame) then
                        return true
                    elseif callback(argument.FlingFrame) then
                        return true
                    end
                    return (callback(argument.Launcher))
                end
                localization2.WindowClass.PopIn =
                    TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                localization2.WindowClass.PopOut =
                    TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                index.PopupShell = function(parent, entries, image)
                    local parent2 = createInstance(
                        "Frame",
                        {
                            Name = "PopupFrame",
                            BackgroundTransparency = 1,
                            Size = UDim2.fromOffset(entries, image),
                            ZIndex = 2,
                            Parent = parent.PopLayer,
                        }
                    )
                    tex.image(
                        parent2,
                        "shadow9",
                        {
                            Name = "Shadow",
                            Position = UDim2.fromOffset(-30, -22),
                            Size = UDim2.new(1, 60, 1, 64),
                            SliceScale = 1,
                            ImageTransparency = 0.4,
                            ZIndex = 1,
                        }
                    )
                    parent = createInstance(
                        "CanvasGroup",
                        {
                            Name = "Popup",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromScale(1, 1),
                            BorderSizePixel = 0,
                            GroupTransparency = 1,
                            ZIndex = 2,
                            Parent = parent2,
                        }
                    )
                    bindTheme(parent, "BackgroundColor3", "Elevated")
                    u.corner(parent, 12)
                    image, entries = tex.image, {}
                    entries.Size, entries.SliceScale, entries.ImageTransparency, entries.ZIndex =
                        UDim2.fromScale(1, 1), 0.86, 0.88, 2
                    image(parent, "gloss9", entries)
                    image = tex.image(
                        parent,
                        "rim9",
                        { Size = UDim2.fromScale(1, 1), SliceScale = 0.86, ImageTransparency = 0.45, ZIndex = 300 }
                    )
                    if image then
                        bindTheme(image, "ImageColor3", "Glass")
                    else
                        bindTheme(u.stroke(parent, Color3.new(1, 1, 1), 1, 0.85), "Color", "Glass")
                    end
                    return parent2, parent, (createInstance("UIScale", { Scale = 0.92, Parent = parent }))
                end
                index.PopupPlace = function(enabled, argument, argument2, argument3, argument4)
                    local maximumValue, absolutePosition =
                        math.max(enabled.PopScale.Scale, 0.1), enabled.PopLayer.AbsolutePosition
                    local calculatedValue, calculatedValue2, calculatedValue3 =
                        (argument.AbsolutePosition - absolutePosition) / maximumValue,
                        argument.AbsoluteSize / maximumValue,
                        enabled.PopLayer.AbsoluteSize / maximumValue
                    maximumValue = argument4 == "left" and calculatedValue.X
                        or calculatedValue.X + calculatedValue2.X - argument2
                    maximumValue = math.clamp(maximumValue, 8, math.max(8, calculatedValue3.X - argument2 - 8))
                    absolutePosition, enabled = calculatedValue.Y + calculatedValue2.Y + 6, false
                    if absolutePosition + argument3 > calculatedValue3.Y - 8 then
                        absolutePosition, enabled = math.max(8, calculatedValue.Y - argument3 - 6), true
                    else
                    end
                    return maximumValue, absolutePosition, argument4 == "left" and 0 or 1, enabled and 1 or 0
                end
                local tweenInfo5 = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                local tweenInfo6 = TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                local tweenInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                index.PopupReveal = function(calculatedValue, instance, argument, argument2, shadow)
                    calculatedValue = shadow and 1 or 0
                    if argument2 then
                        argument2.Scale = 1
                    end
                    argument.AnchorPoint = Vector2.new(0, calculatedValue)
                    argument.Position = UDim2.fromScale(0, calculatedValue)
                    argument.Size = UDim2.new(1, 0, 0, 0)
                    argument.GroupTransparency = 1
                    tweenInstance(argument, tweenInfo5, { Size = UDim2.fromScale(1, 1) })
                    tweenInstance(argument, tweenInfo6, { GroupTransparency = 0 })
                    shadow = instance:FindFirstChild("Shadow")
                    if shadow then
                        shadow.ImageTransparency = 1
                        tweenInstance(shadow, tweenInfo5, { ImageTransparency = 0.4 })
                    end
                end
                index.PopupConceal = function(unused, instance, shadow)
                    tweenInstance(shadow, tweenInfo, { Size = UDim2.new(1, 0, 0, 0), GroupTransparency = 1 })
                    shadow = instance:FindFirstChild("Shadow")
                    if shadow then
                        tweenInstance(shadow, tweenInfo, { ImageTransparency = 1 })
                    end
                end
                index.PopupOrigin = function(unused, argument, argument2, argument3)
                    argument.AnchorPoint = Vector2.new(argument2 or 0.5, argument3 or 0.5)
                    argument.Position = UDim2.fromScale(argument2 or 0.5, argument3 or 0.5)
                end
                index.ConfirmPopup = function(argument, argument2, calculatedValue, argument3)
                    calculatedValue = type(calculatedValue) == "table" and calculatedValue or {}
                    local text, calculatedValue2, value = tostring(calculatedValue.Text or ""), 0
                    if text ~= "" then
                        local roundedValue = math.ceil(13 * (tonumber(u.textScale) or 1))
                        local success, result = pcall(function()
                            local textService, gothamMedium, packedValues =
                                localization2.Services.TextService,
                                Enum.Font.GothamMedium,
                                packValues(Vector2.new(235.7142857142857, 1000))
                            return textService:GetTextSize(
                                text,
                                roundedValue,
                                gothamMedium,
                                unpackTuple(packedValues)
                            )
                        end)
                        calculatedValue2 = (success and result and result.Y or 40) + 6
                        value = calculatedValue2
                    else
                        value = calculatedValue2
                    end
                    local calculatedValue3 = 50 + (value > 0 and value + 8 or 0)
                    local calculatedValue4 = calculatedValue3 + 34 + 14
                    local popupShellResult, parent, parent2 = argument:PopupShell(296, calculatedValue4)
                    local popupPlaceResult, popupPlaceResult2, unused, popupPlaceResult3 =
                        argument:PopupPlace(argument2, 296, calculatedValue4, "right")
                    popupShellResult.Position = UDim2.fromOffset(popupPlaceResult, popupPlaceResult2)
                    argument:PopupReveal(popupShellResult, parent, parent2, popupPlaceResult3 == 1)
                    local calculatedValue2 = calculatedValue.Danger == true
                    local function handleAction()
                        return Color3.new(1, 1, 1)
                    end
                    parent2 = createInstance(
                        "Frame",
                        {
                            Name = "Badge",
                            Position = UDim2.fromOffset(14, 14),
                            Size = UDim2.fromOffset(28, 28),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 0.8,
                            ZIndex = 61,
                            Parent = parent,
                        }
                    )
                    bindTheme(parent2, "BackgroundColor3", calculatedValue2 and "Danger" or "Accent")
                    u.corner(parent2, 9)
                    localization2.icon({
                        Parent = parent2,
                        Icon = calculatedValue.Icon or (calculatedValue2 and "triangle-alert" or "info"),
                        Size = 15,
                        Pos = UDim2.fromScale(0.5, 0.5),
                        Anchor = Vector2.new(0.5, 0.5),
                        Color = calculatedValue2 and "Danger" or "Accent",
                        Z = 62,
                    })
                    localization2.label({
                        Parent = parent,
                        Text = tostring(calculatedValue.Title or "Are you sure?"),
                        Font = font.Semi(),
                        Size = 15,
                        Pos = UDim2.fromOffset(50, 15),
                        Box = UDim2.new(1, -64, 0, 26),
                        Truncate = true,
                        Color = "Text",
                        Z = 61,
                    })
                    local labelResult, value2
                    if value > 0 then
                        labelResult = localization2.label({
                            Parent = parent,
                            Text = text,
                            Font = font.Medium(),
                            Size = 13,
                            Pos = UDim2.fromOffset(16, 50),
                            Box = UDim2.new(1, -32, 0, value),
                            Wrap = true,
                            AlignY = Enum.TextYAlignment.Top,
                            Color = "Muted",
                            Z = 61,
                        })
                        value2 = labelResult
                    else
                        value2 = labelResult
                    end
                    local enabled = false
                    local function isActive2()
                        if enabled then
                            return
                        end
                        enabled = true
                        argument:ClosePopups()
                    end
                    local function callback(text, argument2, argument4, argument5)
                        local parent2 = createInstance(
                            "TextButton",
                            {
                                Name = argument5 and "Accept" or "Cancel",
                                Text = "",
                                AutoButtonColor = false,
                                Position = UDim2.fromOffset(argument2, calculatedValue3),
                                Size = UDim2.fromOffset(argument4, 34),
                                BorderSizePixel = 0,
                                ZIndex = 61,
                                Parent = parent,
                            }
                        )
                        bindTheme(
                            parent2,
                            "BackgroundColor3",
                            argument5 and (calculatedValue2 and "Danger" or "Accent") or "Surface2"
                        )
                        u.corner(parent2, 9)
                        bindTheme(
                            u.stroke(parent2, Color3.new(1, 1, 1), 1, argument5 and 0.78 or 0.88),
                            "Color",
                            "Glass"
                        )
                        local label, properties, calculatedValue5 =
                            localization2.label,
                            {
                                Parent = parent2,
                                Text = text,
                                Font = font.Semi(),
                                Size = 14,
                                Box = UDim2.fromScale(1, 1),
                                AlignX = Enum.TextXAlignment.Center,
                            },
                            argument5 and (calculatedValue2 and handleAction or "OnAccent")
                        properties.Color, properties.Z = calculatedValue5 or "Text", 62
                        label(properties)
                        local value3 = createInstance("UIScale", { Parent = parent2 })
                        local function handleAction2()
                            tweenInstance(parent2, "Quick", { BackgroundTransparency = 0.14 })
                            sound.play("hover", 0.6)
                        end
                        parent2.MouseEnter:Connect(handleAction2)
                        u.leave(parent2, function()
                            tweenInstance(parent2, "Quick", { BackgroundTransparency = 0 })
                            tweenInstance(value3, "Quick", { Scale = 1 })
                        end)
                        local function handleAction3()
                            tweenInstance(value3, "Quick", { Scale = 0.97 })
                        end
                        parent2.MouseButton1Down:Connect(handleAction3)
                        local function handleAction4()
                            tweenInstance(value3, "Quick", { Scale = 1 })
                        end
                        parent2.MouseButton1Up:Connect(handleAction4)
                        return parent2
                    end
                    local value3 = callback(tostring(calculatedValue.Cancel or "Cancel"), 16, 128, false)
                    local value4 = callback(tostring(calculatedValue.Accept or "OK"), 152, 128, true)
                    if value2 then
                        task.delay(0.05, function()
                            if enabled then
                                return
                            elseif not value2.Parent then
                                return
                            end
                            local calculatedValue2 = math.ceil(value2.TextBounds.Y) + 6
                            if calculatedValue2 > value then
                                local calculatedValue5 = calculatedValue2 - value
                                value = calculatedValue2
                                value2.Size = UDim2.new(1, -32, 0, calculatedValue2)
                                popupShellResult.Size = UDim2.fromOffset(296, calculatedValue4 + calculatedValue5)
                                value3.Position =
                                    UDim2.fromOffset(value3.Position.X.Offset, calculatedValue3 + calculatedValue5)
                                value4.Position =
                                    UDim2.fromOffset(value4.Position.X.Offset, calculatedValue3 + calculatedValue5)
                                if popupPlaceResult3 == 1 then
                                    popupShellResult.Position =
                                        UDim2.fromOffset(popupPlaceResult, popupPlaceResult2 - calculatedValue5)
                                end
                            end
                        end)
                    end
                    local function handleAction2()
                        sound.play("click")
                        isActive2()
                    end
                    value3.MouseButton1Click:Connect(handleAction2)
                    local function handleAction3()
                        sound.play("click")
                        isActive2()
                        if type(argument3) == "function" then
                            task.defer(argument3, value4)
                        end
                    end
                    value4.MouseButton1Click:Connect(handleAction3)
                    argument:OpenPopup({
                        close = function()
                            enabled = true
                            argument:PopupConceal(popupShellResult, parent)
                            task.delay(0.18, function()
                                popupShellResult:Destroy()
                            end)
                        end,
                    })
                end
            end
            do
                local u = localization2.U
                local motion = localization2.Motion
                local theme = localization2.Theme
                local font = localization2.Font
                local unused, sound = localization2.Icons, localization2.Sound
                local tex = localization2.Tex
                local createInstance = u.new
                local tweenInstance = motion.tween
                local bindTheme = theme.bind
                local label = localization2.label
                local icon = localization2.icon
                local windowClass = localization2.WindowClass
                local userInputService = localization2.Services.UserInputService
                local color, sidebarEXPANDED, sidebarCOLLAPSED, counter, counter2, rowH, counter3, counter4, capH, counter5, counter6, size =
                    Color3.new(1, 1, 1), 228, 64, 188, 340, 40, 36, 2, 30, 12, 32, 17
                local tweenInfo = TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                windowClass.SIDEBAR_EXPANDED = sidebarEXPANDED
                windowClass.SIDEBAR_COLLAPSED = sidebarCOLLAPSED
                local function paint(argument, argument2, argument3, argument4)
                    local entries = theme.registry[argument]
                    if entries then
                    else
                        entries = {}
                        theme.registry[argument] = entries
                    end
                    entries[argument2] = argument3
                    local calculatedValue, entries = argument4 or "Base", {}
                    entries[argument2] = theme.resolve(argument3)
                    tweenInstance(argument, calculatedValue, entries)
                end
                localization2.paint = paint
                local function callback(argument, argument2)
                    return NumberSequenceKeypoint.new(argument, argument2)
                end
                local function callback2(argument)
                    if argument then
                        return { logoX = (sidebarCOLLAPSED - 36) / 2, logoY = 10, searchY = 52, tabTop = 92, foot = 44 }
                    end
                    return { logoX = 16, logoY = 14, searchY = 68, tabTop = 112, foot = 50 }
                end
                local function callback3(argument)
                    for unused, item in ipairs(argument.Groups) do
                        if item.Row then
                            return item
                        end
                    end
                end
                local function callback4(argument, argument2)
                    if argument.SidebarCollapsed then
                        return 1
                    end
                    return argument2 and 0.05 or 0.4
                end
                windowClass.Densities = { "Comfortable", "Compact" }
                windowClass.applyDensity = function(argument)
                    if argument.Density == "Compact" then
                        argument.RowH = 31
                        argument.CapH = 22
                        argument.TileS = 22
                        argument.LabelX = 36
                    else
                        argument.Density = "Comfortable"
                        argument.RowH = rowH
                        argument.CapH = capH
                        argument.TileS = 30
                        argument.LabelX = 46
                    end
                end
                windowClass._buildSidebar = function(argument, argument2)
                    local parent, sidebarWidth = argument.Win, argument.State
                    local getResult = sidebarWidth.get("sidebarCollapsed", nil)
                    if getResult == nil then
                        local camera = workspace.CurrentCamera
                        getResult = camera ~= nil and camera.ViewportSize.X < 760
                    else
                    end
                    local sidebarCollapsed = getResult == true
                    local value = callback2(sidebarCollapsed)
                    argument.SidebarCollapsed = sidebarCollapsed
                    argument.Density = sidebarWidth.get("density", argument2.Density or "Comfortable")
                    windowClass.applyDensity(argument)
                    argument.GroupLabels = sidebarWidth.get("groupLabels", true) ~= false
                    argument.DefaultSidebarWidth =
                        math.clamp(tonumber(argument2.SidebarWidth) or sidebarEXPANDED, counter, counter2)
                    argument.ExpandedWidth = math.clamp(
                        tonumber(sidebarWidth.get("sidebarWidth", argument.DefaultSidebarWidth))
                            or argument.DefaultSidebarWidth,
                        counter,
                        counter2
                    )
                    sidebarWidth = sidebarCollapsed and sidebarCOLLAPSED or argument.ExpandedWidth
                    argument.SidebarWidth = sidebarWidth
                    local sidebar = createInstance(
                        "Frame",
                        {
                            Name = "Sidebar",
                            Size = UDim2.new(0, sidebarWidth, 1, 0),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 0.3 + (1 - argument.Opacity) * 0.7,
                            ClipsDescendants = true,
                            ZIndex = 2,
                            Parent = parent,
                        }
                    )
                    bindTheme(sidebar, "BackgroundColor3", "Sidebar")
                    argument.Sidebar = sidebar
                    local brandFrame = createInstance(
                        "Frame",
                        {
                            Name = "Edge",
                            AnchorPoint = Vector2.new(1, 0),
                            Position = UDim2.fromScale(1, 0),
                            Size = UDim2.new(0, 1, 1, 0),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 0.84,
                            ZIndex = 3,
                            Parent = sidebar,
                        }
                    )
                    bindTheme(brandFrame, "BackgroundColor3", "Glass")
                    createInstance(
                        "UIGradient",
                        {
                            Transparency = NumberSequence.new({
                                callback(0, 1),
                                callback(0.1, 0),
                                callback(0.9, 0),
                                callback(1, 1),
                            }),
                            Rotation = 90,
                            Parent = brandFrame,
                        }
                    )
                    brandFrame = createInstance(
                        "Frame",
                        { Name = "Brand", Size = UDim2.new(1, 0, 0, 64), BackgroundTransparency = 1, ZIndex = 3, Parent = sidebar }
                    )
                    argument.BrandFrame = brandFrame
                    local logoButton = createInstance(
                        "TextButton",
                        {
                            Name = "Logo",
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            Position = UDim2.fromOffset(value.logoX, value.logoY),
                            Size = UDim2.fromOffset(36, 36),
                            ZIndex = 4,
                            Parent = brandFrame,
                        }
                    )
                    argument.LogoButton = logoButton
                    local foldButton = tex.image(
                        logoButton,
                        "glow",
                        {
                            Name = "Glow",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(96, 96),
                            ImageTransparency = 0.6,
                            ZIndex = 4,
                        }
                    )
                    if foldButton then
                        if argument2.Logo then
                            foldButton.Visible = false
                        else
                            bindTheme(foldButton, "ImageColor3", "Accent")
                        end
                    end
                    if argument2.Logo then
                        createInstance(
                            "ImageLabel",
                            {
                                Name = "Mark",
                                BackgroundTransparency = 1,
                                Size = UDim2.fromOffset(42, 42),
                                Position = UDim2.fromOffset(-3, -3),
                                Image = argument2.Logo,
                                ScaleType = Enum.ScaleType.Fit,
                                ZIndex = 6,
                                Parent = logoButton,
                            }
                        )
                    else
                        local tile, instanceOptions = localization2.tile, { Name = "Face" }
                        instanceOptions.Size, instanceOptions.Color, instanceOptions.Z =
                            UDim2.fromScale(1, 1), "Accent", 5
                        tile(logoButton, instanceOptions)
                        label({
                            Parent = logoButton,
                            Text = tostring(argument2.Initial or string.sub(argument2.Title or "N", 1, 1)),
                            Font = font.Heavy(),
                            Size = 19,
                            Box = UDim2.fromScale(1, 1),
                            AlignX = Enum.TextXAlignment.Center,
                            Color = "OnAccent",
                            Z = 6,
                        })
                    end
                    foldButton = argument2.Logo and 66 or 60
                    argument.TitleLabel = label({
                        Parent = brandFrame,
                        Text = argument2.Title or "GGH",
                        Font = font.Bold(),
                        Size = 17,
                        Pos = UDim2.fromOffset(foldButton, 16),
                        Box = UDim2.new(1, -(foldButton + 44), 0, 19),
                        Truncate = true,
                        Z = 4,
                    })
                    argument.SubtitleLabel = label({
                        Parent = brandFrame,
                        Text = argument2.Subtitle or "",
                        Font = font.Medium(),
                        Size = 11,
                        Pos = UDim2.fromOffset(foldButton, 36),
                        Box = UDim2.new(1, -(foldButton + 44), 0, 14),
                        Color = "Muted",
                        Truncate = true,
                        Z = 4,
                    })
                    if sidebarCollapsed then
                        argument.TitleLabel.TextTransparency, argument.SubtitleLabel.TextTransparency = 1, 1
                    end
                    local searchTile, footer =
                        {
                            Name = "SidebarEdge",
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            AnchorPoint = Vector2.new(0.5, 0),
                            Position = UDim2.new(0, sidebarWidth, 0, 0),
                            Size = UDim2.new(0, 10, 1, 0),
                        },
                        not sidebarCollapsed
                    searchTile.Visible = footer
                    searchTile.ZIndex = 42
                    searchTile.Parent = parent
                    parent = createInstance("TextButton", searchTile)
                    local parent2 = createInstance(
                        "Frame",
                        {
                            Name = "Line",
                            AnchorPoint = Vector2.new(0.5, 0),
                            Position = UDim2.fromScale(0.5, 0),
                            Size = UDim2.new(0, 2, 1, 0),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 1,
                            ZIndex = 43,
                            Parent = parent,
                        }
                    )
                    bindTheme(parent2, "BackgroundColor3", "Accent")
                    createInstance(
                        "UIGradient",
                        {
                            Transparency = NumberSequence.new({
                                callback(0, 1),
                                callback(0.18, 0),
                                callback(0.82, 0),
                                callback(1, 1),
                            }),
                            Rotation = 90,
                            Parent = parent2,
                        }
                    )
                    argument.SidebarEdge = parent
                    local enabled, counter7, counter8, now, value2 = false, 0, 0, 0
                    parent.MouseEnter:Connect(function()
                        if not enabled then
                            tweenInstance(parent2, "Quick", { BackgroundTransparency = 0.45 })
                        end
                        argument:ShowTip("Drag to resize")
                    end)
                    u.leave(parent, function()
                        if not enabled then
                            tweenInstance(parent2, "Quick", { BackgroundTransparency = 1 })
                        end
                        argument:HideTip()
                    end)
                    parent.InputBegan:Connect(function(argument3)
                        if u.isClick(argument3) then
                            if argument.SidebarCollapsed then
                                return
                            end
                        else
                            return
                        end
                        argument:HideTip()
                        if os.clock() - now < 0.35 then
                            now = 0
                            argument:SetSidebarWidth(argument.DefaultSidebarWidth)
                            return
                        end
                        now = os.clock()
                        local x, sidebarWidth = argument3.Position.X, argument.SidebarWidth
                        enabled, counter7, counter8, value2 = true, x, sidebarWidth, argument3
                        tweenInstance(parent2, "Quick", { BackgroundTransparency = 0.05 })
                    end)
                    u.connect(userInputService.InputChanged, function(argument3)
                        if enabled then
                            if u.sameMove(argument3, value2) then
                                local maximumValue, value3 = math.max(argument.Scale.Scale, 0.1), counter8
                                argument:SetSidebarWidth(
                                    value3 + (argument3.Position.X - counter7) / maximumValue,
                                    true
                                )
                            end
                        end
                    end, argument.Conns)
                    u.connect(userInputService.InputEnded, function(argument3)
                        if enabled then
                            if u.sameEnd(argument3, value2) then
                                enabled = false
                                tweenInstance(parent2, "Base", { BackgroundTransparency = 1 })
                                argument.State.set("sidebarWidth", math.floor(argument.ExpandedWidth + 0.5))
                            end
                        end
                    end, argument.Conns)
                    foldButton = createInstance(
                        "TextButton",
                        {
                            Name = "Fold",
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            AnchorPoint = Vector2.new(1, 0),
                            Position = UDim2.new(1, -12, 0, 19),
                            Size = UDim2.fromOffset(28, 28),
                            ZIndex = 5,
                            Parent = brandFrame,
                        }
                    )
                    local tileResult, tile = localization2.tile(
                        foldButton,
                        { Name = "Face", Size = UDim2.fromScale(1, 1), Color = "Elevated", Alpha = 0.35, Z = 5 }
                    )
                    local value3 = icon({
                        Parent = foldButton,
                        Icon = "panel-left-close",
                        Size = 15,
                        Pos = UDim2.fromScale(0.5, 0.5),
                        Anchor = Vector2.new(0.5, 0.5),
                        Color = "Muted",
                        Z = 6,
                    })
                    local calculatedValue = tile and "ImageColor3" or "BackgroundColor3"
                    local function tabCanvas()
                        tweenInstance(tileResult, "Quick", { [calculatedValue] = theme.resolve("Elevated") })
                        tweenInstance(value3, "Quick", { ImageColor3 = theme.resolve("Text") })
                        argument:ShowTip("Collapse sidebar")
                    end
                    foldButton.MouseEnter:Connect(tabCanvas)
                    u.leave(foldButton, function()
                        tweenInstance(value3, "Quick", { ImageColor3 = theme.resolve("Muted") })
                        argument:HideTip()
                    end)
                    local function handleAction()
                        sound.play("click")
                        argument:HideTip()
                        argument:SetSidebarCollapsed(true)
                    end
                    foldButton.MouseButton1Click:Connect(handleAction)
                    argument.FoldButton = foldButton
                    local function instanceOptions()
                        if argument.SidebarCollapsed then
                            sound.play("click")
                            argument:SetSidebarCollapsed(false)
                        end
                    end
                    logoButton.MouseButton1Click:Connect(instanceOptions)
                    local function handleAction()
                        if argument.SidebarCollapsed then
                            argument:ShowTip("Expand sidebar")
                        end
                    end
                    logoButton.MouseEnter:Connect(handleAction)
                    u.leave(logoButton, function()
                        argument:HideTip()
                    end)
                    brandFrame = createInstance(
                        "Frame",
                        {
                            Name = "SearchHolder",
                            Position = UDim2.fromOffset(0, value.searchY),
                            Size = UDim2.new(1, 0, 0, 40),
                            BackgroundTransparency = 1,
                            ZIndex = 3,
                            Parent = sidebar,
                        }
                    )
                    local searchField = createInstance(
                        "Frame",
                        {
                            Name = "Search",
                            Position = UDim2.fromOffset(12, 3),
                            Size = UDim2.new(1, -24, 0, 34),
                            BorderSizePixel = 0,
                            ZIndex = 3,
                            Parent = brandFrame,
                        }
                    )
                    bindTheme(searchField, "BackgroundColor3", "Elevated")
                    u.corner(searchField, 10)
                    createInstance(
                        "UIGradient",
                        { Color = ColorSequence.new(color, Color3.fromRGB(190, 193, 202)), Rotation = 90, Parent = searchField }
                    )
                    local strokeResult = u.stroke(searchField, color, 1, 0.86)
                    bindTheme(strokeResult, "Color", "Glass")
                    icon({
                        Parent = searchField,
                        Icon = "search",
                        Size = 15,
                        Pos = UDim2.new(0, 11, 0.5, 0),
                        Anchor = Vector2.new(0, 0.5),
                        Color = "Faint",
                        Z = 4,
                    })
                    local searchBox = createInstance(
                        "TextBox",
                        {
                            Name = "Box",
                            BackgroundTransparency = 1,
                            Position = UDim2.fromOffset(34, 0),
                            Size = UDim2.new(1, -44, 1, 0),
                            FontFace = font.Medium(),
                            TextSize = 13,
                            PlaceholderText = argument2.SearchText or "Search",
                            Text = "",
                            ClearTextOnFocus = false,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            ZIndex = 4,
                            Parent = searchField,
                        }
                    )
                    bindTheme(searchBox, "TextColor3", "Text")
                    bindTheme(searchBox, "PlaceholderColor3", "Faint")
                    argument.SearchBox = searchBox
                    argument.SearchField = searchField
                    searchField.Visible = footer
                    foldButton.Visible = footer
                    local function handleAction()
                        paint(strokeResult, "Color", "Accent", "Quick")
                        tweenInstance(strokeResult, "Quick", { Transparency = 0.35 })
                    end
                    searchBox.Focused:Connect(handleAction)
                    local function handleAction2()
                        paint(strokeResult, "Color", "Glass", "Quick")
                        tweenInstance(strokeResult, "Quick", { Transparency = 0.86 })
                    end
                    searchBox.FocusLost:Connect(handleAction2)
                    local function handleAction()
                        argument:Search(searchBox.Text)
                    end
                    searchBox:GetPropertyChangedSignal("Text"):Connect(handleAction)
                    local function handleAction2()
                        if string.find(searchBox.Text, "%S") then
                            if not argument.SearchPop then
                                argument:Search(searchBox.Text)
                            end
                        end
                    end
                    searchBox.Focused:Connect(handleAction2)
                    local function handleAction(argument3, argument4)
                        local searchPop = argument.SearchPop
                        if argument3 then
                            if searchPop then
                                if searchPop.Items then
                                    if searchPop.Items[searchPop.Sel or 1] then
                                        argument:_searchJump(searchPop.Items[searchPop.Sel or 1])
                                    end
                                end
                            end
                        elseif argument4 then
                            if argument4.KeyCode == Enum.KeyCode.Escape then
                                searchBox.Text = ""
                            end
                        end
                    end
                    searchBox.FocusLost:Connect(handleAction)
                    u.connect(userInputService.InputBegan, function(argument3)
                        local searchPop = argument.SearchPop
                        if not searchPop then
                            return
                        end
                        local keyCode = argument3.KeyCode
                        if keyCode == Enum.KeyCode.Down or keyCode == Enum.KeyCode.Up then
                            if searchBox:IsFocused() then
                                argument:_searchSelect(
                                    (searchPop.Sel or 1) + (keyCode == Enum.KeyCode.Down and 1 or -1)
                                )
                                return
                            end
                        end
                        keyCode = argument3.UserInputType
                        if keyCode == Enum.UserInputType.MouseButton1 or keyCode == Enum.UserInputType.Touch then
                            local mouseResult = u.mouse()
                            local function callback5(argument3)
                                if argument3 then
                                    if not argument3.Parent then
                                        return false
                                    end
                                else
                                    return false
                                end
                                local absolutePosition, absoluteSize =
                                    argument3.AbsolutePosition, argument3.AbsoluteSize
                                return mouseResult.X >= absolutePosition.X
                                    and mouseResult.X <= absolutePosition.X + absoluteSize.X
                                    and mouseResult.Y >= absolutePosition.Y
                                    and mouseResult.Y <= absolutePosition.Y + absoluteSize.Y
                            end
                            if not (callback5(searchPop.Frame)) then
                                if not (callback5(searchField)) then
                                    argument:_searchClose()
                                end
                            end
                        end
                    end, argument.Conns)
                    searchTile = createInstance(
                        "TextButton",
                        {
                            Name = "SearchTile",
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            AnchorPoint = Vector2.new(0.5, 0),
                            Position = UDim2.new(0.5, 0, 0, 3),
                            Size = UDim2.fromOffset(counter6 + 8, 34),
                            Visible = sidebarCollapsed,
                            ZIndex = 3,
                            Parent = brandFrame,
                        }
                    )
                    local value3 = createInstance(
                        "Frame",
                        {
                            Name = "Face",
                            Size = UDim2.fromScale(1, 1),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 1,
                            ZIndex = 3,
                            Parent = searchTile,
                        }
                    )
                    bindTheme(value3, "BackgroundColor3", "Elevated")
                    u.corner(value3, 10)
                    local value4 = icon({
                        Parent = searchTile,
                        Icon = "search",
                        Size = size,
                        Pos = UDim2.fromScale(0.5, 0.5),
                        Anchor = Vector2.new(0.5, 0.5),
                        Color = "Muted",
                        Z = 4,
                    })
                    local function handleAction2()
                        sound.play("click")
                        argument:SetSidebarCollapsed(false)
                        task.delay(0.2, function()
                            searchBox:CaptureFocus()
                        end)
                    end
                    searchTile.MouseButton1Click:Connect(handleAction2)
                    local function handleAction()
                        tweenInstance(value3, "Quick", { BackgroundTransparency = 0.55 })
                        paint(value4, "ImageColor3", "Text", "Quick")
                        argument:ShowTip("Search")
                    end
                    searchTile.MouseEnter:Connect(handleAction)
                    u.leave(searchTile, function()
                        tweenInstance(value3, "Quick", { BackgroundTransparency = 1 })
                        paint(value4, "ImageColor3", "Muted", "Quick")
                        argument:HideTip()
                    end)
                    argument.SearchTile = searchTile
                    local tabClip = createInstance(
                        "CanvasGroup",
                        {
                            Name = "TabsClip",
                            Position = UDim2.fromOffset(0, value.tabTop),
                            Size = UDim2.new(1, 0, 1, -(value.tabTop + value.foot + 2)),
                            BackgroundTransparency = 1,
                            ZIndex = 3,
                            Parent = sidebar,
                        }
                    )
                    argument.TabClip = tabClip
                    local tabScroll = createInstance(
                        "ScrollingFrame",
                        {
                            Name = "Tabs",
                            Size = UDim2.fromScale(1, 1),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            ScrollBarThickness = 0,
                            ScrollBarImageTransparency = 1,
                            CanvasSize = UDim2.new(),
                            AutomaticCanvasSize = Enum.AutomaticSize.Y,
                            ScrollingDirection = Enum.ScrollingDirection.Y,
                            ZIndex = 3,
                            Parent = tabClip,
                        }
                    )
                    bindTheme(tabScroll, "ScrollBarImageColor3", "Faint")
                    local value3 = createInstance("UIGradient", { Rotation = 90, Parent = tabClip })
                    local function handleAction()
                        if argument.Scaling then
                            argument:_scalingDefer(handleAction)
                            return
                        end
                        local y = tabClip.AbsoluteSize.Y
                        if y < 60 then
                            return
                        end
                        local clampedValue, clampedValue2, minimumValue =
                            math.clamp(tabScroll.CanvasPosition.Y / 10, 0, 1),
                            math.clamp(
                                (
                                    tabScroll.AbsoluteCanvasSize.Y
                                    - tabScroll.CanvasPosition.Y
                                    - tabScroll.AbsoluteWindowSize.Y
                                ) / 10,
                                0,
                                1
                            ),
                            math.min(18 / y, 0.25)
                        value3.Transparency = NumberSequence.new({
                            callback(0, clampedValue * 0.92),
                            callback(minimumValue, 0),
                            callback(1 - minimumValue, 0),
                            callback(1, clampedValue2 * 0.92),
                        })
                    end
                    tabScroll:GetPropertyChangedSignal("CanvasPosition"):Connect(handleAction)
                    tabScroll:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(handleAction)
                    tabScroll:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(handleAction)
                    task.defer(handleAction)
                    tabCanvas = createInstance(
                        "Frame",
                        { Name = "Canvas", Size = UDim2.new(1, 0, 0, 10), BackgroundTransparency = 1, Parent = tabScroll }
                    )
                    argument.TabScroll = tabScroll
                    argument.TabCanvas = tabCanvas
                    argument.TabListFrame = tabCanvas
                    footer = createInstance(
                        "Frame",
                        {
                            Name = "Footer",
                            AnchorPoint = Vector2.new(0, 1),
                            Position = UDim2.fromScale(0, 1),
                            Size = UDim2.new(1, 0, 0, value.foot),
                            BackgroundTransparency = 1,
                            ZIndex = 3,
                            Parent = sidebar,
                        }
                    )
                    sidebarCollapsed = createInstance(
                        "Frame",
                        {
                            Name = "Line",
                            Position = UDim2.fromOffset(14, 0),
                            Size = UDim2.new(1, -28, 0, 1),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 0.88,
                            ZIndex = 3,
                            Parent = footer,
                        }
                    )
                    bindTheme(sidebarCollapsed, "BackgroundColor3", "Glass")
                    createInstance(
                        "UIGradient",
                        {
                            Transparency = NumberSequence.new({
                                callback(0, 1),
                                callback(0.2, 0),
                                callback(0.8, 0),
                                callback(1, 1),
                            }),
                            Parent = sidebarCollapsed,
                        }
                    )
                    argument.FooterText = label({
                        Parent = footer,
                        Text = tostring(argument2.Footer or ""),
                        Font = font.Medium(),
                        Size = 11,
                        Pos = UDim2.fromOffset(18, 1),
                        Box = UDim2.new(1, -96, 1, -1),
                        Color = "Faint",
                        Truncate = true,
                        Z = 4,
                        Name = "Version",
                    })
                    local footerChip = createInstance(
                        "TextButton",
                        {
                            Name = "KeyChip",
                            Text = "",
                            AutoButtonColor = false,
                            AnchorPoint = Vector2.new(1, 0.5),
                            Position = UDim2.new(1, -14, 0.5, 1),
                            Size = UDim2.fromOffset(34, 22),
                            BackgroundTransparency = 1,
                            ZIndex = 4,
                            Parent = footer,
                        }
                    )
                    tile, instanceOptions = localization2.tile, { Name = "Face" }
                    instanceOptions.Size, instanceOptions.Color, instanceOptions.Alpha, instanceOptions.SliceScale, instanceOptions.Z =
                        UDim2.fromScale(1, 1), "Elevated", 0.2, 0.45, 4
                    tile(footerChip, instanceOptions)
                    local imageResult = tex.image(
                        footerChip,
                        "rim9",
                        { Name = "Rim", Size = UDim2.fromScale(1, 1), SliceScale = 0.45, ImageTransparency = 0.6, ZIndex = 6 }
                    )
                    if imageResult then
                        bindTheme(imageResult, "ImageColor3", "Glass")
                    end
                    argument.FooterKey = label({
                        Parent = footerChip,
                        Text = "",
                        Font = font.Semi(),
                        Size = 11,
                        Box = UDim2.fromScale(1, 1),
                        AlignX = Enum.TextXAlignment.Center,
                        Color = "Muted",
                        Z = 7,
                        Name = "Key",
                    })
                    logoButton, sidebar =
                        argument.FooterKey, function()
                            footerChip.Size = UDim2.fromOffset(math.max(30, math.ceil(argument.FooterKey.TextBounds.X) + 18), 22)
                        end
                    logoButton:GetPropertyChangedSignal("TextBounds"):Connect(sidebar)
                    argument.FooterChip = footerChip
                    argument.Footer = footer
                    footerChip.Visible = not argument.IsTouch
                    local enabled, createResult = false
                    local now2 = 0
                    local function isActive2()
                        enabled = false
                        now2 = os.clock()
                        if createResult then
                            createResult:Cancel()
                            createResult = nil
                        end
                        if imageResult then
                            paint(imageResult, "ImageColor3", "Glass", "Quick")
                            tweenInstance(imageResult, "Quick", { ImageTransparency = 0.6 })
                        end
                        paint(argument.FooterKey, "TextColor3", "Muted", "Quick")
                        argument:_syncFooter()
                        task.defer(function()
                            if not enabled then
                                argument.Listening = false
                            end
                        end)
                    end
                    footerChip.MouseEnter:Connect(function()
                        if enabled then
                            return
                        end
                        paint(argument.FooterKey, "TextColor3", "Text", "Quick")
                        if imageResult then
                            tweenInstance(imageResult, "Quick", { ImageTransparency = 0.35 })
                        end
                    end)
                    u.leave(footerChip, function()
                        if enabled then
                            return
                        end
                        paint(argument.FooterKey, "TextColor3", "Muted", "Quick")
                        if imageResult then
                            tweenInstance(imageResult, "Quick", { ImageTransparency = 0.6 })
                        end
                    end)
                    footerChip.MouseButton1Click:Connect(function()
                        if enabled then
                            return
                        elseif os.clock() - now2 < 0.3 then
                            return
                        end
                        sound.play("click")
                        enabled = true
                        argument.FooterKey.Text = "…"
                        paint(argument.FooterKey, "TextColor3", "Accent", "Quick")
                        if imageResult then
                            paint(imageResult, "ImageColor3", "Accent", "Quick")
                            imageResult.ImageTransparency = 0.5
                            createResult = localization2.Services.TweenService:Create(
                                imageResult,
                                TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                                { ImageTransparency = 0.05 }
                            )
                            createResult:Play()
                        end
                        task.defer(function()
                            if enabled then
                                argument.Listening = true
                            end
                        end)
                    end)
                    u.connect(userInputService.InputBegan, function(argument2)
                        if enabled then
                            if not argument.Listening then
                                return
                            end
                        else
                            return
                        end
                        if argument2.UserInputType == Enum.UserInputType.Keyboard then
                            local keyCode = argument2.KeyCode
                            if keyCode == Enum.KeyCode.Escape then
                                isActive2()
                                return
                            elseif keyCode == Enum.KeyCode.Unknown then
                                isActive2()
                                return
                            end
                            argument:SetKey(keyCode)
                            sound.play("tick")
                            isActive2()
                        elseif u.isClick(argument2) then
                            isActive2()
                        elseif argument2.UserInputType == Enum.UserInputType.MouseButton2 then
                            isActive2()
                        end
                    end, argument.Conns)
                    u.connect(userInputService.InputChanged, function(argument2)
                        if not (u.sameMove(argument2, argument.PressInput)) then
                            return
                        end
                        argument:_reorderMove()
                    end, argument.Conns)
                    u.connect(userInputService.InputEnded, function(argument2)
                        if u.sameEnd(argument2, argument.PressInput) then
                            argument:_reorderEnd()
                        end
                    end, argument.Conns)
                end
                windowClass._ensureGroup = function(argument)
                    if argument.CurGroup then
                        return argument.CurGroup
                    end
                    local curGroup = { Key = "_", Tabs = {}, Collapsed = false }
                    table.insert(argument.Groups, curGroup)
                    argument.CurGroup = curGroup
                    return curGroup
                end
                windowClass.TabGroup = function(argument, key)
                    key = tostring(key or "")
                    local row, curGroup = argument.State.get("groups", {}), { Key = key, Tabs = {} }
                    curGroup.Collapsed = type(row) == "table" and row[key] == true
                    row = createInstance(
                        "Frame",
                        {
                            Name = "Group_" .. key,
                            Size = UDim2.new(1, -16, 0, argument.CapH),
                            Position = UDim2.fromOffset(8, 0),
                            BackgroundTransparency = 1,
                            Parent = argument.TabCanvas,
                        }
                    )
                    local value = createInstance(
                        "TextButton",
                        {
                            Name = "Hit",
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            Size = UDim2.fromScale(1, 1),
                            ZIndex = 4,
                            Parent = row,
                        }
                    )
                    curGroup.Row = row
                    curGroup.Label = label({
                        Parent = row,
                        Text = key,
                        Font = font.Bold(),
                        Size = 11,
                        Pos = UDim2.fromOffset(10, 2),
                        Box = UDim2.new(1, -36, 1, -2),
                        Color = "Faint",
                        Z = 2,
                        Name = "Caption",
                    })
                    curGroup.Chev = icon({
                        Parent = row,
                        Icon = "chevron-down",
                        Size = 13,
                        Pos = UDim2.new(1, -10, 0.5, 1),
                        Anchor = Vector2.new(1, 0.5),
                        Color = "Faint",
                        Z = 2,
                    })
                    curGroup.Line = createInstance(
                        "Frame",
                        {
                            Name = "Divider",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(22, 2),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 1,
                            Parent = row,
                        }
                    )
                    bindTheme(curGroup.Line, "BackgroundColor3", "Glass")
                    u.corner(curGroup.Line, UDim.new(1, 0))
                    if curGroup.Collapsed then
                        curGroup.Chev.Rotation = -90
                    end
                    local function handleAction()
                        paint(curGroup.Label, "TextColor3", "Muted", "Quick")
                        paint(curGroup.Chev, "ImageColor3", "Muted", "Quick")
                    end
                    value.MouseEnter:Connect(handleAction)
                    u.leave(value, function()
                        paint(curGroup.Label, "TextColor3", "Faint", "Quick")
                        paint(curGroup.Chev, "ImageColor3", "Faint", "Quick")
                    end)
                    local function handleAction2()
                        if argument.SidebarCollapsed then
                            return
                        end
                        sound.play("tick")
                        argument:SetGroupCollapsed(curGroup, not curGroup.Collapsed)
                    end
                    value.MouseButton1Click:Connect(handleAction2)
                    table.insert(argument.Groups, curGroup)
                    argument.CurGroup = curGroup
                    if argument.SidebarCollapsed then
                        curGroup.Label.TextTransparency, curGroup.Chev.ImageTransparency, curGroup.Line.BackgroundTransparency =
                            1, 1, callback3(argument) == curGroup and 1 or 0.88
                    end
                    argument:_layoutTabs(false)
                    return curGroup.Label
                end
                windowClass.SetGroupCollapsed = function(argument, argument2, groups)
                    if type(argument2) == "string" then
                        for unused, item in ipairs(argument.Groups) do
                            if item.Key == argument2 then
                                argument2 = item
                                break
                            end
                        end
                    else
                    end
                    if type(argument2) ~= "table" then
                        return
                    end
                    argument2.Collapsed = groups and true or false
                    groups = argument.State.get("groups", {})
                    groups = if type(groups) ~= "table" then {} else groups
                    groups[argument2.Key] = argument2.Collapsed or nil
                    argument.State.data.groups = groups
                    argument.State.save()
                    if argument2.Chev then
                        local chev, entries = argument2.Chev, {}
                        entries.Rotation = argument2.Collapsed and -90 or 0
                        tweenInstance(chev, "Base", entries)
                    end
                    argument:_layoutTabs(true)
                end
                local function callback5(argument, argument2)
                    if type(argument) ~= "table" then
                        return math.huge
                    end
                    for key, item in ipairs(argument) do
                        if item == argument2 then
                            return key
                        end
                    end
                    return math.huge
                end
                windowClass._addTabRow = function(argument, pressTab, calculatedValue)
                    local group = argument:_ensureGroup()
                    pressTab.Group = group
                    local sidebarCollapsed = argument.SidebarCollapsed
                    local hit = sidebarCollapsed and counter3 or argument.RowH
                    local row = createInstance(
                        "CanvasGroup",
                        {
                            Name = pressTab.Name,
                            Size = UDim2.new(1, -16, 0, hit),
                            Position = UDim2.fromOffset(8, 0),
                            BackgroundTransparency = 1,
                            Parent = argument.TabCanvas,
                        }
                    )
                    pressTab.Row = row
                    u.corner(row, 12)
                    local bg = createInstance(
                        "Frame",
                        {
                            Name = "Bg",
                            Position = UDim2.fromOffset(1, 1),
                            Size = UDim2.new(1, -2, 1, -2),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            ZIndex = 1,
                            Parent = row,
                        }
                    )
                    bindTheme(bg, "BackgroundColor3", "Elevated")
                    u.corner(bg, 11)
                    hit = u.stroke(bg, color, 1, 1)
                    bindTheme(hit, "Color", "Accent")
                    pressTab.Bg = bg
                    pressTab.BgStroke = hit
                    local getResult, glow =
                        { Transparency = NumberSequence.new({ callback(0, 0), callback(0.5, 0.12), callback(
                            1,
                            0.92
                        ) }) },
                        not sidebarCollapsed
                    getResult.Enabled = glow
                    getResult.Parent = bg
                    pressTab.BgGrad = createInstance("UIGradient", getResult)
                    pressTab.StrokeGrad = createInstance(
                        "UIGradient",
                        {
                            Transparency = NumberSequence.new({
                                callback(0, 0),
                                callback(0.4, 0.35),
                                callback(0.85, 1),
                                callback(1, 1),
                            }),
                            Enabled = glow,
                            Parent = hit,
                        }
                    )
                    hit, getResult =
                        sidebarCollapsed and counter6 or argument.TileS,
                        sidebarCollapsed and (sidebarCOLLAPSED - 16 - counter6) / 2 or 6
                    glow = tex.image(
                        row,
                        "glow",
                        {
                            Name = "Glow",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.new(0, getResult + hit / 2, 0.5, 0),
                            Size = UDim2.new(0, 72, 1, 0),
                            ImageTransparency = 1,
                            ZIndex = 1,
                        }
                    )
                    if glow then
                        bindTheme(glow, "ImageColor3", "Accent")
                    end
                    pressTab.Glow = glow
                    local tile, text = localization2.tile(
                        row,
                        {
                            Name = "Tile",
                            Size = UDim2.fromOffset(hit, hit),
                            Pos = UDim2.new(0, getResult, 0.5, 0),
                            Anchor = Vector2.new(0, 0.5),
                            Color = "Elevated",
                            Alpha = sidebarCollapsed and 1 or 0.4,
                            Z = 2,
                        }
                    )
                    pressTab.Tile, pressTab.TileProp, pressTab.TileAlphaProp =
                        tile,
                        text and "ImageColor3" or "BackgroundColor3",
                        text and "ImageTransparency" or "BackgroundTransparency"
                    pressTab.IconImg = icon({
                        Parent = tile,
                        Icon = calculatedValue.Icon,
                        Size = sidebarCollapsed and size or 16,
                        Pos = UDim2.fromScale(0.5, 0.5),
                        Anchor = Vector2.new(0.5, 0.5),
                        Color = "Muted",
                        Z = 3,
                    })
                    pressTab.Label = label({
                        Parent = row,
                        Text = pressTab.Name,
                        Font = font.Semi(),
                        Size = 14,
                        Pos = UDim2.fromOffset(argument.LabelX, 0),
                        Box = UDim2.new(1, -(argument.LabelX + 10), 1, 0),
                        Color = "Muted",
                        Truncate = true,
                        Z = 2,
                    })
                    if sidebarCollapsed then
                        pressTab.Label.TextTransparency = 1
                    end
                    if calculatedValue.Badge then
                        text = tostring(calculatedValue.Badge)
                        glow = math.max(20, #text * 6.4 + 12)
                        local badge = createInstance(
                            "Frame",
                            {
                                Name = "Badge",
                                AnchorPoint = Vector2.new(1, 0.5),
                                Position = UDim2.new(1, -9, 0.5, 0),
                                Size = UDim2.fromOffset(glow, 18),
                                BorderSizePixel = 0,
                                ZIndex = 3,
                                Parent = row,
                            }
                        )
                        bindTheme(badge, "BackgroundColor3", "Accent")
                        u.corner(badge, UDim.new(1, 0))
                        pressTab.BadgeLabel = label({
                            Parent = badge,
                            Text = text,
                            Font = font.Bold(),
                            Size = 10,
                            Box = UDim2.fromScale(1, 1),
                            AlignX = Enum.TextXAlignment.Center,
                            Color = "OnAccent",
                            Z = 4,
                        })
                        pressTab.Badge = badge
                        pressTab.BadgeWidth = glow
                        pressTab.BadgeRing = u.stroke(badge, color, 2, sidebarCollapsed and 0 or 1)
                        bindTheme(pressTab.BadgeRing, "Color", "Sidebar")
                        if sidebarCollapsed then
                            badge.Size = UDim2.fromOffset(10, 10)
                            badge.Position = UDim2.new(0, getResult + hit - 2, 0.5, -hit / 2 + 4)
                            pressTab.BadgeLabel.TextTransparency = 1
                        end
                    end
                    hit = createInstance(
                        "TextButton",
                        {
                            Name = "Hit",
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            Size = UDim2.fromScale(1, 1),
                            ZIndex = 8,
                            Parent = row,
                        }
                    )
                    pressTab.Hit = hit
                    local function handleAction()
                        pressTab.Hover = true
                        if argument.DraggingTab then
                            return
                        end
                        if argument.Current ~= pressTab then
                            tweenInstance(bg, "Quick", { BackgroundTransparency = 0.6 })
                            paint(pressTab.Label, "TextColor3", "Text", "Quick")
                            tweenInstance(tile, "Quick", { [pressTab.TileAlphaProp] = callback4(argument, true) })
                            paint(pressTab.IconImg, "ImageColor3", "Text", "Quick")
                        end
                        sound.play("hover", 0.4)
                        if argument.SidebarCollapsed then
                            argument:ShowTip(pressTab.Name)
                        end
                    end
                    hit.MouseEnter:Connect(handleAction)
                    u.leave(hit, function()
                        pressTab.Hover = false
                        argument:HideTip()
                        if argument.DraggingTab == pressTab then
                            return
                        end
                        if argument.Current ~= pressTab then
                            tweenInstance(bg, "Quick", { BackgroundTransparency = 1 })
                            paint(pressTab.Label, "TextColor3", "Muted", "Quick")
                            tweenInstance(tile, "Quick", { [pressTab.TileAlphaProp] = callback4(argument, false) })
                            paint(pressTab.IconImg, "ImageColor3", "Muted", "Quick")
                        end
                    end)
                    local function handleAction2(pressInput)
                        if pressInput.UserInputType ~= Enum.UserInputType.MouseButton1 then
                            if pressInput.UserInputType ~= Enum.UserInputType.Touch then
                                return
                            end
                        end
                        argument.PressTab = pressTab
                        argument.PressTime = os.clock()
                        argument.PressInput = pressInput
                        argument.PressAt = u.at(pressInput)
                    end
                    hit.InputBegan:Connect(handleAction2)
                    local function handleAction3()
                        if argument.DraggingTab then
                            return
                        elseif os.clock() - (argument.LastDragEnd or 0) < 0.3 then
                            return
                        end
                        if argument.Current ~= pressTab then
                            sound.play("click", 0.8)
                        end
                        argument:SelectTab(pressTab)
                    end
                    hit.MouseButton1Click:Connect(handleAction3)
                    getResult = argument.State.get("tabOrder", {})
                    calculatedValue = type(getResult) == "table" and getResult[group.Key] or nil
                    handleAction, row = callback5(calculatedValue, pressTab.Name), #group.Tabs + 1
                    if handleAction ~= math.huge then
                        for key, item in ipairs(group.Tabs) do
                            if callback5(calculatedValue, item.Name) > handleAction then
                                row = key
                                break
                            end
                        end
                    else
                    end
                    table.insert(group.Tabs, row, pressTab)
                    argument:_layoutTabs(false)
                end
                windowClass._styleTab = function(argument, argument2, argument3, bgStroke)
                    if not argument2.Row then
                        return
                    end
                    local calculatedValue, tileProp, tileAlphaProp =
                        bgStroke and "Base" or TweenInfo.new(0), argument2.TileProp, argument2.TileAlphaProp
                    if argument3 then
                        paint(argument2.Tile, tileProp, "Accent", calculatedValue)
                        tweenInstance(argument2.Tile, calculatedValue, { [tileAlphaProp] = 0 })
                        paint(argument2.IconImg, "ImageColor3", "OnAccent", calculatedValue)
                        paint(argument2.Label, "TextColor3", "Text", calculatedValue)
                        local sidebarCollapsed, bg, entries = argument.SidebarCollapsed, argument2.Bg, {}
                        entries.BackgroundTransparency = sidebarCollapsed and 1 or 0.42
                        tweenInstance(bg, calculatedValue, entries)
                        paint(argument2.BgStroke, "Color", "Accent", calculatedValue)
                        bgStroke, entries = argument2.BgStroke, {}
                        entries.Transparency = sidebarCollapsed and 1 or 0.72
                        tweenInstance(bgStroke, calculatedValue, entries)
                        if argument2.Glow then
                            tweenInstance(argument2.Glow, calculatedValue, { ImageTransparency = 0.5 })
                        end
                    else
                        paint(argument2.Tile, tileProp, "Elevated", calculatedValue)
                        local tile, bg = argument2.Tile, {}
                        bg[tileAlphaProp] = callback4(argument, argument2.Hover)
                        tweenInstance(tile, calculatedValue, bg)
                        paint(
                            argument2.IconImg,
                            "ImageColor3",
                            argument2.Hover and "Text" or "Muted",
                            calculatedValue
                        )
                        paint(argument2.Label, "TextColor3", argument2.Hover and "Text" or "Muted", calculatedValue)
                        bg, tile = argument2.Bg, {}
                        tile.BackgroundTransparency = argument2.Hover and 0.6 or 1
                        tweenInstance(bg, calculatedValue, tile)
                        tweenInstance(argument2.BgStroke, calculatedValue, { Transparency = 1 })
                        if argument2.Glow then
                            tweenInstance(argument2.Glow, calculatedValue, { ImageTransparency = 1 })
                        end
                    end
                end
                local function callback6(argument, targetY, argument2, argument3, argument4)
                    local row = argument.Row
                    argument.TargetY = targetY
                    argument.RowToken = (argument.RowToken or 0) + 1
                    local rowToken = argument.RowToken
                    local position, size2 = UDim2.fromOffset(8, targetY), UDim2.new(1, -16, 0, argument4)
                    if not argument3 then
                        row.Position = position
                        row.Size = size2
                        row.GroupTransparency = argument2 and 1 or 0
                        row.Visible = not argument2
                        return
                    end
                    if not argument2 then
                        row.Visible = true
                    end
                    tweenInstance(
                        row,
                        tweenInfo,
                        { Position = position, Size = size2, GroupTransparency = argument2 and 1 or 0 }
                    )
                    if argument2 then
                        task.delay(0.36, function()
                            if argument.RowToken == rowToken then
                                row.Visible = false
                            end
                        end)
                    end
                end
                windowClass._layoutTabs = function(argument, argument2)
                    if not argument.TabCanvas then
                        return
                    end
                    argument2 = if motion.enabled then argument2 else false
                    local sidebarCollapsed = argument.SidebarCollapsed
                    local calculatedValue, calculatedValue2, counter7 =
                        sidebarCollapsed and counter3 or argument.RowH, argument.GroupLabels ~= false, 4
                    for key, item in ipairs(argument.Groups) do
                        if item.Row and not calculatedValue2 then
                            item.Row.Visible = false
                            item.Row.Position = UDim2.fromOffset(8, counter7)
                            item.Row.Size = UDim2.new(1, -16, 0, 0)
                        else
                            if item.Row then
                                item.Row.Visible = true
                                key = sidebarCollapsed and (item == callback3(argument) and 6 or counter5)
                                    or argument.CapH
                                item.Row.Position = UDim2.fromOffset(8, counter7)
                                if argument2 then
                                    tweenInstance(
                                        item.Row,
                                        tweenInfo,
                                        { Position = UDim2.fromOffset(8, counter7), Size = UDim2.new(1, -16, 0, key) }
                                    )
                                else
                                    item.Row.Size = UDim2.new(1, -16, 0, key)
                                end
                                counter7 += key
                            else
                            end
                        end
                        local calculatedValue3, value =
                            item.Collapsed and not sidebarCollapsed and calculatedValue2, counter7
                        counter7 = value
                        for unused, item2 in ipairs(item.Tabs) do
                            if item2 ~= argument.DraggingTab then
                                callback6(
                                    item2,
                                    calculatedValue3 and value or counter7,
                                    calculatedValue3,
                                    argument2,
                                    calculatedValue
                                )
                            end
                            counter7 = if calculatedValue3
                                then counter7
                                else counter7 + (calculatedValue + counter4)
                        end
                        counter7 = if #item.Tabs > 0
                            then if calculatedValue3
                                then counter7
                                else if calculatedValue2 then counter7 + 4 else counter7
                            else counter7
                    end
                    argument.TabCanvas.Size = UDim2.new(1, 0, 0, counter7 + 6)
                end
                windowClass.SetGroupLabels = function(argument, groupLabels)
                    groupLabels = groupLabels ~= false
                    if groupLabels == (argument.GroupLabels ~= false) then
                        return
                    end
                    argument.GroupLabels = groupLabels
                    argument.State.set("groupLabels", groupLabels)
                    if groupLabels and not argument.SidebarCollapsed then
                        for unused, item in ipairs(argument.Groups) do
                            if item.Row then
                                item.Label.TextTransparency, item.Chev.ImageTransparency = 1, 1
                                tweenInstance(item.Label, "Base", { TextTransparency = 0 })
                                tweenInstance(item.Chev, "Base", { ImageTransparency = 0 })
                            end
                        end
                    end
                    argument:_layoutTabs(true)
                    if argument.OnGroupLabels then
                        pcall(argument.OnGroupLabels, groupLabels)
                    end
                end
                windowClass._revealTab = function(argument, offset)
                    local tabScroll, calculatedValue = argument.TabScroll, offset and offset.Row
                    if tabScroll then
                        if not calculatedValue then
                            return
                        end
                    else
                        return
                    end
                    offset = calculatedValue.Position.Y.Offset
                    local calculatedValue2, calculatedValue3, y =
                        offset + calculatedValue.Size.Y.Offset,
                        tabScroll.AbsoluteWindowSize.Y / math.max(argument.Scale.Scale, 0.1),
                        tabScroll.CanvasPosition.Y
                    calculatedValue = if offset - 6 < y
                        then math.max(0, offset - 6)
                        else if calculatedValue2 + 6 > y + calculatedValue3
                            then calculatedValue2 + 6 - calculatedValue3
                            else y
                    if math.abs(calculatedValue - y) < 1 then
                        return
                    end
                    tweenInstance(tabScroll, "Base", { CanvasPosition = Vector2.new(0, calculatedValue) })
                end
                windowClass.SetSidebarCollapsed = function(argument, visible, argument2)
                    visible = visible and true or false
                    if visible == argument.SidebarCollapsed then
                        if not argument2 then
                            return
                        end
                    end
                    argument.SidebarCollapsed = visible
                    argument.State.set("sidebarCollapsed", visible)
                    local sidebarWidth = visible and sidebarCOLLAPSED or argument.ExpandedWidth
                    argument.SidebarWidth = sidebarWidth
                    local calculatedValue, main, visible2 =
                        argument2 and TweenInfo.new(0) or TweenInfo.new(
                            0.38,
                            Enum.EasingStyle.Quint,
                            Enum.EasingDirection.Out
                        ),
                        argument.Sidebar,
                        {}
                    visible2.Size = UDim2.new(0, sidebarWidth, 1, 0)
                    tweenInstance(main, calculatedValue, visible2)
                    argument.Main.Size = UDim2.new(1, -sidebarWidth, 1, 0)
                    main, visible2 = argument.Main, {}
                    visible2.Position = UDim2.fromOffset(sidebarWidth, 0)
                    tweenInstance(main, calculatedValue, visible2)
                    visible2, main = argument.SidebarEdge, {}
                    main.Position = UDim2.new(0, sidebarWidth, 0, 0)
                    tweenInstance(visible2, calculatedValue, main)
                    visible2 = nil
                    visible2, argument.SidebarEdge.Visible = not visible, not visible
                    local calculatedValue2, footerText, tabClip, chev =
                        argument2 and TweenInfo.new(0) or "Base", callback2(visible), argument.LogoButton, {}
                    chev.Position = UDim2.fromOffset(footerText.logoX, footerText.logoY)
                    tweenInstance(tabClip, calculatedValue, chev)
                    sidebarWidth, tabClip = argument.SearchField.Parent, {}
                    tabClip.Position = UDim2.fromOffset(0, footerText.searchY)
                    tweenInstance(sidebarWidth, calculatedValue, tabClip)
                    tabClip, chev = argument.TabClip, { Position = UDim2.fromOffset(0, footerText.tabTop) }
                    chev.Size = UDim2.new(1, 0, 1, -(footerText.tabTop + footerText.foot + 2))
                    tweenInstance(tabClip, calculatedValue, chev)
                    main, sidebarWidth = argument.Footer, {}
                    sidebarWidth.Size = UDim2.new(1, 0, 0, footerText.foot)
                    tweenInstance(main, calculatedValue, sidebarWidth)
                    main, sidebarWidth = argument.TitleLabel, {}
                    sidebarWidth.TextTransparency = visible and 1 or 0
                    tweenInstance(main, calculatedValue2, sidebarWidth)
                    footerText, chev = argument.SubtitleLabel, {}
                    chev.TextTransparency = visible and 1 or 0
                    tweenInstance(footerText, calculatedValue2, chev)
                    footerText, sidebarWidth = argument.FooterText, {}
                    sidebarWidth.TextTransparency = visible and 1 or 0
                    tweenInstance(footerText, calculatedValue2, sidebarWidth)
                    tweenInstance(
                        argument.FooterChip,
                        calculatedValue,
                        {
                            AnchorPoint = visible and Vector2.new(0.5, 0.5) or Vector2.new(1, 0.5),
                            Position = visible and UDim2.new(0.5, 0, 0.5, 1) or UDim2.new(1, -14, 0.5, 1),
                        }
                    )
                    argument.FoldButton.Visible = visible2
                    argument.SearchField.Parent.Visible = true
                    argument.SearchField.Visible = visible2
                    argument.SearchTile.Visible = visible
                    for label2, item in ipairs(argument.Groups) do
                        if item.Row then
                            label2, sidebarWidth = item.Label, {}
                            sidebarWidth.TextTransparency = visible and 1 or 0
                            tweenInstance(label2, calculatedValue2, sidebarWidth)
                            chev, tabClip = item.Chev, {}
                            tabClip.ImageTransparency = visible and 1 or 0
                            tweenInstance(chev, calculatedValue2, tabClip)
                            local line, entries, calculatedValue3 =
                                item.Line, {}, visible and (callback3(argument) == item and 1 or 0.88)
                            entries.BackgroundTransparency = calculatedValue3 or 1
                            tweenInstance(line, calculatedValue2, entries)
                        end
                        for unused, item2 in ipairs(item.Tabs) do
                            main, footerText =
                                visible and counter6 or argument.TileS,
                                visible and (sidebarCOLLAPSED - 16 - counter6) / 2 or 6
                            item2.BgGrad.Enabled, item2.StrokeGrad.Enabled = visible2, visible2
                            tweenInstance(
                                item2.Tile,
                                calculatedValue,
                                { Size = UDim2.fromOffset(main, main), Position = UDim2.new(0, footerText, 0.5, 0) }
                            )
                            local glow, label3 = item2.IconImg, {}
                            label3.Size = UDim2.fromOffset(visible and size or 16, visible and size or 16)
                            tweenInstance(glow, calculatedValue, label3)
                            argument:_styleTab(item2, argument.Current == item2, not argument2)
                            label3, glow = item2.Label, {}
                            glow.TextTransparency = visible and 1 or 0
                            tweenInstance(label3, calculatedValue2, glow)
                            if item2.Glow then
                                glow, label3 = item2.Glow, {}
                                label3.Position = UDim2.new(0, footerText + main / 2, 0.5, 0)
                                tweenInstance(glow, calculatedValue, label3)
                            end
                            if item2.Badge then
                                if visible then
                                    glow, label3 = item2.Badge, { Size = UDim2.fromOffset(10, 10) }
                                    label3.Position = UDim2.new(0, footerText + main - 2, 0.5, -main / 2 + 4)
                                    tweenInstance(glow, calculatedValue, label3)
                                    tweenInstance(item2.BadgeLabel, calculatedValue2, { TextTransparency = 1 })
                                    tweenInstance(item2.BadgeRing, calculatedValue2, { Transparency = 0 })
                                else
                                    tweenInstance(
                                        item2.Badge,
                                        calculatedValue,
                                        { Size = UDim2.fromOffset(item2.BadgeWidth, 18), Position = UDim2.new(
                                            1,
                                            -9,
                                            0.5,
                                            0
                                        ) }
                                    )
                                    tweenInstance(item2.BadgeLabel, calculatedValue2, { TextTransparency = 0 })
                                    tweenInstance(item2.BadgeRing, calculatedValue2, { Transparency = 1 })
                                end
                            end
                        end
                    end
                    argument:_layoutTabs(not argument2)
                    if argument.OnSidebarChanged then
                        pcall(argument.OnSidebarChanged, visible)
                    end
                end
                windowClass.SetDensity = function(argument, density)
                    local enabled = false
                    for unused, item in ipairs(windowClass.Densities) do
                        enabled = if item == density then true else enabled
                    end
                    if not enabled then
                        return
                    end
                    argument.Density = density
                    argument.State.set("density", density)
                    windowClass.applyDensity(argument)
                    if not argument.SidebarCollapsed then
                        for key, item in ipairs(argument.Groups) do
                            for tile, item2 in ipairs(item.Tabs) do
                                density, tile, key = argument.TileS, item2.Tile, {}
                                key.Size = UDim2.fromOffset(density, density)
                                tweenInstance(tile, "Base", key)
                                local glow, entries =
                                    item2.Label, { Position = UDim2.fromOffset(argument.LabelX, 0) }
                                entries.Size = UDim2.new(1, -(argument.LabelX + 10), 1, 0)
                                tweenInstance(glow, "Base", entries)
                                if item2.Glow then
                                    glow, tile = item2.Glow, {}
                                    tile.Position = UDim2.new(0, 6 + density / 2, 0.5, 0)
                                    tweenInstance(glow, "Base", tile)
                                end
                            end
                        end
                    end
                    argument:_layoutTabs(true)
                end
                windowClass.SetSidebarWidth = function(argument, sidebarWidth, argument2)
                    localization2.trace("SetSidebarWidth")
                    local main =
                        math.min(counter2, math.max(counter, (argument.Size and argument.Size.X or 860) - 420))
                    sidebarWidth = math.clamp(tonumber(sidebarWidth) or sidebarEXPANDED, counter, main)
                    argument.ExpandedWidth = sidebarWidth
                    if not argument2 then
                        argument.State.set("sidebarWidth", math.floor(sidebarWidth + 0.5))
                    end
                    if argument.OnSidebarWidth then
                        pcall(argument.OnSidebarWidth, sidebarWidth)
                    end
                    if argument.SidebarCollapsed then
                        return
                    end
                    argument.SidebarWidth = sidebarWidth
                    local calculatedValue, sidebar, sidebarEdge =
                        argument2 and TweenInfo.new(0) or TweenInfo.new(
                            0.25,
                            Enum.EasingStyle.Quint,
                            Enum.EasingDirection.Out
                        ),
                        argument.Sidebar,
                        {}
                    sidebarEdge.Size = UDim2.new(0, sidebarWidth, 1, 0)
                    tweenInstance(sidebar, calculatedValue, sidebarEdge)
                    argument.Main.Size = UDim2.new(1, -sidebarWidth, 1, 0)
                    main, sidebar = argument.Main, {}
                    sidebar.Position = UDim2.fromOffset(sidebarWidth, 0)
                    tweenInstance(main, calculatedValue, sidebar)
                    sidebarEdge, main = argument.SidebarEdge, {}
                    main.Position = UDim2.new(0, sidebarWidth, 0, 0)
                    tweenInstance(sidebarEdge, calculatedValue, main)
                end
                windowClass.ToggleSidebar = function(argument)
                    argument:SetSidebarCollapsed(not argument.SidebarCollapsed)
                end
                local function callback5(argument)
                    return (u.at(argument.PressInput).Y - argument.TabCanvas.AbsolutePosition.Y)
                        / math.max(argument.Scale.Scale, 0.1)
                end
                windowClass._reorderMove = function(argument)
                    local draggingTab = argument.PressTab
                    if not draggingTab then
                        if not argument.DraggingTab then
                            return
                        end
                    end
                    if not argument.DraggingTab then
                        local value = u.at(argument.PressInput)
                        if argument.IsTouch then
                            if os.clock() - (argument.PressTime or 0) < 0.35 then
                                if (value - argument.PressAt).Magnitude >= 9 then
                                    argument.PressTab = nil
                                end
                                return
                            end
                        end
                        if (value - argument.PressAt).Magnitude < 9 then
                            return
                        end
                        argument.DraggingTab = draggingTab
                        argument.DragOffset = callback5(argument) - (draggingTab.TargetY or 0)
                        draggingTab.Row.ZIndex = 10
                        argument:HideTip()
                        tweenInstance(draggingTab.Bg, "Quick", { BackgroundTransparency = 0.25 })
                        paint(draggingTab.BgStroke, "Color", "Accent", "Quick")
                        tweenInstance(draggingTab.BgStroke, "Quick", { Transparency = 0.35 })
                        if draggingTab.Glow then
                            tweenInstance(draggingTab.Glow, "Quick", { ImageTransparency = 0.5 })
                        end
                        sound.play("tick")
                    end
                    draggingTab = argument.DraggingTab
                    if not draggingTab then
                        return
                    end
                    argument:_tabPopFeedback(draggingTab)
                    local group, calculatedValue =
                        draggingTab.Group, argument.SidebarCollapsed and counter3 or argument.RowH
                    local calculatedValue2 = group.Tabs[1] and group.Tabs[1].TargetY or 0
                    local calculatedValue3 = calculatedValue2
                        + math.max(0, #group.Tabs - 1) * (calculatedValue + counter4)
                    local clampedValue = math.clamp(
                        callback5(argument) - argument.DragOffset,
                        calculatedValue2 - 8,
                        calculatedValue3 + 8
                    )
                    draggingTab.Row.Position = UDim2.fromOffset(8, clampedValue)
                    local calculatedValue4, calculatedValue5, clampedValue2 =
                        clampedValue + calculatedValue / 2, calculatedValue2, 1
                    for index = 1, #group.Tabs, 1 do
                        if group.Tabs[index] ~= draggingTab then
                            clampedValue2 = if calculatedValue4 > calculatedValue5 + calculatedValue / 2
                                then clampedValue2 + 1
                                else clampedValue2
                            calculatedValue5 = calculatedValue5 + (calculatedValue + counter4)
                        else
                        end
                    end
                    clampedValue2 = math.clamp(clampedValue2, 1, #group.Tabs)
                    calculatedValue3 = nil
                    for key, item in ipairs(group.Tabs) do
                        calculatedValue3 = if item == draggingTab then key else calculatedValue3
                    end
                    if calculatedValue3 then
                        if calculatedValue3 ~= clampedValue2 then
                            table.remove(group.Tabs, calculatedValue3)
                            table.insert(group.Tabs, clampedValue2, draggingTab)
                            argument:_layoutTabs(true)
                            sound.play("tick", 0.6)
                        end
                    end
                end
                windowClass._tabPopFeedback = function(argument, argument2)
                    local shadow, frame =
                        u.at(argument.PressInput),
                        argument.Sidebar.AbsolutePosition.X + argument.Sidebar.AbsoluteSize.X
                    local tabPopIntent = shadow.X > frame + 46 * math.max(argument.Scale.Scale, 0.1)
                        and #argument2.Sections > 0
                    if not argument.TabGhost then
                        frame = createInstance(
                            "CanvasGroup",
                            {
                                Name = "TabGhost",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Size = UDim2.fromOffset(160, 44),
                                BorderSizePixel = 0,
                                GroupTransparency = 1,
                                Visible = false,
                                ZIndex = 400,
                                Parent = argument.FloatLayer,
                            }
                        )
                        bindTheme(frame, "BackgroundColor3", "Elevated")
                        u.corner(frame, 14)
                        local shadow2 = tex.image(
                            frame,
                            "rim9",
                            { Size = UDim2.fromScale(1, 1), SliceScale = 1, ImageTransparency = 0.3, ZIndex = 402 }
                        )
                        if shadow2 then
                            bindTheme(shadow2, "ImageColor3", "Accent")
                        else
                            bindTheme(u.stroke(frame, color, 1, 0.4), "Color", "Accent")
                        end
                        shadow2 = tex.image(
                            argument.FloatLayer,
                            "shadow9",
                            {
                                Name = "TabGhostShadow",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Size = UDim2.fromOffset(220, 100),
                                SliceScale = 1,
                                ImageTransparency = 1,
                                Visible = false,
                                ZIndex = 399,
                            }
                        )
                        localization2.tile(
                            frame,
                            {
                                Name = "Tile",
                                Size = UDim2.fromOffset(28, 28),
                                Pos = UDim2.fromOffset(8, 8),
                                Color = "Accent",
                                Z = 401,
                            }
                        )
                        argument.TabGhost = {
                            Frame = frame,
                            Shadow = shadow2,
                            Icon = icon({
                                Parent = frame,
                                Icon = "layout-panel-top",
                                Size = 15,
                                Pos = UDim2.fromOffset(22, 22),
                                Anchor = Vector2.new(0.5, 0.5),
                                Color = "OnAccent",
                                Z = 403,
                            }),
                            Label = label({
                                Parent = frame,
                                Text = "",
                                Font = font.Semi(),
                                Size = 13,
                                Pos = UDim2.fromOffset(44, 0),
                                Box = UDim2.new(1, -52, 1, 0),
                                Truncate = true,
                                Z = 403,
                            }),
                        }
                    end
                    local tabGhost = argument.TabGhost
                    local maximumValue = math.max(argument.FloatScale.Scale, 0.1)
                    local frame2 = (shadow - argument.FloatLayer.AbsolutePosition) / maximumValue
                    tabGhost.Frame.Position = UDim2.fromOffset(frame2.X + 96, frame2.Y)
                    if tabGhost.Shadow then
                        tabGhost.Shadow.Position = UDim2.fromOffset(frame2.X + 96, frame2.Y + 6)
                    end
                    if tabPopIntent ~= argument.TabPopIntent then
                        argument.TabPopIntent = tabPopIntent
                        tabGhost.Label.Text = argument2.Label and argument2.Label.Text or argument2.Name
                        if argument2.IconImg then
                            if argument2.IconImg.Image ~= "" then
                                tabGhost.Icon.Image, tabGhost.Icon.ImageRectOffset, tabGhost.Icon.ImageRectSize =
                                    argument2.IconImg.Image,
                                    argument2.IconImg.ImageRectOffset,
                                    argument2.IconImg.ImageRectSize
                                tabGhost.Icon.Visible = true
                            end
                        end
                        if tabPopIntent then
                            tabGhost.Frame.Visible = true
                            if tabGhost.Shadow then
                                tabGhost.Shadow.Visible = true
                            end
                            sound.play("click", 0.7)
                        end
                        frame2, frame = tabGhost.Frame, {}
                        frame.GroupTransparency = tabPopIntent and 0 or 1
                        tweenInstance(frame2, "Base", frame)
                        if tabGhost.Shadow then
                            shadow, maximumValue = tabGhost.Shadow, {}
                            maximumValue.ImageTransparency = tabPopIntent and 0.45 or 1
                            tweenInstance(shadow, "Base", maximumValue)
                        end
                        local row, entries = argument2.Row, {}
                        entries.GroupTransparency = tabPopIntent and 0.45 or 0
                        tweenInstance(row, "Quick", entries)
                        if not tabPopIntent then
                            task.delay(0.2, function()
                                if not argument.TabPopIntent then
                                    tabGhost.Frame.Visible = false
                                    if tabGhost.Shadow then
                                        tabGhost.Shadow.Visible = false
                                    end
                                end
                            end)
                        end
                    end
                end
                windowClass._reorderEnd = function(argument)
                    local tabOrder = argument.DraggingTab
                    argument.PressTab = nil
                    if not tabOrder then
                        return
                    end
                    argument.DraggingTab = nil
                    argument.LastDragEnd = os.clock()
                    if argument.TabPopIntent then
                        argument.TabPopIntent = false
                        local tabGhost = argument.TabGhost
                        if tabGhost then
                            tweenInstance(tabGhost.Frame, "Quick", { GroupTransparency = 1 })
                            if tabGhost.Shadow then
                                tweenInstance(tabGhost.Shadow, "Quick", { ImageTransparency = 1 })
                            end
                            task.delay(0.2, function()
                                tabGhost.Frame.Visible = false
                                if tabGhost.Shadow then
                                    tabGhost.Shadow.Visible = false
                                end
                            end)
                        end
                        tweenInstance(tabOrder.Row, "Quick", { GroupTransparency = 0 })
                        local maximumValue = math.max(argument.FloatScale.Scale, 0.1)
                        local calculatedValue = (u.at(argument.PressInput) - argument.FloatLayer.AbsolutePosition)
                            / maximumValue
                        argument:FloatTab(tabOrder, calculatedValue - Vector2.new(80, 20))
                    end
                    tabOrder.Row.ZIndex = 1
                    argument:_styleTab(tabOrder, argument.Current == tabOrder, true)
                    argument:_layoutTabs(true)
                    tabOrder = {}
                    for key, item in ipairs(argument.Groups) do
                        key = {}
                        for unused, item2 in ipairs(item.Tabs) do
                            table.insert(key, item2.Name)
                        end
                        tabOrder[item.Key] = key
                    end
                    argument.State.data.tabOrder = tabOrder
                    argument.State.save()
                    if argument.OnTabOrder then
                        pcall(argument.OnTabOrder, tabOrder)
                    end
                end
            end
            do
                local u = localization2.U
                local motion = localization2.Motion
                local theme = localization2.Theme
                local font = localization2.Font
                local unused, sound = localization2.Icons, localization2.Sound
                local tex = localization2.Tex
                local createInstance = u.new
                local tweenInstance = motion.tween
                local bindTheme = theme.bind
                local label = localization2.label
                local icon = localization2.icon
                local paint = localization2.paint
                local windowClass = localization2.WindowClass
                local userInputService = localization2.Services.UserInputService
                local color, index = Color3.new(1, 1, 1), {}
                index.__index = index
                localization2.TabClass = index
                local index2 = {}
                index2.__index = index2
                localization2.SectionClass = index2
                local tweenInfo = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                windowClass.Tab = function(window, name)
                    name = (if type(name) == "string" then { Name = name } else name) or {}
                    local setmetatableResult = setmetatable({}, index)
                    setmetatableResult.Window = window
                    setmetatableResult.Name = name.Name or "Tab " .. #window.TabList + 1
                    setmetatableResult.Title = name.Title or setmetatableResult.Name
                    setmetatableResult.Desc = name.Desc or ""
                    setmetatableResult.Icon = name.Icon
                    setmetatableResult.Rows = {}
                    setmetatableResult.Sections = {}
                    setmetatableResult.Pages = {}
                    setmetatableResult.Loads = {}
                    setmetatableResult.Columns = name.Columns or 2
                    window.Tabs[setmetatableResult.Name] = setmetatableResult
                    table.insert(window.TabList, setmetatableResult)
                    window:_addTabRow(setmetatableResult, name)
                    local frame = createInstance(
                        "CanvasGroup",
                        {
                            Name = setmetatableResult.Name,
                            Size = UDim2.fromScale(1, 1),
                            BackgroundTransparency = 1,
                            Visible = false,
                            Parent = window.Parking or window.Body,
                        }
                    )
                    setmetatableResult.Frame = frame
                    setmetatableResult.RefreshGen = localization2.Refresh.gen
                    setmetatableResult.PageHost = createInstance(
                        "Frame",
                        { Name = "Pages", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, Parent = frame }
                    )
                    return setmetatableResult
                end
                index._setActive = function(argument, argument2)
                    argument.Window:_styleTab(argument, argument2, true)
                end
                windowClass.SelectTab = function(argument, entry)
                    localization2.trace("SelectTab")
                    local current
                    if type(entry) == "string" then
                        entry = argument.Tabs[entry]
                        current = entry
                    else
                        current = entry
                    end
                    if not current or current == argument.Current then
                        return
                    end
                    local current2 = argument.Current
                    argument.Current = current
                    argument:ClosePopups()
                    if current.Group then
                        if current.Group.Collapsed then
                            if not argument.SidebarCollapsed then
                                argument:SetGroupCollapsed(current.Group, false)
                            end
                        end
                    end
                    if current2 then
                        argument:_styleTab(current2, false, true)
                        local frame = current2.Frame
                        tweenInstance(
                            frame,
                            "Quick",
                            { GroupTransparency = 1, Position = UDim2.fromOffset(-14, 0) }
                        )
                        task.delay(0.16, function()
                            if argument.Current ~= current2 then
                                frame.Visible = false
                                if argument.Parking then
                                    frame.Parent = argument.Parking
                                    current2.RefreshGen = localization2.Refresh.gen
                                end
                            end
                        end)
                    end
                    argument:_styleTab(current, true, true)
                    argument:_revealTab(current)
                    local frame = current.Frame
                    if frame.Parent ~= argument.Body then
                        frame.Parent = argument.Body
                        if current.RefreshGen ~= localization2.Refresh.gen then
                            localization2.Refresh.sync(frame)
                            current.RefreshGen = localization2.Refresh.gen
                        end
                    end
                    frame.Visible = true
                    frame.GroupTransparency = 1
                    frame.Position = UDim2.fromOffset(18, 0)
                    tweenInstance(frame, "Base", { GroupTransparency = 0, Position = UDim2.fromOffset(0, 0) })
                    task.delay(0.2, function()
                        if argument.Current == current then
                            current:_balanceActive()
                        end
                    end)
                    argument.HeaderTitle.Text = current.Title
                    argument.HeaderDesc.Text = current.Desc or ""
                    if argument.OnTabChanged then
                        pcall(argument.OnTabChanged, current)
                    end
                end
                local counter, counter2, counter3, counter4, text, entries =
                    46, 7, 40, 360, "  ›  ", { tab = 30, sub = 22, section = 10, row = 0 }
                local function callback(gsubResult)
                    gsubResult = string.lower(tostring(gsubResult or ""))
                    gsubResult = string.gsub(gsubResult, "<[^>]->", "")
                    gsubResult = string.gsub(gsubResult, "\208([\144-\159])", function(argument)
                        return "\208" .. string.char(string.byte(argument) + 32)
                    end)
                    gsubResult = string.gsub(gsubResult, "\208([\160-\175])", function(argument)
                        return "\209" .. string.char(string.byte(argument) - 32)
                    end)
                    return (
                        string.gsub(gsubResult, "\208([\129\132\134\135])", function(argument)
                            return "\209" .. string.char(string.byte(argument) + 16)
                        end)
                    )
                end
                local function callback2(argument)
                    return (string.gsub(tostring(argument or ""), "<[^>]->", ""))
                end
                local function callback3(gsubResult)
                    gsubResult = string.gsub(gsubResult, "&", "&amp;")
                    gsubResult = string.gsub(gsubResult, "<", "&lt;")
                    return (string.gsub(gsubResult, ">", "&gt;"))
                end
                local function callback4(argument, argument2, argument3)
                    local findResult, findResult2 = string.find(callback(argument), argument2, 1, true)
                    if not findResult then
                        return callback3(argument)
                    end
                    return callback3(string.sub(argument, 1, findResult - 1))
                        .. '<font color="#'
                        .. argument3
                        .. '">'
                        .. callback3(string.sub(argument, findResult, findResult2))
                        .. "</font>"
                        .. callback3(string.sub(argument, findResult2 + 1))
                end
                windowClass._searchSubLabel = function(calculatedValue, argument, entry)
                    calculatedValue = entry and entry.Key
                    if calculatedValue then
                        if calculatedValue == "_" then
                            return nil
                        elseif not argument.SubButtons then
                            return nil
                        end
                    else
                        return nil
                    end
                    entry = argument.SubButtons[calculatedValue]
                    return callback2(entry and entry.Label and entry.Label.Text or calculatedValue)
                end
                windowClass._searchCollect = function(argument)
                    local entries2 = {}
                    for path, tab in ipairs(argument.TabList) do
                        path = callback2(tab.Label and tab.Label.Text or tab.Name)
                        local hay = callback(path .. " " .. tostring(tab.Name))
                        table.insert(
                            entries2,
                            {
                                kind = "tab",
                                tab = tab,
                                title = path,
                                path = localization2.tr("Tab"),
                                hay = hay,
                                titleL = callback(path),
                            }
                        )
                        if tab.SubDefs and tab.SubButtons then
                            for key, item in ipairs(tab.SubDefs) do
                                key = tab.SubButtons[item.key]
                                local title =
                                    callback2(key and key.Label and key.Label.Text or item.label or item.key)
                                table.insert(
                                    entries2,
                                    {
                                        kind = "sub",
                                        tab = tab,
                                        sub = item.key,
                                        title = title,
                                        path = path,
                                        hay = callback(title .. " " .. tostring(item.key)) .. " " .. hay,
                                        titleL = callback(title),
                                    }
                                )
                            end
                        end
                        for searchSubLabelResult, sec in ipairs(tab.Sections) do
                            if not sec.Hidden then
                                if sec.TitleLabel then
                                    if not sec.ParentSection then
                                        searchSubLabelResult, hay =
                                            argument:_searchSubLabel(tab, sec.Page), callback2(sec.TitleLabel.Text)
                                        local path2 = searchSubLabelResult and path .. text .. searchSubLabelResult
                                            or path
                                        table.insert(
                                            entries2,
                                            {
                                                kind = "section",
                                                tab = tab,
                                                sec = sec,
                                                title = hay,
                                                path = path2,
                                                hay = callback(hay .. " " .. tostring(sec.Key) .. " " .. path2),
                                                titleL = callback(hay),
                                            }
                                        )
                                    end
                                end
                            end
                        end
                        for row, item in ipairs(tab.Rows) do
                            row = item.row
                            if
                                row
                                and row.Title
                                and not row.selfHidden
                                and not row.parentHidden
                                and row.Frame
                                and row.Frame.Parent
                            then
                                local chain, sec, enabled = {}, item.sec, true
                                while sec and sec.ParentSection do
                                    enabled = if sec.OwnerRow
                                        then if sec.OwnerRow.selfHidden
                                            then false
                                            else if sec.OwnerRow.parentHidden then false else enabled
                                        else enabled
                                    table.insert(chain, sec)
                                    sec = sec.ParentSection
                                end
                                hay = callback2(row.Title.Text)
                                if enabled and sec and not sec.Hidden and hay ~= "" then
                                    local success, result = { path }, argument:_searchSubLabel(tab, sec.Page)
                                    if result then
                                        table.insert(success, result)
                                    end
                                    if sec.TitleLabel then
                                        table.insert(success, callback2(sec.TitleLabel.Text))
                                    end
                                    for index3 = #chain, 1, -1 do
                                        result = chain[index3].OwnerRow
                                        if result then
                                            if result.Title then
                                                table.insert(success, callback2(result.Title.Text))
                                            end
                                        end
                                    end
                                    local path2, calculatedValue =
                                        table.concat(success, text),
                                        (row.Desc and row.Desc.Text or "") .. " " .. tostring(
                                            row.Opts and row.Opts.Text or ""
                                        )
                                    if row.SearchOptions then
                                        success, result = pcall(row.SearchOptions)
                                        calculatedValue = if success
                                            then if type(result) == "string"
                                                then calculatedValue .. " " .. result
                                                else calculatedValue
                                            else calculatedValue
                                    else
                                    end
                                    table.insert(
                                        entries2,
                                        {
                                            kind = "row",
                                            tab = tab,
                                            sec = sec,
                                            row = row,
                                            chain = chain,
                                            title = hay,
                                            path = path2,
                                            hay = callback(hay .. " " .. calculatedValue .. " " .. path2),
                                            titleL = callback(hay),
                                        }
                                    )
                                end
                            end
                        end
                    end
                    return entries2
                end
                windowClass._searchRank = function(argument, entries2)
                    local gsubResult = callback(entries2)
                    gsubResult = string.gsub(gsubResult, "^%s+", "")
                    gsubResult = string.gsub(gsubResult, "%s+$", "")
                    if gsubResult == "" then
                        return {}, gsubResult
                    end
                    entries2 = {}
                    for key in string.gmatch(gsubResult, "%S+") do
                        table.insert(entries2, key)
                    end
                    local entries3, entries4 = {}, {}
                    for findResult, item in ipairs(argument:_searchCollect()) do
                        findResult = string.find(item.titleL, gsubResult, 1, true)
                        local calculatedValue, enabled, enabled2 =
                            if findResult == 1 then 120 else if findResult then 70 else 0, findResult ~= nil, true
                        for unused, item2 in ipairs(entries2) do
                            if string.find(item.titleL, item2, 1, true) then
                                calculatedValue, enabled = calculatedValue + 18, true
                            else
                                if string.find(item.hay, item2, 1, true) then
                                    calculatedValue += 4
                                else
                                    enabled2 = false
                                    break
                                end
                            end
                        end
                        if enabled2 and (enabled or item.kind ~= "row") then
                            findResult = item.kind .. "|" .. item.title .. "|" .. item.path
                            if not entries4[findResult] then
                                entries4[findResult] = true
                                item.score = calculatedValue + entries[item.kind] - #item.titleL / 40
                                table.insert(entries3, item)
                            end
                        end
                    end
                    table.sort(entries3, function(argument2, argument)
                        return argument2.score > argument.score
                    end)
                    while #entries3 > counter3 do
                        table.remove(entries3)
                    end
                    return entries3, gsubResult
                end
                windowClass._searchClose = function(argument)
                    local searchPop = argument.SearchPop
                    if not searchPop then
                        return
                    end
                    argument.SearchPop = nil
                    argument:PopupConceal(searchPop.Frame, searchPop.Shell)
                    task.delay(0.18, function()
                        pcall(function()
                            searchPop.Frame:Destroy()
                        end)
                    end)
                end
                windowClass._searchOpen = function(argument, h)
                    if argument.SearchPop then
                        return argument.SearchPop
                    end
                    local searchResults, shell, popupShellResult = argument:PopupShell(counter4, h)
                    searchResults.Name = "SearchResults"
                    local list = createInstance(
                        "ScrollingFrame",
                        {
                            Name = "List",
                            Position = UDim2.fromOffset(0, 5),
                            Size = UDim2.new(1, 0, 1, -10),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            ScrollBarThickness = 2,
                            CanvasSize = UDim2.new(),
                            AutomaticCanvasSize = Enum.AutomaticSize.Y,
                            ScrollingDirection = Enum.ScrollingDirection.Y,
                            ZIndex = 61,
                            Parent = shell,
                        }
                    )
                    bindTheme(list, "ScrollBarImageColor3", "Faint")
                    u.list(list, 2)
                    u.pad(list, 0, 5, 0, 5)
                    local empty = label({
                        Parent = shell,
                        Text = localization2.tr("Nothing found"),
                        Font = font.Medium(),
                        Size = 13,
                        Color = "Muted",
                        AlignX = Enum.TextXAlignment.Center,
                        Box = UDim2.fromScale(1, 1),
                        Z = 62,
                    })
                    empty.Visible = false
                    local searchPop = {
                        Frame = searchResults,
                        Shell = shell,
                        List = list,
                        Empty = empty,
                        Rows = {},
                        Items = {},
                        Sel = 1,
                        H = h,
                    }
                    argument.SearchPop = searchPop
                    local popupPlaceResult, popupPlaceResult2, unused, popupPlaceResult3 =
                        argument:PopupPlace(argument.SearchField, counter4, h, "left")
                    searchResults.Position = UDim2.fromOffset(popupPlaceResult, popupPlaceResult2)
                    argument:PopupReveal(searchResults, shell, popupShellResult, popupPlaceResult3 == 1)
                    table.insert(argument.Popups, {
                        close = function()
                            if argument.SearchPop == searchPop then
                                argument:_searchClose()
                            end
                        end,
                    })
                    return searchPop
                end
                windowClass._searchSelect = function(calculatedValue, sel)
                    local y = calculatedValue.SearchPop
                    if y then
                        if #y.Rows == 0 then
                            return
                        end
                    else
                        return
                    end
                    sel = math.clamp(sel, 1, #y.Rows)
                    y.Sel = sel
                    for key, item in ipairs(y.Rows) do
                        tweenInstance(item, "Quick", { BackgroundTransparency = key == sel and 0.84 or 1 })
                    end
                    local list, maximumValue, calculatedValue2 =
                        y.List, math.max(calculatedValue.PopScale.Scale, 0.1), (sel - 1) * (counter + 2)
                    calculatedValue, y = list.AbsoluteWindowSize.Y / maximumValue, list.CanvasPosition.Y
                    if calculatedValue2 < y then
                        list.CanvasPosition = Vector2.new(0, calculatedValue2)
                    elseif calculatedValue > 1 then
                        if calculatedValue2 + counter > y + calculatedValue then
                            list.CanvasPosition = Vector2.new(0, calculatedValue2 + counter - calculatedValue)
                        end
                    end
                end
                windowClass._searchRender = function(argument, items, h)
                    local searchPop = argument.SearchPop
                    if not searchPop then
                        return
                    end
                    for unused, item in ipairs(searchPop.Rows) do
                        item:Destroy()
                    end
                    searchPop.Rows = {}
                    searchPop.Items = items
                    searchPop.Empty.Visible = #items == 0
                    local quint = theme.resolve("Accent"):ToHex()
                    for layoutOrder, item in ipairs(items) do
                        local parent = createInstance(
                            "TextButton",
                            {
                                Name = "Result",
                                Text = "",
                                AutoButtonColor = false,
                                Size = UDim2.new(1, 0, 0, counter),
                                BackgroundTransparency = 1,
                                BorderSizePixel = 0,
                                LayoutOrder = layoutOrder,
                                ZIndex = 62,
                                Parent = searchPop.List,
                            }
                        )
                        bindTheme(parent, "BackgroundColor3", "Accent")
                        u.corner(parent, 9)
                        local parent2 = createInstance(
                            "Frame",
                            {
                                Name = "Tile",
                                AnchorPoint = Vector2.new(0, 0.5),
                                Position = UDim2.new(0, 8, 0.5, 0),
                                Size = UDim2.fromOffset(30, 30),
                                BorderSizePixel = 0,
                                BackgroundTransparency = 0.82,
                                ZIndex = 63,
                                Parent = parent,
                            }
                        )
                        bindTheme(parent2, "BackgroundColor3", "Accent")
                        u.corner(parent2, 9)
                        icon({
                            Parent = parent2,
                            Icon = item.tab.Icon or "search",
                            Size = 15,
                            Pos = UDim2.fromScale(0.5, 0.5),
                            Anchor = Vector2.new(0.5, 0.5),
                            Color = "Accent",
                            Z = 64,
                        })
                        label({
                            Parent = parent,
                            Text = callback4(item.title, h, quint),
                            Rich = true,
                            Font = font.Semi(),
                            Size = 13,
                            Pos = UDim2.fromOffset(48, 6),
                            Box = UDim2.new(1, -58, 0, 18),
                            Truncate = true,
                            Z = 63,
                        })
                        label({
                            Parent = parent,
                            Text = callback3(item.path),
                            Rich = true,
                            Font = font.Medium(),
                            Size = 11,
                            Color = "Muted",
                            Pos = UDim2.fromOffset(48, 24),
                            Box = UDim2.new(1, -58, 0, 15),
                            Truncate = true,
                            Z = 63,
                        })
                        local function handleAction()
                            if searchPop.Sel ~= layoutOrder then
                                argument:_searchSelect(layoutOrder)
                            end
                        end
                        parent.MouseEnter:Connect(handleAction)
                        local function handleAction2()
                            argument:_searchJump(item)
                        end
                        parent.MouseButton1Click:Connect(handleAction2)
                        table.insert(searchPop.Rows, parent)
                    end
                    h = #items == 0 and 56 or math.min(#items, counter2) * (counter + 2) + 8
                    if searchPop.H ~= h then
                        searchPop.H = h
                        local frame, new, enum = searchPop.Frame, TweenInfo.new, Enum
                        quint, items = enum.EasingStyle.Quint, Enum.EasingDirection
                        local value, entries = new(0.2, quint, items.Out), {}
                        entries.Size = UDim2.fromOffset(counter4, h)
                        tweenInstance(frame, value, entries)
                    end
                    searchPop.List.CanvasPosition = Vector2.zero
                    searchPop.Sel = 1
                    argument:_searchSelect(1)
                end
                windowClass._searchFlash = function(unused, parent)
                    if parent then
                        if not parent.Parent then
                            return
                        end
                    else
                        return
                    end
                    local value = createInstance(
                        "Frame",
                        {
                            Name = "SearchFlash",
                            Size = UDim2.fromScale(1, 1),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 1,
                            ZIndex = 0,
                            Parent = parent,
                        }
                    )
                    bindTheme(value, "BackgroundColor3", "Accent")
                    u.corner(value, 10)
                    local strokeResult = u.stroke(value, color, 1.5, 1)
                    bindTheme(strokeResult, "Color", "Accent")
                    local tweenInfo2 = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local tweenInfo3 = TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                    task.spawn(function()
                        for unused = 1, 2, 1 do
                            tweenInstance(value, tweenInfo2, { BackgroundTransparency = 0.8 })
                            tweenInstance(strokeResult, tweenInfo2, { Transparency = 0.25 })
                            task.wait(0.24)
                            tweenInstance(value, tweenInfo3, { BackgroundTransparency = 1 })
                            tweenInstance(strokeResult, tweenInfo3, { Transparency = 1 })
                            task.wait(0.56)
                        end
                        value:Destroy()
                    end)
                end
                windowClass._searchScroll = function(argument, easingDirection, quint)
                    if easingDirection then
                        if easingDirection.Floating then
                            return
                        end
                    else
                        return
                    end
                    local calculatedValue = easingDirection.Page and easingDirection.Page.Scroll
                    if calculatedValue then
                        if quint then
                            if not quint.Parent then
                                return
                            end
                        else
                            return
                        end
                    else
                        return
                    end
                    easingDirection = math.max(argument.Scale.Scale, 0.1)
                    local calculatedValue2, calculatedValue3 =
                        (quint.AbsolutePosition.Y - calculatedValue.AbsolutePosition.Y) / easingDirection
                            + calculatedValue.CanvasPosition.Y,
                        calculatedValue.AbsoluteWindowSize.Y / easingDirection
                    quint = math.max(0, calculatedValue.AbsoluteCanvasSize.Y / easingDirection - calculatedValue3)
                    local clampedValue, new, enum =
                        math.clamp(calculatedValue2 - calculatedValue3 * 0.3, 0, quint), TweenInfo.new, Enum
                    quint, easingDirection = enum.EasingStyle.Quint, Enum.EasingDirection
                    calculatedValue3, enum = new(0.45, quint, easingDirection.Out), {}
                    enum.CanvasPosition = Vector2.new(0, clampedValue)
                    tweenInstance(calculatedValue, calculatedValue3, enum)
                end
                windowClass._searchJump = function(argument, argument2)
                    if argument2 then
                        if not argument2.tab then
                            return
                        end
                    else
                        return
                    end
                    local tab = argument2.tab
                    argument:_searchClose()
                    argument.SearchBox.Text = ""
                    pcall(function()
                        argument.SearchBox:ReleaseFocus()
                    end)
                    sound.play("click")
                    if argument.Current ~= tab then
                        argument:SelectTab(tab)
                    end
                    if argument2.kind == "tab" then
                        return
                    end
                    local sec = argument2.sec
                    local ownerToggle = argument2.sub or sec and sec.Page and sec.Page.Key
                    if ownerToggle then
                        if tab.SubButtons then
                            if tab.SubButtons[ownerToggle] then
                                if tab.ActiveSub ~= ownerToggle then
                                    tab:SelectSub(ownerToggle)
                                end
                            end
                        end
                    end
                    if argument2.kind == "sub" then
                        return
                    end
                    if sec and sec.Collapsed then
                        sec:SetCollapsed(false)
                    end
                    tab = argument2.chain or {}
                    for index3 = #tab, 1, -1 do
                        ownerToggle = tab[index3].OwnerToggle
                        if ownerToggle then
                            if ownerToggle.SetDrawer then
                                if ownerToggle.IsDrawerOpen then
                                    if not (ownerToggle:IsDrawerOpen()) then
                                        ownerToggle:SetDrawer(true)
                                    end
                                end
                            end
                        end
                    end
                    local calculatedValue = argument2.kind == "row" and argument2.row.Frame or sec and sec.Wrap
                    local calculatedValue2 = argument2.kind == "row" and argument2.row.Frame or sec and sec.Card
                    task.delay(0.4, function()
                        if argument.Destroyed then
                            return
                        elseif calculatedValue then
                            if not calculatedValue.Parent then
                                return
                            end
                        else
                            return
                        end
                        argument:_searchScroll(sec, calculatedValue)
                        task.delay(0.35, function()
                            argument:_searchFlash(calculatedValue2)
                        end)
                    end)
                end
                windowClass.Search = function(argument, calculatedValue)
                    localization2.trace("Search")
                    if argument.Query ~= "" then
                        for unused, item in ipairs(argument.TabList) do
                            for unused, item2 in ipairs(item.Rows) do
                                if item2.searchHidden then
                                    item2.searchHidden = false
                                    item2.refresh()
                                end
                            end
                            for unused, item2 in ipairs(item.Sections) do
                                item2:_refreshVisibility()
                            end
                            if item.Label then
                                if not argument.SidebarCollapsed then
                                    tweenInstance(item.Label, "Quick", { TextTransparency = 0 })
                                end
                            end
                            if item.IconImg then
                                tweenInstance(item.IconImg, "Quick", { ImageTransparency = 0 })
                            end
                        end
                    end
                    argument.Query = ""
                    local text2 = tostring(calculatedValue or "")
                    if not (string.find(text2, "%S")) then
                        argument:_searchClose()
                        return
                    end
                    local searchRankResult, searchRankResult2 = argument:_searchRank(text2)
                    calculatedValue = #searchRankResult == 0 and 56
                        or math.min(#searchRankResult, counter2) * (counter + 2) + 8
                    argument:_searchOpen(calculatedValue)
                    argument:_searchRender(searchRankResult, searchRankResult2)
                end
                index._page = function(argument, key)
                    key = key or "_"
                    local entries2 = argument.Pages[key]
                    if entries2 then
                        return entries2
                    end
                    local one = argument.Columns == 1
                        or argument.PageColumns ~= nil and argument.PageColumns[key] == 1
                    local calculatedValue = argument.SubBar and 48 or 0
                    local root = createInstance(
                        "CanvasGroup",
                        {
                            Name = "Clip_" .. tostring(key),
                            Position = UDim2.fromOffset(0, calculatedValue),
                            Size = UDim2.new(1, 0, 1, -calculatedValue),
                            BackgroundTransparency = 1,
                            Visible = key == "_" or key == argument.ActiveSub,
                            Parent = argument.PageHost,
                        }
                    )
                    local parent = createInstance(
                        "ScrollingFrame",
                        {
                            Name = "Page_" .. tostring(key),
                            Size = UDim2.fromScale(1, 1),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            ScrollBarThickness = 3,
                            ScrollBarImageTransparency = 0.4,
                            CanvasSize = UDim2.new(),
                            AutomaticCanvasSize = Enum.AutomaticSize.Y,
                            ScrollingDirection = Enum.ScrollingDirection.Y,
                            Parent = root,
                        }
                    )
                    local value = createInstance("UIGradient", { Rotation = 90, Parent = root })
                    local function handleAction()
                        if argument.Window.Scaling then
                            argument.Window:_scalingDefer(handleAction)
                            return
                        end
                        local y = root.AbsoluteSize.Y
                        if y < 60 then
                            return
                        end
                        local clampedValue, clampedValue2, minimumValue =
                            math.clamp(parent.CanvasPosition.Y / 12, 0, 1),
                            math.clamp(
                                (
                                    parent.AbsoluteCanvasSize.Y
                                    - parent.CanvasPosition.Y
                                    - parent.AbsoluteWindowSize.Y
                                ) / 12,
                                0,
                                1
                            ),
                            math.min(22 / y, 0.3)
                        value.Transparency = NumberSequence.new({
                            NumberSequenceKeypoint.new(0, clampedValue * 0.9),
                            NumberSequenceKeypoint.new(minimumValue, 0),
                            NumberSequenceKeypoint.new(1 - minimumValue, 0),
                            NumberSequenceKeypoint.new(1, clampedValue2 * 0.9),
                        })
                    end
                    parent:GetPropertyChangedSignal("CanvasPosition"):Connect(handleAction)
                    parent:GetPropertyChangedSignal("AbsoluteCanvasSize"):Connect(handleAction)
                    parent:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(handleAction)
                    task.defer(handleAction)
                    bindTheme(parent, "ScrollBarImageColor3", "Faint")
                    u.pad(parent, 6, 0, 22, 0)
                    local parent2 = createInstance(
                        "Frame",
                        {
                            Name = "Columns",
                            Position = UDim2.fromOffset(22, 0),
                            Size = UDim2.new(1, -44, 0, 0),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundTransparency = 1,
                            Parent = parent,
                        }
                    )
                    local left = createInstance(
                        "Frame",
                        {
                            Name = "Left",
                            Size = UDim2.new(one and 1 or 0.5, one and 0 or -8, 0, 0),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundTransparency = 1,
                            Parent = parent2,
                        }
                    )
                    u.list(left, 16)
                    local right = createInstance(
                        "Frame",
                        {
                            Name = "Right",
                            AnchorPoint = Vector2.new(1, 0),
                            Position = UDim2.fromScale(1, 0),
                            Size = UDim2.new(0.5, -8, 0, 0),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundTransparency = 1,
                            Visible = not one,
                            Parent = parent2,
                        }
                    )
                    u.list(right, 16)
                    entries2 = {
                        Root = root,
                        Scroll = parent,
                        Left = left,
                        Right = right,
                        Load = { 0, 0 },
                        Key = key,
                        Cols = parent2,
                        One = one,
                    }
                    local value, enabled =
                        createInstance(
                            "UIListLayout",
                            { Padding = UDim.new(0, 16), SortOrder = Enum.SortOrder.LayoutOrder }
                        ),
                        false
                    local function handleAction()
                        if argument.Window.Scaling then
                            argument.Window:_scalingDefer(handleAction)
                            return
                        end
                        local maximumValue = math.max(argument.Window.Scale.Scale, 0.1)
                        local calculatedValue = parent.AbsoluteSize.X / maximumValue
                        maximumValue = if one then not one else calculatedValue < 440
                        if maximumValue == enabled then
                            return
                        end
                        enabled = maximumValue
                        if maximumValue then
                            left.Size = UDim2.new(1, 0, 0, 0)
                            right.AnchorPoint, right.Position, right.Size =
                                Vector2.zero, UDim2.new(), UDim2.new(1, 0, 0, 0)
                            left.LayoutOrder = 1
                            right.LayoutOrder = 2
                            value.Parent = parent2
                        else
                            value.Parent = nil
                            left.Size = UDim2.new(0.5, -8, 0, 0)
                            right.AnchorPoint, right.Position, right.Size =
                                Vector2.new(1, 0), UDim2.fromScale(1, 0), UDim2.new(0.5, -8, 0, 0)
                        end
                    end
                    parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(handleAction)
                    task.defer(handleAction)
                    argument.Pages[key] = entries2
                    return entries2
                end
                index.SubTabs = function(argument, subBar)
                    if argument.SubBar then
                        return
                    end
                    local subDefs = {}
                    for unused, key in ipairs(subBar or {}) do
                        key = if type(key) == "string" then { key = key, label = key } else key
                        if type(key) == "table" then
                            if key.key then
                                table.insert(subDefs, key)
                            end
                        end
                    end
                    if #subDefs == 0 then
                        return
                    end
                    argument.SubDefs = subDefs
                    for unused, item in ipairs(subDefs) do
                        if item.Columns then
                            argument.PageColumns = argument.PageColumns or {}
                            argument.PageColumns[item.key] = item.Columns
                        end
                    end
                    subBar = createInstance(
                        "Frame",
                        { Name = "SubBar", Size = UDim2.new(1, 0, 0, 48), BackgroundTransparency = 1, Parent = argument.Frame }
                    )
                    argument.SubBar = subBar
                    local parent = createInstance(
                        "Frame",
                        {
                            Name = "Shell",
                            Position = UDim2.fromOffset(22, 6),
                            Size = UDim2.fromOffset(0, 36),
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0,
                            Parent = subBar,
                        }
                    )
                    bindTheme(parent, "BackgroundColor3", "Surface")
                    u.corner(parent, 11)
                    bindTheme(u.stroke(parent, color, 1, 0.9), "Color", "Glass")
                    local subPill = createInstance(
                        "Frame",
                        {
                            Name = "Pill",
                            Size = UDim2.fromOffset(60, 30),
                            Position = UDim2.fromOffset(3, 3),
                            BorderSizePixel = 0,
                            ZIndex = 2,
                            Parent = parent,
                        }
                    )
                    bindTheme(subPill, "BackgroundColor3", "Elevated")
                    u.corner(subPill, 9)
                    bindTheme(u.stroke(subPill, color, 1, 0.88), "Color", "Glass")
                    argument.SubPill = subPill
                    subPill = createInstance(
                        "Frame",
                        {
                            Name = "Row",
                            Size = UDim2.new(0, 0, 1, 0),
                            AutomaticSize = Enum.AutomaticSize.X,
                            BackgroundTransparency = 1,
                            ZIndex = 3,
                            Parent = parent,
                        }
                    )
                    u.list(
                        subPill,
                        2,
                        Enum.FillDirection.Horizontal,
                        Enum.HorizontalAlignment.Left,
                        Enum.VerticalAlignment.Center
                    )
                    u.pad(subPill, 3, 3, 3, 3)
                    argument.SubButtons = {}
                    for layoutOrder, def in ipairs(subDefs) do
                        local parent2 = createInstance(
                            "TextButton",
                            {
                                Name = def.key,
                                Text = "",
                                AutoButtonColor = false,
                                BackgroundTransparency = 1,
                                Size = UDim2.fromOffset(0, 30),
                                AutomaticSize = Enum.AutomaticSize.X,
                                LayoutOrder = layoutOrder,
                                ZIndex = 4,
                                Parent = subPill,
                            }
                        )
                        local pad, label2 =
                            u.pad(parent2, 0, 15, 0, 15),
                            label({
                                Parent = parent2,
                                Text = def.label or def.key,
                                Font = font.Semi(),
                                Size = 13,
                                Box = UDim2.new(0, 0, 1, 0),
                                Auto = Enum.AutomaticSize.X,
                                Color = "Muted",
                                Z = 4,
                            })
                        local entry, subButtons, key, entries =
                            u.textReg[label2],
                            argument.SubButtons,
                            def.key,
                            { Button = parent2, Label = label2, Def = def, Pad = pad }
                        entries.Base, subButtons[key] = entry and entry.size or 13, entries
                        local function handleAction()
                            if argument.ActiveSub ~= def.key then
                                paint(label2, "TextColor3", "Text", "Quick")
                            end
                            sound.play("hover", 0.4)
                        end
                        parent2.MouseEnter:Connect(handleAction)
                        u.leave(parent2, function()
                            if argument.ActiveSub ~= def.key then
                                paint(label2, "TextColor3", "Muted", "Quick")
                            end
                        end)
                        local function handleAction2()
                            if argument.ActiveSub ~= def.key then
                                sound.play("tick")
                            end
                            argument:SelectSub(def.key)
                        end
                        parent2.MouseButton1Click:Connect(handleAction2)
                    end
                    for unused, item in pairs(argument.Pages) do
                        item.Root.Position = UDim2.fromOffset(0, 48)
                        item.Root.Size = UDim2.new(1, 0, 1, -48)
                    end
                    argument.ActiveSub = subDefs[1].key
                    local function isActive2()
                        argument:_placePill(true)
                    end
                    local function handleAction()
                        argument:_queueFitSubs()
                        if argument.Window.Scaling then
                            argument.Window:_scalingDefer(isActive2)
                            return
                        end
                        isActive2()
                    end
                    parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(handleAction)
                    local function handleAction2()
                        argument:_queueFitSubs()
                    end
                    subBar:GetPropertyChangedSignal("AbsoluteSize"):Connect(handleAction2)
                    task.defer(function()
                        argument:_placePill(true)
                    end)
                    argument:_queueFitSubs()
                end
                index._queueFitSubs = function(argument)
                    if argument.FitQueued then
                        return
                    end
                    argument.FitQueued = true
                    task.delay(0.06, function()
                        argument.FitQueued = false
                        local window = argument.Window
                        if window then
                            if window.Destroyed then
                                return
                            end
                        else
                            return
                        end
                        if window.Scaling then
                            window:_scalingDefer(function()
                                argument:_queueFitSubs()
                            end)
                            return
                        end
                        pcall(argument._fitSubs, argument)
                    end)
                end
                index._fitSubs = function(argument)
                    local subBar = argument.SubBar
                    local subPill = argument.SubPill
                    local calculatedValue = subPill and subPill.Parent
                    if subBar and calculatedValue then
                        if not argument.SubButtons then
                            return
                        end
                    else
                        return
                    end
                    subPill = calculatedValue.AbsoluteSize.Y / 36
                    if subPill <= 0.01 then
                        return
                    end
                    local subFitAvail = subBar.AbsoluteSize.X / subPill
                    if subFitAvail < 60 then
                        return
                    end
                    if argument.SubFitAvail then
                        if math.abs(argument.SubFitAvail - subFitAvail) > 2 then
                            argument.SubFitAdj = 1
                        end
                    else
                        argument.SubFitAdj = 1
                    end
                    argument.SubFitAvail = subFitAvail
                    local size, calculatedValue2, calculatedValue3 = argument.SubFitAdj or 1, 0, 0
                    for textSize, item in pairs(argument.SubButtons) do
                        textSize = item.Label.TextSize
                        if textSize <= 0 then
                            return
                        end
                        calculatedValue2, calculatedValue3 =
                            calculatedValue2 + 1,
                            calculatedValue3
                                + item.Label.AbsoluteSize.X / subPill * (item.Base * u.textScale) / textSize
                    end
                    if calculatedValue2 == 0 then
                        return
                    elseif calculatedValue3 <= 0 then
                        return
                    end
                    calculatedValue3 /= size
                    local calculatedValue4, margin, pad, f = (calculatedValue2 - 1) * 2 + 6, 22, 15, 1
                    if calculatedValue3 + calculatedValue2 * 30 + calculatedValue4 + 44 > subFitAvail then
                        margin, pad =
                            10,
                            math.floor(
                                (subFitAvail - 20 - calculatedValue4 - calculatedValue3) / (2 * calculatedValue2)
                            )
                        if pad >= 6 then
                            pad = math.min(pad, 15)
                        else
                            pad, f =
                                6, (subFitAvail - 20 - calculatedValue4 - calculatedValue2 * 12) / calculatedValue3
                            if f < 0.75 then
                                margin, pad, f =
                                    4,
                                    3,
                                    (subFitAvail - 8 - calculatedValue4 - calculatedValue2 * 6) / calculatedValue3
                            else
                            end
                            f = math.clamp(f, 0.6, 1)
                        end
                    else
                    end
                    subPill = false
                    if calculatedValue.Position.X.Offset ~= margin then
                        calculatedValue.Position = UDim2.fromOffset(margin, 6)
                        subPill = true
                    else
                    end
                    for key, item in pairs(argument.SubButtons) do
                        if item.Pad then
                            if item.Pad.PaddingLeft.Offset ~= pad then
                                item.Pad.PaddingLeft, item.Pad.PaddingRight = UDim.new(0, pad), UDim.new(0, pad)
                                subPill = true
                            else
                            end
                        else
                        end
                        size, key = math.max(8, math.floor(item.Base * f + 0.5)), u.textReg[item.Label]
                        if key then
                            if key.size ~= size then
                                key.size = size
                                font.sizeOne(item.Label)
                                subPill = true
                            else
                            end
                        else
                        end
                    end
                    argument.SubFit = { margin = margin, pad = pad, f = f }
                    if subPill then
                        task.defer(function()
                            argument:_placePill(true)
                        end)
                    end
                    task.delay(0.08, function()
                        if calculatedValue.Parent then
                            if not subBar.Parent then
                                return
                            end
                        else
                            return
                        end
                        local calculatedValue5 = calculatedValue.AbsoluteSize.Y / 36
                        if calculatedValue5 <= 0.01 then
                            return
                        end
                        if
                            (
                                    calculatedValue.AbsolutePosition.X
                                    + calculatedValue.AbsoluteSize.X
                                    - subBar.AbsolutePosition.X
                                )
                                / calculatedValue5
                            > subBar.AbsoluteSize.X / calculatedValue5 - 2
                        then
                            if (argument.SubFitAdj or 1) > 0.8 then
                                argument.SubFitAdj = (argument.SubFitAdj or 1) - 0.04
                                pcall(argument._fitSubs, argument)
                            end
                        end
                    end)
                end
                index._placePill = function(argument, argument2)
                    local calculatedValue = argument.SubButtons and argument.SubButtons[argument.ActiveSub]
                    if calculatedValue then
                        if argument.SubPill then
                            if not argument.SubPill.Parent then
                                return
                            end
                        else
                            return
                        end
                    else
                        return
                    end
                    local parent = argument.SubPill.Parent
                    local calculatedValue2 = parent.AbsoluteSize.Y / 36
                    if calculatedValue2 <= 0.01 then
                        return
                    end
                    local calculatedValue3, calculatedValue4 =
                        (calculatedValue.Button.AbsolutePosition.X - parent.AbsolutePosition.X) / calculatedValue2,
                        calculatedValue.Button.AbsoluteSize.X / calculatedValue2
                    if calculatedValue4 <= 1 then
                        return
                    end
                    parent = {
                        Position = UDim2.fromOffset(calculatedValue3, 3),
                        Size = UDim2.fromOffset(calculatedValue4, 30),
                    }
                    if argument2 then
                        argument.SubPill.Position, argument.SubPill.Size = parent.Position, parent.Size
                    else
                        tweenInstance(
                            argument.SubPill,
                            TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                            parent
                        )
                    end
                    for key, item in pairs(argument.SubButtons) do
                        paint(
                            item.Label,
                            "TextColor3",
                            key == argument.ActiveSub and "Text" or "Muted",
                            argument2 and TweenInfo.new(0) or "Quick"
                        )
                    end
                end
                index.SelectSub = function(argument, activeSub)
                    if argument.SubButtons then
                        if argument.SubButtons[activeSub] then
                            if activeSub == argument.ActiveSub then
                                return
                            end
                        else
                            return
                        end
                    else
                        return
                    end
                    local activeSub2 = argument.ActiveSub
                    argument.ActiveSub = activeSub
                    argument.Window:ClosePopups()
                    argument:_placePill(false)
                    local root, pageResult = argument.Pages[activeSub2], argument:_page(activeSub)
                    if root then
                        root.Root.Visible = false
                    end
                    pageResult.Root.Visible = true
                    pageResult.Root.Position = UDim2.fromOffset(18, 48)
                    root, activeSub2 = pageResult.Root, {}
                    activeSub2.Position = UDim2.fromOffset(0, 48)
                    tweenInstance(root, "Base", activeSub2)
                    task.delay(0.2, function()
                        if argument.ActiveSub == activeSub then
                            argument:_balanceActive()
                        end
                    end)
                    if argument.OnSubChanged then
                        pcall(argument.OnSubChanged, activeSub)
                    end
                end
                index._balance = function(argument, argument2, argument3)
                    if not argument2 then
                        return
                    end
                    local window = argument.Window
                    if window.Destroyed then
                        return
                    elseif not argument2.Root.Visible then
                        return
                    end
                    if not window.Scaling then
                        for unused, item in ipairs(argument.Sections) do
                            if item.Page == argument2 then
                                if item._sync then
                                    if not item.Floating then
                                        pcall(item._sync)
                                    end
                                end
                            end
                        end
                    end
                    if argument2.One then
                        return
                    elseif argument.Columns == 1 then
                        return
                    end
                    if window.Scaling then
                        if (argument3 or 0) < 12 then
                            task.delay(0.25, function()
                                argument:_balance(argument2, (argument3 or 0) + 1)
                            end)
                        end
                        return
                    end
                    local maximumValue, entries2, counter = math.max(window.Scale.Scale, 0.1), {}, 0
                    for k, sec in ipairs(argument.Sections) do
                        if sec.Page == argument2 then
                            if sec.ParentSection then
                            else
                                if sec.Wrap then
                                    if sec.Wrap.Parent then
                                        table.insert(entries2, { sec = sec, k = k })
                                        counter = if sec.Pinned
                                            then counter
                                            else if sec.Floating then counter else counter + 1
                                    else
                                    end
                                else
                                end
                            end
                        else
                        end
                    end
                    if counter == 0 then
                        return
                    end
                    window = {}
                    for key, item in ipairs(entries2) do
                        local sec, calculatedValue = item.sec, 0
                        if sec.Floating then
                            calculatedValue = sec.Slot and sec.Slot.Visible and sec.Slot.AbsoluteSize.Y / maximumValue
                                or 0
                        else
                            if sec.Hidden then
                            else
                                if sec.Wrap.Visible then
                                    key = sec.Wrap.AbsoluteSize.Y / maximumValue
                                    if key < 2 then
                                        if (argument3 or 0) < 12 then
                                            task.delay(0.25, function()
                                                argument:_balance(argument2, (argument3 or 0) + 1)
                                            end)
                                        end
                                        return
                                    end
                                    calculatedValue = key
                                else
                                end
                            end
                        end
                        window[sec] = calculatedValue
                    end
                    maximumValue = { 0, 0 }
                    for side, item in ipairs(entries2) do
                        local sec, sec2 = item.sec
                        if sec.Pinned then
                            sec2 = sec.Side or 1
                        else
                            if sec.Floating then
                                sec2 = sec.Side or 1
                            else
                                side = maximumValue[1] <= maximumValue[2] + 1 and 1 or 2
                                local parent = side == 1 and argument2.Left or argument2.Right
                                if sec.Wrap.Parent ~= parent then
                                    sec.Wrap.Parent = parent
                                end
                                sec.Side = side
                                sec2 = side
                            end
                        end
                        local calculatedValue = sec.Floating and sec.Slot or sec.Wrap
                        if calculatedValue then
                            calculatedValue.LayoutOrder = item.k
                        end
                        if window[sec] > 0 then
                            maximumValue[sec2] = maximumValue[sec2] + (window[sec] + 16)
                        end
                    end
                    argument2.BalancedCount = #entries2
                end
                index._balanceActive = function(argument, argument2)
                    local calculatedValue = argument.Pages[argument.ActiveSub or "_"] or argument.Pages._
                    if not calculatedValue then
                        return
                    end
                    local counter = 0
                    for unused, item in ipairs(argument.Sections) do
                        counter = if item.Page == calculatedValue
                            then if item.ParentSection then counter else counter + 1
                            else counter
                    end
                    if not argument2 then
                        if calculatedValue.BalancedCount == counter then
                            return
                        end
                    end
                    argument:_balance(calculatedValue)
                end
                index._queueBalance = function(argument, argument2)
                    if argument2.BalanceQueued then
                        return
                    end
                    argument2.BalanceQueued = true
                    task.delay(0.4, function()
                        argument2.BalanceQueued = false
                        if argument.Window.Current == argument then
                            if argument2.Root.Visible then
                                argument:_balanceActive()
                            end
                        end
                    end)
                end
                index.Section = function(tab, title)
                    if type(title) == "string" then
                        title = { Title = title }
                    else
                    end
                    local calculatedValue = title or {}
                    local window = tab.Window
                    local head = calculatedValue.Sub
                        or tab.SubDefs and (calculatedValue.Sub or tab.BuildSub or tab.SubDefs[1].key)
                    local page, headHit = tab:_page(head or "_"), calculatedValue.Side
                    local body, setmetatableResult =
                        if tab.Columns == 1
                            then page.Left
                            else if page.One
                                then page.Left
                                else if headHit == "Right"
                                    then page.Right
                                    else if headHit == "Left"
                                        then page.Left
                                        else page.Load[1] <= page.Load[2] and page.Left or page.Right,
                        setmetatable({}, index2)
                    setmetatableResult.Tab = tab
                    setmetatableResult.Window = window
                    setmetatableResult.Page = page
                    setmetatableResult.Side = body == page.Left and 1 or 2
                    setmetatableResult.Pinned = headHit ~= nil
                    setmetatableResult.Rows = {}
                    setmetatableResult.Order = 0
                    setmetatableResult.Key = tab.Name .. "/" .. tostring(calculatedValue.Title or "Section")
                    tab.KeyCount = tab.KeyCount or {}
                    headHit = (tab.KeyCount[setmetatableResult.Key] or 0) + 1
                    tab.KeyCount[setmetatableResult.Key] = headHit
                    if headHit > 1 then
                        setmetatableResult.Key = setmetatableResult.Key .. "#" .. headHit
                    end
                    table.insert(tab.Sections, setmetatableResult)
                    local wrap = createInstance(
                        "Frame",
                        {
                            Name = calculatedValue.Title or "Section",
                            Size = UDim2.new(1, 0, 0, 44),
                            BackgroundTransparency = 1,
                            LayoutOrder = #body:GetChildren(),
                            Parent = body,
                        }
                    )
                    setmetatableResult.Wrap = wrap
                    setmetatableResult.Shadow = tex.image(
                        wrap,
                        "shadow9",
                        {
                            Name = "Shadow",
                            Position = UDim2.fromOffset(-28, -18),
                            Size = UDim2.new(1, 56, 1, 58),
                            SliceScale = 1,
                            ImageTransparency = 0.62,
                            ZIndex = 0,
                        }
                    )
                    local card = createInstance(
                        "Frame",
                        {
                            Name = "Card",
                            Size = UDim2.new(1, 0, 0, 44),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 0.03,
                            ClipsDescendants = true,
                            ZIndex = 1,
                            Parent = wrap,
                        }
                    )
                    bindTheme(card, "BackgroundColor3", "Surface")
                    u.corner(card, 14)
                    setmetatableResult.CardGrad = createInstance(
                        "UIGradient",
                        { Color = ColorSequence.new(color, Color3.fromRGB(208, 210, 218)), Rotation = 90, Parent = card }
                    )
                    setmetatableResult.Card = card
                    setmetatableResult.Gloss = tex.image(
                        card,
                        "gloss9",
                        { Name = "Gloss", Size = UDim2.fromScale(1, 1), SliceScale = 1, ImageTransparency = 0.9, ZIndex = 1 }
                    )
                    setmetatableResult.Grain = tex.image(
                        card,
                        "grain",
                        { Name = "Grain", Size = UDim2.fromScale(1, 1), ImageTransparency = 0.94, ZIndex = 1 }
                    )
                    setmetatableResult.Spot = tex.image(
                        card,
                        "glow",
                        {
                            Name = "Spot",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Size = UDim2.fromOffset(300, 220),
                            ImageTransparency = 1,
                            ZIndex = 1,
                        }
                    )
                    if setmetatableResult.Spot then
                        bindTheme(setmetatableResult.Spot, "ImageColor3", "Accent")
                    end
                    setmetatableResult.Rim = tex.image(
                        card,
                        "rim9",
                        { Name = "Rim", Size = UDim2.fromScale(1, 1), SliceScale = 1, ImageTransparency = 0.5, ZIndex = 8 }
                    )
                    if setmetatableResult.Rim then
                        bindTheme(setmetatableResult.Rim, "ImageColor3", "Glass")
                    else
                        bindTheme(u.stroke(card, color, 1, 0.92), "Color", "Glass")
                    end
                    local parent = createInstance(
                        "Frame",
                        {
                            Name = "Stack",
                            Size = UDim2.new(1, 0, 0, 0),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundTransparency = 1,
                            ZIndex = 2,
                            Parent = card,
                        }
                    )
                    u.list(parent, 0)
                    setmetatableResult._sync = function()
                        if window.Scaling then
                            if not setmetatableResult.Floating then
                                window:_scalingDefer(setmetatableResult._sync)
                                return
                            end
                        end
                        local roundedValue = math.ceil(parent.AbsoluteSize.Y / math.max(window.Scale.Scale, 0.1))
                        if roundedValue < 1 then
                            return
                        end
                        card.Size = UDim2.new(1, 0, 0, roundedValue)
                        wrap.Size = UDim2.new(wrap.Size.X.Scale, wrap.Size.X.Offset, 0, roundedValue)
                    end
                    parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(setmetatableResult._sync)
                    head = createInstance(
                        "Frame",
                        {
                            Name = "Head",
                            Size = UDim2.new(1, 0, 0, 44),
                            BackgroundTransparency = 1,
                            LayoutOrder = 0,
                            ZIndex = 3,
                            Parent = parent,
                        }
                    )
                    setmetatableResult.Head = head
                    body = 16
                    if calculatedValue.Icon then
                        setmetatableResult.IconTile = localization2.tile(
                            head,
                            {
                                Name = "IconTile",
                                Size = UDim2.fromOffset(26, 26),
                                Pos = UDim2.new(0, 12, 0.5, 0),
                                Anchor = Vector2.new(0, 0.5),
                                Color = "Accent",
                                Alpha = 0.78,
                                Z = 3,
                            }
                        )
                        setmetatableResult.HeadIcon = icon({
                            Parent = head,
                            Icon = calculatedValue.Icon,
                            Size = 15,
                            Pos = UDim2.new(0, 25, 0.5, 0),
                            Anchor = Vector2.new(0.5, 0.5),
                            Color = "Accent",
                            Z = 4,
                        })
                        body = 46
                    else
                    end
                    setmetatableResult.TitleLabel = label({
                        Parent = head,
                        Text = calculatedValue.Title or "Section",
                        Font = font.Bold(),
                        Size = 14,
                        Pos = UDim2.new(0, body, 0, 0),
                        Box = UDim2.new(1, -body - 52, 1, 0),
                        Truncate = true,
                        Z = 4,
                    })
                    setmetatableResult.Accessory = createInstance(
                        "Frame",
                        {
                            Name = "Accessory",
                            AnchorPoint = Vector2.new(1, 0.5),
                            Position = UDim2.new(1, -34, 0.5, 0),
                            Size = UDim2.fromOffset(0, 24),
                            AutomaticSize = Enum.AutomaticSize.X,
                            BackgroundTransparency = 1,
                            ZIndex = 9,
                            Parent = head,
                        }
                    )
                    u.list(
                        setmetatableResult.Accessory,
                        6,
                        Enum.FillDirection.Horizontal,
                        Enum.HorizontalAlignment.Right,
                        Enum.VerticalAlignment.Center
                    )
                    setmetatableResult.Chev = icon({
                        Parent = head,
                        Icon = "chevron-down",
                        Size = 14,
                        Pos = UDim2.new(1, -16, 0.5, 0),
                        Anchor = Vector2.new(0.5, 0.5),
                        Color = "Faint",
                        Z = 4,
                    })
                    setmetatableResult.HeadLine = createInstance(
                        "Frame",
                        {
                            Name = "Line",
                            AnchorPoint = Vector2.new(0.5, 1),
                            Position = UDim2.new(0.5, 0, 1, 0),
                            Size = UDim2.new(1, -28, 0, 1),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 0.5,
                            ZIndex = 3,
                            Parent = head,
                        }
                    )
                    bindTheme(setmetatableResult.HeadLine, "BackgroundColor3", "Line")
                    createInstance(
                        "UIGradient",
                        {
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 1),
                                NumberSequenceKeypoint.new(0.12, 0),
                                NumberSequenceKeypoint.new(0.88, 0),
                                NumberSequenceKeypoint.new(1, 1),
                            }),
                            Parent = setmetatableResult.HeadLine,
                        }
                    )
                    headHit = createInstance(
                        "TextButton",
                        {
                            Name = "Hit",
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            Size = UDim2.fromScale(1, 1),
                            ZIndex = 6,
                            Parent = head,
                        }
                    )
                    setmetatableResult.HeadHit = headHit
                    local function handleAction(argument)
                        if argument.UserInputType ~= Enum.UserInputType.MouseButton1 then
                            if argument.UserInputType ~= Enum.UserInputType.Touch then
                                return
                            end
                        end
                        window:_cardPress(setmetatableResult, argument)
                    end
                    headHit.InputBegan:Connect(handleAction)
                    local function getResult()
                        if window.CardDrag then
                            return
                        elseif os.clock() - (window.LastCardDrag or 0) < 0.3 then
                            return
                        end
                        if calculatedValue.Collapsible == false then
                            return
                        end
                        sound.play("tick")
                        setmetatableResult:SetCollapsed(not setmetatableResult.Collapsed)
                    end
                    headHit.MouseButton1Click:Connect(getResult)
                    local function handleAction()
                        if calculatedValue.Collapsible ~= false then
                            paint(setmetatableResult.Chev, "ImageColor3", "Text", "Quick")
                        end
                        window:ShowTip("Drag out to float · click to fold")
                    end
                    headHit.MouseEnter:Connect(handleAction)
                    u.leave(headHit, function()
                        paint(setmetatableResult.Chev, "ImageColor3", "Faint", "Quick")
                        window:HideTip()
                    end)
                    if calculatedValue.Collapsible == false then
                        setmetatableResult.Chev.Visible = false
                    end
                    body = createInstance(
                        "Frame",
                        {
                            Name = "Body",
                            Size = UDim2.new(1, 0, 0, 0),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundTransparency = 1,
                            ClipsDescendants = true,
                            LayoutOrder = 1,
                            ZIndex = 2,
                            Parent = parent,
                        }
                    )
                    setmetatableResult.Body = body
                    head = createInstance(
                        "Frame",
                        {
                            Name = "Content",
                            Size = UDim2.new(1, 0, 0, 0),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundTransparency = 1,
                            ZIndex = 2,
                            Parent = body,
                        }
                    )
                    u.list(head, 0)
                    u.pad(head, 6, 6, 10, 6)
                    setmetatableResult.Content = head
                    local function handleAction2()
                        if setmetatableResult.Spot then
                            local unused = setmetatableResult.Floating
                        else
                            return
                        end
                        local mouseResult, maximumValue = u.mouse(), math.max(window.Scale.Scale, 0.1)
                        local calculatedValue = (mouseResult - card.AbsolutePosition) / maximumValue
                        setmetatableResult.Spot.Position = UDim2.fromOffset(calculatedValue.X, calculatedValue.Y)
                    end
                    card.MouseMoved:Connect(handleAction2)
                    local function getResult2()
                        if setmetatableResult.Spot then
                            tweenInstance(setmetatableResult.Spot, "Base", { ImageTransparency = 0.9 })
                        end
                        if setmetatableResult.Rim then
                            tweenInstance(setmetatableResult.Rim, "Quick", { ImageTransparency = 0.25 })
                        end
                    end
                    card.MouseEnter:Connect(getResult2)
                    u.leave(card, function()
                        if setmetatableResult.Spot then
                            tweenInstance(setmetatableResult.Spot, "Base", { ImageTransparency = 1 })
                        end
                        if setmetatableResult.Rim then
                            local rim, entries = setmetatableResult.Rim, {}
                            entries.ImageTransparency = setmetatableResult.Floating and 0.3 or 0.5
                            tweenInstance(rim, "Quick", entries)
                        end
                    end)
                    page.Load[setmetatableResult.Side] += 1
                    tab:_queueBalance(page)
                    window:_applyCardStyle(setmetatableResult)
                    getResult = window.State.get("collapsed", {})
                    if type(getResult) == "table" then
                        if getResult[setmetatableResult.Key] then
                            setmetatableResult:SetCollapsed(true, true)
                        end
                    end
                    getResult2 = window.State.get("floats", {})
                    if type(getResult2) == "table" and getResult2[setmetatableResult.Key] then
                        local entry = getResult2[setmetatableResult.Key]
                        task.delay(0.8, function()
                            if not setmetatableResult.Floating then
                                if not window.Destroyed then
                                    pcall(function()
                                        window:FloatSection(
                                            setmetatableResult,
                                            Vector2.new(tonumber(entry[1]) or 40, tonumber(entry[2]) or 40)
                                        )
                                    end)
                                end
                            end
                        end)
                    end
                    return setmetatableResult
                end
                index2.SetTitle = function(argument, argument2)
                    argument.TitleLabel.Text = tostring(argument2)
                end
                index2._refreshVisibility = function(argument)
                    local enabled = false
                    for unused, item in ipairs(argument.Rows) do
                        if item.Frame.Visible then
                            enabled = true
                            break
                        end
                    end
                    local calculatedValue = argument.Window.Query or ""
                    if argument.Floating then
                        argument.Wrap.Visible = not argument.Hidden
                    else
                        local wrap, hidden = argument.Wrap, argument.Hidden
                        wrap.Visible = if hidden then not hidden else calculatedValue == "" or enabled
                    end
                end
                index2.SetVisible = function(argument, argument2)
                    argument.Hidden = not argument2
                    argument:_refreshVisibility()
                end
                index2.SetCollapsed = function(argument, collapsed, argument2)
                    collapsed = collapsed and true or false
                    if collapsed == argument.Collapsed then
                        return
                    end
                    argument.Collapsed = collapsed
                    local window = argument.Window
                    local collapsed2 = window.State.get("collapsed", {})
                    collapsed2 = if type(collapsed2) ~= "table" then {} else collapsed2
                    collapsed2[argument.Key] = collapsed or nil
                    window.State.data.collapsed = collapsed2
                    window.State.save()
                    local body = argument.Body
                    local content, maximumValue = argument.Content, math.max(window.Scale.Scale, 0.1)
                    argument.BodyToken = (argument.BodyToken or 0) + 1
                    local bodyToken = argument.BodyToken
                    local calculatedValue, chev, entries =
                        (argument2 or not motion.enabled) and TweenInfo.new(0) or "Base", argument.Chev, {}
                    entries.Rotation = collapsed and -90 or 0
                    tweenInstance(chev, calculatedValue, entries)
                    chev, entries = argument.HeadLine, {}
                    entries.BackgroundTransparency = collapsed and 1 or 0.5
                    tweenInstance(chev, calculatedValue, entries)
                    calculatedValue = math.ceil(content.AbsoluteSize.Y / maximumValue) + 16
                    if collapsed then
                        body.AutomaticSize = Enum.AutomaticSize.None
                        body.Size = UDim2.new(1, 0, 0, argument2 and 0 or calculatedValue)
                        if not argument2 then
                            tweenInstance(body, tweenInfo, { Size = UDim2.new(1, 0, 0, 0) })
                        end
                    else
                        body.AutomaticSize = Enum.AutomaticSize.None
                        if argument2 then
                            body.AutomaticSize = Enum.AutomaticSize.Y
                            body.Size = UDim2.new(1, 0, 0, 0)
                        else
                            tweenInstance(body, tweenInfo, { Size = UDim2.new(1, 0, 0, calculatedValue) })
                            task.delay(0.34, function()
                                if argument.BodyToken == bodyToken then
                                    if not argument.Collapsed then
                                        body.AutomaticSize = Enum.AutomaticSize.Y
                                        body.Size = UDim2.new(1, 0, 0, 0)
                                    end
                                end
                            end)
                        end
                    end
                end
                index2.IsCollapsed = function(argument)
                    return argument.Collapsed == true
                end
                index2.Float = function(argument, argument2)
                    argument.Window:FloatSection(argument, argument2)
                end
                index2.Dock = function(argument)
                    argument.Window:DockSection(argument)
                end
                index2._row = function(sec, opts)
                    sec.Order = sec.Order + 1
                    sec.Tab.Loads[sec.Page.Key] = (sec.Tab.Loads[sec.Page.Key] or 0) + 1
                    if not sec.ParentSection then
                        sec.Page.Load[sec.Side] += 1
                    end
                    local window = sec.Window
                    local text2, calculatedValue = opts.Desc, sec.Nested == true
                    local calculatedValue2 = opts.Height
                        or (text2 and (calculatedValue and 46 or 50) or (calculatedValue and 33 or 38))
                    local indent, frame =
                        (opts.Indent or 0) * 14,
                        createInstance(
                            "Frame",
                            {
                                Name = opts.Name or "Row",
                                Size = UDim2.new(1, 0, 0, calculatedValue2),
                                BackgroundTransparency = 1,
                                LayoutOrder = opts.Order or sec.Order,
                                Parent = opts.Parent or sec.Content,
                            }
                        )
                    local hover = createInstance(
                        "Frame",
                        {
                            Name = "Hover",
                            Position = UDim2.fromOffset(indent, 1),
                            Size = UDim2.new(1, -indent, 1, -2),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 1,
                            Parent = frame,
                        }
                    )
                    bindTheme(hover, "BackgroundColor3", "Elevated")
                    u.corner(hover, 9)
                    if indent > 0 then
                        local value = createInstance(
                            "Frame",
                            {
                                Name = "Guide",
                                Position = UDim2.fromOffset(indent - 6, 8),
                                Size = UDim2.new(0, 2, 1, -16),
                                BorderSizePixel = 0,
                                Parent = frame,
                            }
                        )
                        bindTheme(value, "BackgroundColor3", theme.accentSoft(0.45))
                        u.corner(value, UDim.new(1, 0))
                    end
                    local row = { Frame = frame, Hover = hover, Section = sec, Opts = opts, Indent = indent }
                    local calculatedValue3 = 10 + indent
                    row.Title = label({
                        Parent = frame,
                        Text = opts.Text or "",
                        Font = font.Medium(),
                        Size = calculatedValue and 13 or 14,
                        Color = calculatedValue and function(argument)
                            return argument.Text:Lerp(argument.Muted, 0.22)
                        end or nil,
                        Pos = UDim2.fromOffset(calculatedValue3, text2 and 8 or 0),
                        Box = UDim2.new(
                            1,
                            -(calculatedValue3 + (opts.Reserve or 70)),
                            0,
                            text2 and 18 or calculatedValue2
                        ),
                        Truncate = true,
                        Rich = opts.Rich,
                    })
                    if text2 then
                        row.Desc = label({
                            Parent = frame,
                            Text = text2,
                            Font = font.Regular(),
                            Size = 12,
                            Pos = UDim2.fromOffset(calculatedValue3, 27),
                            Box = UDim2.new(1, -(calculatedValue3 + (opts.Reserve or 70)), 0, 16),
                            Color = "Muted",
                            Truncate = true,
                        })
                    end
                    row.Right = createInstance(
                        "Frame",
                        {
                            Name = "Right",
                            AnchorPoint = Vector2.new(1, 0.5),
                            Position = UDim2.new(1, -10, 0.5, 0),
                            Size = UDim2.fromOffset(0, 28),
                            AutomaticSize = Enum.AutomaticSize.X,
                            BackgroundTransparency = 1,
                            ZIndex = 2,
                            Parent = frame,
                        }
                    )
                    u.list(
                        row.Right,
                        8,
                        Enum.FillDirection.Horizontal,
                        Enum.HorizontalAlignment.Right,
                        Enum.VerticalAlignment.Center
                    )
                    local calculatedValue4, calculatedValue5, calculatedValue6, fitTitle = (
                        if text2 then not text2 else not opts.Height
                    )
                            and opts.Wrap ~= false
                            and (calculatedValue and 46 or 52)
                        or nil
                    local function handleAction()
                        if not calculatedValue4 then
                            return
                        end
                        local title = row.Title
                        local calculatedValue = title.Text
                            .. "|"
                            .. tostring(title.TextSize)
                            .. "|"
                            .. tostring(title.FontFace)
                        if calculatedValue == calculatedValue6 then
                            return
                        end
                        calculatedValue6 = calculatedValue
                        task.spawn(function()
                            local textWidthResult = u.textWidth(title.Text, title.FontFace, title.TextSize)
                            if calculatedValue6 == calculatedValue then
                                calculatedValue5 = textWidthResult
                                if fitTitle then
                                    fitTitle()
                                end
                            end
                        end)
                    end
                    fitTitle = function()
                        if window.Scaling then
                            window:_scalingDefer(fitTitle)
                            return
                        end
                        local wrapped = math.max(window.Scale.Scale, 0.1)
                        if row.OnWidth then
                            row.OnWidth(frame.AbsoluteSize.X / wrapped)
                        end
                        if opts.Reserve == 0 then
                            return
                        elseif not row.Right.Visible then
                            return
                        end
                        local calculatedValue = row.Right.AbsoluteSize.X / wrapped
                        local calculatedValue6, offset =
                            frame.AbsoluteSize.X / wrapped - calculatedValue3 - calculatedValue - 16,
                            row.Title.Size.Y.Offset
                        if calculatedValue4 then
                            if calculatedValue5 then
                                calculatedValue = calculatedValue5
                                wrapped = calculatedValue > math.max(calculatedValue6, 40) + 1
                                if wrapped ~= (row.wrapped == true) then
                                    row.wrapped = wrapped
                                    row.Title.TextWrapped = wrapped
                                    frame.Size =
                                        UDim2.new(1, 0, 0, wrapped and calculatedValue4 or calculatedValue2)
                                end
                                offset = wrapped and calculatedValue4 or calculatedValue2
                            else
                            end
                        else
                        end
                        row.Title.Size =
                            UDim2.new(0, math.max(calculatedValue6, 40), row.Title.Size.Y.Scale, offset)
                        if row.Desc then
                            row.Desc.Size = UDim2.new(0, math.max(calculatedValue6, 40), 0, 16)
                        end
                    end
                    row.fitTitle = fitTitle
                    row.Right:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitTitle)
                    frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(fitTitle)
                    if calculatedValue4 then
                        row.Title:GetPropertyChangedSignal("Text"):Connect(handleAction)
                        row.Title:GetPropertyChangedSignal("TextSize"):Connect(handleAction)
                        row.Title:GetPropertyChangedSignal("FontFace"):Connect(handleAction)
                        task.defer(handleAction)
                    end
                    task.defer(fitTitle)
                    row.selfHidden = false
                    row.parentHidden = false
                    row.searchHidden = false
                    local entry = {
                        sec = sec,
                        searchHidden = false,
                        row = row,
                        text = function()
                            local calculatedValue7 = row.Title and row.Title.Text or ""
                            calculatedValue7 = if row.Desc
                                then calculatedValue7 .. " " .. row.Desc.Text
                                else calculatedValue7
                            calculatedValue7 = if row.SearchExtra
                                then calculatedValue7 .. " " .. row.SearchExtra()
                                else calculatedValue7
                            return string.lower(calculatedValue7)
                        end,
                    }
                    row.isVisible = function()
                        return not (row.selfHidden or row.parentHidden or entry.searchHidden)
                    end
                    entry.refresh = function()
                        frame.Visible = row.isVisible()
                        if row.OnRefresh then
                            row.OnRefresh()
                        end
                    end
                    row.Entry = entry
                    table.insert(sec.Tab.Rows, entry)
                    table.insert(sec.Rows, row)
                    row.setHover = function(argument)
                        tweenInstance(hover, "Quick", { BackgroundTransparency = argument and 0.55 or 1 })
                    end
                    local function handleAction()
                        row.setHover(true)
                        if opts.Tooltip then
                            window:ShowTip(opts.Tooltip)
                        end
                    end
                    frame.MouseEnter:Connect(handleAction)
                    u.leave(frame, function()
                        row.setHover(false)
                        if opts.Tooltip then
                            window:HideTip()
                        end
                    end)
                    row.SetText = function(argument)
                        row.Title.Text = tostring(argument)
                    end
                    row.SetDesc = function(argument)
                        if row.Desc then
                            row.Desc.Text = tostring(argument)
                        end
                    end
                    row.SetVisible = function(argument)
                        row.selfHidden = not argument
                        entry.refresh()
                        sec:_refreshVisibility()
                    end
                    row.SetParentHidden = function(argument)
                        row.parentHidden = argument and true or false
                        entry.refresh()
                        sec:_refreshVisibility()
                    end
                    row.hit = function()
                        return (
                            createInstance(
                                "TextButton",
                                {
                                    Name = "Hit",
                                    Text = "",
                                    AutoButtonColor = false,
                                    BackgroundTransparency = 1,
                                    Size = UDim2.fromScale(1, 1),
                                    ZIndex = 1,
                                    Parent = frame,
                                }
                            )
                        )
                    end
                    return row
                end
                windowClass.CardStyles = { "Glass", "Frosted", "Tinted", "Flat" }
                windowClass._applyCardStyle = function(resolveResult, argument)
                    local calculatedValue, card = resolveResult.CardStyle or "Glass", argument.Card
                    if not card then
                        return
                    end
                    resolveResult = theme.resolve("Accent")
                    if calculatedValue == "Flat" then
                        card.BackgroundTransparency = 0
                        argument.CardGrad.Color = ColorSequence.new(color)
                        if argument.Gloss then
                            argument.Gloss.ImageTransparency = 1
                        end
                        if argument.Grain then
                            argument.Grain.ImageTransparency = 1
                        end
                    elseif calculatedValue == "Frosted" then
                        card.BackgroundTransparency = 0.32
                        argument.CardGrad.Color = ColorSequence.new(color, Color3.fromRGB(220, 222, 230))
                        if argument.Gloss then
                            argument.Gloss.ImageTransparency = 0.72
                        end
                        if argument.Grain then
                            argument.Grain.ImageTransparency = 0.9
                        end
                    elseif calculatedValue == "Tinted" then
                        card.BackgroundTransparency = 0.03
                        argument.CardGrad.Color =
                            ColorSequence.new(color:Lerp(resolveResult, 0.05), color:Lerp(resolveResult, 0.34))
                        if argument.Gloss then
                            argument.Gloss.ImageTransparency = 0.88
                        end
                        if argument.Grain then
                            argument.Grain.ImageTransparency = 0.94
                        end
                    else
                        card.BackgroundTransparency = 0.03
                        argument.CardGrad.Color = ColorSequence.new(color, Color3.fromRGB(208, 210, 218))
                        if argument.Gloss then
                            argument.Gloss.ImageTransparency = 0.9
                        end
                        if argument.Grain then
                            argument.Grain.ImageTransparency = 0.94
                        end
                    end
                end
                windowClass.SetCardStyle = function(argument, cardStyle)
                    localization2.trace("SetCardStyle")
                    for unused, item in ipairs(windowClass.CardStyles) do
                        if item == cardStyle then
                            argument.CardStyle = cardStyle
                            argument.State.set("cardStyle", cardStyle)
                            for unused, item2 in ipairs(argument.TabList) do
                                for unused, item in ipairs(item2.Sections) do
                                    argument:_applyCardStyle(item)
                                end
                            end
                            return
                        end
                    end
                end
                windowClass._nextZ = function(argument)
                    argument.FloatZ = argument.FloatZ + 1
                    return argument.FloatZ
                end
                windowClass._initCards = function(argument)
                    u.connect(userInputService.InputChanged, function(argument2)
                        if argument.CardPress then
                            if u.sameMove(argument2, argument.CardPress.input) then
                                argument:_cardMove()
                            end
                        end
                    end, argument.Conns)
                    u.connect(userInputService.InputEnded, function(argument2)
                        if u.sameEnd(argument2, argument.CardPress and argument.CardPress.input) then
                            argument:_cardEnd()
                        end
                    end, argument.Conns)
                end
                windowClass._cardPress = function(argument, sec, input)
                    argument.CardPress = { sec = sec, at = u.at(input), t = os.clock(), input = input }
                    if sec.Floating then
                        sec.Wrap.ZIndex = argument:_nextZ()
                    end
                end
                windowClass._cardMove = function(argument)
                    local cardDrag = argument.CardPress
                    if not cardDrag then
                        return
                    end
                    local sec, slotGlow, maximumValue =
                        cardDrag.sec, u.at(cardDrag.input), math.max(argument.FloatScale.Scale, 0.1)
                    if not argument.CardDrag then
                        local magnitude = (slotGlow - cardDrag.at).Magnitude
                        if sec.Floating then
                            if magnitude < 4 then
                                return
                            end
                        else
                            if argument.IsTouch then
                                if os.clock() - cardDrag.t < 0.35 then
                                    if magnitude >= 10 then
                                        argument.CardPress = nil
                                    end
                                    return
                                end
                            end
                            if magnitude < 12 then
                                return
                            elseif os.clock() - cardDrag.t < 0.08 then
                                return
                            end
                            argument:FloatSection(
                                sec,
                                (sec.Card.AbsolutePosition - argument.FloatLayer.AbsolutePosition) / maximumValue
                            )
                            sound.play("click", 0.8)
                        end
                        magnitude = (sec.Wrap.AbsolutePosition - argument.FloatLayer.AbsolutePosition)
                            / maximumValue
                        argument.CardDrag = {
                            sec = sec,
                            grab = (slotGlow - argument.FloatLayer.AbsolutePosition) / maximumValue - magnitude,
                            fresh = not sec.WasFloating,
                        }
                        argument:HideTip()
                        tweenInstance(sec.Shadow, "Quick", { ImageTransparency = 0.25 })
                    end
                    cardDrag = argument.CardDrag
                    local point, calculatedValue, nearSlot =
                        (slotGlow - argument.FloatLayer.AbsolutePosition) / maximumValue - cardDrag.grab,
                        argument.FloatLayer.AbsoluteSize / maximumValue,
                        sec.Wrap.AbsoluteSize / maximumValue
                    point = Vector2.new(
                        math.clamp(point.X, 8 - nearSlot.X + 80, calculatedValue.X - 80),
                        math.clamp(point.Y, 4, calculatedValue.Y - 40)
                    )
                    sec.Wrap.Position = UDim2.fromOffset(point.X, point.Y)
                    if sec.Slot then
                        if sec.SlotStroke then
                            cardDrag, calculatedValue =
                                sec.Slot.AbsolutePosition + sec.Slot.AbsoluteSize / 2,
                                sec.Wrap.AbsolutePosition + Vector2.new(
                                    sec.Wrap.AbsoluteSize.X / 2,
                                    math.min(sec.Wrap.AbsoluteSize.Y / 2, 40)
                                )
                            nearSlot = argument.IsOpen
                                and sec.Tab == argument.Current
                                and (cardDrag - calculatedValue).Magnitude < 110 * maximumValue
                            if nearSlot ~= sec.NearSlot then
                                sec.NearSlot = nearSlot
                                local slotStroke, entries2 = sec.SlotStroke, {}
                                entries2.Transparency = nearSlot and 0.2 or 0.86
                                tweenInstance(slotStroke, "Quick", entries2)
                                if sec.SlotGlow then
                                    slotGlow, slotStroke = sec.SlotGlow, {}
                                    slotStroke.ImageTransparency = nearSlot and 0.7 or 1
                                    tweenInstance(slotGlow, "Quick", slotStroke)
                                end
                            end
                        end
                    end
                end
                windowClass._cardEnd = function(argument)
                    local unused = argument.CardPress
                    argument.CardPress = nil
                    local cardDrag = argument.CardDrag
                    if not cardDrag then
                        return
                    end
                    argument.CardDrag = nil
                    argument.LastCardDrag = os.clock()
                    local sec = cardDrag.sec
                    tweenInstance(sec.Shadow, "Base", { ImageTransparency = 0.3 })
                    if sec.NearSlot then
                        sec.NearSlot = false
                        argument:DockSection(sec)
                        return
                    end
                    local position, floats = sec.Wrap.Position, argument.State.get("floats", {})
                    floats = if type(floats) ~= "table" then {} else floats
                    floats[sec.Key] = { math.floor(position.X.Offset), math.floor(position.Y.Offset) }
                    argument.State.data.floats = floats
                    argument.State.save()
                end
                windowClass.FloatSection = function(argument, argument2, floats)
                    localization2.trace("FloatSection")
                    if argument2.Floating then
                        return
                    elseif argument.Destroyed then
                        return
                    end
                    local wrap, unused, maximumValue =
                        argument2.Wrap, argument2.Card, math.max(argument.FloatScale.Scale, 0.1)
                    local calculatedValue = wrap.AbsoluteSize / maximumValue
                    local slot = createInstance(
                        "Frame",
                        {
                            Name = "Slot",
                            Size = UDim2.new(1, 0, 0, math.max(44, calculatedValue.Y)),
                            LayoutOrder = wrap.LayoutOrder,
                            BackgroundTransparency = 1,
                            Parent = wrap.Parent,
                        }
                    )
                    local parent = createInstance(
                        "Frame",
                        {
                            Name = "Ghost",
                            Size = UDim2.new(1, -4, 1, -4),
                            Position = UDim2.fromOffset(2, 2),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 0.6,
                            Parent = slot,
                        }
                    )
                    bindTheme(parent, "BackgroundColor3", "Surface")
                    u.corner(parent, 14)
                    argument2.SlotStroke = u.stroke(parent, color, 1, 0.86)
                    bindTheme(argument2.SlotStroke, "Color", "Accent")
                    argument2.SlotGlow = tex.image(
                        slot,
                        "glow",
                        {
                            Name = "Glow",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.new(1, 60, 1, 60),
                            ImageTransparency = 1,
                        }
                    )
                    if argument2.SlotGlow then
                        bindTheme(argument2.SlotGlow, "ImageColor3", "Accent")
                    end
                    icon({
                        Parent = parent,
                        Icon = "picture-in-picture-2",
                        Size = 20,
                        Pos = UDim2.fromScale(0.5, 0.42),
                        Anchor = Vector2.new(0.5, 0.5),
                        Color = "Faint",
                    })
                    label({
                        Parent = parent,
                        Text = localization2.tr("Floating · drag back to dock"),
                        Font = font.Medium(),
                        Size = 12,
                        Pos = UDim2.fromScale(0, 0.42),
                        Box = UDim2.new(1, 0, 0, 16),
                        AlignX = Enum.TextXAlignment.Center,
                        Color = "Faint",
                    }).Position =
                        UDim2.new(0, 0, 0.42, 16)
                    argument2.Slot = slot
                    wrap.Parent = argument.FloatLayer
                    wrap.Size = UDim2.new(0, math.floor(calculatedValue.X), 0, math.floor(calculatedValue.Y))
                    calculatedValue = floats
                        or (wrap.AbsolutePosition - argument.FloatLayer.AbsolutePosition) / maximumValue
                    wrap.Position = UDim2.fromOffset(calculatedValue.X, calculatedValue.Y)
                    wrap.ZIndex = argument:_nextZ()
                    argument2.Floating = true
                    argument2.WasFloating = true
                    table.insert(argument.Floats, argument2)
                    if argument2.Shadow then
                        argument2.Shadow.ImageTransparency = 0.3
                    end
                    if argument2.Rim then
                        argument2.Rim.ImageTransparency = 0.3
                    end
                    slot, wrap, parent =
                        createInstance(
                            "TextButton",
                            {
                                Name = "Dock",
                                Text = "",
                                AutoButtonColor = false,
                                BackgroundTransparency = 1,
                                Size = UDim2.fromOffset(24, 24),
                                LayoutOrder = 9,
                                ZIndex = 7,
                                Parent = argument2.Accessory,
                            }
                        ),
                        localization2.tile,
                        { Name = "Face" }
                    parent.Size, parent.Color, parent.Alpha, parent.Z = UDim2.fromScale(1, 1), "Elevated", 0.3, 7
                    wrap(slot, parent)
                    local value = icon({
                        Parent = slot,
                        Icon = "undo-2",
                        Size = 13,
                        Pos = UDim2.fromScale(0.5, 0.5),
                        Anchor = Vector2.new(0.5, 0.5),
                        Color = "Muted",
                        Z = 8,
                    })
                    local function handleAction()
                        paint(value, "ImageColor3", "Text", "Quick")
                        argument:ShowTip("Return to window")
                    end
                    slot.MouseEnter:Connect(handleAction)
                    u.leave(slot, function()
                        paint(value, "ImageColor3", "Muted", "Quick")
                        argument:HideTip()
                    end)
                    local function handleAction2()
                        argument:HideTip()
                        sound.play("click")
                        argument:DockSection(argument2)
                    end
                    slot.MouseButton1Click:Connect(handleAction2)
                    argument2.DockButton = slot
                    argument2:_refreshVisibility()
                    floats = argument.State.get("floats", {})
                    floats = if type(floats) ~= "table" then {} else floats
                    floats[argument2.Key] = { math.floor(calculatedValue.X), math.floor(calculatedValue.Y) }
                    argument.State.data.floats = floats
                    argument.State.save()
                    argument:_refreshTabState(argument2.Tab)
                end
                windowClass.FloatTab = function(argument, argument2, argument3)
                    localization2.trace("FloatTab")
                    argument2 = if type(argument2) == "string" then argument.Tabs[argument2] else argument2
                    if argument2 then
                        if argument.Destroyed then
                            return
                        end
                    else
                        return
                    end
                    local maximumValue = math.max(argument.FloatScale.Scale, 0.1)
                    local calculatedValue, point, calculatedValue2 =
                        argument.FloatLayer.AbsoluteSize / maximumValue,
                        Vector2.new(math.max(12, argument3.X), math.max(12, argument3.Y)),
                        argument.Parking and argument2.Frame.Parent == argument.Parking
                    if calculatedValue2 then
                        argument2.Frame.Visible = false
                        argument2.Frame.Parent = argument.Body
                        if argument2.RefreshGen ~= localization2.Refresh.gen then
                            localization2.Refresh.sync(argument2.Frame)
                            argument2.RefreshGen = localization2.Refresh.gen
                        end
                    end
                    local x, y, minimumValue = point.X, point.Y, math.min(point.X + 640, calculatedValue.X - 24)
                    maximumValue = 0
                    for unused, item in ipairs(argument2.Sections) do
                        if item.Floating then
                        else
                            if item.Hidden then
                            else
                                local calculatedValue3, calculatedValue4, maximumValue2, calculatedValue5 = item.Wrap.AbsoluteSize
                                    / math.max(argument.Scale.Scale, 0.1)
                                if x + calculatedValue3.X > minimumValue then
                                    if x > point.X then
                                        local x2, calculatedValue6, counter = point.X, y + (maximumValue + 14), 0
                                        calculatedValue4, maximumValue2, calculatedValue5 =
                                            x2, counter, calculatedValue6
                                    else
                                        calculatedValue4, maximumValue2, calculatedValue5 = x, maximumValue, y
                                    end
                                else
                                    calculatedValue4, maximumValue2, calculatedValue5 = x, maximumValue, y
                                end
                                argument:FloatSection(
                                    item,
                                    Vector2.new(
                                        math.clamp(
                                            calculatedValue4,
                                            8,
                                            math.max(8, calculatedValue.X - calculatedValue3.X - 8)
                                        ),
                                        math.clamp(calculatedValue5, 8, math.max(8, calculatedValue.Y - 80))
                                    )
                                )
                                calculatedValue4 += calculatedValue3.X + 14
                                maximumValue2 = math.max(maximumValue2, calculatedValue3.Y)
                                x, maximumValue, y = calculatedValue4, maximumValue2, calculatedValue5
                            end
                        end
                    end
                    if calculatedValue2 then
                        if argument.Current ~= argument2 then
                            argument2.Frame.Parent = argument.Parking
                        end
                    end
                    argument:_refreshTabState(argument2)
                end
                windowClass.DockTab = function(argument, argument2)
                    localization2.trace("DockTab")
                    argument2 = if type(argument2) == "string" then argument.Tabs[argument2] else argument2
                    if not argument2 then
                        return
                    end
                    for unused, item in ipairs(argument2.Sections) do
                        if item.Floating then
                            argument:DockSection(item)
                        end
                    end
                    argument:_refreshTabState(argument2)
                end
                windowClass._refreshTabState = function(argument, argument2)
                    if not argument2 or not argument2.PageHost then
                        return
                    end
                    local calculatedValue, counter5 = 0, 0
                    for unused, item in ipairs(argument2.Sections) do
                        if item.Hidden then
                        else
                            calculatedValue, counter5 =
                                calculatedValue + 1, if item.Floating then counter5 + 1 else counter5
                        end
                    end
                    local visible = calculatedValue > 0 and counter5 == calculatedValue
                    if visible and not argument2.EmptyState then
                        local emptyState = createInstance(
                            "Frame",
                            {
                                Name = "Popped",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = UDim2.fromScale(0.5, 0.45),
                                Size = UDim2.fromOffset(240, 150),
                                BackgroundTransparency = 1,
                                ZIndex = 3,
                                Parent = argument2.PageHost,
                            }
                        )
                        local imageResult = tex.image(
                            emptyState,
                            "glow",
                            {
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = UDim2.fromScale(0.5, 0.35),
                                Size = UDim2.fromOffset(200, 200),
                                ImageTransparency = 0.86,
                                ZIndex = 2,
                            }
                        )
                        if imageResult then
                            bindTheme(imageResult, "ImageColor3", "Accent")
                        end
                        icon({
                            Parent = emptyState,
                            Icon = "picture-in-picture-2",
                            Size = 30,
                            Pos = UDim2.new(0.5, 0, 0, 28),
                            Anchor = Vector2.new(0.5, 0.5),
                            Color = "Faint",
                            Z = 4,
                        })
                        label({
                            Parent = emptyState,
                            Text = localization2.tr("Panels are floating"),
                            Font = font.Semi(),
                            Size = 14,
                            Pos = UDim2.fromOffset(0, 56),
                            Box = UDim2.new(1, 0, 0, 20),
                            AlignX = Enum.TextXAlignment.Center,
                            Color = "Muted",
                            Z = 4,
                            Name = "Caption",
                        })
                        local parent, tile, instanceOptions =
                            createInstance(
                                "TextButton",
                                {
                                    Name = "DockAll",
                                    Text = "",
                                    AutoButtonColor = false,
                                    BackgroundTransparency = 1,
                                    AnchorPoint = Vector2.new(0.5, 0),
                                    Position = UDim2.new(0.5, 0, 0, 92),
                                    Size = UDim2.fromOffset(150, 34),
                                    ZIndex = 4,
                                    Parent = emptyState,
                                }
                            ),
                            localization2.tile,
                            { Name = "Face" }
                        instanceOptions.Size, instanceOptions.Color, instanceOptions.SliceScale, instanceOptions.Z =
                            UDim2.fromScale(1, 1), "Accent", 0.6, 4
                        tile(parent, instanceOptions)
                        instanceOptions = tex.image(
                            parent,
                            "rim9",
                            { Size = UDim2.fromScale(1, 1), SliceScale = 0.64, ImageTransparency = 0.6, ZIndex = 6 }
                        )
                        if instanceOptions then
                            bindTheme(instanceOptions, "ImageColor3", "Glass")
                        end
                        label({
                            Parent = parent,
                            Text = localization2.tr("Dock all"),
                            Font = font.Semi(),
                            Size = 13,
                            Box = UDim2.fromScale(1, 1),
                            AlignX = Enum.TextXAlignment.Center,
                            Color = "OnAccent",
                            Z = 7,
                            Name = "Caption",
                        })
                        local value = createInstance("UIScale", { Parent = parent })
                        local function handleAction()
                            tweenInstance(value, "Quick", { Scale = 1.05 })
                        end
                        parent.MouseEnter:Connect(handleAction)
                        u.leave(parent, function()
                            tweenInstance(value, "Quick", { Scale = 1 })
                        end)
                        local function handleAction2()
                            sound.play("click")
                            argument:DockTab(argument2)
                        end
                        parent.MouseButton1Click:Connect(handleAction2)
                        argument2.EmptyState = emptyState
                    end
                    if argument2.EmptyState then
                        argument2.EmptyState.Visible = visible
                    end
                    for unused, item in ipairs(argument2.Sections) do
                        if item.Slot then
                            item.Slot.Visible = not visible
                        end
                    end
                end
                windowClass.DockSection = function(argument, argument2)
                    localization2.trace("DockSection")
                    if not argument2.Floating then
                        return
                    end
                    argument2.Floating = false
                    for key, item in ipairs(argument.Floats) do
                        if item == argument2 then
                            table.remove(argument.Floats, key)
                            break
                        end
                    end
                    local floats, slot = argument2.Wrap, argument2.Slot
                    if slot then
                        if slot.Parent then
                            floats.LayoutOrder = slot.LayoutOrder
                            floats.Parent = slot.Parent
                            slot:Destroy()
                        end
                    end
                    argument2.Slot = nil
                    argument2.SlotStroke = nil
                    argument2.SlotGlow = nil
                    floats.Position = UDim2.new()
                    floats.Size = UDim2.new(1, 0, 0, floats.AbsoluteSize.Y / math.max(argument.Scale.Scale, 0.1))
                    floats.ZIndex = 1
                    if argument2.DockButton then
                        argument2.DockButton:Destroy()
                        argument2.DockButton = nil
                    end
                    if argument2.Shadow then
                        tweenInstance(argument2.Shadow, "Base", { ImageTransparency = 0.62 })
                    end
                    if argument2.Rim then
                        argument2.Rim.ImageTransparency = 0.5
                    end
                    task.defer(function()
                        if argument2._sync then
                            argument2._sync()
                        end
                    end)
                    argument2:_refreshVisibility()
                    floats = argument.State.get("floats", {})
                    if type(floats) == "table" then
                        floats[argument2.Key] = nil
                        argument.State.data.floats = floats
                        argument.State.save()
                    end
                    argument:_refreshTabState(argument2.Tab)
                end
            end
            do
                local u = localization2.U
                local motion, theme = localization2.Motion, localization2.Theme
                local font = localization2.Font
                local unused, sound = localization2.Icons, localization2.Sound
                local createInstance = u.new
                local tweenInstance = motion.tween
                local bindTheme = theme.bind
                local label = localization2.label
                local icon = localization2.icon
                local sectionClass, userInputService =
                    localization2.SectionClass, localization2.Services.UserInputService
                local color = Color3.new(1, 1, 1)
                local tex = localization2.Tex
                local function paint(argument, argument2, argument3, argument4)
                    local entries = theme.registry[argument]
                    if entries then
                    else
                        entries = {}
                        theme.registry[argument] = entries
                    end
                    entries[argument2] = argument3
                    local calculatedValue, entries = argument4 or "Base", {}
                    entries[argument2] = theme.resolve(argument3)
                    tweenInstance(argument, calculatedValue, entries)
                end
                localization2.paint = paint
                local function safe(argument, ...)
                    if type(argument) ~= "function" then
                        return
                    end
                    local success, result = pcall(argument, ...)
                    if not success then
                        warn("[GGH] " .. tostring(result))
                    end
                end
                localization2.safe = safe
                local function keyName(argument)
                    if typeof(argument) ~= "EnumItem" then
                        return "None"
                    end
                    if argument.EnumType == Enum.UserInputType then
                        if argument == Enum.UserInputType.MouseButton1 then
                            return "MB1"
                        end
                        if argument == Enum.UserInputType.MouseButton2 then
                            return "MB2"
                        end
                        if argument == Enum.UserInputType.MouseButton3 then
                            return "MB3"
                        end
                        return "None"
                    end
                    return ({
                        LeftShift = "LShift",
                        RightShift = "RShift",
                        LeftControl = "LCtrl",
                        RightControl = "RCtrl",
                        LeftAlt = "LAlt",
                        RightAlt = "RAlt",
                        Backquote = "`",
                        Return = "Enter",
                        F13 = "MB4",
                        F14 = "MB5",
                    })[argument.Name] or argument.Name
                end
                localization2.keyName = keyName
                localization2.keyHeld = function(argument)
                    if typeof(argument) ~= "EnumItem" then
                        return false
                    end
                    local success, result = pcall(function()
                        if argument.EnumType == Enum.UserInputType then
                            return userInputService:IsMouseButtonPressed(argument)
                        end
                        return userInputService:IsKeyDown(argument)
                    end)
                    return success and result or false
                end
                localization2.bindHit = function(argument, argument2, argument3, argument4)
                    if typeof(argument3) ~= "EnumItem" then
                        return false
                    end
                    if argument3.EnumType == Enum.UserInputType then
                        if argument2.UserInputType ~= argument3 then
                            return false
                        elseif argument4 then
                            return false
                        end
                        if argument then
                            if argument.PointerOverUI then
                                if argument:PointerOverUI() then
                                    return false
                                end
                            end
                        end
                        return true
                    end
                    return argument2.UserInputType == Enum.UserInputType.Keyboard and argument2.KeyCode == argument3
                end
                local function callback(argument)
                    local createResult = localization2.Services.TweenService:Create(
                        argument,
                        TweenInfo.new(0.55, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                        { Transparency = 0.15 }
                    )
                    createResult:Play()
                    return createResult
                end
                local fromRGBResult = Color3.fromRGB(190, 193, 202)
                local function field(parent, strokeResult)
                    local parent2 = createInstance(
                        strokeResult.Class or "Frame",
                        {
                            Name = strokeResult.Name or "Field",
                            Size = strokeResult.Size,
                            BorderSizePixel = 0,
                            LayoutOrder = strokeResult.Order or 10,
                            ZIndex = strokeResult.Z or 2,
                            Parent = parent,
                        }
                    )
                    if strokeResult.Class == "TextButton" then
                        parent2.Text = ""
                        parent2.AutoButtonColor = false
                    end
                    bindTheme(parent2, "BackgroundColor3", "Elevated")
                    u.corner(parent2, strokeResult.Radius or 8)
                    createInstance(
                        "UIGradient",
                        { Color = ColorSequence.new(color, fromRGBResult), Rotation = 90, Parent = parent2 }
                    )
                    strokeResult = u.stroke(parent2, color, 1, 0.84)
                    bindTheme(strokeResult, "Color", "Glass")
                    return parent2, strokeResult
                end
                localization2.field = field
                local function callback2(argument, parent, key, argument2, argument3)
                    local chip = createInstance(
                        "TextButton",
                        {
                            Name = "Bind",
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            Size = UDim2.fromOffset(36, 26),
                            LayoutOrder = argument3 or 5,
                            ZIndex = 3,
                            Parent = parent,
                        }
                    )
                    argument3 = createInstance(
                        "Frame",
                        {
                            Name = "Base",
                            Size = UDim2.fromScale(1, 1),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.fromRGB(6, 7, 10),
                            ZIndex = 3,
                            Parent = chip,
                        }
                    )
                    u.corner(argument3, 7)
                    local strokeResult = u.stroke(argument3, color, 1, 0.9)
                    bindTheme(strokeResult, "Color", "Glass")
                    local parent = createInstance(
                        "Frame",
                        { Name = "Face", Size = UDim2.new(1, 0, 0, 23), BorderSizePixel = 0, ZIndex = 4, Parent = chip }
                    )
                    bindTheme(parent, "BackgroundColor3", "Elevated")
                    u.corner(parent, 7)
                    createInstance(
                        "UIGradient",
                        { Color = ColorSequence.new(color, Color3.fromRGB(196, 199, 208)), Rotation = 90, Parent = parent }
                    )
                    local strokeResult2 = u.stroke(parent, color, 1, 0.82)
                    bindTheme(strokeResult2, "Color", "Glass")
                    local value, entries, enabled, value2 =
                        label({
                            Parent = parent,
                            Text = "",
                            Font = font.Semi(),
                            Size = 12,
                            Box = UDim2.fromScale(1, 1),
                            AlignX = Enum.TextXAlignment.Center,
                            Color = "Muted",
                            Z = 5,
                        }),
                        { Key = key, Chip = chip },
                        false
                    local enabled2 = false
                    local function isActive2()
                        if typeof(entries.Key) ~= "EnumItem" then
                            return "—"
                        end
                        return keyName(entries.Key)
                    end
                    local function isActive3()
                        local text = isActive2()
                        chip.Size =
                            UDim2.fromOffset(math.max(34, math.floor((utf8.len(text) or #text) * 7.4 + 18)), 26)
                        value.Text = text
                    end
                    isActive3()
                    local function isActive4()
                        enabled = false
                        task.defer(function()
                            if not enabled then
                                argument.Listening = false
                            end
                        end)
                        if value2 then
                            value2:Cancel()
                            value2 = nil
                        end
                        paint(strokeResult2, "Color", "Glass", "Quick")
                        tweenInstance(strokeResult2, "Quick", { Transparency = enabled2 and 0.6 or 0.82 })
                        paint(strokeResult, "Color", "Glass", "Quick")
                        tweenInstance(strokeResult, "Quick", { Transparency = 0.9 })
                        paint(value, "TextColor3", entries.Key and "Text" or "Faint", "Quick")
                        isActive3()
                    end
                    paint(value, "TextColor3", entries.Key and "Text" or "Faint", TweenInfo.new(0))
                    entries.Set = function(key, argument3)
                        entries.Key = key
                        if enabled then
                            isActive3()
                        else
                            isActive4()
                        end
                        if not argument3 then
                            safe(argument2, key)
                        end
                    end
                    chip.MouseEnter:Connect(function()
                        enabled2 = true
                        if not enabled then
                            tweenInstance(strokeResult2, "Quick", { Transparency = 0.6 })
                        end
                    end)
                    u.leave(chip, function()
                        enabled2 = false
                        if not enabled then
                            tweenInstance(strokeResult2, "Quick", { Transparency = 0.82 })
                        end
                        tweenInstance(
                            parent,
                            "Quick",
                            { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 23) }
                        )
                    end)
                    local function handleAction()
                        tweenInstance(
                            parent,
                            "Quick",
                            { Position = UDim2.fromOffset(0, 2), Size = UDim2.new(1, 0, 0, 21) }
                        )
                    end
                    chip.MouseButton1Down:Connect(handleAction)
                    local function handleAction2()
                        tweenInstance(
                            parent,
                            "PopSmall",
                            { Position = UDim2.fromOffset(0, 0), Size = UDim2.new(1, 0, 0, 23) }
                        )
                    end
                    chip.MouseButton1Up:Connect(handleAction2)
                    chip.MouseButton2Click:Connect(function()
                        if enabled then
                            return
                        elseif entries.Key == nil then
                            return
                        elseif os.clock() - (entries.BoundAt or 0) < 0.3 then
                            return
                        end
                        sound.play("tick")
                        entries.Key = nil
                        isActive4()
                        safe(argument2, nil)
                    end)
                    chip.MouseButton1Click:Connect(function()
                        if enabled then
                            return
                        elseif os.clock() - (entries.BoundAt or 0) < 0.3 then
                            return
                        end
                        sound.play("click")
                        enabled = true
                        value.Text = localization2.tr("Press") .. " …"
                        chip.Size = UDim2.fromOffset(66, 26)
                        paint(value, "TextColor3", "Accent", "Quick")
                        paint(strokeResult2, "Color", "Accent", "Quick")
                        paint(strokeResult, "Color", "Accent", "Quick")
                        tweenInstance(strokeResult, "Quick", { Transparency = 0.55 })
                        value2 = callback(strokeResult2)
                        task.defer(function()
                            argument.Listening = true
                        end)
                    end)
                    u.connect(userInputService.InputBegan, function(argument3)
                        if enabled then
                            if not argument.Listening then
                                return
                            end
                        else
                            return
                        end
                        local key
                        if argument3.UserInputType == Enum.UserInputType.Keyboard then
                            if argument3.KeyCode == Enum.KeyCode.Escape then
                                isActive4()
                                return
                            end
                            if
                                argument3.KeyCode == Enum.KeyCode.Backspace
                                or argument3.KeyCode == Enum.KeyCode.Delete
                            then
                                entries.Key = nil
                                isActive4()
                                safe(argument2, nil)
                                return
                            end
                            key = argument3.KeyCode
                        else
                            if argument3.UserInputType == Enum.UserInputType.Touch then
                                isActive4()
                                return
                            elseif
                                argument3.UserInputType == Enum.UserInputType.MouseButton1
                                or argument3.UserInputType == Enum.UserInputType.MouseButton2
                                or argument3.UserInputType == Enum.UserInputType.MouseButton3
                            then
                                key = argument3.UserInputType
                                entries.BoundAt = os.clock()
                            else
                            end
                        end
                        if key then
                            entries.Key = key
                            isActive4()
                            sound.play("tick")
                            safe(argument2, key)
                        end
                    end, argument.Conns)
                    return entries
                end
                sectionClass.Toggle = function(parentSection, argument)
                    local calculatedValue = argument or {}
                    local window = parentSection.Window
                    local rowObj = parentSection:_row({
                        Text = calculatedValue.Text,
                        Desc = calculatedValue.Desc,
                        Tooltip = calculatedValue.Tooltip,
                        Reserve = (calculatedValue.Keybind ~= nil or calculatedValue.Bind) and 128 or 70,
                        Indent = calculatedValue.Indent,
                        Order = calculatedValue.Order,
                        Parent = calculatedValue.Parent,
                    })
                    local calculatedValue2 = calculatedValue.Default and true or false
                    local hitResult, counter, counter2, counter3, value, value2 = rowObj.hit(), 48, 24, 18
                    if parentSection.Nested then
                        counter, counter3 = 38, 14
                        value, counter2, value2 = counter, 20, counter3
                    else
                        value, value2 = counter, counter3
                    end
                    local parent = createInstance(
                        "Frame",
                        {
                            Name = "Switch",
                            Size = UDim2.fromOffset(value, counter2),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            LayoutOrder = 10,
                            ZIndex = 2,
                            Parent = rowObj.Right,
                        }
                    )
                    u.corner(parent, UDim.new(1, 0))
                    local strokeResult = u.stroke(parent, color, 1, 0.86)
                    bindTheme(strokeResult, "Color", "Glass")
                    local imageResult = tex.image(
                        parent,
                        "glow",
                        {
                            Name = "Glow",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(value + 36, counter2 + 32),
                            ImageTransparency = 1,
                            ZIndex = 1,
                        }
                    )
                    if imageResult then
                        bindTheme(imageResult, "ImageColor3", "Accent")
                    end
                    local imageResult2 =
                        tex.image(parent, "pillfill", { Name = "Fill", Size = UDim2.fromScale(1, 1), ZIndex = 2 })
                    local image, content = tex.image, { Name = "Shade" }
                    content.Size, content.ZIndex = UDim2.fromScale(1, 1), 3
                    image(parent, "trackshade", content)
                    if not imageResult2 then
                        parent.BackgroundTransparency = 0
                    end
                    local value3 = createInstance(
                        "Frame",
                        {
                            Name = "Knob",
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.new(0, 3, 0.5, 0),
                            Size = UDim2.fromOffset(value2, value2),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            ZIndex = 4,
                            Parent = parent,
                        }
                    )
                    local imageResult3 =
                        tex.image(value3, "knob", { Name = "Face", Size = UDim2.fromScale(1, 1), ZIndex = 4 })
                    if imageResult3 then
                        u.shadow(imageResult3, 0.45, 5, 1.5, 0)
                    else
                        value3.BackgroundTransparency = 0
                        u.corner(value3, UDim.new(1, 0))
                    end
                    local enabled = false
                    local function callback(calculatedValue3)
                        local calculatedValue4 = enabled and value2 + 6 or value2
                        local calculatedValue5, calculatedValue6, calculatedValue7 =
                            calculatedValue2 and value - calculatedValue4 - 3 or 3,
                            calculatedValue3 and TweenInfo.new(0) or TweenInfo.new(
                                0.3,
                                Enum.EasingStyle.Quint,
                                Enum.EasingDirection.Out
                            ),
                            calculatedValue3 and TweenInfo.new(0) or "Quick"
                        tweenInstance(
                            value3,
                            calculatedValue6,
                            {
                                Position = UDim2.new(0, calculatedValue5, 0.5, 0),
                                Size = UDim2.fromOffset(calculatedValue4, value2),
                            }
                        )
                        calculatedValue3, calculatedValue5 =
                            imageResult2 or parent, imageResult2 and "ImageColor3" or "BackgroundColor3"
                        paint(
                            calculatedValue3,
                            calculatedValue5,
                            calculatedValue2 and "Accent" or "Elevated",
                            calculatedValue7
                        )
                        paint(
                            imageResult3 or value3,
                            imageResult3 and "ImageColor3" or "BackgroundColor3",
                            calculatedValue2 and "OnAccent"
                                or function(argument)
                                    return argument.Muted:Lerp(argument.Text, 0.5)
                                end,
                            calculatedValue7
                        )
                        if imageResult then
                            tweenInstance(
                                imageResult,
                                calculatedValue7,
                                { ImageTransparency = calculatedValue2 and 0.6 or 1 }
                            )
                        end
                        paint(strokeResult, "Color", calculatedValue2 and "Accent" or "Glass", calculatedValue7)
                        tweenInstance(
                            strokeResult,
                            calculatedValue7,
                            { Transparency = calculatedValue2 and 0.55 or 0.86 }
                        )
                    end
                    callback(true)
                    local ownerToggle = {}
                    ownerToggle.Row = rowObj.Frame
                    ownerToggle.Type = "Toggle"
                    local function callback3(calculatedValue3, argument)
                        calculatedValue3 = calculatedValue3 and true or false
                        local calculatedValue4 = calculatedValue3 ~= calculatedValue2
                        calculatedValue2 = calculatedValue3
                        callback(false)
                        if calculatedValue4 then
                            window:_kbDirty()
                        end
                        if calculatedValue4 then
                            if ownerToggle.Changed then
                                safe(ownerToggle.Changed, calculatedValue2)
                            end
                        end
                        if argument ~= false then
                            safe(calculatedValue.Callback, calculatedValue2)
                        end
                    end
                    hitResult.MouseButton1Down:Connect(function()
                        enabled = true
                        callback(false)
                    end)
                    hitResult.MouseButton1Up:Connect(function()
                        enabled = false
                    end)
                    u.leave(hitResult, function()
                        if enabled then
                            enabled = false
                            callback(false)
                        end
                    end)
                    hitResult.MouseButton1Click:Connect(function()
                        if calculatedValue.Locked then
                            return
                        end
                        enabled = false
                        sound.play(calculatedValue2 and "off" or "on")
                        callback3(not calculatedValue2)
                    end)
                    if calculatedValue.Keybind ~= nil or calculatedValue.Bind then
                        ownerToggle.Bind = callback2(
                            window,
                            rowObj.Right,
                            typeof(calculatedValue.Keybind) == "EnumItem" and calculatedValue.Keybind or nil,
                            function(argument)
                                safe(calculatedValue.OnBind, argument)
                                window:_kbDirty()
                            end,
                            5
                        )
                        window:RegisterKeybind({
                            kind = "toggle",
                            name = function()
                                return rowObj.Title.Text
                            end,
                            key = function()
                                return ownerToggle.Bind.Key
                            end,
                            active = function()
                                local value4 = calculatedValue2
                                return value4
                            end,
                            set = function(argument)
                                ownerToggle.Bind.Set(argument)
                            end,
                            toggle = function()
                                if calculatedValue.Locked then
                                    return
                                end
                                sound.play(calculatedValue2 and "off" or "on")
                                callback3(not calculatedValue2)
                            end,
                            alive = function()
                                return rowObj.Frame.Parent ~= nil
                            end,
                        })
                        if calculatedValue.KeyToggle then
                            u.connect(userInputService.InputBegan, function(argument, argument2)
                                if window.Destroyed then
                                    return
                                elseif window.Listening then
                                    return
                                elseif calculatedValue.Locked then
                                    return
                                end
                                if userInputService:GetFocusedTextBox() then
                                    return
                                end
                                local key = ownerToggle.Bind.Key
                                if localization2.bindHit(window, argument, key, argument2) then
                                    sound.play(calculatedValue2 and "off" or "on")
                                    callback3(not calculatedValue2)
                                end
                            end, window.Conns)
                        end
                    end
                    if calculatedValue.Drawer then
                        local value4 =
                            icon({ Parent = rowObj.Right, Icon = "settings", Size = 13, Color = "Faint", Z = 3 })
                        value4.LayoutOrder = 8
                        parentSection.Order = parentSection.Order + 1
                        local indent = rowObj.Indent
                        local value5 = createInstance(
                            "Frame",
                            {
                                Name = "Tile",
                                Position = UDim2.fromOffset(indent + 2, 1),
                                Size = UDim2.new(1, -(indent + 4), 0, rowObj.Frame.Size.Y.Offset - 2),
                                BorderSizePixel = 0,
                                BackgroundTransparency = 1,
                                ZIndex = 0,
                                Parent = rowObj.Frame,
                            }
                        )
                        bindTheme(value5, "BackgroundColor3", "Elevated")
                        u.corner(value5, 10)
                        local drawerFrame = createInstance(
                            "Frame",
                            {
                                Name = "Drawer",
                                Size = UDim2.new(1, 0, 0, 0),
                                BackgroundTransparency = 1,
                                ClipsDescendants = true,
                                LayoutOrder = parentSection.Order,
                                Parent = calculatedValue.Parent or parentSection.Content,
                            }
                        )
                        local parent = createInstance(
                            "Frame",
                            {
                                Name = "Panel",
                                Position = UDim2.fromOffset(indent, 0),
                                Size = UDim2.new(1, -indent, 0, 0),
                                AutomaticSize = Enum.AutomaticSize.Y,
                                BorderSizePixel = 0,
                                BackgroundTransparency = 1,
                                Parent = drawerFrame,
                            }
                        )
                        content = createInstance(
                            "Frame",
                            {
                                Name = "Content",
                                Size = UDim2.new(1, 0, 0, 0),
                                AutomaticSize = Enum.AutomaticSize.Y,
                                BackgroundTransparency = 1,
                                Parent = parent,
                            }
                        )
                        u.list(content, 0)
                        bindTheme(
                            createInstance(
                                "Frame",
                                {
                                    Name = "Rule",
                                    Position = UDim2.new(0, 12, 0, 0),
                                    Size = UDim2.new(1, -24, 0, 1),
                                    BorderSizePixel = 0,
                                    BackgroundTransparency = 0.92,
                                    ZIndex = 2,
                                    Parent = parent,
                                }
                            ),
                            "BackgroundColor3",
                            "Glass"
                        )
                        u.pad(content, 3, 2, 4, 2)
                        local drawer, value =
                            setmetatable(
                                {
                                    Tab = parentSection.Tab,
                                    Window = window,
                                    Page = parentSection.Page,
                                    Side = parentSection.Side,
                                    Rows = parentSection.Rows,
                                    Order = 0,
                                    Content = content,
                                    Card = parentSection.Card,
                                    ParentSection = parentSection,
                                    Nested = true,
                                },
                                localization2.SectionClass
                            ),
                            parentSection
                        drawer.OwnerToggle = ownerToggle
                        drawer.OwnerRow = rowObj
                        drawer._refreshVisibility = function()
                            value:_refreshVisibility()
                        end
                        local entries = {}
                        drawer._row = function(argument, argument2)
                            local rowResult = localization2.SectionClass._row(argument, argument2)
                            table.insert(entries, rowResult)
                            return rowResult
                        end
                        rowObj.SearchExtra = function()
                            local entries2 = {}
                            for unused, item in ipairs(entries) do
                                table.insert(entries2, item.Entry.text())
                            end
                            return table.concat(entries2, " ")
                        end
                        local enabled2, enabled3 = false, false
                        local function isActive2()
                            local calculatedValue3 = enabled2 or enabled3
                            return calculatedValue3
                        end
                        local function isActive3()
                            local maximumValue = math.max(window.Scale.Scale, 0.1)
                            return math.floor(parent.AbsoluteSize.Y / maximumValue + 10)
                        end
                        local function callback(argument)
                            return UDim2.new(
                                1,
                                -(indent + 4),
                                0,
                                rowObj.Frame.Size.Y.Offset - 2 + math.max(argument - 8, 0)
                            )
                        end
                        local function callback4(argument)
                            local tweenInfo = isActive2()
                            paint(
                                value4,
                                "ImageColor3",
                                tweenInfo and "Accent" or "Faint",
                                argument and TweenInfo.new(0) or "Quick"
                            )
                            local calculatedValue3, backgroundTransparency =
                                tweenInfo and isActive3() or 0, tweenInfo and 0.42 or 1
                            if argument then
                                drawerFrame.Size = UDim2.new(1, 0, 0, calculatedValue3)
                                value5.Size = callback(calculatedValue3)
                                value5.BackgroundTransparency = backgroundTransparency
                            else
                                tweenInfo = TweenInfo.new(0.34, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                                tweenInstance(
                                    drawerFrame,
                                    tweenInfo,
                                    { Size = UDim2.new(1, 0, 0, calculatedValue3) }
                                )
                                tweenInstance(
                                    value5,
                                    tweenInfo,
                                    { Size = callback(calculatedValue3), BackgroundTransparency = backgroundTransparency }
                                )
                            end
                        end
                        local function callback5(argument, argument2)
                            enabled2 = argument and true or false
                            callback4(argument2)
                        end
                        rowObj.OnRefresh = function()
                            local calculatedValue3 = window.Query or ""
                            local enabled = calculatedValue3 == ""
                            if enabled then
                            else
                                for unused, item in ipairs(entries) do
                                    if item.isVisible() then
                                        enabled = true
                                        break
                                    end
                                end
                            end
                            drawerFrame.Visible = rowObj.isVisible() and enabled
                            value5.Visible = drawerFrame.Visible
                            local calculatedValue4 = calculatedValue3 ~= "" and enabled and rowObj.isVisible()
                            if calculatedValue4 ~= enabled3 then
                                enabled3 = calculatedValue4
                                callback4(false)
                            end
                        end
                        local function handleAction()
                            if window.Scaling then
                                window:_scalingDefer(handleAction)
                                return
                            end
                            if isActive2() then
                                local value = isActive3()
                                drawerFrame.Size = UDim2.new(1, 0, 0, value)
                                value5.Size = callback(value)
                            end
                        end
                        parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(handleAction)
                        ownerToggle.Drawer = drawer
                        ownerToggle.DrawerFrame = drawerFrame
                        ownerToggle.SetDrawer = function(unused, argument, argument2)
                            callback5(argument, argument2)
                        end
                        ownerToggle.IsDrawerOpen = function(argument)
                            argument = enabled2
                            return argument
                        end
                        ownerToggle.Changed = function(argument)
                            callback5(argument, false)
                        end
                        task.defer(function()
                            callback5(calculatedValue2, true)
                        end)
                    end
                    ownerToggle.Set = function(unused, argument)
                        callback3(argument, true)
                    end
                    ownerToggle.SetValue = function(unused, argument)
                        callback3(argument, true)
                    end
                    ownerToggle.SetSilent = function(unused, argument)
                        callback3(argument, false)
                    end
                    ownerToggle.Get = function(argument)
                        argument = calculatedValue2
                        return argument
                    end
                    ownerToggle.SetText = function(unused, argument)
                        rowObj.SetText(argument)
                    end
                    ownerToggle.SetDesc = function(unused, argument)
                        rowObj.SetDesc(argument)
                    end
                    ownerToggle.SetVisible = function(unused, argument)
                        rowObj.SetVisible(argument)
                    end
                    ownerToggle.SetParentHidden = function(unused, argument)
                        rowObj.SetParentHidden(argument)
                    end
                    ownerToggle.SetLocked = function(unused, locked)
                        calculatedValue.Locked = locked
                    end
                    ownerToggle.RowObj = rowObj
                    ownerToggle.Title = rowObj.Title
                    ownerToggle.DescLabel = rowObj.Desc
                    return ownerToggle
                end
                sectionClass.Slider = function(argument, argument2)
                    local calculatedValue = argument2 or {}
                    local calculatedValue2 = tonumber(calculatedValue.Min) or 0
                    local calculatedValue3, calculatedValue4 = tonumber(calculatedValue.Max) or 100
                    if calculatedValue3 <= calculatedValue2 then
                        calculatedValue3 = calculatedValue2 + 1
                        calculatedValue4 = calculatedValue3
                    else
                        calculatedValue4 = calculatedValue3
                    end
                    local calculatedValue5 = tonumber(calculatedValue.Decimals)
                        or tonumber(calculatedValue.Rounding)
                        or 0
                    local rowObj = argument:_row({
                        Text = calculatedValue.Text,
                        Tooltip = calculatedValue.Tooltip,
                        Height = 56,
                        Reserve = 90,
                        Indent = calculatedValue.Indent,
                        Order = calculatedValue.Order,
                        Parent = calculatedValue.Parent,
                    })
                    rowObj.Title.Position = UDim2.fromOffset(10 + rowObj.Indent, 7)
                    rowObj.Title.Size = UDim2.new(1, -(100 + rowObj.Indent), 0, 20)
                    local value = label({
                        Parent = rowObj.Frame,
                        Text = "",
                        Font = font.Semi(),
                        Size = 13,
                        Anchor = Vector2.new(1, 0),
                        Pos = UDim2.new(1, -12, 0, 7),
                        Box = UDim2.fromOffset(90, 20),
                        AlignX = Enum.TextXAlignment.Right,
                        Color = "Muted",
                    })
                    rowObj.Right.Visible = false
                    rowObj.OnWidth = function(argument2)
                        local maximumValue = math.max(argument.Window.Scale.Scale, 0.1)
                        local calculatedValue3 = value.TextBounds.X / maximumValue
                        rowObj.Title.Size = UDim2.new(
                            0,
                            math.max(argument2 - (10 + rowObj.Indent) - calculatedValue3 - 28, 40),
                            0,
                            20
                        )
                    end
                    local function parent()
                        if rowObj.fitTitle then
                            rowObj.fitTitle()
                        end
                    end
                    value:GetPropertyChangedSignal("TextBounds"):Connect(parent)
                    parent = createInstance(
                        "TextButton",
                        {
                            Name = "Track",
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            Position = UDim2.new(0, 12 + rowObj.Indent, 0, 30),
                            Size = UDim2.new(1, -(24 + rowObj.Indent), 0, 20),
                            ZIndex = 2,
                            Parent = rowObj.Frame,
                        }
                    )
                    local parent2 = createInstance(
                        "Frame",
                        {
                            Name = "Bar",
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.fromScale(0, 0.5),
                            Size = UDim2.new(1, 0, 0, 8),
                            BorderSizePixel = 0,
                            ZIndex = 2,
                            Parent = parent,
                        }
                    )
                    bindTheme(parent2, "BackgroundColor3", "Elevated")
                    u.corner(parent2, UDim.new(1, 0))
                    local parent3 = createInstance(
                        "Frame",
                        {
                            Name = "Shade",
                            Size = UDim2.fromScale(1, 1),
                            BorderSizePixel = 0,
                            BackgroundColor3 = Color3.new(0, 0, 0),
                            ZIndex = 2,
                            Parent = parent2,
                        }
                    )
                    u.corner(parent3, UDim.new(1, 0))
                    createInstance(
                        "UIGradient",
                        {
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 0.35),
                                NumberSequenceKeypoint.new(0.6, 0.9),
                                NumberSequenceKeypoint.new(1, 1),
                            }),
                            Rotation = 90,
                            Parent = parent3,
                        }
                    )
                    bindTheme(u.stroke(parent2, color, 1, 0.9), "Color", "Glass")
                    local parent4 = createInstance(
                        "Frame",
                        { Name = "Fill", Size = UDim2.fromScale(0, 1), BorderSizePixel = 0, ZIndex = 3, Parent = parent2 }
                    )
                    bindTheme(parent4, "BackgroundColor3", "Accent")
                    u.corner(parent4, UDim.new(1, 0))
                    createInstance(
                        "UIGradient",
                        { Color = ColorSequence.new(Color3.fromRGB(200, 200, 200), color), Parent = parent4 }
                    )
                    parent3 = u.shadow(parent4, 0.55, 8, 0, 0)
                    if parent3 then
                        bindTheme(parent3, "Color", "Accent")
                    end
                    local parent5 = createInstance(
                        "Frame",
                        {
                            Name = "Knob",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0, 0.5),
                            Size = UDim2.fromOffset(16, 16),
                            BorderSizePixel = 0,
                            ZIndex = 4,
                            Parent = parent2,
                        }
                    )
                    bindTheme(parent5, "BackgroundColor3", "OnAccent")
                    u.corner(parent5, UDim.new(1, 0))
                    if tex.image(parent5, "knob", { Name = "Face", Size = UDim2.fromScale(1, 1), ZIndex = 4 }) then
                        parent5.BackgroundTransparency = 1
                    end
                    bindTheme(u.stroke(parent5, color, 2, 0.1), "Color", "Accent")
                    u.shadow(parent5, 0.35, 6, 1, 0)
                    local value2 = createInstance("UIScale", { Parent = parent5 })
                    local v, entries =
                        u.clamp(
                            tonumber(calculatedValue.Default) or calculatedValue2,
                            calculatedValue2,
                            calculatedValue4
                        ),
                        {}
                    entries.Row = rowObj.Frame
                    entries.Type = "Slider"
                    local function callback(argument2)
                        if calculatedValue.Display then
                            local success, result = pcall(calculatedValue.Display, argument2)
                            if success then
                                if type(result) == "string" then
                                    return result
                                end
                            end
                        end
                        return u.fmt(argument2, calculatedValue5) .. (calculatedValue.Suffix or "")
                    end
                    local function callback3(argument2)
                        local calculatedValue3, calculatedValue6 =
                            (v - calculatedValue2) / (calculatedValue4 - calculatedValue2),
                            argument2 and TweenInfo.new(0) or TweenInfo.new(
                                0.09,
                                Enum.EasingStyle.Quad,
                                Enum.EasingDirection.Out
                            )
                        tweenInstance(parent4, calculatedValue6, { Size = UDim2.fromScale(calculatedValue3, 1) })
                        tweenInstance(
                            parent5,
                            calculatedValue6,
                            { Position = UDim2.fromScale(calculatedValue3, 0.5) }
                        )
                        value.Text = callback(v)
                    end
                    callback3(true)
                    local function callback4(roundResult, argument2)
                        roundResult = u.round(
                            u.clamp(tonumber(roundResult) or calculatedValue2, calculatedValue2, calculatedValue4),
                            calculatedValue5
                        )
                        roundResult = if calculatedValue.Step
                            then u.round(
                                math.floor((roundResult - calculatedValue2) / calculatedValue.Step + 0.5)
                                        * calculatedValue.Step
                                    + calculatedValue2,
                                calculatedValue5
                            )
                            else roundResult
                        if roundResult == v then
                            if argument2 ~= "force" then
                                return
                            end
                        end
                        local value3 = v
                        v = roundResult
                        callback3(false)
                        if argument2 ~= false then
                            safe(calculatedValue.Callback, v)
                        end
                        if value3 ~= v then
                            if entries.Changed then
                                safe(entries.Changed, v)
                            end
                        end
                    end
                    local enabled, enabled2, enabled3, enabled4 = false
                    local now = 0
                    local function callback(argument2)
                        if v ~= argument2 then
                            if os.clock() - now > 0.04 then
                                now = os.clock()
                                sound.play("tick", 0.5)
                            end
                        end
                    end
                    local function callback5(argument2)
                        local x, x2 = parent2.AbsolutePosition.X, parent2.AbsoluteSize.X
                        local clampedValue, value3, value4 =
                            u.clamp((argument2.X - x) / math.max(x2, 1), 0, 1), v, calculatedValue2
                        callback4(value4 + (calculatedValue4 - calculatedValue2) * clampedValue, true)
                        callback(value3)
                    end
                    local function callback6(argument2)
                        local maximumValue = math.max(parent2.AbsoluteSize.X, 1)
                        local clampedValue, value3, value4 =
                            u.clamp(
                                (enabled4.v - calculatedValue2) / (calculatedValue4 - calculatedValue2)
                                    + (argument2.X - enabled4.x) / maximumValue,
                                0,
                                1
                            ),
                            v,
                            calculatedValue2
                        callback4(value4 + (calculatedValue4 - calculatedValue2) * clampedValue, true)
                        callback(value3)
                    end
                    parent.InputBegan:Connect(function(input)
                        if u.isClick(input) then
                            if calculatedValue.Locked then
                                return
                            end
                        else
                            return
                        end
                        if input.UserInputType == Enum.UserInputType.Touch then
                            enabled3 = { input = input, x = input.Position.X, y = input.Position.Y }
                            return
                        end
                        enabled, enabled2, enabled4 = true, input, nil
                        tweenInstance(value2, "Quick", { Scale = 1.3 })
                        paint(value, "TextColor3", "Text", "Quick")
                        callback5(input.Position)
                    end)
                    u.connect(userInputService.InputChanged, function(argument2)
                        if enabled3 then
                            if argument2 == enabled3.input then
                                local calculatedValue3, calculatedValue5 =
                                    argument2.Position.X - enabled3.x, argument2.Position.Y - enabled3.y
                                if
                                    math.abs(calculatedValue5) > 10
                                    and math.abs(calculatedValue5) > math.abs(calculatedValue3)
                                then
                                    enabled3 = nil
                                elseif math.abs(calculatedValue3) > 8 then
                                    enabled3, enabled, enabled2 = nil, true, argument2
                                    enabled4 = { x = argument2.Position.X, v = v }
                                    tweenInstance(value2, "Quick", { Scale = 1.3 })
                                    paint(value, "TextColor3", "Text", "Quick")
                                end
                                return
                            end
                        end
                        if enabled then
                            if u.sameMove(argument2, enabled2) then
                                if enabled4 then
                                    callback6(argument2.Position)
                                else
                                    callback5(argument2.Position)
                                end
                            end
                        end
                    end, argument.Window.Conns)
                    u.connect(userInputService.InputEnded, function(argument2)
                        if enabled3 then
                            if argument2 == enabled3.input then
                                enabled3 = nil
                            end
                        end
                        if enabled then
                            if u.sameEnd(argument2, enabled2) then
                                enabled, enabled4 = false, nil
                                tweenInstance(value2, "PopSmall", { Scale = 1 })
                                paint(value, "TextColor3", "Muted", "Quick")
                                safe(calculatedValue.Released, v)
                            end
                        end
                    end, argument.Window.Conns)
                    rowObj.Frame.MouseEnter:Connect(function()
                        if not enabled then
                            tweenInstance(value2, "Quick", { Scale = 1.15 })
                        end
                    end)
                    u.leave(rowObj.Frame, function()
                        if not enabled then
                            tweenInstance(value2, "Quick", { Scale = 1 })
                        end
                    end)
                    entries.Set = function(unused, argument)
                        callback4(argument, true)
                    end
                    entries.SetValue = function(unused, argument)
                        callback4(argument, true)
                    end
                    entries.SetSilent = function(unused, argument)
                        callback4(argument, false)
                    end
                    entries.Get = function(argument2)
                        argument2 = v
                        return argument2
                    end
                    entries.SetMax = function(unused, argument)
                        calculatedValue4 = tonumber(argument) or calculatedValue4
                        callback4(v, false)
                        callback3(true)
                    end
                    entries.SetMin = function(unused, argument)
                        calculatedValue2 = tonumber(argument) or calculatedValue2
                        callback4(v, false)
                        callback3(true)
                    end
                    entries.Refresh = function(unused)
                        callback3(true)
                    end
                    entries.SetText = function(unused, argument)
                        rowObj.SetText(argument)
                    end
                    entries.SetVisible = function(unused, argument)
                        rowObj.SetVisible(argument)
                    end
                    entries.SetParentHidden = function(unused, argument)
                        rowObj.SetParentHidden(argument)
                    end
                    entries.RowObj = rowObj
                    entries.Title = rowObj.Title
                    return entries
                end
                local function callback3(argument)
                    local entries = {}
                    for unused, value in ipairs(argument or {}) do
                        if type(value) == "table" then
                            table.insert(
                                entries,
                                {
                                    value = value.code ~= nil and value.code or value.value or value[1],
                                    label = tostring(
                                        value.label
                                            or value.Text
                                            or value.code
                                            or value.value
                                            or value[2]
                                            or value[1]
                                    ),
                                    image = value.image or value.Image,
                                }
                            )
                        else
                            local insert, entries2 = table.insert, { value = value }
                            entries2.label = tostring(value)
                            insert(entries, entries2)
                        end
                    end
                    return entries
                end
                sectionClass.Dropdown = function(calculatedValue, argument)
                    local calculatedValue2 = argument or {}
                    local window = calculatedValue.Window
                    local calculatedValue3 = calculatedValue.Nested == true and calculatedValue2.Inline ~= true
                    local rowObj = calculatedValue:_row({
                        Text = calculatedValue2.Text,
                        Desc = calculatedValue2.Desc,
                        Tooltip = calculatedValue2.Tooltip,
                        Reserve = calculatedValue3 and 0 or 190,
                        Height = calculatedValue3 and (calculatedValue2.Desc and 74 or 60) or nil,
                        Indent = calculatedValue2.Indent,
                        Order = calculatedValue2.Order,
                        Parent = calculatedValue2.Parent,
                    })
                    local value = callback3(calculatedValue2.Options or calculatedValue2.Values)
                    local calculatedValue4, entries, default, value2 = calculatedValue2.Multi == true, {}
                    if calculatedValue4 then
                        local callback, calculatedValue5 =
                            ipairs, type(calculatedValue2.Default) == "table" and calculatedValue2.Default or {}
                        for unused, item in callback(calculatedValue5) do
                            entries[item] = true
                        end
                        value2 = default
                    else
                        default = calculatedValue2.Default
                        value2 = default
                    end
                    local parent, value3
                    if calculatedValue3 then
                        calculatedValue = 10 + rowObj.Indent
                        local value4, value5 = field(
                            rowObj.Frame,
                            { Class = "TextButton", Name = "Box", Size = UDim2.new(
                                1,
                                -(calculatedValue + 10),
                                0,
                                28
                            ) }
                        )
                        value4.Position = UDim2.fromOffset(calculatedValue, rowObj.Frame.Size.Y.Offset - 33)
                        rowObj.Title.Position = UDim2.fromOffset(calculatedValue, 5)
                        rowObj.Title.Size = UDim2.new(1, -(calculatedValue + 10), 0, 18)
                        if rowObj.Desc then
                            rowObj.Desc.Position = UDim2.fromOffset(calculatedValue, 24)
                            rowObj.Desc.Size = UDim2.new(1, -(calculatedValue + 10), 0, 16)
                        end
                        rowObj.Right.Visible = false
                        parent, value3 = value4, value5
                    else
                        parent, value3 = field(
                            rowObj.Right,
                            { Class = "TextButton", Name = "Box", Size = UDim2.fromOffset(150, 30) }
                        )
                    end
                    local value4
                    local function isActive2()
                        task.spawn(function()
                            local text = rowObj.Title.Text
                            local textWidthResult = u.textWidth(text, rowObj.Title.FontFace, 14)
                            if rowObj.Title.Text == text then
                                value4 = textWidthResult
                                if rowObj.fitTitle then
                                    rowObj.fitTitle()
                                end
                            end
                        end)
                    end
                    rowObj.OnWidth = function(argument)
                        if calculatedValue3 then
                            return
                        end
                        local roundedValue = argument * 0.44
                        roundedValue = if value4
                            then math.max(roundedValue, argument - (10 + rowObj.Indent) - value4 - 36)
                            else roundedValue
                        roundedValue = math.floor(u.clamp(roundedValue, 100, 190))
                        if parent.Size.X.Offset ~= roundedValue then
                            parent.Size = UDim2.fromOffset(roundedValue, 30)
                        end
                    end
                    rowObj.Title:GetPropertyChangedSignal("Text"):Connect(isActive2)
                    rowObj.Title:GetPropertyChangedSignal("FontFace"):Connect(isActive2)
                    isActive2()
                    local value5 = label({
                        Parent = parent,
                        Text = "",
                        Font = font.Medium(),
                        Size = 13,
                        Pos = UDim2.fromOffset(12, 0),
                        Box = UDim2.new(1, -46, 1, 0),
                        Truncate = true,
                        Z = 3,
                    })
                    local value4 = createInstance(
                        "ImageLabel",
                        {
                            Name = "ValueIcon",
                            BackgroundTransparency = 1,
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.new(0, 8, 0.5, 0),
                            Size = UDim2.fromOffset(20, 20),
                            ScaleType = Enum.ScaleType.Fit,
                            Visible = false,
                            ZIndex = 3,
                            Parent = parent,
                        }
                    )
                    u.corner(value4, 5)
                    createInstance(
                        "Frame",
                        {
                            Name = "Divider",
                            AnchorPoint = Vector2.new(1, 0.5),
                            Position = UDim2.new(1, -30, 0.5, 0),
                            Size = UDim2.new(0, 1, 1, -12),
                            BorderSizePixel = 0,
                            BackgroundColor3 = color,
                            BackgroundTransparency = 0.9,
                            ZIndex = 3,
                            Parent = parent,
                        }
                    )
                    local value6, entries2 =
                        icon({
                            Parent = parent,
                            Icon = "chevron-down",
                            Size = 14,
                            Pos = UDim2.new(1, -15, 0.5, 0),
                            Anchor = Vector2.new(0.5, 0.5),
                            Color = "Muted",
                            Z = 3,
                        }),
                        {}
                    entries2.Row = rowObj.Frame
                    entries2.Type = "Dropdown"
                    local function callback(argument)
                        local value7 = value
                        for unused, item in ipairs(value7) do
                            if item.value == argument then
                                return item.label
                            end
                        end
                        return argument ~= nil and tostring(argument) or nil
                    end
                    local function isActive2()
                        if calculatedValue4 then
                            local entries3, concatResult = {}, value
                            for key, item in ipairs(concatResult) do
                                key = entries
                                if key[item.value] then
                                    table.insert(entries3, item.label)
                                end
                            end
                            concatResult = table.concat(entries3, ", ")
                            value5.Text = #entries3 == 0
                                    and (calculatedValue2.Placeholder or localization2.tr("None"))
                                or (
                                    (#entries3 == 1 or #concatResult <= 13) and concatResult
                                    or #entries3 .. " " .. localization2.tr("selected")
                                )
                        else
                            local text = callback(value2)
                                or (calculatedValue2.Placeholder or localization2.tr("Select"))
                            value5.Text = text
                        end
                        local image
                        if calculatedValue4 then
                        else
                            local value7 = value
                            for unused, item in ipairs(value7) do
                                if item.value == value2 then
                                    image = item.image
                                    break
                                end
                            end
                        end
                        if image then
                            value4.Image = image
                            value4.Visible = true
                            value5.Position = UDim2.fromOffset(34, 0)
                            value5.Size = UDim2.new(1, -68, 1, 0)
                        elseif value4.Visible then
                            value4.Visible = false
                            value5.Position = UDim2.fromOffset(12, 0)
                            value5.Size = UDim2.new(1, -46, 1, 0)
                        end
                    end
                    isActive2()
                    rowObj.SearchExtra = function()
                        return value5.Text
                    end
                    rowObj.SearchOptions = function()
                        local entries3, value5 = {}, value
                        for unused, item in ipairs(value5) do
                            table.insert(entries3, tostring(item.label))
                        end
                        return table.concat(entries3, " ")
                    end
                    local function isActive3()
                        if not calculatedValue4 then
                            local value5 = value2
                            return value5
                        end
                        local entries3, value4 = {}, value
                        for key, item in ipairs(value4) do
                            key = entries
                            if key[item.value] then
                                table.insert(entries3, item.value)
                            end
                        end
                        return entries3
                    end
                    local enabled = false
                    local function handleAction()
                        if enabled then
                            window:ClosePopups()
                            return
                        end
                        enabled = true
                        sound.play("click")
                        local maximumValue, calculatedValue, maximumValue2 =
                            math.max(window.PopScale.Scale, 0.1), value, 96
                        for unused, item in ipairs(calculatedValue) do
                            maximumValue2 = math.max(maximumValue2, u.textWidth(item.label, font.Medium(), 13) + 56)
                        end
                        local minimumValue, count =
                            math.min(math.max(parent.AbsoluteSize.X / maximumValue, maximumValue2), 280), #value
                        maximumValue = count > 8 and 42 or 0
                        calculatedValue = math.min(count, 8) * 32 + 8 + maximumValue
                        local popupShellResult, parent2, popupShellResult2 =
                            window:PopupShell(minimumValue, calculatedValue)
                        local popupPlaceResult, popupPlaceResult2, unused, popupPlaceResult3 =
                            window:PopupPlace(parent, minimumValue, calculatedValue, "right")
                        popupShellResult.Position = UDim2.fromOffset(popupPlaceResult, popupPlaceResult2)
                        window:PopupReveal(popupShellResult, parent2, popupShellResult2, popupPlaceResult3 == 1)
                        tweenInstance(value6, "Base", { Rotation = 180 })
                        paint(value3, "Color", "Accent", "Quick")
                        tweenInstance(value3, "Quick", { Transparency = 0.25 })
                        paint(value6, "ImageColor3", "Accent", "Quick")
                        local lowerResult = ""
                        local parent3 = createInstance(
                            "ScrollingFrame",
                            {
                                Name = "List",
                                Position = UDim2.fromOffset(0, maximumValue),
                                Size = UDim2.new(1, 0, 1, -maximumValue),
                                BackgroundTransparency = 1,
                                BorderSizePixel = 0,
                                ScrollBarThickness = 2,
                                CanvasSize = UDim2.new(),
                                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                                ZIndex = 61,
                                Parent = parent2,
                            }
                        )
                        bindTheme(parent3, "ScrollBarImageColor3", "Faint")
                        u.list(parent3, 2)
                        u.pad(parent3, 5, 5, 5, 5)
                        local entries3 = {}
                        local function isActive4()
                            local value4 = entries3
                            for unused, item in ipairs(value4) do
                                item:Destroy()
                            end
                            entries3 = {}
                            value4 = value
                            for layoutOrder, item in ipairs(value4) do
                                if
                                    lowerResult == "" or string.find(string.lower(item.label), lowerResult, 1, true)
                                then
                                    local entry
                                    if calculatedValue4 then
                                        local value4 = entries
                                        entry = value4[item.value]
                                    else
                                        entry = calculatedValue4
                                    end
                                    local calculatedValue = entry
                                        or (if calculatedValue4 then not calculatedValue4 else item.value == value2)
                                    local parent4 = createInstance(
                                        "TextButton",
                                        {
                                            Name = "Opt",
                                            Text = "",
                                            AutoButtonColor = false,
                                            Size = UDim2.new(1, 0, 0, 30),
                                            BackgroundTransparency = calculatedValue and 0.8 or 1,
                                            BorderSizePixel = 0,
                                            LayoutOrder = layoutOrder,
                                            ZIndex = 62,
                                            Parent = parent3,
                                        }
                                    )
                                    bindTheme(
                                        parent4,
                                        "BackgroundColor3",
                                        calculatedValue and "Accent" or "Surface2"
                                    )
                                    u.corner(parent4, 8)
                                    entry = 11
                                    if item.image then
                                        local value4 = createInstance(
                                            "ImageLabel",
                                            {
                                                Name = "Icon",
                                                Image = item.image,
                                                BackgroundTransparency = 1,
                                                AnchorPoint = Vector2.new(0, 0.5),
                                                Position = UDim2.new(0, 8, 0.5, 0),
                                                Size = UDim2.fromOffset(22, 22),
                                                ScaleType = Enum.ScaleType.Fit,
                                                ZIndex = 62,
                                                Parent = parent4,
                                            }
                                        )
                                        u.corner(value4, 6)
                                        entry = 37
                                    else
                                    end
                                    local value4 = label({
                                        Parent = parent4,
                                        Text = item.label,
                                        Font = calculatedValue and font.Semi() or font.Medium(),
                                        Size = 13,
                                        Pos = UDim2.fromOffset(entry, 0),
                                        Box = UDim2.new(1, -(entry + 27), 1, 0),
                                        Truncate = true,
                                        Color = "Text",
                                        Z = 62,
                                    })
                                    local value5 = icon({
                                        Parent = parent4,
                                        Icon = "check",
                                        Size = 14,
                                        Pos = UDim2.new(1, -10, 0.5, 0),
                                        Anchor = Vector2.new(1, 0.5),
                                        Color = "Accent",
                                        Z = 62,
                                    })
                                    if not calculatedValue then
                                        value5.ImageTransparency = 1
                                    end
                                    local enabled2 = false
                                    local function isActive5()
                                        local entry
                                        if calculatedValue4 then
                                            local value7 = entries
                                            entry = value7[item.value]
                                        else
                                            entry = calculatedValue4
                                        end
                                        local calculatedValue = entry
                                            or (
                                                if calculatedValue4
                                                    then not calculatedValue4
                                                    else item.value == value2
                                            )
                                        paint(
                                            parent4,
                                            "BackgroundColor3",
                                            calculatedValue and "Accent" or "Surface2",
                                            "Quick"
                                        )
                                        local entries4, calculatedValue3 =
                                            {}, enabled2 and (calculatedValue and 0.68 or 0.5)
                                        entries4.BackgroundTransparency = calculatedValue3
                                            or (calculatedValue and 0.8 or 1)
                                        tweenInstance(parent4, "Quick", entries4)
                                    end
                                    parent4.MouseEnter:Connect(function()
                                        enabled2 = true
                                        isActive5()
                                    end)
                                    u.leave(parent4, function()
                                        enabled2 = false
                                        isActive5()
                                    end)
                                    parent4.MouseButton1Click:Connect(function()
                                        sound.play("tick")
                                        if calculatedValue4 then
                                            local value7, value8, value9 = entries, item.value, entries
                                            local entry = value9[item.value]
                                            value7[value8] = if entry then nil else not entry
                                            value7 = entries
                                            value8 = value7[item.value] == true
                                            tweenInstance(
                                                value5,
                                                "Quick",
                                                { ImageTransparency = value8 and 0 or 1 }
                                            )
                                            value4.FontFace = value8 and font.Semi() or font.Medium()
                                            isActive5()
                                            isActive2()
                                            safe(calculatedValue2.Callback, isActive3())
                                            if entries2.Changed then
                                                safe(entries2.Changed, isActive3())
                                            end
                                        else
                                            value2 = item.value
                                            isActive2()
                                            window:ClosePopups()
                                            safe(calculatedValue2.Callback, value2)
                                            if entries2.Changed then
                                                safe(entries2.Changed, value2)
                                            end
                                        end
                                    end)
                                    table.insert(entries3, parent4)
                                end
                            end
                        end
                        if maximumValue > 0 then
                            local value4 = createInstance(
                                "TextBox",
                                {
                                    Name = "Filter",
                                    Position = UDim2.fromOffset(6, 7),
                                    Size = UDim2.new(1, -12, 0, 28),
                                    BorderSizePixel = 0,
                                    Text = "",
                                    PlaceholderText = localization2.tr("Search") .. "...",
                                    FontFace = font.Medium(),
                                    TextSize = 13,
                                    ClearTextOnFocus = false,
                                    TextXAlignment = Enum.TextXAlignment.Left,
                                    ZIndex = 62,
                                    Parent = parent2,
                                }
                            )
                            bindTheme(value4, "BackgroundColor3", "Surface")
                            bindTheme(value4, "TextColor3", "Text")
                            bindTheme(value4, "PlaceholderColor3", "Faint")
                            u.corner(value4, 7)
                            u.pad(value4, 0, 8, 0, 8)
                            value4:GetPropertyChangedSignal("Text"):Connect(function()
                                lowerResult = string.lower(value4.Text)
                                isActive4()
                            end)
                        end
                        isActive4()
                        window:OpenPopup({
                            close = function()
                                enabled = false
                                tweenInstance(value6, "Base", { Rotation = 0 })
                                paint(value3, "Color", "Glass", "Quick")
                                tweenInstance(value3, "Quick", { Transparency = 0.84 })
                                paint(value6, "ImageColor3", "Muted", "Quick")
                                window:PopupConceal(popupShellResult, parent2)
                                task.delay(0.18, function()
                                    popupShellResult:Destroy()
                                end)
                            end,
                        })
                    end
                    parent.MouseButton1Click:Connect(handleAction)
                    parent.MouseEnter:Connect(function()
                        if enabled then
                            return
                        end
                        paint(value3, "Color", "Accent", "Quick")
                        tweenInstance(value3, "Quick", { Transparency = 0.62 })
                        paint(value6, "ImageColor3", "Text", "Quick")
                    end)
                    u.leave(parent, function()
                        if enabled then
                            return
                        end
                        paint(value3, "Color", "Glass", "Quick")
                        tweenInstance(value3, "Quick", { Transparency = 0.84 })
                        paint(value6, "ImageColor3", "Muted", "Quick")
                    end)
                    entries2.Set = function(unused, argument, argument2)
                        if calculatedValue4 then
                            entries = {}
                            local callback, calculatedValue = ipairs, type(argument) == "table" and argument or {}
                            for unused, item in callback(calculatedValue) do
                                entries[item] = true
                            end
                        else
                            value2 = argument
                        end
                        isActive2()
                        if not argument2 then
                            safe(calculatedValue2.Callback, isActive3())
                        end
                    end
                    entries2.SetValue = function(unused, argument)
                        entries2:Set(argument)
                    end
                    entries2.SetSilent = function(unused, argument)
                        entries2:Set(argument, true)
                    end
                    entries2.Get = function(unused)
                        return isActive3()
                    end
                    entries2.SetOptions = function(unused, argument)
                        value = callback3(argument)
                        isActive2()
                    end
                    entries2.Refresh = entries2.SetOptions
                    entries2.SetText = function(unused, argument)
                        rowObj.SetText(argument)
                    end
                    entries2.SetVisible = function(unused, argument)
                        rowObj.SetVisible(argument)
                    end
                    entries2.SetParentHidden = function(unused, argument)
                        rowObj.SetParentHidden(argument)
                    end
                    entries2.RowObj = rowObj
                    entries2.Title = rowObj.Title
                    return entries2
                end
                sectionClass.Button = function(parent, argument)
                    local calculatedValue = argument or {}
                    local window = parent.Window
                    local rowObj = parent:_row({
                        Text = "",
                        Tooltip = calculatedValue.Tooltip,
                        Height = 44,
                        Reserve = 0,
                        Indent = calculatedValue.Indent,
                        Order = calculatedValue.Order,
                        Parent = calculatedValue.Parent,
                    })
                    rowObj.Title.Visible = false
                    rowObj.Right.Visible = false
                    rowObj.Hover.Visible = false
                    local calculatedValue2 = calculatedValue.Style == "Primary"
                    local base = createInstance(
                        "TextButton",
                        {
                            Name = "Button",
                            Text = "",
                            AutoButtonColor = false,
                            Position = UDim2.fromOffset(8 + rowObj.Indent, 5),
                            Size = UDim2.new(1, -(16 + rowObj.Indent), 0, 34),
                            BorderSizePixel = 0,
                            ClipsDescendants = true,
                            ZIndex = 2,
                            Parent = rowObj.Frame,
                        }
                    )
                    bindTheme(base, "BackgroundColor3", calculatedValue2 and "Accent" or "Surface2")
                    u.corner(base, 9)
                    local parent2 = u.stroke(base, color, 1, 0.9)
                    bindTheme(parent2, "Color", "Glass")
                    local shadowResult = u.shadow(base, 0.7, 10, 3, 0)
                    local value = createInstance("UIScale", { Parent = base })
                    createInstance(
                        "UIGradient",
                        { Color = ColorSequence.new(color, Color3.fromRGB(205, 207, 214)), Rotation = 90, Parent = base }
                    )
                    parent = createInstance(
                        "Frame",
                        {
                            Name = "Bevel",
                            Size = UDim2.new(1, -16, 0, 1),
                            Position = UDim2.fromOffset(8, 1),
                            BorderSizePixel = 0,
                            BackgroundColor3 = color,
                            BackgroundTransparency = calculatedValue2 and 0.55 or 0.8,
                            ZIndex = 3,
                            Parent = base,
                        }
                    )
                    createInstance(
                        "UIGradient",
                        {
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 1),
                                NumberSequenceKeypoint.new(0.5, 0),
                                NumberSequenceKeypoint.new(1, 1),
                            }),
                            Parent = parent,
                        }
                    )
                    local imageTransparency = 1
                    local imageTransparency2 = calculatedValue2 and 0.76 or 0.66
                    parent = createInstance(
                        "CanvasGroup",
                        { Name = "SpotClip", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 2, Parent = base }
                    )
                    u.corner(parent, 9)
                    local imageResult = tex.image(
                        parent,
                        "glow",
                        {
                            Name = "Spot",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(190, 120),
                            ImageTransparency = imageTransparency,
                            ZIndex = 2,
                        }
                    )
                    if imageResult then
                        bindTheme(imageResult, "ImageColor3", calculatedValue2 and "OnAccent" or "Accent")
                    end
                    local value2 = createInstance(
                        "UIGradient",
                        {
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 0.85),
                                NumberSequenceKeypoint.new(0.5, 0),
                                NumberSequenceKeypoint.new(1, 0.85),
                            }),
                            Enabled = false,
                            Parent = parent2,
                        }
                    )
                    local tweenInfo = TweenInfo.new(0.24, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                    local tweenInfo2 = TweenInfo.new(0.32, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
                    local tweenInfo3 = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local tweenInfo4 = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    local tweenInfo5, enabled =
                        TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), false
                    local function callback(argument)
                        local absolutePosition, absoluteSize = base.AbsolutePosition, base.AbsoluteSize
                        if absoluteSize.X < 1 then
                            return
                        end
                        local clampedValue = u.clamp((u.mouse().X - absolutePosition.X) / absoluteSize.X, 0, 1)
                        if imageResult then
                            if argument then
                                imageResult.Position = UDim2.fromScale(clampedValue, 0.5)
                            else
                                tweenInstance(
                                    imageResult,
                                    tweenInfo3,
                                    { Position = UDim2.fromScale(clampedValue, 0.5) }
                                )
                            end
                        end
                        if argument then
                            value2.Offset = Vector2.new(clampedValue - 0.5, 0)
                        else
                            tweenInstance(value2, tweenInfo3, { Offset = Vector2.new(clampedValue - 0.5, 0) })
                        end
                    end
                    parent = createInstance(
                        "Frame",
                        { Name = "Content", Size = UDim2.fromScale(1, 1), BackgroundTransparency = 1, ZIndex = 3, Parent = base }
                    )
                    local label2 = label({
                        Parent = parent,
                        Text = calculatedValue.Text or "Button",
                        Font = font.Semi(),
                        Size = 14,
                        Box = UDim2.fromScale(1, 1),
                        AlignX = Enum.TextXAlignment.Center,
                        Color = calculatedValue2 and "OnAccent" or "Text",
                        Z = 3,
                    })
                    if calculatedValue.Icon then
                        label2.Size = UDim2.new(1, -24, 1, 0)
                        label2.Position = UDim2.fromOffset(24, 0)
                        icon({
                            Parent = parent,
                            Icon = calculatedValue.Icon,
                            Size = 15,
                            Pos = UDim2.new(
                                0.5,
                                -math.floor(u.textWidth(calculatedValue.Text or "", font.Semi(), 14) / 2) - 2,
                                0.5,
                                0
                            ),
                            Anchor = Vector2.new(1, 0.5),
                            Color = calculatedValue2 and "OnAccent" or "Accent",
                            Z = 3,
                        })
                    end
                    local enabled2, counter = false, 0
                    local entries = { Row = rowObj.Frame, Type = "Button", Base = base }
                    local function isActive2()
                        enabled2 = false
                        label2.Text = calculatedValue.Text or "Button"
                        value2.Enabled = enabled
                        local calculatedValue3 = enabled and (calculatedValue2 and "OnAccent" or "Accent")
                        paint(parent2, "Color", calculatedValue3 or "Glass", "Quick")
                        local entries2, calculatedValue3 = {}, enabled and (calculatedValue2 and 0.55 or 0.4)
                        entries2.Transparency = calculatedValue3 or 0.9
                        tweenInstance(parent2, "Quick", entries2)
                    end
                    base.MouseEnter:Connect(function()
                        if calculatedValue.Locked then
                            return
                        end
                        enabled = true
                        callback(true)
                        if imageResult then
                            tweenInstance(imageResult, tweenInfo, { ImageTransparency = imageTransparency2 })
                        end
                        if not calculatedValue2 then
                            paint(base, "BackgroundColor3", "Elevated", tweenInfo)
                        end
                        if shadowResult then
                            tweenInstance(shadowResult, tweenInfo, { Transparency = 0.55 })
                        end
                        if not enabled2 then
                            value2.Enabled = true
                            paint(parent2, "Color", calculatedValue2 and "OnAccent" or "Accent", tweenInfo)
                            tweenInstance(parent2, tweenInfo, { Transparency = calculatedValue2 and 0.55 or 0.4 })
                        end
                        sound.play("hover", 0.6)
                        if calculatedValue.Tooltip then
                            window:ShowTip(calculatedValue.Tooltip)
                        end
                    end)
                    base.MouseMoved:Connect(function()
                        if enabled then
                            callback(false)
                        end
                    end)
                    u.leave(base, function()
                        enabled = false
                        if imageResult then
                            tweenInstance(imageResult, tweenInfo2, { ImageTransparency = imageTransparency })
                        end
                        if not calculatedValue2 then
                            paint(base, "BackgroundColor3", "Surface2", tweenInfo2)
                        end
                        if shadowResult then
                            tweenInstance(shadowResult, tweenInfo2, { Transparency = 0.75 })
                        end
                        if not enabled2 then
                            paint(parent2, "Color", "Glass", tweenInfo2)
                            tweenInstance(parent2, tweenInfo2, { Transparency = 0.9 })
                            task.delay(0.32, function()
                                if not enabled then
                                    if not enabled2 then
                                        value2.Enabled = false
                                    end
                                end
                            end)
                        end
                        tweenInstance(value, tweenInfo5, { Scale = 1 })
                        window:HideTip()
                    end)
                    local function handleAction()
                        if calculatedValue.Locked then
                            return
                        end
                        tweenInstance(value, tweenInfo4, { Scale = 0.975 })
                        if imageResult then
                            tweenInstance(
                                imageResult,
                                tweenInfo4,
                                { ImageTransparency = imageTransparency2 - 0.14 }
                            )
                        end
                    end
                    base.MouseButton1Down:Connect(handleAction)
                    base.MouseButton1Up:Connect(function()
                        tweenInstance(value, tweenInfo5, { Scale = 1 })
                        if imageResult then
                            tweenInstance(
                                imageResult,
                                tweenInfo5,
                                { ImageTransparency = enabled and imageTransparency2 or imageTransparency }
                            )
                        end
                    end)
                    base.MouseButton1Click:Connect(function()
                        if calculatedValue.Locked then
                            return
                        end
                        sound.play("click")
                        if calculatedValue.Confirm then
                            if type(window.ConfirmPopup) == "function" then
                                local function handleAction2()
                                    safe(calculatedValue.Callback)
                                end
                                window:ConfirmPopup(base, calculatedValue.Confirm, handleAction2)
                                return
                            end
                        end
                        if calculatedValue.DoubleClick and not enabled2 then
                            enabled2 = true
                            counter += 1
                            local value3 = counter
                            label2.Text = calculatedValue.ConfirmText or "Click again to confirm"
                            value2.Enabled = false
                            paint(parent2, "Color", "Danger", "Quick")
                            tweenInstance(parent2, "Quick", { Transparency = 0.3 })
                            task.delay(2.5, function()
                                if enabled2 then
                                    if counter == value3 then
                                        isActive2()
                                    end
                                end
                            end)
                            return
                        end
                        if enabled2 then
                            isActive2()
                        end
                        safe(calculatedValue.Callback)
                    end)
                    entries.SetText = function(unused, argument)
                        calculatedValue.Text = tostring(argument)
                        if not enabled2 then
                            label2.Text = calculatedValue.Text
                        end
                    end
                    entries.SetVisible = function(unused, argument)
                        rowObj.SetVisible(argument)
                    end
                    entries.SetParentHidden = function(unused, argument)
                        rowObj.SetParentHidden(argument)
                    end
                    entries.SetLocked = function(unused, locked)
                        calculatedValue.Locked = locked
                        label2.TextTransparency = locked and 0.5 or 0
                    end
                    rowObj.SearchExtra = function()
                        return calculatedValue.Text or ""
                    end
                    entries.RowObj = rowObj
                    entries.Label = label2
                    return entries
                end
                sectionClass.Keybind = function(argument, argument2)
                    local calculatedValue = argument2 or {}
                    local window = argument.Window
                    local rowObj, entries =
                        argument:_row({
                            Text = calculatedValue.Text,
                            Desc = calculatedValue.Desc,
                            Tooltip = calculatedValue.Tooltip,
                            Reserve = 110,
                            Indent = calculatedValue.Indent,
                            Order = calculatedValue.Order,
                            Parent = calculatedValue.Parent,
                        }),
                        {}
                    entries.Row = rowObj.Frame
                    entries.Type = "Keybind"
                    local value = callback2(window, rowObj.Right, calculatedValue.Default, function(key)
                        entries.Key = key
                        window:_kbDirty()
                        safe(calculatedValue.Callback, key)
                        safe(calculatedValue.ChangedCallback, key)
                    end, 10)
                    entries.Key = calculatedValue.Default
                    u.connect(userInputService.InputBegan, function(argument, argument2)
                        if window.Listening then
                            return
                        elseif calculatedValue.Pressed then
                            if not entries.Key then
                                return
                            end
                        else
                            return
                        end
                        if userInputService:GetFocusedTextBox() then
                            return
                        end
                        if localization2.bindHit(window, argument, entries.Key, argument2) then
                            safe(calculatedValue.Pressed, entries.Key)
                        end
                    end, window.Conns)
                    entries.Set = function(unused, key)
                        entries.Key = key
                        value.Set(key, true)
                        window:_kbDirty()
                    end
                    if not calculatedValue.NoList then
                        window:RegisterKeybind({
                            kind = "key",
                            name = function()
                                return rowObj.Title.Text
                            end,
                            key = function()
                                return entries.Key
                            end,
                            active = function()
                                if type(calculatedValue.Active) == "function" then
                                    return calculatedValue.Active() and true or false
                                end
                                return localization2.keyHeld(entries.Key)
                            end,
                            set = function(argument)
                                value.Set(argument)
                            end,
                            alive = function()
                                return rowObj.Frame.Parent ~= nil
                            end,
                        })
                    end
                    entries.SetValue = entries.Set
                    entries.Get = function(unused)
                        return entries.Key
                    end
                    entries.SetText = function(unused, argument)
                        rowObj.SetText(argument)
                    end
                    entries.SetVisible = function(unused, argument)
                        rowObj.SetVisible(argument)
                    end
                    entries.SetParentHidden = function(unused, argument)
                        rowObj.SetParentHidden(argument)
                    end
                    rowObj.SearchExtra = function()
                        return keyName(entries.Key)
                    end
                    entries.RowObj = rowObj
                    entries.Title = rowObj.Title
                    return entries
                end
                sectionClass.Input = function(argument, argument2)
                    local calculatedValue = argument2 or {}
                    local rowObj = argument:_row({
                        Text = calculatedValue.Text,
                        Desc = calculatedValue.Desc,
                        Tooltip = calculatedValue.Tooltip,
                        Reserve = 200,
                        Indent = calculatedValue.Indent,
                        Order = calculatedValue.Order,
                        Parent = calculatedValue.Parent,
                    })
                    local parent, value = field(
                        rowObj.Right,
                        { Name = "Input", Size = UDim2.fromOffset(calculatedValue.Width or 150, 30) }
                    )
                    if not calculatedValue.Width then
                        rowObj.OnWidth = function(argument)
                            local roundedValue = math.floor(u.clamp(argument * 0.5, 118, 200))
                            if parent.Size.X.Offset ~= roundedValue then
                                parent.Size = UDim2.fromOffset(roundedValue, 30)
                            end
                        end
                    end
                    local box = createInstance(
                        "TextBox",
                        {
                            Name = "Box",
                            BackgroundTransparency = 1,
                            Position = UDim2.fromOffset(10, 0),
                            Size = UDim2.new(1, -20, 1, 0),
                            Text = tostring(calculatedValue.Default or ""),
                            PlaceholderText = calculatedValue.Placeholder or "",
                            FontFace = font.Medium(),
                            TextSize = 13,
                            ClearTextOnFocus = calculatedValue.ClearOnFocus == true,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            TextTruncate = Enum.TextTruncate.AtEnd,
                            ZIndex = 3,
                            Parent = parent,
                        }
                    )
                    bindTheme(box, "TextColor3", "Text")
                    bindTheme(box, "PlaceholderColor3", "Faint")
                    local entries, text = { Row = rowObj.Frame, Type = "Input", Box = box }, box.Text
                    local function handleAction()
                        paint(value, "Color", "Accent", "Quick")
                        tweenInstance(value, "Quick", { Transparency = 0.25 })
                    end
                    box.Focused:Connect(handleAction)
                    box.FocusLost:Connect(function(argument)
                        paint(value, "Color", "Glass", "Quick")
                        tweenInstance(value, "Quick", { Transparency = 0.84 })
                        if calculatedValue.Numeric then
                            if box.Text ~= "" then
                                if not (tonumber(box.Text)) then
                                    box.Text = text
                                end
                            end
                        end
                        if box.Text ~= text or argument then
                            text = box.Text
                            safe(
                                calculatedValue.Callback,
                                calculatedValue.Numeric and tonumber(box.Text) or box.Text
                            )
                            safe(
                                calculatedValue.Finished,
                                calculatedValue.Numeric and tonumber(box.Text) or box.Text,
                                argument
                            )
                        end
                    end)
                    if calculatedValue.Live then
                        local function handleAction2()
                            if calculatedValue.Numeric then
                                if box.Text ~= "" then
                                    if not (tonumber(box.Text)) then
                                        if box.Text ~= "-" then
                                            if box.Text ~= "." then
                                                return
                                            end
                                        end
                                    end
                                end
                            end
                            safe(
                                calculatedValue.Callback,
                                calculatedValue.Numeric and tonumber(box.Text) or box.Text
                            )
                        end
                        box:GetPropertyChangedSignal("Text"):Connect(handleAction2)
                    end
                    entries.Set = function(unused, argument)
                        box.Text = tostring(argument or "")
                        text = box.Text
                    end
                    entries.SetValue = entries.Set
                    entries.Get = function(unused)
                        return calculatedValue.Numeric and tonumber(box.Text) or box.Text
                    end
                    entries.SetText = function(unused, argument)
                        rowObj.SetText(argument)
                    end
                    entries.SetVisible = function(unused, argument)
                        rowObj.SetVisible(argument)
                    end
                    entries.SetParentHidden = function(unused, argument)
                        rowObj.SetParentHidden(argument)
                    end
                    entries.RowObj = rowObj
                    entries.Title = rowObj.Title
                    return entries
                end
                local function callback(argument)
                    return "#" .. string.upper(argument:ToHex())
                end
                sectionClass.Colorpicker = function(entries, argument)
                    local calculatedValue = argument or {}
                    local window = entries.Window
                    local rowObj = entries:_row({
                        Text = calculatedValue.Text,
                        Desc = calculatedValue.Desc,
                        Tooltip = calculatedValue.Tooltip,
                        Reserve = 150,
                        Indent = calculatedValue.Indent,
                        Order = calculatedValue.Order,
                        Parent = calculatedValue.Parent,
                    })
                    local backgroundColor = typeof(calculatedValue.Default) == "Color3" and calculatedValue.Default
                        or Color3.new(1, 1, 1)
                    local clampedValue = math.clamp(tonumber(calculatedValue.DefaultAlpha) or 1, 0, 1)
                    local calculatedValue2 = calculatedValue.Alpha ~= false
                    local clampedValue2, clampedValue3, toHSVResult = backgroundColor:ToHSV()
                    local function isActive2()
                        if calculatedValue2 then
                            if clampedValue < 0.995 then
                                local value, calculatedValue3 =
                                    callback(backgroundColor), "  " .. math.floor(clampedValue * 100 + 0.5) .. "%"
                                return value .. calculatedValue3
                            end
                        end
                        local value = backgroundColor
                        return callback(value)
                    end
                    local value = label({
                        Parent = rowObj.Right,
                        Text = isActive2(),
                        Font = font.Semi(),
                        Size = 12,
                        Box = UDim2.new(0, 0, 0, 20),
                        Auto = Enum.AutomaticSize.X,
                        AlignX = Enum.TextXAlignment.Right,
                        Color = "Faint",
                        Z = 3,
                        Name = "Hex",
                    })
                    value.LayoutOrder = 5
                    local value2
                    local function image()
                        task.spawn(function()
                            local text = rowObj.Title.Text
                            local textWidthResult = u.textWidth(text, rowObj.Title.FontFace, 14)
                            if rowObj.Title.Text == text then
                                value2 = textWidthResult
                                if rowObj.fitTitle then
                                    rowObj.fitTitle()
                                end
                            end
                        end)
                    end
                    rowObj.OnWidth = function(argument)
                        if not value2 then
                            return
                        end
                        local maximumValue = math.max(value.TextBounds.X / math.max(window.Scale.Scale, 0.1), 52)
                        local visible = argument - (10 + rowObj.Indent) - value2 - 44 - maximumValue - 32 >= 0
                        if value.Visible ~= visible then
                            value.Visible = visible
                        end
                    end
                    rowObj.Title:GetPropertyChangedSignal("Text"):Connect(image)
                    rowObj.Title:GetPropertyChangedSignal("FontFace"):Connect(image)
                    image()
                    local parent = createInstance(
                        "TextButton",
                        {
                            Name = "Swatch",
                            Text = "",
                            AutoButtonColor = false,
                            Size = UDim2.fromOffset(44, 24),
                            BackgroundTransparency = 1,
                            LayoutOrder = 10,
                            ZIndex = 3,
                            Parent = rowObj.Right,
                        }
                    )
                    local value2 = createInstance("UIScale", { Parent = parent })
                    image =
                        tex.image(parent, "checker", { Name = "Checker", Size = UDim2.fromScale(1, 1), ZIndex = 3 })
                    if image then
                        u.corner(image, 8)
                    end
                    local value3 = createInstance(
                        "Frame",
                        {
                            Name = "Fill",
                            Size = UDim2.fromScale(1, 1),
                            BorderSizePixel = 0,
                            BackgroundColor3 = backgroundColor,
                            BackgroundTransparency = calculatedValue2 and 1 - clampedValue or 0,
                            ZIndex = 4,
                            Parent = parent,
                        }
                    )
                    u.corner(value3, 8)
                    image, entries = tex.image, {}
                    entries.Size, entries.SliceScale, entries.ImageTransparency, entries.ZIndex =
                        UDim2.fromScale(1, 1), 0.57, 0.75, 5
                    image(parent, "gloss9", entries)
                    image = tex.image(
                        parent,
                        "rim9",
                        { Size = UDim2.fromScale(1, 1), SliceScale = 0.57, ImageTransparency = 0.3, ZIndex = 6 }
                    )
                    if image then
                        bindTheme(image, "ImageColor3", "Glass")
                    else
                        bindTheme(u.stroke(parent, color, 1, 0.7), "Color", "Glass")
                    end
                    local entries2 = {}
                    entries2.Row = rowObj.Frame
                    entries2.Type = "Colorpicker"
                    local isActive3
                    local function callback2(argument)
                        backgroundColor = Color3.fromHSV(clampedValue2, clampedValue3, toHSVResult)
                        value3.BackgroundColor3 = backgroundColor
                        value3.BackgroundTransparency = calculatedValue2 and 1 - clampedValue or 0
                        value.Text = isActive2()
                        if isActive3 then
                            isActive3()
                        end
                        if argument ~= false then
                            safe(calculatedValue.Callback, backgroundColor, clampedValue)
                            if entries2.Changed then
                                safe(entries2.Changed, backgroundColor, clampedValue)
                            end
                        end
                    end
                    local function callback3(parent2, argument)
                        local parent3 = createInstance(
                            "Frame",
                            {
                                Name = "Knob",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Size = UDim2.fromOffset(argument, argument),
                                BackgroundColor3 = backgroundColor,
                                ZIndex = 10,
                                Parent = parent2,
                            }
                        )
                        u.corner(parent3, UDim.new(1, 0))
                        u.stroke(parent3, color, 2, 0, Enum.ApplyStrokeMode.Border)
                        argument = createInstance(
                            "Frame",
                            {
                                Name = "Shade",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.new(1, 6, 1, 6),
                                BackgroundTransparency = 1,
                                ZIndex = 9,
                                Parent = parent3,
                            }
                        )
                        u.corner(argument, UDim.new(1, 0))
                        u.stroke(argument, Color3.new(0, 0, 0), 1, 0.7, Enum.ApplyStrokeMode.Border)
                        return parent3
                    end
                    local function handleAction()
                        sound.play("click")
                        local counter, counter2, parent2 = 12, 194, 234
                        local popupShellResult, parent3, fieldResult = window:PopupShell(236, parent2)
                        local parent4, parent5, unused, imageResult =
                            window:PopupPlace(parent, 236, parent2, "right")
                        popupShellResult.Position = UDim2.fromOffset(parent4, parent5)
                        window:PopupReveal(popupShellResult, parent3, fieldResult, imageResult == 1)
                        tweenInstance(value2, "Quick", { Scale = 0.94 })
                        local value, value3 = backgroundColor, clampedValue
                        local parent6 = createInstance(
                            "TextButton",
                            {
                                Name = "SV",
                                Text = "",
                                AutoButtonColor = false,
                                Position = UDim2.fromOffset(counter, counter),
                                Size = UDim2.fromOffset(212, 124),
                                BorderSizePixel = 0,
                                BackgroundColor3 = Color3.fromHSV(clampedValue2, 1, 1),
                                ZIndex = 5,
                                Parent = parent3,
                            }
                        )
                        u.corner(parent6, 9)
                        parent4 = createInstance(
                            "Frame",
                            {
                                Size = UDim2.fromScale(1, 1),
                                BorderSizePixel = 0,
                                BackgroundColor3 = color,
                                ZIndex = 6,
                                Parent = parent6,
                            }
                        )
                        u.corner(parent4, 9)
                        createInstance("UIGradient", { Transparency = NumberSequence.new(0, 1), Parent = parent4 })
                        parent2 = createInstance(
                            "Frame",
                            {
                                Size = UDim2.fromScale(1, 1),
                                BorderSizePixel = 0,
                                BackgroundColor3 = Color3.new(0, 0, 0),
                                ZIndex = 7,
                                Parent = parent6,
                            }
                        )
                        u.corner(parent2, 9)
                        createInstance(
                            "UIGradient",
                            { Transparency = NumberSequence.new(1, 0), Rotation = 90, Parent = parent2 }
                        )
                        parent5 = tex.image(
                            parent6,
                            "rim9",
                            { Size = UDim2.fromScale(1, 1), SliceScale = 0.71, ImageTransparency = 0.6, ZIndex = 8 }
                        )
                        if parent5 then
                            bindTheme(parent5, "ImageColor3", "Glass")
                        end
                        local value4 = callback3(parent6, 14)
                        parent2 = createInstance(
                            "Frame",
                            {
                                Name = "Preview",
                                Position = UDim2.fromOffset(counter, 148),
                                Size = UDim2.fromOffset(34, 34),
                                BackgroundTransparency = 1,
                                ZIndex = 5,
                                Parent = parent3,
                            }
                        )
                        parent4 = tex.image(parent2, "checker", { Size = UDim2.fromScale(1, 1), ZIndex = 5 })
                        if parent4 then
                            u.corner(parent4, UDim.new(1, 0))
                        end
                        local value5 = createInstance(
                            "Frame",
                            {
                                Name = "Fill",
                                Size = UDim2.fromScale(1, 1),
                                BorderSizePixel = 0,
                                BackgroundColor3 = backgroundColor,
                                ZIndex = 6,
                                Parent = parent2,
                            }
                        )
                        u.corner(value5, UDim.new(1, 0))
                        bindTheme(u.stroke(value5, color, 1, 0.75, Enum.ApplyStrokeMode.Border), "Color", "Glass")
                        fieldResult, parent2, imageResult = 60, 157, calculatedValue2 and 150 or 160
                        local parent4 = createInstance(
                            "TextButton",
                            {
                                Name = "Hue",
                                Text = "",
                                AutoButtonColor = false,
                                Position = UDim2.fromOffset(fieldResult, imageResult),
                                Size = UDim2.fromOffset(parent2, 10),
                                BorderSizePixel = 0,
                                BackgroundColor3 = color,
                                ZIndex = 5,
                                Parent = parent3,
                            }
                        )
                        u.corner(parent4, UDim.new(1, 0))
                        imageResult = {}
                        for index = 0, 6, 1 do
                            table.insert(
                                imageResult,
                                ColorSequenceKeypoint.new(index / 6, Color3.fromHSV(index / 6, 1, 1))
                            )
                        end
                        createInstance("UIGradient", { Color = ColorSequence.new(imageResult), Parent = parent4 })
                        local value6 = callback3(parent4, 14)
                        local parent7, value7, parent8, value8, value9, value10
                        if calculatedValue2 then
                            parent7 = createInstance(
                                "TextButton",
                                {
                                    Name = "Alpha",
                                    Text = "",
                                    AutoButtonColor = false,
                                    Position = UDim2.fromOffset(fieldResult, 170),
                                    Size = UDim2.fromOffset(parent2, 10),
                                    BorderSizePixel = 0,
                                    BackgroundTransparency = 1,
                                    ZIndex = 5,
                                    Parent = parent3,
                                }
                            )
                            u.corner(parent7, UDim.new(1, 0))
                            imageResult =
                                tex.image(parent7, "checker", { Size = UDim2.fromScale(1, 1), ZIndex = 5 })
                            if imageResult then
                                u.corner(imageResult, UDim.new(1, 0))
                            end
                            parent8 = createInstance(
                                "Frame",
                                {
                                    Size = UDim2.fromScale(1, 1),
                                    BorderSizePixel = 0,
                                    BackgroundColor3 = backgroundColor,
                                    ZIndex = 6,
                                    Parent = parent7,
                                }
                            )
                            u.corner(parent8, UDim.new(1, 0))
                            createInstance(
                                "UIGradient",
                                { Transparency = NumberSequence.new(1, 0), Parent = parent8 }
                            )
                            value7 = callback3(parent7, 14)
                            value8, value9, value10 = parent7, value7, parent8
                        else
                            value8, value9, value10 = parent7, value7, parent8
                        end
                        parent2 = calculatedValue2 and 56 or 0
                        imageResult = 178 - (calculatedValue2 and parent2 + 6 or 0)
                        local parent9, fieldResult2 = localization2.field(
                            parent3,
                            { Name = "HexField", Size = UDim2.fromOffset(imageResult, 28), Z = 5 }
                        )
                        parent9.Position = UDim2.fromOffset(counter, counter2)
                        label({
                            Parent = parent9,
                            Text = "#",
                            Font = font.Semi(),
                            Size = 12,
                            Pos = UDim2.fromOffset(9, 0),
                            Box = UDim2.fromOffset(10, 28),
                            Color = "Faint",
                            Z = 6,
                        })
                        local value11 = createInstance(
                            "TextBox",
                            {
                                BackgroundTransparency = 1,
                                Position = UDim2.fromOffset(20, 0),
                                Size = UDim2.new(1, -26, 1, 0),
                                Text = "",
                                FontFace = font.Semi(),
                                TextSize = 13,
                                ClearTextOnFocus = false,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                ZIndex = 6,
                                Parent = parent9,
                            }
                        )
                        bindTheme(value11, "TextColor3", "Text")
                        local value12, value13, value7, value14
                        if calculatedValue2 then
                            parent5, fieldResult = localization2.field(
                                parent3,
                                { Name = "AlphaField", Size = UDim2.fromOffset(parent2, 28), Z = 5 }
                            )
                            parent5.Position = UDim2.fromOffset(counter + imageResult + 6, counter2)
                            value12 = createInstance(
                                "TextBox",
                                {
                                    BackgroundTransparency = 1,
                                    Position = UDim2.fromOffset(8, 0),
                                    Size = UDim2.new(1, -24, 1, 0),
                                    Text = "",
                                    FontFace = font.Semi(),
                                    TextSize = 13,
                                    ClearTextOnFocus = false,
                                    TextXAlignment = Enum.TextXAlignment.Right,
                                    ZIndex = 6,
                                    Parent = parent5,
                                }
                            )
                            bindTheme(value12, "TextColor3", "Text")
                            label({
                                Parent = parent5,
                                Text = "%",
                                Font = font.Semi(),
                                Size = 12,
                                Anchor = Vector2.new(1, 0),
                                Pos = UDim2.new(1, -8, 0, 0),
                                Box = UDim2.fromOffset(12, 28),
                                AlignX = Enum.TextXAlignment.Right,
                                Color = "Faint",
                                Z = 6,
                            })
                            value7, value14 = value12, fieldResult
                        else
                            value7, value14 = value12, value13
                        end
                        local parent7, fieldResult3 = localization2.field(
                            parent3,
                            { Class = "TextButton", Name = "Revert", Size = UDim2.fromOffset(28, 28), Z = 5 }
                        )
                        parent7.Position = UDim2.fromOffset(196, counter2)
                        local value12 = icon({
                            Parent = parent7,
                            Icon = "rotate-ccw",
                            Size = 13,
                            Pos = UDim2.fromScale(0.5, 0.5),
                            Anchor = Vector2.new(0.5, 0.5),
                            Color = "Muted",
                            Z = 6,
                        })
                        local function handleAction2()
                            paint(value12, "ImageColor3", "Text", "Quick")
                            paint(fieldResult3, "Color", "Accent", "Quick")
                            tweenInstance(fieldResult3, "Quick", { Transparency = 0.5 })
                        end
                        parent7.MouseEnter:Connect(handleAction2)
                        u.leave(parent7, function()
                            paint(value12, "ImageColor3", "Muted", "Quick")
                            paint(fieldResult3, "Color", "Glass", "Quick")
                            tweenInstance(fieldResult3, "Quick", { Transparency = 0.84 })
                        end)
                        local tweenInfo, enabled =
                            TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), true
                        function isActive3()
                            local calculatedValue = enabled and TweenInfo.new(0) or tweenInfo
                            enabled = false
                            tweenInstance(
                                value4,
                                calculatedValue,
                                { Position = UDim2.fromScale(clampedValue3, 1 - toHSVResult) }
                            )
                            value4.BackgroundColor3 = backgroundColor
                            parent6.BackgroundColor3 = Color3.fromHSV(clampedValue2, 1, 1)
                            tweenInstance(
                                value6,
                                calculatedValue,
                                { Position = UDim2.fromScale(clampedValue2, 0.5) }
                            )
                            value6.BackgroundColor3 = Color3.fromHSV(clampedValue2, 1, 1)
                            value5.BackgroundColor3 = backgroundColor
                            value5.BackgroundTransparency = calculatedValue2 and 1 - clampedValue or 0
                            if value8 then
                                value10.BackgroundColor3 = backgroundColor
                                tweenInstance(
                                    value9,
                                    calculatedValue,
                                    { Position = UDim2.fromScale(clampedValue, 0.5) }
                                )
                                value9.BackgroundColor3 = backgroundColor
                                if not (value7:IsFocused()) then
                                    value7.Text = tostring(math.floor(clampedValue * 100 + 0.5))
                                end
                            end
                            if not (value11:IsFocused()) then
                                value11.Text = string.sub(callback(backgroundColor), 2)
                            end
                        end
                        isActive3()
                        local value15
                        local function callback3(argument)
                            if value15 == "sv" then
                                clampedValue3 = u.clamp(
                                    (argument.X - parent6.AbsolutePosition.X) / math.max(parent6.AbsoluteSize.X, 1),
                                    0,
                                    1
                                )
                                toHSVResult = 1
                                    - u.clamp(
                                        (argument.Y - parent6.AbsolutePosition.Y)
                                            / math.max(parent6.AbsoluteSize.Y, 1),
                                        0,
                                        1
                                    )
                            elseif value15 == "hue" then
                                clampedValue2 = u.clamp(
                                    (argument.X - parent4.AbsolutePosition.X) / math.max(parent4.AbsoluteSize.X, 1),
                                    0,
                                    0.999
                                )
                            elseif value15 == "alpha" then
                                if value8 then
                                    clampedValue = u.clamp(
                                        (argument.X - value8.AbsolutePosition.X)
                                            / math.max(value8.AbsoluteSize.X, 1),
                                        0,
                                        1
                                    )
                                end
                            end
                            callback2(true)
                        end
                        local value16
                        local function callback(argument, argument2, argument3)
                            value15, value16 = argument, argument3
                            if argument2 then
                                tweenInstance(argument2, "Quick", { Size = UDim2.fromOffset(17, 17) })
                            end
                        end
                        local function isActive2()
                            local entries = { value4, value6, value9 }
                            for key, item in ipairs(entries) do
                                if item then
                                    local new, enum = TweenInfo.new, Enum
                                    local quint, easingDirection = enum.EasingStyle.Quint, Enum.EasingDirection
                                    key, enum = new(0.25, quint, easingDirection.Out), {}
                                    enum.Size = UDim2.fromOffset(14, 14)
                                    tweenInstance(item, key, enum)
                                end
                            end
                            value15 = nil
                        end
                        local entries = {}
                        local function handleAction2(argument)
                            if u.isClick(argument) then
                                callback("sv", value4, argument)
                                callback3(argument.Position)
                            end
                        end
                        parent6.InputBegan:Connect(handleAction2)
                        local function handleAction3(argument)
                            if u.isClick(argument) then
                                callback("hue", value6, argument)
                                callback3(argument.Position)
                            end
                        end
                        parent4.InputBegan:Connect(handleAction3)
                        if value8 then
                            local function handleAction2(argument)
                                if u.isClick(argument) then
                                    callback("alpha", value9, argument)
                                    callback3(argument.Position)
                                end
                            end
                            value8.InputBegan:Connect(handleAction2)
                        end
                        table.insert(
                            entries,
                            userInputService.InputChanged:Connect(function(argument)
                                if value15 then
                                    if u.sameMove(argument, value16) then
                                        callback3(argument.Position)
                                    end
                                end
                            end)
                        )
                        table.insert(
                            entries,
                            userInputService.InputEnded:Connect(function(argument)
                                if value15 then
                                    if u.sameEnd(argument, value16) then
                                        isActive2()
                                    end
                                end
                            end)
                        )
                        parent7.MouseButton1Click:Connect(function()
                            clampedValue2, clampedValue3, toHSVResult = value:ToHSV()
                            clampedValue = value3
                            callback2(true)
                            sound.play("tick")
                            tweenInstance(
                                value12,
                                TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
                                { Rotation = -360 }
                            )
                            task.delay(0.36, function()
                                value12.Rotation = 0
                            end)
                        end)
                        local function handleAction2()
                            paint(fieldResult2, "Color", "Accent", "Quick")
                            tweenInstance(fieldResult2, "Quick", { Transparency = 0.25 })
                        end
                        value11.Focused:Connect(handleAction2)
                        value11.FocusLost:Connect(function()
                            paint(fieldResult2, "Color", "Glass", "Quick")
                            tweenInstance(fieldResult2, "Quick", { Transparency = 0.84 })
                            local text = value11.Text
                            local success, gsubResult, result =
                                string.match(text, "^%s*(%d+)%s*[,;%s]%s*(%d+)%s*[,;%s]%s*(%d+)%s*$")
                            if success then
                                clampedValue2, clampedValue3, toHSVResult = Color3.fromRGB(
                                    math.clamp(tonumber(success), 0, 255),
                                    math.clamp(tonumber(gsubResult), 0, 255),
                                    math.clamp(tonumber(result), 0, 255)
                                ):ToHSV()
                                callback2(true)
                                isActive3()
                                return
                            end
                            gsubResult = text:gsub("#", ""):gsub("%s", "")
                            gsubResult = if #gsubResult == 3
                                then gsubResult:sub(1, 1):rep(2) .. gsubResult:sub(2, 2):rep(2) .. gsubResult
                                    :sub(3, 3)
                                    :rep(2)
                                else gsubResult
                            result, success = pcall(Color3.fromHex, gsubResult)
                            if result then
                                if typeof(success) == "Color3" then
                                    if #gsubResult == 6 then
                                        clampedValue2, clampedValue3, toHSVResult = success:ToHSV()
                                        callback2(true)
                                    end
                                end
                            end
                            isActive3()
                        end)
                        if value7 then
                            local function handleAction4()
                                paint(value14, "Color", "Accent", "Quick")
                                tweenInstance(value14, "Quick", { Transparency = 0.25 })
                            end
                            value7.Focused:Connect(handleAction4)
                            value7.FocusLost:Connect(function()
                                paint(value14, "Color", "Glass", "Quick")
                                tweenInstance(value14, "Quick", { Transparency = 0.84 })
                                local numberValue = tonumber((value7.Text:gsub("%%", "")))
                                if numberValue then
                                    clampedValue = math.clamp(numberValue, 0, 100) / 100
                                    callback2(true)
                                end
                                isActive3()
                            end)
                        end
                        window:OpenPopup({
                            close = function()
                                for unused, item in ipairs(entries) do
                                    item:Disconnect()
                                end
                                isActive3 = nil
                                tweenInstance(value2, "Quick", { Scale = 1 })
                                window:PopupConceal(popupShellResult, parent3)
                                task.delay(0.18, function()
                                    popupShellResult:Destroy()
                                end)
                            end,
                        })
                    end
                    parent.MouseButton1Click:Connect(handleAction)
                    local function handleAction2()
                        if not (value2:GetAttribute("open")) then
                            tweenInstance(value2, "Quick", { Scale = 1.06 })
                        end
                    end
                    parent.MouseEnter:Connect(handleAction2)
                    u.leave(parent, function()
                        tweenInstance(value2, "Quick", { Scale = 1 })
                    end)
                    entries2.Set = function(unused, argument, argument2)
                        if typeof(argument) ~= "Color3" then
                            return
                        end
                        clampedValue2, clampedValue3, toHSVResult = argument:ToHSV()
                        if argument2 ~= nil then
                            clampedValue = math.clamp(tonumber(argument2) or 1, 0, 1)
                        end
                        callback2(true)
                    end
                    entries2.SetValue = entries2.Set
                    entries2.SetValueRGB = entries2.Set
                    entries2.SetSilent = function(unused, argument, argument2)
                        if typeof(argument) ~= "Color3" then
                            return
                        end
                        clampedValue2, clampedValue3, toHSVResult = argument:ToHSV()
                        if argument2 ~= nil then
                            clampedValue = math.clamp(tonumber(argument2) or 1, 0, 1)
                        end
                        callback2(false)
                    end
                    entries2.Get = function(unused)
                        local value4, value5 = backgroundColor, clampedValue
                        return value4, value5
                    end
                    entries2.SetText = function(unused, argument)
                        rowObj.SetText(argument)
                    end
                    entries2.SetVisible = function(unused, argument)
                        rowObj.SetVisible(argument)
                    end
                    entries2.SetParentHidden = function(unused, argument)
                        rowObj.SetParentHidden(argument)
                    end
                    entries2.RowObj = rowObj
                    entries2.Title = rowObj.Title
                    return entries2
                end
                sectionClass.Label = function(argument, text)
                    text = (if type(text) == "string" then { Text = text } else text) or {}
                    argument.Order = argument.Order + 1
                    local row = createInstance(
                        "Frame",
                        {
                            Name = "Label",
                            Size = UDim2.new(1, 0, 0, 0),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundTransparency = 1,
                            LayoutOrder = text.Order or argument.Order,
                            Parent = text.Parent or argument.Content,
                        }
                    )
                    u.pad(row, 6, 10, 6, 10 + (text.Indent or 0) * 14)
                    local title = label({
                        Parent = row,
                        Text = text.Text or "",
                        Font = font.Regular(),
                        Size = text.Size or 13,
                        Box = UDim2.new(1, 0, 0, 0),
                        Auto = Enum.AutomaticSize.Y,
                        Wrap = true,
                        Rich = true,
                        Color = text.Color or "Muted",
                    })
                    local options =
                        { Frame = row, Title = title, selfHidden = false, parentHidden = false, searchHidden = false }
                    local entry = {
                        text = function()
                            return string.lower(title.Text)
                        end,
                        refresh = function()
                            row.Visible = not (options.selfHidden or options.parentHidden or options.searchHidden)
                        end,
                    }
                    table.insert(argument.Tab.Rows, entry)
                    table.insert(argument.Rows, options)
                    options.Entry = entry
                    return {
                        Row = row,
                        Type = "Label",
                        Label = title,
                        SetText = function(unused, argument)
                            title.Text = tostring(argument)
                        end,
                        SetVisible = function(unused, argument)
                            options.selfHidden = not argument
                            entry.refresh()
                        end,
                        SetParentHidden = function(unused, argument)
                            options.parentHidden = argument and true or false
                            entry.refresh()
                        end,
                        Title = title,
                    }
                end
                sectionClass.Paragraph = function(argument, calculatedValue)
                    calculatedValue = calculatedValue or {}
                    argument.Order = argument.Order + 1
                    local row = createInstance(
                        "Frame",
                        {
                            Name = "Paragraph",
                            Size = UDim2.new(1, 0, 0, 0),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundTransparency = 1,
                            LayoutOrder = calculatedValue.Order or argument.Order,
                            Parent = calculatedValue.Parent or argument.Content,
                        }
                    )
                    u.pad(row, 8, 10, 8, 10)
                    u.list(row, 3)
                    local value = label({
                        Parent = row,
                        Text = calculatedValue.Title or "",
                        Font = font.Semi(),
                        Size = 14,
                        Box = UDim2.new(1, 0, 0, 18),
                    })
                    local value2 = label({
                        Parent = row,
                        Text = calculatedValue.Text or "",
                        Font = font.Regular(),
                        Size = 13,
                        Box = UDim2.new(1, 0, 0, 0),
                        Auto = Enum.AutomaticSize.Y,
                        Wrap = true,
                        Rich = true,
                        Color = "Muted",
                    })
                    value2.LayoutOrder = 1
                    return {
                        Row = row,
                        Type = "Paragraph",
                        SetTitle = function(unused, argument)
                            value.Text = tostring(argument)
                        end,
                        SetText = function(unused, argument)
                            value2.Text = tostring(argument)
                        end,
                        SetVisible = function(unused, visible)
                            row.Visible = visible
                        end,
                    }
                end
                sectionClass.Divider = function(argument, argument2)
                    argument.Order = argument.Order + 1
                    local row = createInstance(
                        "Frame",
                        {
                            Name = "Divider",
                            Size = UDim2.new(1, 0, 0, argument2 and 30 or 13),
                            BackgroundTransparency = 1,
                            LayoutOrder = argument.Order,
                            Parent = argument.Content,
                        }
                    )
                    bindTheme(
                        createInstance(
                            "Frame",
                            {
                                AnchorPoint = Vector2.new(0, 1),
                                Position = UDim2.new(0, 10, 1, -6),
                                Size = UDim2.new(1, -20, 0, 1),
                                BorderSizePixel = 0,
                                Parent = row,
                            }
                        ),
                        "BackgroundColor3",
                        "Line"
                    )
                    local value, label2
                    if argument2 then
                        value = label({
                            Parent = row,
                            Text = string.upper(argument2),
                            Font = font.Bold(),
                            Size = 11,
                            Pos = UDim2.fromOffset(10, 4),
                            Box = UDim2.new(1, -20, 0, 14),
                            Color = "Faint",
                        })
                        label2 = value
                    else
                        label2 = value
                    end
                    return {
                        Row = row,
                        Type = "Divider",
                        Label = label2,
                        SetText = function(unused, argument)
                            if label2 then
                                label2.Text = string.upper(tostring(argument))
                            end
                        end,
                        SetVisible = function(unused, visible)
                            row.Visible = visible
                        end,
                    }
                end
                sectionClass.Container = function(argument, calculatedValue)
                    calculatedValue = calculatedValue or {}
                    argument.Order = argument.Order + 1
                    local value = createInstance(
                        "Frame",
                        {
                            Name = "Container",
                            Size = UDim2.new(1, 0, 0, 0),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundTransparency = 1,
                            LayoutOrder = calculatedValue.Order or argument.Order,
                            Parent = calculatedValue.Parent or argument.Content,
                        }
                    )
                    u.pad(value, calculatedValue.Pad or 4, 8, calculatedValue.Pad or 4, 8)
                    u.list(value, calculatedValue.Gap or 6)
                    return value
                end
            end
            do
                local u = localization2.U
                local motion, theme = localization2.Motion, localization2.Theme
                local font = localization2.Font
                local unused, sound = localization2.Icons, localization2.Sound
                local tex = localization2.Tex
                local createInstance = u.new
                local tweenInstance = motion.tween
                local bindTheme = theme.bind
                local label = localization2.label
                local icon = localization2.icon
                local windowClass, entries =
                    localization2.WindowClass,
                    {
                        info = { token = "Accent", icon = "bell" },
                        success = { token = "Success", icon = "circle-check" },
                        warning = { token = "Warning", icon = "triangle-alert" },
                        danger = { token = "Danger", icon = "circle-x" },
                        error = { token = "Danger", icon = "circle-x" },
                    }
                local tweenInfo = TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
                local tweenInfo2 = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
                windowClass.Notify = function(argument, title)
                    if type(title) == "string" then
                        title = { Title = title }
                    else
                    end
                    local calculatedValue = title or {}
                    local calculatedValue2, maximumValue =
                        entries[string.lower(tostring(calculatedValue.Kind or calculatedValue.Type or "info"))]
                            or entries.info,
                        math.max(tonumber(calculatedValue.Duration) or 4, 0.5)
                    if not argument.ToastLayout then
                        argument.ToastLayout = u.list(
                            argument.Toasts,
                            8,
                            Enum.FillDirection.Vertical,
                            Enum.HorizontalAlignment.Right,
                            Enum.VerticalAlignment.Bottom
                        )
                    end
                    argument.ToastOrder = (argument.ToastOrder or 0) + 1
                    local parent = createInstance(
                        "Frame",
                        {
                            Name = "Toast",
                            Size = UDim2.new(1, 0, 0, 0),
                            BackgroundTransparency = 1,
                            LayoutOrder = argument.ToastOrder,
                            Parent = argument.Toasts,
                        }
                    )
                    local parent2 = createInstance(
                        "Frame",
                        {
                            Name = "Slide",
                            Position = UDim2.fromOffset(40, 0),
                            Size = UDim2.new(1, 0, 0, 52),
                            BackgroundTransparency = 1,
                            Parent = parent,
                        }
                    )
                    local imageResult = tex.image(
                        parent2,
                        "shadow9",
                        {
                            Name = "Shadow",
                            Position = UDim2.fromOffset(-22, -14),
                            Size = UDim2.new(1, 44, 1, 46),
                            SliceScale = 1,
                            ImageTransparency = 1,
                            ZIndex = 0,
                        }
                    )
                    local parent3 = createInstance(
                        "CanvasGroup",
                        { Name = "Card", Size = UDim2.new(1, 0, 0, 52), BorderSizePixel = 0, GroupTransparency = 1, Parent = parent2 }
                    )
                    bindTheme(parent3, "BackgroundColor3", "Surface")
                    u.corner(parent3, 12)
                    createInstance(
                        "UIGradient",
                        {
                            Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(214, 216, 224)),
                            Rotation = 90,
                            Parent = parent3,
                        }
                    )
                    local image, parent4 = tex.image, { Name = "Gloss" }
                    parent4.Size, parent4.SliceScale, parent4.ImageTransparency, parent4.ZIndex =
                        UDim2.fromScale(1, 1), 0.86, 0.92, 1
                    image(parent3, "gloss9", parent4)
                    parent4 = tex.image(
                        parent3,
                        "glow",
                        {
                            Name = "Tint",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.new(0, 30, 0.5, 0),
                            Size = UDim2.fromOffset(150, 110),
                            ImageTransparency = 0.86,
                            ZIndex = 1,
                        }
                    )
                    if parent4 then
                        bindTheme(parent4, "ImageColor3", calculatedValue2.token)
                    end
                    local imageResult2 = tex.image(
                        parent3,
                        "rim9",
                        { Name = "Rim", Size = UDim2.fromScale(1, 1), SliceScale = 0.86, ImageTransparency = 0.5, ZIndex = 9 }
                    )
                    if imageResult2 then
                        bindTheme(imageResult2, "ImageColor3", "Glass")
                    else
                        bindTheme(u.stroke(parent3, Color3.new(1, 1, 1), 1, 0.88), "Color", "Glass")
                    end
                    parent4 = createInstance(
                        "Frame",
                        {
                            Name = "Badge",
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.new(0, 13, 0.5, 0),
                            Size = UDim2.fromOffset(30, 30),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 0.84,
                            ZIndex = 3,
                            Parent = parent3,
                        }
                    )
                    bindTheme(parent4, "BackgroundColor3", calculatedValue2.token)
                    u.corner(parent4, UDim.new(1, 0))
                    bindTheme(u.stroke(parent4, Color3.new(1, 1, 1), 1, 0.62), "Color", calculatedValue2.token)
                    icon({
                        Parent = parent4,
                        Icon = calculatedValue.Icon or calculatedValue2.icon,
                        Size = 15,
                        Pos = UDim2.fromScale(0.5, 0.5),
                        Anchor = Vector2.new(0.5, 0.5),
                        Color = calculatedValue2.token,
                        Z = 4,
                    })
                    local parent5 = createInstance(
                        "Frame",
                        {
                            Name = "Body",
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.new(0, 54, 0.5, 0),
                            Size = UDim2.new(1, -86, 0, 0),
                            AutomaticSize = Enum.AutomaticSize.Y,
                            BackgroundTransparency = 1,
                            ZIndex = 3,
                            Parent = parent3,
                        }
                    )
                    u.pad(parent5, 11, 0, 11, 0)
                    u.list(parent5, 2)
                    label({
                        Parent = parent5,
                        Text = calculatedValue.Title or localization2.tr("Notification"),
                        Font = font.Semi(),
                        Size = 14,
                        Box = UDim2.new(1, 0, 0, 17),
                        Truncate = true,
                        Z = 4,
                        Name = "Title",
                    })
                    if calculatedValue.Text then
                        if calculatedValue.Text ~= "" then
                            label({
                                Parent = parent5,
                                Text = calculatedValue.Text,
                                Font = font.Regular(),
                                Size = 12,
                                Box = UDim2.new(1, 0, 0, 0),
                                Auto = Enum.AutomaticSize.Y,
                                Wrap = true,
                                Rich = true,
                                Color = "Muted",
                                Z = 4,
                                Name = "Text",
                            }).LayoutOrder =
                                1
                        end
                    end
                    parent4 = createInstance(
                        "TextButton",
                        {
                            Name = "Close",
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            AnchorPoint = Vector2.new(1, 0.5),
                            Position = UDim2.new(1, -8, 0.5, 0),
                            Size = UDim2.fromOffset(22, 22),
                            ZIndex = 11,
                            Parent = parent3,
                        }
                    )
                    local value = createInstance(
                        "Frame",
                        {
                            Name = "Face",
                            Size = UDim2.fromScale(1, 1),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 1,
                            ZIndex = 11,
                            Parent = parent4,
                        }
                    )
                    bindTheme(value, "BackgroundColor3", "Elevated")
                    u.corner(value, 7)
                    local value2 = icon({
                        Parent = parent4,
                        Icon = "x",
                        Size = 12,
                        Pos = UDim2.fromScale(0.5, 0.5),
                        Anchor = Vector2.new(0.5, 0.5),
                        Color = "Muted",
                        Z = 12,
                    })
                    value2.ImageTransparency = 1
                    local value3 = createInstance(
                        "Frame",
                        {
                            Name = "Timer",
                            AnchorPoint = Vector2.new(0, 1),
                            Position = UDim2.fromScale(0, 1),
                            Size = UDim2.new(1, 0, 0, 2),
                            BorderSizePixel = 0,
                            BackgroundTransparency = 0.35,
                            ZIndex = 8,
                            Parent = parent3,
                        }
                    )
                    bindTheme(value3, "BackgroundColor3", calculatedValue2.token)
                    image = createInstance(
                        "TextButton",
                        {
                            Name = "Hit",
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundTransparency = 1,
                            Size = UDim2.fromScale(1, 1),
                            ZIndex = 10,
                            Parent = parent3,
                        }
                    )
                    local function handleAction()
                        local roundedValue =
                            math.ceil(parent5.AbsoluteSize.Y / math.max(argument.ToastScale.Scale, 0.1))
                        if roundedValue > 0 then
                            local size = UDim2.new(1, 0, 0, math.max(52, roundedValue))
                            parent3.Size = size
                            parent2.Size = size
                        end
                    end
                    parent5:GetPropertyChangedSignal("AbsoluteSize"):Connect(handleAction)
                    task.defer(handleAction)
                    local enabled, enabled2 = false, false
                    local function dismiss()
                        if enabled then
                            return
                        end
                        enabled = true
                        tweenInstance(parent2, tweenInfo2, { Position = UDim2.fromOffset(60, 0) })
                        tweenInstance(parent3, tweenInfo2, { GroupTransparency = 1 })
                        if imageResult then
                            tweenInstance(imageResult, tweenInfo2, { ImageTransparency = 1 })
                        end
                        task.delay(0.2, function()
                            tweenInstance(parent, "Base", { Size = UDim2.new(1, 0, 0, 0) })
                            task.delay(0.28, function()
                                parent:Destroy()
                            end)
                        end)
                    end
                    local function handleAction()
                        if calculatedValue.OnClick then
                            task.spawn(calculatedValue.OnClick)
                        end
                        dismiss()
                    end
                    image.MouseButton1Click:Connect(handleAction)
                    parent4.MouseButton1Click:Connect(dismiss)
                    local function callback(argument2)
                        enabled2 = argument2
                        tweenInstance(value2, "Quick", { ImageTransparency = argument2 and 0.1 or 1 })
                        tweenInstance(value, "Quick", { BackgroundTransparency = argument2 and 0.35 or 1 })
                        if imageResult2 then
                            tweenInstance(imageResult2, "Quick", { ImageTransparency = argument2 and 0.3 or 0.5 })
                        end
                    end
                    local function handleAction()
                        callback(true)
                    end
                    image.MouseEnter:Connect(handleAction)
                    u.leave(image, function()
                        callback(false)
                    end)
                    local function handleAction2()
                        callback(true)
                        tweenInstance(value2, "Quick", { ImageColor3 = theme.resolve("Text") })
                    end
                    parent4.MouseEnter:Connect(handleAction2)
                    u.leave(parent4, function()
                        tweenInstance(value2, "Quick", { ImageColor3 = theme.resolve("Muted") })
                    end)
                    local function callback2(argument2)
                        if enabled then
                            return
                        end
                        local calculatedValue3 = parent2.AbsoluteSize.Y / math.max(argument.ToastScale.Scale, 0.1)
                        if argument2 then
                            tweenInstance(parent, "Base", { Size = UDim2.new(1, 0, 0, calculatedValue3) })
                        else
                            parent.Size = UDim2.new(1, 0, 0, calculatedValue3)
                        end
                    end
                    local function handleAction()
                        callback2(false)
                    end
                    parent2:GetPropertyChangedSignal("AbsoluteSize"):Connect(handleAction)
                    task.defer(function()
                        task.wait()
                        callback2(true)
                        tweenInstance(parent2, tweenInfo, { Position = UDim2.fromOffset(0, 0) })
                        tweenInstance(parent3, tweenInfo, { GroupTransparency = 0 })
                        if imageResult then
                            tweenInstance(imageResult, tweenInfo, { ImageTransparency = 0.45 })
                        end
                        local value = maximumValue
                        while true do
                            local waitResult = if enabled then not enabled else value > 0
                            if not waitResult then
                                break
                            end
                            waitResult = task.wait()
                            value = if enabled2 then value else value - waitResult
                            value3.Size = UDim2.new(math.clamp(value / maximumValue, 0, 1), 0, 0, 2)
                        end
                        dismiss()
                    end)
                    if calculatedValue.Sound ~= false then
                        sound.play("notify")
                    end
                    return { Dismiss = dismiss }
                end
                localization2.Notify = function(entry, argument)
                    entry = localization2.Windows[#localization2.Windows]
                    if entry then
                        if not entry.Destroyed then
                            return entry:Notify(argument)
                        end
                    end
                    return nil
                end
            end
            do
                local u = localization2.U
                local motion = localization2.Motion
                local theme = localization2.Theme
                local font = localization2.Font
                local icons = localization2.Icons
                local sound = localization2.Sound
                local tex = localization2.Tex
                local createInstance = u.new
                local tweenInstance = motion.tween
                local unused, label = theme.bind, localization2.label
                local unused, unused2, safe = localization2.icon, localization2.paint, localization2.safe
                local windowClass = localization2.WindowClass
                local sectionClass, color = localization2.SectionClass, Color3.new(1, 1, 1)
                sectionClass.Palette = function(parent, argument)
                    local calculatedValue = argument or {}
                    local unused, entries = parent.Window, {}
                    for unused, item in ipairs(calculatedValue.Options or {}) do
                        if type(item) == "table" then
                            if typeof(item[2]) == "Color3" then
                                table.insert(entries, { name = item[1], color = item[2] })
                            end
                        end
                    end
                    local rowObj = parent:_row({
                        Text = calculatedValue.Text,
                        Desc = "",
                        Height = 74,
                        Reserve = 0,
                        Name = "Palette",
                        Order = calculatedValue.Order,
                        Parent = calculatedValue.Parent,
                    })
                    if rowObj.Desc then
                        rowObj.Desc.Visible = false
                    end
                    rowObj.Title.Position = UDim2.fromOffset(10, 9)
                    rowObj.Title.Size = UDim2.new(1, -20, 0, 18)
                    parent = createInstance(
                        "Frame",
                        {
                            Name = "Swatches",
                            Position = UDim2.fromOffset(10, 36),
                            Size = UDim2.new(1, -20, 0, 30),
                            BackgroundTransparency = 1,
                            ZIndex = 3,
                            Parent = rowObj.Frame,
                        }
                    )
                    u.list(
                        parent,
                        8,
                        Enum.FillDirection.Horizontal,
                        Enum.HorizontalAlignment.Left,
                        Enum.VerticalAlignment.Center
                    )
                    local value, entries2 =
                        label({
                            Parent = rowObj.Frame,
                            Text = "",
                            Font = font.Semi(),
                            Size = 12,
                            Anchor = Vector2.new(1, 0),
                            Pos = UDim2.new(1, -10, 0, 10),
                            Box = UDim2.fromOffset(120, 16),
                            AlignX = Enum.TextXAlignment.Right,
                            Color = "Muted",
                            Z = 3,
                        }),
                        { Type = "Palette" }
                    entries2.Row = rowObj.Frame
                    entries2.Items = {}
                    local value2
                    local function callback(argument, argument2)
                        value2 = argument
                        for key, item in pairs(entries2.Items) do
                            local calculatedValue2, ring, calculatedValue3 =
                                key == argument, item.ring, argument2 and "Base"
                            local scale, entries3 = calculatedValue3 or TweenInfo.new(0), {}
                            entries3.Transparency = calculatedValue2 and 0 or 1
                            tweenInstance(ring, scale, entries3)
                            scale, ring = item.scale, argument2 and "PopSmall"
                            key, entries3 = ring or TweenInfo.new(0), {}
                            entries3.Scale = calculatedValue2 and 1 or 0.86
                            tweenInstance(scale, key, entries3)
                            ring, key = item.check, argument2 and "Base"
                            item, scale = key or TweenInfo.new(0), {}
                            scale.ImageTransparency = calculatedValue2 and 0 or 1
                            tweenInstance(ring, item, scale)
                        end
                        value.Text = argument or ""
                    end
                    for parent2, item in ipairs(entries) do
                        local parent3 = createInstance(
                            "TextButton",
                            {
                                Name = item.name,
                                Text = "",
                                AutoButtonColor = false,
                                BackgroundTransparency = 1,
                                Size = UDim2.fromOffset(28, 28),
                                LayoutOrder = parent2,
                                ZIndex = 3,
                                Parent = parent,
                            }
                        )
                        local scale = createInstance("UIScale", { Scale = 0.86, Parent = parent3 })
                        local halo = tex.image(
                            parent3,
                            "glow",
                            {
                                Name = "Halo",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromOffset(64, 64),
                                ImageTransparency = 1,
                                ImageColor3 = item.color,
                                ZIndex = 2,
                            }
                        )
                        parent2 = createInstance(
                            "Frame",
                            {
                                Name = "Dot",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(0.72, 0.72),
                                BorderSizePixel = 0,
                                BackgroundColor3 = item.color,
                                ZIndex = 4,
                                Parent = parent3,
                            }
                        )
                        u.corner(parent2, UDim.new(1, 0))
                        createInstance(
                            "UIGradient",
                            {
                                Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(190, 190, 200)),
                                Rotation = 90,
                                Parent = parent2,
                            }
                        )
                        local image, entries3 = tex.image, {}
                        entries3.Size, entries3.SliceScale, entries3.ImageTransparency, entries3.ZIndex =
                            UDim2.fromScale(1, 1), 0.7, 0.7, 5
                        image(parent2, "gloss9", entries3)
                        entries3 = createInstance(
                            "Frame",
                            {
                                Name = "Ring",
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromScale(1, 1),
                                BackgroundTransparency = 1,
                                ZIndex = 3,
                                Parent = parent3,
                            }
                        )
                        u.corner(entries3, UDim.new(1, 0))
                        local ring, check =
                            u.stroke(entries3, item.color, 2, 1, Enum.ApplyStrokeMode.Border),
                            createInstance(
                                "ImageLabel",
                                {
                                    Name = "Check",
                                    AnchorPoint = Vector2.new(0.5, 0.5),
                                    Position = UDim2.fromScale(0.5, 0.5),
                                    Size = UDim2.fromOffset(12, 12),
                                    BackgroundTransparency = 1,
                                    ImageColor3 = color,
                                    ImageTransparency = 1,
                                    Visible = false,
                                    ZIndex = 6,
                                    Parent = parent2,
                                }
                            )
                        icons.apply(check, "check")
                        entries2.Items[item.name] =
                            { ring = ring, scale = scale, check = check, halo = halo, button = parent3 }
                        parent3.MouseEnter:Connect(function()
                            local value3 = value2
                            if value3 ~= item.name then
                                tweenInstance(scale, "Quick", { Scale = 1.1 })
                            end
                            if halo then
                                tweenInstance(halo, "Quick", { ImageTransparency = 0.72 })
                            end
                            sound.play("hover", 0.4)
                            value.Text = item.name
                        end)
                        u.leave(parent3, function()
                            local value3 = value2
                            if value3 ~= item.name then
                                tweenInstance(scale, "Quick", { Scale = 0.86 })
                            end
                            if halo then
                                tweenInstance(halo, "Quick", { ImageTransparency = 1 })
                            end
                            value.Text = value2 or ""
                        end)
                        local function handleAction()
                            sound.play("tick")
                            callback(item.name, true)
                            safe(calculatedValue.Callback, item.name, item.color)
                            if entries2.Changed then
                                safe(entries2.Changed, item.name, item.color)
                            end
                        end
                        parent3.MouseButton1Click:Connect(handleAction)
                    end
                    rowObj.OnWidth = function(argument)
                        local maximumValue = math.max(#entries, 1)
                        local roundedValue =
                            math.floor(u.clamp((argument - 20 - (maximumValue - 1) * 8) / maximumValue, 18, 28))
                        for unused, item in pairs(entries2.Items) do
                            item.button.Size = UDim2.fromOffset(roundedValue, roundedValue)
                        end
                    end
                    entries2.Set = function(unused, argument, argument2)
                        if not entries2.Items[argument] then
                            callback(nil, true)
                            return
                        end
                        callback(argument, true)
                        if not argument2 then
                            for unused, item in ipairs(entries) do
                                if item.name == argument then
                                    safe(calculatedValue.Callback, item.name, item.color)
                                end
                            end
                        end
                    end
                    entries2.SetValue = entries2.Set
                    entries2.SetSilent = function(unused, argument)
                        entries2:Set(argument, true)
                    end
                    entries2.Get = function(argument)
                        argument = value2
                        return argument
                    end
                    entries2.SetVisible = function(unused, argument)
                        rowObj.SetVisible(argument)
                    end
                    entries2.SetParentHidden = function(unused, argument)
                        rowObj.SetParentHidden(argument)
                    end
                    entries2.RowObj = rowObj
                    entries2.Title = rowObj.Title
                    parent = calculatedValue.Default
                    if typeof(parent) == "Color3" then
                        for unused, item in ipairs(entries) do
                            if item.color:ToHex() == parent:ToHex() then
                                parent = item.name
                                break
                            end
                        end
                    else
                    end
                    for unused, item in pairs(entries2.Items) do
                        item.check.Visible = true
                    end
                    callback(entries2.Items[parent] and parent or nil, false)
                    return entries2
                end
                local function isActive2()
                    local entries, enabled =
                        {}, { "Crimson", "Ember", "Gold", "Mint", "Ocean", "Violet", "Rose", "Ice" }
                    for unused, item in ipairs(enabled) do
                        if theme.Presets[item] then
                            table.insert(entries, { item, theme.Presets[item] })
                        end
                    end
                    for key, item in pairs(theme.Presets) do
                        enabled = false
                        for unused, item2 in ipairs(entries) do
                            enabled = if item2[1] == key then true else enabled
                        end
                        if not enabled then
                            table.insert(entries, { key, item })
                        end
                    end
                    return entries
                end
                windowClass.AddAppearance = function(argument, argument2, calculatedValue)
                    calculatedValue = calculatedValue or {}
                    local state, appearanceRefs = argument.State, {}
                    argument.AppearanceRefs = appearanceRefs
                    local uiPage = argument2:Section({
                        Title = "Interface",
                        Icon = "layout-panel-left",
                        Sub = calculatedValue.Sub,
                        Side = calculatedValue.Side1,
                    })
                    if not calculatedValue.SkipKey then
                        appearanceRefs.key = uiPage:Keybind({
                            Text = "Menu key",
                            Default = argument.Key,
                            Callback = function(argument3)
                                if argument3 then
                                    argument:SetKey(argument3)
                                end
                            end,
                        })
                        argument:OnKeyChanged(function(argument3)
                            if appearanceRefs.key then
                                if appearanceRefs.key.Get then
                                    if appearanceRefs.key:Get() ~= argument3 then
                                        appearanceRefs.key:Set(argument3)
                                    end
                                end
                            end
                        end)
                    end
                    appearanceRefs.scale = uiPage:Slider({
                        Text = "UI scale",
                        Min = 0.6,
                        Max = 1.4,
                        Decimals = 2,
                        Default = argument.UserScale,
                        Suffix = "x",
                        Callback = function() end,
                        Released = function(argument3)
                            argument:SetScale(argument3)
                        end,
                    })
                    appearanceRefs.autofit = uiPage:Toggle({
                        Text = "Fit to screen",
                        Default = argument.AutoFit,
                        Callback = function(argument3)
                            argument:SetAutoFit(argument3)
                        end,
                    })
                    appearanceRefs.radius = uiPage:Slider({
                        Text = "Corner radius",
                        Min = 0,
                        Max = 2,
                        Decimals = 2,
                        Default = tonumber(state.get("radius", 1)) or 1,
                        Suffix = "x",
                        Callback = function(argument3)
                            argument:SetCornerRadius(argument3)
                        end,
                    })
                    appearanceRefs.textScale = uiPage:Slider({
                        Text = "Text size",
                        Min = 0.85,
                        Max = 1.25,
                        Decimals = 2,
                        Default = tonumber(state.get("textScale", 1)) or 1,
                        Suffix = "x",
                        Callback = function(argument3)
                            argument:SetTextScale(argument3)
                        end,
                    })
                    local uiPage2 = {}
                    for unused, item in ipairs(font.Families) do
                        table.insert(uiPage2, item[1])
                    end
                    appearanceRefs.font = uiPage:Dropdown({
                        Text = "Font",
                        Options = uiPage2,
                        Default = font.name,
                        Callback = function(argument3)
                            argument:SetFont(argument3)
                        end,
                    })
                    appearanceRefs.opacity = uiPage:Slider({
                        Text = "Window opacity",
                        Min = 0.5,
                        Max = 1,
                        Decimals = 2,
                        Default = argument.Opacity,
                        Callback = function(argument3)
                            argument:SetOpacity(argument3)
                        end,
                    })
                    appearanceRefs.sbWidth = uiPage:Slider({
                        Text = "Sidebar width",
                        Min = 188,
                        Max = 340,
                        Decimals = 0,
                        Default = argument.ExpandedWidth,
                        Suffix = " px",
                        Callback = function() end,
                        Released = function(argument3)
                            argument:SetSidebarWidth(argument3)
                        end,
                    })
                    argument.OnSidebarWidth = function(argument3)
                        if appearanceRefs.sbWidth then
                            appearanceRefs.sbWidth:SetSilent(argument3)
                        end
                    end
                    appearanceRefs.density = uiPage:Dropdown({
                        Text = "Sidebar density",
                        Options = windowClass.Densities,
                        Default = argument.Density,
                        Callback = function(argument3)
                            argument:SetDensity(argument3)
                        end,
                    })
                    appearanceRefs.compact = uiPage:Toggle({
                        Text = "Compact sidebar",
                        Default = argument.SidebarCollapsed == true,
                        Callback = function(argument3)
                            argument:SetSidebarCollapsed(argument3)
                        end,
                    })
                    argument.OnSidebarChanged = function(argument3)
                        if appearanceRefs.compact then
                            appearanceRefs.compact:SetSilent(argument3)
                        end
                    end
                    appearanceRefs.groupLabels = uiPage:Toggle({
                        Text = "Group labels",
                        Default = argument.GroupLabels ~= false,
                        Callback = function(argument3)
                            argument:SetGroupLabels(argument3)
                        end,
                    })
                    argument.OnGroupLabels = function(argument3)
                        if appearanceRefs.groupLabels then
                            appearanceRefs.groupLabels:SetSilent(argument3)
                        end
                    end
                    uiPage2 = argument2:Section({
                        Title = "Theme",
                        Icon = "palette",
                        Sub = calculatedValue.Sub,
                        Side = calculatedValue.Side2,
                    })
                    appearanceRefs.palette = uiPage2:Palette({
                        Text = "Accent",
                        Options = isActive2(),
                        Default = theme.tokens.Accent,
                        Callback = function(unused, argument3)
                            argument:SetAccent(argument3)
                            if appearanceRefs.accent then
                                appearanceRefs.accent:SetSilent(argument3)
                            end
                        end,
                    })
                    appearanceRefs.accent = uiPage2:Colorpicker({
                        Text = "Custom accent",
                        Alpha = false,
                        Default = theme.tokens.Accent,
                        Callback = function(argument3)
                            argument:SetAccent(argument3)
                            if appearanceRefs.palette then
                                appearanceRefs.palette:Set(nil, true)
                            end
                        end,
                    })
                    local uiPage3 = {}
                    for unused, item in ipairs(windowClass.BackgroundStyles) do
                        table.insert(uiPage3, item)
                    end
                    local options = {}
                    for unused, item in ipairs(theme.Bases) do
                        table.insert(options, item[1])
                    end
                    appearanceRefs.base = uiPage2:Dropdown({
                        Text = "Base theme",
                        Options = options,
                        Default = theme.base,
                        Callback = function(argument3)
                            argument:SetBase(argument3)
                            if appearanceRefs.panel then
                                appearanceRefs.panel:SetSilent(theme.tokens.Background)
                            end
                            if appearanceRefs.halloween then
                                appearanceRefs.halloween:SetSilent(argument:IsHalloween())
                            end
                        end,
                    })
                    appearanceRefs.panel = uiPage2:Colorpicker({
                        Text = "Panel color",
                        Alpha = false,
                        Default = theme.tokens.Background,
                        Callback = function(argument3)
                            argument:SetPanelColor(argument3)
                            if appearanceRefs.base then
                                appearanceRefs.base:SetSilent("Custom")
                            end
                        end,
                    })
                    options = {}
                    for unused, item in ipairs(windowClass.CardStyles) do
                        table.insert(options, item)
                    end
                    appearanceRefs.cards = uiPage2:Dropdown({
                        Text = "Card style",
                        Options = options,
                        Default = argument.CardStyle,
                        Callback = function(argument3)
                            argument:SetCardStyle(argument3)
                        end,
                    })
                    appearanceRefs.bg = uiPage2:Dropdown({
                        Text = "Background",
                        Options = uiPage3,
                        Default = argument.BgStyle,
                        Callback = function(argument3)
                            argument:SetBackground(argument3)
                            if appearanceRefs.halloween then
                                appearanceRefs.halloween:SetSilent(argument:IsHalloween())
                            end
                        end,
                    })
                    appearanceRefs.bgInt = uiPage2:Slider({
                        Text = "Background intensity",
                        Min = 0,
                        Max = 1.5,
                        Decimals = 2,
                        Default = argument.BgIntensity,
                        Callback = function(argument3)
                            argument:SetBackgroundIntensity(argument3)
                        end,
                    })
                    appearanceRefs.blur = uiPage2:Toggle({
                        Text = "Blur behind menu",
                        Default = argument.BlurEnabled,
                        Callback = function(argument3)
                            argument:SetBlur(argument3)
                        end,
                    })
                    uiPage3 = argument2:Section({
                        Title = "Behavior",
                        Icon = "sliders-horizontal",
                        Sub = calculatedValue.Sub,
                        Side = calculatedValue.Side3,
                    })
                    appearanceRefs.motion = uiPage3:Toggle({
                        Text = "Animations",
                        Default = motion.enabled,
                        Callback = function(argument3)
                            argument:SetMotion(argument3)
                        end,
                    })
                    appearanceRefs.sounds = uiPage3:Toggle({
                        Text = "Interface sounds",
                        Default = sound.enabled,
                        Callback = function(argument3)
                            argument:SetSounds(argument3)
                        end,
                    })
                    appearanceRefs.volume = uiPage3:Slider({
                        Text = "Sound volume",
                        Min = 0,
                        Max = 1,
                        Decimals = 2,
                        Default = sound.volume,
                        Callback = function(argument3)
                            argument:SetVolume(argument3)
                        end,
                    })
                    appearanceRefs.tips = uiPage3:Toggle({
                        Text = "Tooltips",
                        Default = argument.TooltipsOn,
                        Callback = function(argument3)
                            argument:SetTooltips(argument3)
                        end,
                    })
                    appearanceRefs.launcher = uiPage3:Toggle({
                        Text = "Launcher button",
                        Default = argument.LauncherOn,
                        Callback = function(argument3)
                            argument:SetLauncher(argument3)
                        end,
                    })
                    if calculatedValue.Overlays ~= false then
                        appearanceRefs.watermark = uiPage3:Toggle({
                            Text = "Show FPS / Ping",
                            Default = state.get("watermark", false) == true,
                            Callback = function(argument3)
                                argument:SetWatermark(argument3)
                            end,
                        })
                        appearanceRefs.kblist = uiPage3:Toggle({
                            Text = "Keybind list",
                            Default = state.get("keybindList", argument.IsTouch == true) == true,
                            Callback = function(argument3)
                                argument:SetKeybindList(argument3)
                            end,
                        })
                    end
                    local callback = calculatedValue.Translate or function(argument3)
                        return argument3
                    end
                    appearanceRefs.reset = uiPage3:Button({
                        Text = "Reset appearance",
                        Icon = "rotate-ccw",
                        DoubleClick = true,
                        Callback = function()
                            argument:ResetAppearance()
                            argument:SyncAppearance()
                            argument:Notify({ Title = callback("Appearance reset"), Kind = "success" })
                        end,
                    })
                    return { uiPage, uiPage2, uiPage3 }
                end
                windowClass.SyncAppearance = function(argument)
                    local appearanceRefs = argument.AppearanceRefs
                    if not appearanceRefs then
                        return
                    end
                    local state = argument.State
                    appearanceRefs.scale:SetSilent(argument.UserScale)
                    if appearanceRefs.autofit then
                        appearanceRefs.autofit:SetSilent(argument.AutoFit)
                    end
                    appearanceRefs.radius:SetSilent(tonumber(state.get("radius", 1)) or 1)
                    appearanceRefs.textScale:SetSilent(tonumber(state.get("textScale", 1)) or 1)
                    appearanceRefs.font:SetSilent(font.name)
                    appearanceRefs.opacity:SetSilent(argument.Opacity)
                    appearanceRefs.density:SetSilent(argument.Density)
                    appearanceRefs.sbWidth:SetSilent(argument.ExpandedWidth)
                    appearanceRefs.compact:SetSilent(argument.SidebarCollapsed == true)
                    if appearanceRefs.groupLabels then
                        appearanceRefs.groupLabels:SetSilent(argument.GroupLabels ~= false)
                    end
                    appearanceRefs.palette:Set(nil, true)
                    for key, item in pairs(theme.Presets) do
                        if item:ToHex() == theme.tokens.Accent:ToHex() then
                            appearanceRefs.palette:Set(key, true)
                        end
                    end
                    appearanceRefs.accent:SetSilent(theme.tokens.Accent)
                    appearanceRefs.base:SetSilent(theme.base)
                    if appearanceRefs.halloween then
                        appearanceRefs.halloween:SetSilent(argument:IsHalloween())
                    end
                    appearanceRefs.panel:SetSilent(argument.PanelColor or theme.tokens.Background)
                    appearanceRefs.cards:SetSilent(argument.CardStyle)
                    appearanceRefs.bg:SetSilent(argument.BgStyle)
                    appearanceRefs.bgInt:SetSilent(argument.BgIntensity)
                    appearanceRefs.blur:SetSilent(argument.BlurEnabled)
                    appearanceRefs.motion:SetSilent(motion.enabled)
                    appearanceRefs.sounds:SetSilent(sound.enabled)
                    appearanceRefs.volume:SetSilent(sound.volume)
                    appearanceRefs.tips:SetSilent(argument.TooltipsOn)
                    appearanceRefs.launcher:SetSilent(argument.LauncherOn)
                    if appearanceRefs.watermark then
                        appearanceRefs.watermark:SetSilent(state.get("watermark", false) == true)
                    end
                    if appearanceRefs.kblist then
                        appearanceRefs.kblist:SetSilent(state.get("keybindList", false) == true)
                    end
                end
            end
            do
                local u = localization2.U
                local motion, theme = localization2.Motion, localization2.Theme
                local font = localization2.Font
                local unused, sound = localization2.Icons, localization2.Sound
                local tex = localization2.Tex
                local createInstance = u.new
                local tweenInstance = motion.tween
                local bindTheme = theme.bind
                local label = localization2.label
                local icon = localization2.icon
                local windowClass, userInputService =
                    localization2.WindowClass, localization2.Services.UserInputService
                local runService = localization2.Services.RunService
                local color = Color3.new(1, 1, 1)
                local function callback(argument, name, position, image)
                    local parent = createInstance(
                        "Frame",
                        {
                            Name = name,
                            Position = position,
                            Size = UDim2.fromOffset(0, 30),
                            AutomaticSize = Enum.AutomaticSize.X,
                            BackgroundTransparency = 1,
                            Visible = false,
                            ZIndex = 6,
                            Parent = argument.Gui,
                        }
                    )
                    tex.image(
                        parent,
                        "shadow9",
                        {
                            Name = "Shadow",
                            Position = UDim2.fromOffset(-24, -16),
                            Size = UDim2.new(1, 48, 1, 52),
                            SliceScale = 1,
                            ImageTransparency = 0.5,
                            ZIndex = 5,
                        }
                    )
                    name = createInstance(
                        "Frame",
                        {
                            Name = "Card",
                            Size = image and UDim2.new(0, 0, 1, 0) or UDim2.fromScale(1, 1),
                            AutomaticSize = image and Enum.AutomaticSize.X or Enum.AutomaticSize.None,
                            BorderSizePixel = 0,
                            BackgroundTransparency = 0.04,
                            ZIndex = 6,
                            Parent = parent,
                        }
                    )
                    bindTheme(name, "BackgroundColor3", "Surface")
                    u.corner(name, 11)
                    createInstance(
                        "UIGradient",
                        { Color = ColorSequence.new(color, Color3.fromRGB(208, 210, 218)), Rotation = 90, Parent = name }
                    )
                    image, position = tex.image, { Name = "Gloss" }
                    position.Size, position.SliceScale, position.ImageTransparency, position.ZIndex =
                        UDim2.fromScale(1, 1), 0.79, 0.9, 6
                    image(name, "gloss9", position)
                    position = tex.image(
                        name,
                        "rim9",
                        { Name = "Rim", Size = UDim2.fromScale(1, 1), SliceScale = 0.79, ImageTransparency = 0.45, ZIndex = 12 }
                    )
                    if position then
                        bindTheme(position, "ImageColor3", "Glass")
                    else
                        bindTheme(u.stroke(name, color, 1, 0.85), "Color", "Glass")
                    end
                    local value = createInstance("UIScale", { Parent = parent })
                    local function handleAction()
                        if not parent.Parent then
                            return
                        end
                        local viewportSize, position, absoluteSize =
                            workspace.CurrentCamera.ViewportSize, parent.Position, parent.AbsoluteSize
                        if absoluteSize.X <= 0 then
                            return
                        elseif absoluteSize.Y <= 0 then
                            return
                        end
                        local clampedValue, clampedValue2 =
                            math.clamp(position.X.Offset, 4, math.max(4, viewportSize.X - absoluteSize.X - 4)),
                            math.clamp(position.Y.Offset, 4, math.max(4, viewportSize.Y - absoluteSize.Y - 4))
                        if clampedValue ~= position.X.Offset or clampedValue2 ~= position.Y.Offset then
                            parent.Position = UDim2.fromOffset(clampedValue, clampedValue2)
                        end
                    end
                    local function handleAction2()
                        task.defer(handleAction)
                    end
                    parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(handleAction2)
                    local function handleAction3()
                        if parent.Visible then
                            task.defer(handleAction)
                        end
                    end
                    parent:GetPropertyChangedSignal("Visible"):Connect(handleAction3)
                    argument:OnScreenScale(function(scale)
                        if not parent.Parent then
                            return false
                        end
                        value.Scale = scale
                        task.defer(handleAction)
                    end)
                    return parent, name
                end
                local function callback2(argument, argument2, argument3, argument4)
                    local enabled, enabled2, enabled3, enabled4 = false
                    argument2.InputBegan:Connect(function(argument5)
                        if not (u.isClick(argument5)) then
                            return
                        end
                        local position, position2
                        position, position2, enabled = argument5.Position, argument3.Position, true
                        enabled2, enabled3, enabled4 = position, position2, argument5
                        local connection
                        connection = argument5.Changed:Connect(function()
                            if argument5.UserInputState == Enum.UserInputState.End then
                                enabled = false
                                connection:Disconnect()
                                local position = argument3.Position
                                argument.State.data[argument4] =
                                    { math.floor(position.X.Offset), math.floor(position.Y.Offset) }
                                argument.State.save()
                            end
                        end)
                    end)
                    u.connect(userInputService.InputChanged, function(argument5)
                        if enabled then
                            if u.sameMove(argument5, enabled4) then
                                local calculatedValue, viewportSize =
                                    argument5.Position - enabled2, workspace.CurrentCamera.ViewportSize
                                local clampedValue, clampedValue2 =
                                    math.clamp(
                                        enabled3.X.Offset + calculatedValue.X,
                                        4,
                                        math.max(4, viewportSize.X - argument3.AbsoluteSize.X - 4)
                                    ),
                                    math.clamp(
                                        enabled3.Y.Offset + calculatedValue.Y,
                                        4,
                                        math.max(4, viewportSize.Y - argument3.AbsoluteSize.Y - 4)
                                    )
                                argument3.Position = UDim2.fromOffset(clampedValue, clampedValue2)
                            end
                        end
                    end, argument.Conns)
                end
                local function callback3(argument, argument2, argument3)
                    local getResult = argument.State.get(argument2, nil)
                    if type(getResult) == "table" then
                        if tonumber(getResult[1]) then
                            if tonumber(getResult[2]) then
                                return UDim2.fromOffset(getResult[1], getResult[2])
                            end
                        end
                    end
                    return argument3
                end
                windowClass.SetWatermark = function(argument, calculatedValue)
                    localization2.trace("SetWatermark")
                    calculatedValue = calculatedValue and true or false
                    argument.State.set("watermark", calculatedValue)
                    if calculatedValue then
                        if not argument.WatermarkFrame then
                            argument:_buildWatermark()
                        end
                        argument.WatermarkFrame.Visible = true
                    elseif argument.WatermarkFrame then
                        argument.WatermarkFrame.Visible = false
                    end
                end
                windowClass.SetWatermarkTitle = function(argument, text)
                    argument.WatermarkTitleText = text
                    local watermarkTitle = argument.WatermarkTitle
                    if not watermarkTitle then
                        return
                    end
                    if text then
                        if watermarkTitle.AutomaticSize ~= Enum.AutomaticSize.None then
                            watermarkTitle.AutomaticSize = Enum.AutomaticSize.None
                            watermarkTitle.Size = UDim2.new(0, 38, 1, 0)
                            watermarkTitle.TextXAlignment = Enum.TextXAlignment.Center
                        end
                        if watermarkTitle.Text ~= text then
                            watermarkTitle.Text = text
                        end
                    else
                        local text2 = tostring(argument.TitleLabel and argument.TitleLabel.Text or "GGH")
                        if watermarkTitle.AutomaticSize ~= Enum.AutomaticSize.X then
                            watermarkTitle.Size = UDim2.new(0, 0, 1, 0)
                            watermarkTitle.AutomaticSize = Enum.AutomaticSize.X
                            watermarkTitle.TextXAlignment = Enum.TextXAlignment.Left
                        end
                        if watermarkTitle.Text ~= text2 then
                            watermarkTitle.Text = text2
                        end
                    end
                end
                local function callback4(argument, argument2, argument3, argument4)
                    if argument4 then
                        if argument <= argument2 then
                            return "Success"
                        elseif argument <= argument3 then
                            return "Warning"
                        end
                        return "Danger"
                    end
                    if argument >= argument2 then
                        return "Success"
                    elseif argument >= argument3 then
                        return "Warning"
                    end
                    return "Danger"
                end
                local function isActive2()
                    local getValueResult
                    pcall(function()
                        getValueResult = localization2.Services.Players.LocalPlayer:GetNetworkPing() * 1000
                    end)
                    if not getValueResult then
                        pcall(function()
                            getValueResult = game:GetService("Stats").Network.ServerStatsItem["Data Ping"]
                                :GetValue()
                        end)
                    end
                    return getValueResult
                end
                windowClass._buildWatermark = function(argument)
                    local watermarkFrame, parent = callback(
                        argument,
                        "Watermark",
                        callback3(argument, "watermarkPos", UDim2.fromOffset(16, 16)),
                        true
                    )
                    watermarkFrame.Size = UDim2.fromOffset(0, 34)
                    u.corner(parent, 12)
                    local parent2 = createInstance(
                        "Frame",
                        {
                            Name = "Row",
                            Size = UDim2.new(0, 0, 1, 0),
                            AutomaticSize = Enum.AutomaticSize.X,
                            BackgroundTransparency = 1,
                            ZIndex = 7,
                            Parent = parent,
                        }
                    )
                    u.pad(parent2, 0, 12, 0, 8)
                    u.list(
                        parent2,
                        10,
                        Enum.FillDirection.Horizontal,
                        Enum.HorizontalAlignment.Left,
                        Enum.VerticalAlignment.Center
                    )
                    local watermarkTitle = createInstance(
                        "Frame",
                        {
                            Name = "Logo",
                            Size = UDim2.fromOffset(22, 22),
                            BackgroundTransparency = 1,
                            LayoutOrder = 1,
                            ZIndex = 7,
                            Parent = parent2,
                        }
                    )
                    if argument.LogoAsset then
                        createInstance(
                            "ImageLabel",
                            {
                                Name = "Mark",
                                BackgroundTransparency = 1,
                                AnchorPoint = Vector2.new(0.5, 0.5),
                                Position = UDim2.fromScale(0.5, 0.5),
                                Size = UDim2.fromOffset(26, 26),
                                Image = argument.LogoAsset,
                                ScaleType = Enum.ScaleType.Fit,
                                ZIndex = 8,
                                Parent = watermarkTitle,
                            }
                        )
                    else
                        local tile, instanceOptions = localization2.tile, { Name = "Face" }
                        instanceOptions.Size, instanceOptions.Color, instanceOptions.SliceScale, instanceOptions.Z =
                            UDim2.fromScale(1, 1), "Accent", 0.4, 7
                        tile(watermarkTitle, instanceOptions)
                        label({
                            Parent = watermarkTitle,
                            Text = tostring(argument.Initial or "N"),
                            Font = font.Heavy(),
                            Size = 11,
                            Box = UDim2.fromScale(1, 1),
                            AlignX = Enum.TextXAlignment.Center,
                            Color = "OnAccent",
                            Z = 9,
                        })
                    end
                    watermarkTitle = label({
                        Parent = parent2,
                        Text = tostring(argument.TitleLabel and argument.TitleLabel.Text or "GGH"),
                        Font = font.Bold(),
                        Size = 13,
                        Box = UDim2.new(0, 0, 1, 0),
                        Auto = Enum.AutomaticSize.X,
                        Z = 8,
                        Name = "Title",
                    })
                    watermarkTitle.LayoutOrder = 2
                    argument.WatermarkTitle = watermarkTitle
                    if argument.WatermarkTitleText then
                        argument:SetWatermarkTitle(argument.WatermarkTitleText)
                    end
                    local function callback5(layoutOrder)
                        bindTheme(
                            createInstance(
                                "Frame",
                                {
                                    Name = "Sep",
                                    Size = UDim2.fromOffset(1, 14),
                                    BorderSizePixel = 0,
                                    BackgroundTransparency = 0.82,
                                    LayoutOrder = layoutOrder,
                                    ZIndex = 8,
                                    Parent = parent2,
                                }
                            ),
                            "BackgroundColor3",
                            "Glass"
                        )
                    end
                    local function callback6(icon2, icon3, text, argument2)
                        local parent3 = createInstance(
                            "Frame",
                            {
                                Name = "Stat",
                                Size = UDim2.new(0, 0, 1, 0),
                                AutomaticSize = Enum.AutomaticSize.X,
                                BackgroundTransparency = 1,
                                LayoutOrder = icon2,
                                ZIndex = 8,
                                Parent = parent2,
                            }
                        )
                        u.list(
                            parent3,
                            5,
                            Enum.FillDirection.Horizontal,
                            Enum.HorizontalAlignment.Left,
                            Enum.VerticalAlignment.Center
                        )
                        icon2 = icon({ Parent = parent3, Icon = icon3, Size = 14, Color = "Muted", Z = 8 })
                        icon2.LayoutOrder = 1
                        icon3 = label({
                            Parent = parent3,
                            Text = "--",
                            Font = font.Bold(),
                            Size = 13,
                            Box = UDim2.new(0, argument2, 1, 0),
                            AlignX = Enum.TextXAlignment.Right,
                            Color = "Text",
                            Z = 8,
                            Name = "Value",
                        })
                        icon3.LayoutOrder = 2
                        label({
                            Parent = parent3,
                            Text = text,
                            Font = font.Medium(),
                            Size = 10,
                            Box = UDim2.new(0, 0, 1, 0),
                            Auto = Enum.AutomaticSize.X,
                            Color = "Faint",
                            Z = 8,
                            Name = "Suffix",
                        }).LayoutOrder =
                            3
                        return { icon = icon2, value = icon3, tone = nil }
                    end
                    callback5(3)
                    local value = callback6(4, "gauge", "FPS", 28)
                    callback5(5)
                    local value2 = callback6(6, "wifi", "MS", 30)
                    local function callback7(argument2, tone)
                        if argument2.tone == tone then
                            return
                        end
                        argument2.tone = tone
                        localization2.paint(argument2.icon, "ImageColor3", tone, "Base")
                        localization2.paint(argument2.value, "TextColor3", tone, "Base")
                    end
                    callback2(argument, parent, watermarkFrame, "watermarkPos")
                    if argument.State.get("watermarkPos", nil) == nil then
                        task.defer(function()
                            local viewportSize, x = workspace.CurrentCamera.ViewportSize, parent.AbsoluteSize.X
                            if x > 0 then
                                watermarkFrame.Position = UDim2.fromOffset(math.floor(viewportSize.X - x - 16), 16)
                            end
                        end)
                    end
                    local counter = 0
                    local now = os.clock()
                    u.connect(runService.RenderStepped, function()
                        if not watermarkFrame.Visible then
                            local now2
                            now2, counter = os.clock(), 0
                            now = now2
                            return
                        end
                        counter += 1
                        local now2 = os.clock()
                        local calculatedValue = now2 - now
                        if calculatedValue >= 0.5 then
                            local roundedValue = math.floor(counter / calculatedValue + 0.5)
                            counter, now = 0, now2
                            value.value.Text = tostring(roundedValue)
                            callback7(value, callback4(roundedValue, 55, 30, false))
                            roundedValue = isActive2()
                            if roundedValue then
                                local roundedValue2 = math.floor(roundedValue + 0.5)
                                value2.value.Text = tostring(roundedValue2)
                                callback7(value2, callback4(roundedValue2, 90, 180, true))
                            else
                                value2.value.Text = "--"
                            end
                        end
                    end, argument.Conns)
                    argument.WatermarkFrame = watermarkFrame
                    watermarkFrame.Visible = false
                end
                local counter, counter2, counter3, counter4, counter5, entries =
                    190,
                    32,
                    26,
                    3,
                    280,
                    {
                        { "Menu key", "menu" },
                    }
                local function callback4(argument)
                    local custom = (localization2.KeybindIcons or {})[argument]
                    if custom then
                        return custom
                    end
                    for unused, item in ipairs(entries) do
                        if argument == item[1] then
                            return item[2]
                        elseif argument == localization2.tr(item[1]) then
                            return item[2]
                        end
                    end
                    return "keyboard"
                end
                local color = Color3.new(1, 1, 1)
                local textColor3 = Color3.fromRGB(200, 203, 214)
                Color3.fromRGB(16, 16, 20)
                local function callback5(argument, ...)
                    if type(argument) ~= "function" then
                        return false, nil
                    end
                    return pcall(argument, ...)
                end
                windowClass.RegisterKeybind = function(argument, argument2)
                    argument.KeybindEntries = argument.KeybindEntries or {}
                    table.insert(argument.KeybindEntries, argument2)
                    argument:_kbDirty()
                end
                windowClass._kbDirty = function(argument)
                    if argument.KbPending then
                        return
                    elseif argument.Destroyed then
                        return
                    end
                    argument.KbPending = true
                    task.defer(function()
                        argument.KbPending = false
                        if argument.KeybindFrame then
                            if not argument.Destroyed then
                                argument:_kbRebuild()
                            end
                        end
                    end)
                end
                windowClass.SetKeybindList = function(argument, calculatedValue)
                    localization2.trace("SetKeybindList")
                    calculatedValue = calculatedValue and true or false
                    argument.State.set("keybindList", calculatedValue)
                    if calculatedValue then
                        if not argument.KeybindFrame then
                            argument:_buildKeybindList()
                        end
                        argument.KeybindFrame.Visible = true
                        argument:_kbRebuild(true)
                    elseif argument.KeybindFrame then
                        argument:_kbCancel()
                        argument.KeybindFrame.Visible = false
                    end
                end
                windowClass._kbCapture = function(argument, kbCap)
                    if argument.KbCap == kbCap then
                        return
                    end
                    argument:_kbCancel()
                    argument.KbCap = kbCap
                    kbCap.capture(true)
                    task.defer(function()
                        if argument.KbCap == kbCap then
                            argument.Listening = true
                        end
                    end)
                end
                windowClass._kbCancel = function(argument)
                    local kbCap = argument.KbCap
                    if not kbCap then
                        return
                    end
                    argument.KbCap = nil
                    kbCap.capture(false)
                    task.defer(function()
                        if not argument.KbCap then
                            argument.Listening = false
                        end
                    end)
                end
                local function callback6(argument, entry)
                    local featureState = { entry = entry, on = false }
                    local calculatedValue = argument.IsTouch == true
                    local visible = type(entry.toggle) == "function"
                    local frame = createInstance(
                        "TextButton",
                        {
                            Name = "Entry",
                            Text = "",
                            AutoButtonColor = false,
                            Size = UDim2.new(1, 0, 0, counter3),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            ZIndex = 8,
                            Parent = argument.KeybindList,
                        }
                    )
                    local value = createInstance(
                        "Frame",
                        {
                            Name = "Bar",
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.new(0, 0, 0.5, 0),
                            Size = UDim2.fromOffset(3, 0),
                            BorderSizePixel = 0,
                            ZIndex = 9,
                            Parent = frame,
                        }
                    )
                    u.corner(value, UDim.new(1, 0))
                    bindTheme(value, "BackgroundColor3", "Accent")
                    local parent = createInstance(
                        "Frame",
                        {
                            Name = "Slide",
                            Position = UDim2.fromOffset(5, 0),
                            Size = UDim2.new(1, -5, 1, 0),
                            BackgroundTransparency = 1,
                            ZIndex = 8,
                            Parent = frame,
                        }
                    )
                    local parent2 = createInstance(
                        "Frame",
                        {
                            Name = "Bg",
                            Size = UDim2.fromScale(1, 1),
                            BackgroundColor3 = color,
                            BackgroundTransparency = 0.92,
                            BorderSizePixel = 0,
                            ZIndex = 8,
                            Parent = parent,
                        }
                    )
                    u.corner(parent2, UDim.new(1, 0))
                    createInstance(
                        "UIGradient",
                        {
                            Transparency = NumberSequence.new({
                                NumberSequenceKeypoint.new(0, 0),
                                NumberSequenceKeypoint.new(0.6, 0.3),
                                NumberSequenceKeypoint.new(1, 0.85),
                            }),
                            Parent = parent2,
                        }
                    )
                    local parent3 = createInstance(
                        "Frame",
                        {
                            Name = "Ic",
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.new(0, 4, 0.5, 0),
                            Size = UDim2.fromOffset(counter3 - 8, counter3 - 8),
                            BackgroundColor3 = color,
                            BackgroundTransparency = 0.87,
                            BorderSizePixel = 0,
                            ZIndex = 9,
                            Parent = parent,
                        }
                    )
                    u.corner(parent3, UDim.new(1, 0))
                    local value2 = createInstance(
                        "UIStroke",
                        { Color = color, Transparency = 0.75, Thickness = 1, Parent = parent3 }
                    )
                    local value3 = createInstance(
                        "ImageLabel",
                        {
                            Name = "Glyph",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(11, 11),
                            BackgroundTransparency = 1,
                            ImageColor3 = color,
                            Visible = false,
                            ZIndex = 10,
                            Parent = parent3,
                        }
                    )
                    localization2.Icons.apply(value3, "keyboard")
                    local calculatedValue2 = counter3 + 2
                    local value4, counter6 =
                        createInstance(
                            "TextLabel",
                            {
                                Name = "Name",
                                BackgroundTransparency = 1,
                                Position = UDim2.fromOffset(calculatedValue2, 0),
                                Size = UDim2.new(1, -(calculatedValue2 + 60), 1, 0),
                                FontFace = font.Semi(),
                                TextSize = 11,
                                TextColor3 = textColor3,
                                TextXAlignment = Enum.TextXAlignment.Left,
                                TextTruncate = Enum.TextTruncate.AtEnd,
                                Text = "",
                                ZIndex = 10,
                                Parent = parent,
                            }
                        ),
                        14
                    local parent4 = createInstance(
                        "TextButton",
                        {
                            Name = "Switch",
                            Text = "",
                            AutoButtonColor = false,
                            AnchorPoint = Vector2.new(1, 0.5),
                            Position = UDim2.new(1, -5, 0.5, 0),
                            Size = UDim2.fromOffset(24, counter6),
                            BackgroundColor3 = color,
                            BackgroundTransparency = 0.8,
                            BorderSizePixel = 0,
                            Visible = visible,
                            ZIndex = 10,
                            Parent = parent,
                        }
                    )
                    u.corner(parent4, UDim.new(1, 0))
                    local value5 = createInstance(
                        "Frame",
                        {
                            Name = "Knob",
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.new(0, 2, 0.5, 0),
                            Size = UDim2.fromOffset(10, 10),
                            BackgroundColor3 = color,
                            BorderSizePixel = 0,
                            ZIndex = 11,
                            Parent = parent4,
                        }
                    )
                    u.corner(value5, UDim.new(1, 0))
                    local counter7 = 34
                    local parent5 = createInstance(
                        "TextButton",
                        {
                            Name = "Key",
                            Text = "",
                            AutoButtonColor = false,
                            BackgroundColor3 = color,
                            BackgroundTransparency = 0.88,
                            AnchorPoint = Vector2.new(1, 0.5),
                            Position = UDim2.new(1, -34, 0.5, 0),
                            Size = UDim2.fromOffset(18, 15),
                            BorderSizePixel = 0,
                            Visible = not calculatedValue,
                            ZIndex = 10,
                            Parent = parent,
                        }
                    )
                    u.corner(parent5, 4)
                    local value6 = createInstance(
                        "UIStroke",
                        {
                            Color = color,
                            Transparency = 0.8,
                            Thickness = 1,
                            ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
                            Parent = parent5,
                        }
                    )
                    local value7, enabled, createResult, value8 =
                        createInstance(
                            "TextLabel",
                            {
                                Name = "Text",
                                BackgroundTransparency = 1,
                                Size = UDim2.fromScale(1, 1),
                                FontFace = font.Bold(),
                                TextSize = 10,
                                TextColor3 = color,
                                Text = "",
                                ZIndex = 11,
                                Parent = parent5,
                            }
                        ),
                        false
                    featureState.frame = frame
                    local function callback7(text, argument2)
                        local maximumValue = math.max(18, math.floor(#text * 6 + 10))
                        value7.Text = text
                        text = UDim2.fromOffset(maximumValue, 15)
                        if argument2 then
                            parent5.Size = text
                        else
                            tweenInstance(parent5, "Quick", { Size = text })
                        end
                        text = calculatedValue and counter7 or counter7 + maximumValue + 6
                        value4.Size = UDim2.new(1, -(calculatedValue2 + text), 1, 0)
                    end
                    local function apply(argument2)
                        local calculatedValue2, on, calculatedValue3, resolveResult =
                            argument2 and TweenInfo.new(0) or "Quick",
                            featureState.on,
                            enabled and argument.KbCap ~= featureState,
                            theme.resolve("Accent")
                        tweenInstance(
                            parent2,
                            calculatedValue2,
                            {
                                BackgroundColor3 = on and resolveResult or color,
                                BackgroundTransparency = on and (calculatedValue3 and 0.08 or 0.2)
                                    or (calculatedValue3 and 0.85 or 0.92),
                            }
                        )
                        tweenInstance(
                            parent,
                            calculatedValue2,
                            { Position = UDim2.fromOffset(calculatedValue3 and 8 or 5, 0) }
                        )
                        local entries, fromOffset, calculatedValue4 =
                            {}, UDim2.fromOffset, on and 14 or (calculatedValue3 and 8 or 0)
                        entries.Size = fromOffset(3, calculatedValue4)
                        tweenInstance(value, calculatedValue2, entries)
                        tweenInstance(
                            parent3,
                            calculatedValue2,
                            { BackgroundTransparency = on and 0 or (calculatedValue3 and 0.78 or 0.87) }
                        )
                        tweenInstance(value2, calculatedValue2, { Transparency = on and 1 or 0.75 })
                        tweenInstance(
                            value3,
                            calculatedValue2,
                            {
                                ImageColor3 = on and resolveResult or color,
                                ImageTransparency = (on or calculatedValue3) and 0 or 0.15,
                            }
                        )
                        tweenInstance(
                            value4,
                            calculatedValue2,
                            { TextColor3 = (on or calculatedValue3) and color or textColor3 }
                        )
                        tweenInstance(parent4, calculatedValue2, { BackgroundTransparency = on and 0 or 0.8 })
                        tweenInstance(
                            value5,
                            calculatedValue2,
                            {
                                Position = on and UDim2.new(1, -(counter6 - 2), 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
                                BackgroundColor3 = on and resolveResult or color,
                            }
                        )
                        if argument.KbCap ~= featureState then
                            tweenInstance(
                                parent5,
                                calculatedValue2,
                                { BackgroundTransparency = on and 0.72 or 0.88 }
                            )
                            tweenInstance(
                                value6,
                                calculatedValue2,
                                { Color = color, Transparency = on and 0.55 or 0.8 }
                            )
                            tweenInstance(
                                value7,
                                calculatedValue2,
                                { TextTransparency = featureState.key and 0 or 0.55 }
                            )
                        end
                    end
                    featureState.refresh = function(argument2)
                        local value9, key = callback5(entry.key)
                        key = if value9 then if typeof(key) ~= "EnumItem" then nil else key else nil
                        if key == nil then
                            if argument.KbCap ~= featureState then
                                if not argument.KbEdit then
                                    if not calculatedValue then
                                        return true
                                    end
                                end
                            end
                        end
                        if entry.alive then
                            local value, value10 = callback5(entry.alive)
                            if value then
                                if value10 == false then
                                    return true
                                end
                            end
                        end
                        local on, text = callback5(entry.name)
                        text = on and tostring(text) or ""
                        if value4.Text ~= text then
                            value4.Text = text
                            value9 = callback4(text)
                            if value9 ~= value8 then
                                value8 = value9
                                localization2.Icons.apply(value3, value9)
                            end
                        end
                        value9, on = callback5(entry.active)
                        on = value9 and on and true or false
                        local calculatedValue2, calculatedValue3 =
                            featureState.key ~= key and featureState.key ~= nil and not calculatedValue,
                            featureState.key == nil ~= (key == nil)
                        featureState.key = key
                        if on ~= featureState.on then
                            featureState.on = on
                            apply(argument2)
                        elseif argument2 then
                            featureState.on = on
                            apply(argument2)
                        elseif calculatedValue3 then
                            featureState.on = on
                            apply(argument2)
                        end
                        if argument.KbCap ~= featureState then
                            on = key and localization2.keyName(key) or "—"
                            if on ~= featureState.keyTxt then
                                featureState.keyTxt = on
                                callback7(on, argument2)
                            end
                        end
                        return calculatedValue2
                    end
                    featureState.capture = function(argument2)
                        if argument2 then
                            featureState.keyTxt = nil
                            callback7("…")
                            tweenInstance(value7, "Quick", { TextTransparency = 0 })
                            tweenInstance(value6, "Quick", { Color = theme.resolve("Accent"), Transparency = 0 })
                            if createResult then
                                createResult:Cancel()
                            end
                            createResult = localization2.Services.TweenService:Create(
                                value6,
                                TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
                                { Transparency = 0.6 }
                            )
                            createResult:Play()
                        else
                            if createResult then
                                createResult:Cancel()
                                createResult = nil
                            end
                            featureState.keyTxt = nil
                            featureState.refresh()
                            apply()
                        end
                    end
                    local function handleAction()
                        if argument.KbCap then
                            return
                        elseif not visible then
                            return
                        end
                        localization2.safe(entry.toggle)
                        task.defer(function()
                            if featureState.refresh() then
                                argument:_kbDirty()
                            end
                        end)
                    end
                    frame.MouseEnter:Connect(function()
                        enabled = true
                        apply()
                    end)
                    u.leave(frame, function()
                        enabled = false
                        apply()
                    end)
                    frame.MouseButton1Click:Connect(handleAction)
                    parent4.MouseButton1Click:Connect(handleAction)
                    local function handleAction2()
                        if argument.KbCap ~= featureState then
                            tweenInstance(parent5, "Quick", { BackgroundTransparency = 0.66 })
                        end
                    end
                    parent5.MouseEnter:Connect(handleAction2)
                    u.leave(parent5, function()
                        if argument.KbCap ~= featureState then
                            tweenInstance(
                                parent5,
                                "Quick",
                                { BackgroundTransparency = featureState.on and 0.72 or 0.88 }
                            )
                        end
                    end)
                    local function handleAction()
                        if entry.set then
                            if argument.KbCap == featureState then
                                return
                            elseif os.clock() - (argument.KbBoundAt or 0) < 0.3 then
                                return
                            end
                        else
                            return
                        end
                        sound.play("click")
                        argument:_kbCapture(featureState)
                    end
                    parent5.MouseButton1Click:Connect(handleAction)
                    local function handleAction2()
                        if entry.set then
                            if argument.KbCap then
                                return
                            elseif os.clock() - (argument.KbBoundAt or 0) < 0.3 then
                                return
                            end
                        else
                            return
                        end
                        sound.play("tick")
                        localization2.safe(entry.set, nil)
                        argument:_kbRebuild()
                    end
                    parent5.MouseButton2Click:Connect(handleAction2)
                    featureState.apply = apply
                    featureState.refresh(true)
                    apply(true)
                    return featureState
                end
                local function callback7(parent, argument, argument2, argument3)
                    local calculatedValue, calculatedValue2 = argument3 and 24 or 18, argument3 and 34 or 18
                    local parent2 = createInstance(
                        "TextButton",
                        {
                            Name = "Btn",
                            Text = "",
                            AutoButtonColor = false,
                            AnchorPoint = Vector2.new(1, 0.5),
                            Position = argument3
                                    and argument2 + UDim2.fromOffset(
                                        math.floor((calculatedValue2 - calculatedValue) / 2),
                                        0
                                    )
                                or argument2,
                            Size = UDim2.fromOffset(calculatedValue2, calculatedValue2),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            ZIndex = 9,
                            Parent = parent,
                        }
                    )
                    local parent3 = createInstance(
                        "Frame",
                        {
                            Name = "Face",
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(calculatedValue, calculatedValue),
                            BackgroundColor3 = color,
                            BackgroundTransparency = 0.88,
                            BorderSizePixel = 0,
                            ZIndex = 9,
                            Parent = parent2,
                        }
                    )
                    u.corner(parent3, UDim.new(1, 0))
                    local value = createInstance(
                        "UIStroke",
                        { Color = color, Transparency = 0.78, Thickness = 1, Parent = parent3 }
                    )
                    local value2 = createInstance(
                        "ImageLabel",
                        {
                            AnchorPoint = Vector2.new(0.5, 0.5),
                            Position = UDim2.fromScale(0.5, 0.5),
                            Size = UDim2.fromOffset(argument3 and 13 or 10, argument3 and 13 or 10),
                            BackgroundTransparency = 1,
                            ImageColor3 = color,
                            Visible = false,
                            ZIndex = 10,
                            Parent = parent3,
                        }
                    )
                    localization2.Icons.apply(value2, argument)
                    local enabled, enabled2 = false, false
                    local function isActive2()
                        local resolveResult, properties, backgroundTransparency =
                            theme.resolve("Accent"),
                            { BackgroundColor3 = enabled and color or color },
                            enabled and 0 or (enabled2 and 0.78 or 0.88)
                        properties.BackgroundTransparency = backgroundTransparency
                        tweenInstance(parent3, "Quick", properties)
                        tweenInstance(value, "Quick", { Transparency = enabled and 1 or 0.78 })
                        tweenInstance(value2, "Quick", { ImageColor3 = enabled and resolveResult or color })
                    end
                    parent2.MouseEnter:Connect(function()
                        enabled2 = true
                        isActive2()
                    end)
                    u.leave(parent2, function()
                        enabled2 = false
                        isActive2()
                    end)
                    local function handleAction(argument)
                        if argument ~= nil then
                            enabled = argument and true or false
                        end
                        isActive2()
                    end
                    return parent2, value2, handleAction
                end
                windowClass._buildKeybindList = function(argument)
                    local keybindFrame, keybindCard = callback(
                        argument,
                        "KeybindList",
                        callback3(argument, "keybindPos", UDim2.fromOffset(16, 190))
                    )
                    keybindFrame.AutomaticSize = Enum.AutomaticSize.None
                    keybindFrame.Size = UDim2.fromOffset(counter, counter2 + 30)
                    keybindCard.AutomaticSize = Enum.AutomaticSize.None
                    keybindCard.ClipsDescendants = true
                    u.corner(keybindCard, 14)
                    local parent = createInstance(
                        "Frame",
                        {
                            Name = "Head",
                            Size = UDim2.new(1, 0, 0, counter2),
                            BackgroundTransparency = 1,
                            ZIndex = 7,
                            Parent = keybindCard,
                        }
                    )
                    local value = createInstance(
                        "TextLabel",
                        {
                            Name = "Title",
                            BackgroundTransparency = 1,
                            Position = UDim2.fromOffset(11, 0),
                            Size = UDim2.new(0, 0, 1, 0),
                            AutomaticSize = Enum.AutomaticSize.X,
                            FontFace = font.Bold(),
                            TextSize = 13,
                            TextColor3 = color,
                            TextXAlignment = Enum.TextXAlignment.Left,
                            Text = localization2.tr("Keybinds"),
                            ZIndex = 8,
                            Parent = parent,
                        }
                    )
                    local parent2 = createInstance(
                        "Frame",
                        {
                            Name = "Count",
                            AnchorPoint = Vector2.new(0, 0.5),
                            Position = UDim2.new(0, 11 + math.ceil(value.TextBounds.X) + 7, 0.5, 0),
                            Size = UDim2.fromOffset(0, 15),
                            AutomaticSize = Enum.AutomaticSize.X,
                            BorderSizePixel = 0,
                            ZIndex = 8,
                            Parent = parent,
                        }
                    )
                    bindTheme(parent2, "BackgroundColor3", "Accent")
                    u.corner(parent2, UDim.new(1, 0))
                    local kbCountLabel = createInstance(
                        "TextLabel",
                        {
                            Name = "Value",
                            BackgroundTransparency = 1,
                            Size = UDim2.new(0, 0, 1, 0),
                            AutomaticSize = Enum.AutomaticSize.X,
                            FontFace = font.Bold(),
                            TextSize = 10,
                            Text = "0/0",
                            ZIndex = 9,
                            Parent = parent2,
                        }
                    )
                    bindTheme(kbCountLabel, "TextColor3", "OnAccent")
                    u.pad(kbCountLabel, 0, 6, 0, 6)
                    local function keybindList()
                        parent2.Position = UDim2.new(0, 11 + math.ceil(value.TextBounds.X) + 7, 0.5, 0)
                    end
                    value:GetPropertyChangedSignal("TextBounds"):Connect(keybindList)
                    local value2, value = callback7(
                        parent,
                        argument.State.get("keybindFold", false) == true and "chevron-down" or "chevron-up",
                        UDim2.new(1, -8, 0.5, 0),
                        argument.IsTouch
                    )
                    local value3, unused, callback =
                        callback7(parent, "pencil", UDim2.new(1, -30, 0.5, 0), argument.IsTouch)
                    value3.Visible = not argument.IsTouch
                    keybindList = createInstance(
                        "ScrollingFrame",
                        {
                            Name = "List",
                            Position = UDim2.fromOffset(0, counter2),
                            Size = UDim2.new(1, 0, 1, -counter2),
                            BackgroundTransparency = 1,
                            BorderSizePixel = 0,
                            ScrollBarThickness = 2,
                            ScrollingDirection = Enum.ScrollingDirection.Y,
                            CanvasSize = UDim2.new(),
                            AutomaticCanvasSize = Enum.AutomaticSize.Y,
                            ZIndex = 7,
                            Parent = keybindCard,
                        }
                    )
                    bindTheme(keybindList, "ScrollBarImageColor3", "Faint")
                    u.list(keybindList, counter4)
                    u.pad(keybindList, 5, 6, 6, 5)
                    local kbEmpty = label({
                        Parent = keybindList,
                        Text = "—",
                        Font = font.Medium(),
                        Size = 11,
                        Box = UDim2.new(1, 0, 0, 18),
                        AlignX = Enum.TextXAlignment.Center,
                        Color = "Faint",
                        Z = 8,
                        Name = "Empty",
                    })
                    kbEmpty.LayoutOrder = 1000000
                    callback2(argument, parent, keybindFrame, "keybindPos")
                    argument.KeybindFrame = keybindFrame
                    argument.KeybindCard = keybindCard
                    argument.KeybindList = keybindList
                    argument.KbRows = {}
                    argument.KbEmpty = kbEmpty
                    argument.KbCountLabel = kbCountLabel
                    argument.KbEdit = false
                    argument.KbFold = argument.State.get("keybindFold", false) == true
                    theme.onChange(function(argument2)
                        if argument2 ~= "Accent" then
                            return
                        elseif argument.Destroyed then
                            return
                        elseif not argument.KbRows then
                            return
                        end
                        for unused, item in pairs(argument.KbRows) do
                            if item.apply then
                                if item.frame.Parent then
                                    pcall(item.apply)
                                end
                            end
                        end
                        pcall(callback)
                    end)
                    local function handleAction()
                        sound.play("click")
                        argument:_kbCancel()
                        argument.KbEdit = not argument.KbEdit
                        if argument.KbEdit then
                            if argument.KbFold then
                                argument.KbFold = false
                                argument.State.set("keybindFold", false)
                                localization2.Icons.apply(value, "chevron-up")
                            end
                        end
                        callback(argument.KbEdit)
                        argument:_kbRebuild()
                    end
                    value3.MouseButton1Click:Connect(handleAction)
                    local function handleAction2()
                        sound.play("tick")
                        argument:_kbCancel()
                        argument.KbFold = not argument.KbFold
                        if argument.KbFold then
                            if argument.KbEdit then
                                argument.KbEdit = false
                                callback(false)
                            end
                        end
                        argument.State.set("keybindFold", argument.KbFold)
                        localization2.Icons.apply(value, argument.KbFold and "chevron-down" or "chevron-up")
                        argument:_kbRebuild()
                    end
                    value2.MouseButton1Click:Connect(handleAction2)
                    u.connect(userInputService.InputBegan, function(argument2)
                        local kbCap = argument.KbCap
                        if kbCap then
                            if not argument.Listening then
                                return
                            end
                        else
                            return
                        end
                        local userInputType, userInputType2 = argument2.UserInputType
                        if userInputType == Enum.UserInputType.Keyboard then
                            local keyCode = argument2.KeyCode
                            if keyCode == Enum.KeyCode.Escape then
                                argument:_kbCancel()
                                return
                            end
                            if keyCode == Enum.KeyCode.Backspace or keyCode == Enum.KeyCode.Delete then
                                sound.play("tick")
                                localization2.safe(kbCap.entry.set, nil)
                                argument:_kbCancel()
                                argument:_kbRebuild()
                                return
                            end
                            userInputType2 = if keyCode ~= Enum.KeyCode.Unknown then keyCode else userInputType2
                        else
                            if
                                userInputType == Enum.UserInputType.MouseButton2
                                or userInputType == Enum.UserInputType.MouseButton3
                            then
                                argument.KbBoundAt = os.clock()
                                userInputType2 = userInputType
                            else
                                if userInputType == Enum.UserInputType.MouseButton1 then
                                    argument.KbBoundAt = os.clock()
                                    argument:_kbCancel()
                                    return
                                elseif userInputType == Enum.UserInputType.Touch then
                                    argument:_kbCancel()
                                    return
                                end
                            end
                        end
                        if userInputType2 then
                            sound.play("tick")
                            localization2.safe(kbCap.entry.set, userInputType2)
                            argument:_kbCancel()
                            argument:_kbRebuild()
                        end
                    end, argument.Conns)
                    local counter6 = 0
                    u.connect(runService.Heartbeat, function(argument2)
                        if argument.Destroyed then
                            return
                        elseif not keybindFrame.Visible then
                            return
                        end
                        counter6 += argument2
                        if counter6 < 0.08 then
                            return
                        end
                        counter6 = 0
                        local enabled, calculatedValue, counter6 = false, 0, 0
                        for unused, item in pairs(argument.KbRows) do
                            enabled = if item.refresh() then true else enabled
                            if item.key or argument.IsTouch then
                                calculatedValue, counter6 =
                                    calculatedValue + 1, if item.on then counter6 + 1 else counter6
                            else
                            end
                        end
                        if enabled then
                            argument:_kbDirty()
                        else
                            argument:_kbCount(counter6, calculatedValue)
                        end
                    end, argument.Conns)
                end
                windowClass._kbCount = function(text, argument, argument2)
                    local kbCountLabel = text.KbCountLabel
                    if not kbCountLabel then
                        return
                    end
                    text = tostring(argument) .. "/" .. tostring(argument2)
                    if kbCountLabel.Text ~= text then
                        kbCountLabel.Text = text
                    end
                end
                windowClass._kbRebuild = function(calculatedValue, argument)
                    local keybindFrame = calculatedValue.KeybindFrame
                    if keybindFrame then
                        if calculatedValue.Destroyed then
                            return
                        end
                    else
                        return
                    end
                    local keybindEntries = {}
                    for unused, item in ipairs(calculatedValue.KeybindEntries or {}) do
                        local enabled, enabled2 = true, true
                        if item.alive then
                            enabled, enabled2 = callback5(item.alive)
                        else
                        end
                        if enabled then
                            if enabled2 ~= false then
                                table.insert(keybindEntries, item)
                            end
                        else
                            table.insert(keybindEntries, item)
                        end
                    end
                    calculatedValue.KeybindEntries = keybindEntries
                    local kbRows, size, entries, counter6, calculatedValue2, counter7 =
                        calculatedValue.KbRows, {}, {}, 0, 0, 0
                    for key, item in ipairs(keybindEntries) do
                        local entry, value = callback5(item.key)
                        value = if entry then if typeof(value) ~= "EnumItem" then nil else value else nil
                        local value2, calculatedValue3 = callback5(item.name)
                        entry = value2 and tostring(calculatedValue3) or ""
                        local calculatedValue4, calculatedValue5, calculatedValue6 =
                            entry .. "|" .. (value and tostring(value) or (calculatedValue.KbEdit and "" or "-")),
                            calculatedValue.KbCap ~= nil and calculatedValue.KbCap.entry == item
                        if calculatedValue.IsTouch then
                            calculatedValue6 = type(item.toggle) == "function" and entry ~= "" and not size[entry]
                            calculatedValue4 = entry
                        else
                            calculatedValue3 = calculatedValue5 or value ~= nil and not size[calculatedValue4]
                            calculatedValue6 = calculatedValue3
                                or calculatedValue.KbEdit
                                    and item.set ~= nil
                                    and entry ~= ""
                                    and not size[calculatedValue4]
                        end
                        if calculatedValue6 then
                            size[calculatedValue4] = true
                            entries[item] = true
                            entry = kbRows[item]
                            if entry then
                                entry.refresh()
                            else
                                entry = callback6(calculatedValue, item)
                                kbRows[item] = entry
                            end
                            entry.frame.LayoutOrder = ((value or calculatedValue.IsTouch) and 0 or 100000) + key
                            counter6 += 1
                            if value or calculatedValue.IsTouch then
                                calculatedValue2, counter7 =
                                    calculatedValue2 + 1, if entry.on then counter7 + 1 else counter7
                            else
                            end
                        else
                        end
                    end
                    keybindEntries = {}
                    for key in pairs(kbRows) do
                        if not entries[key] then
                            table.insert(keybindEntries, key)
                        end
                    end
                    for unused, item in ipairs(keybindEntries) do
                        entries = kbRows[item]
                        kbRows[item] = nil
                        if calculatedValue.KbCap == entries then
                            calculatedValue:_kbCancel()
                        end
                        entries.frame:Destroy()
                    end
                    calculatedValue.KbEmpty.Visible = counter6 == 0
                    calculatedValue:_kbCount(counter7, calculatedValue2)
                    entries = calculatedValue.KbFold == true
                    calculatedValue.KeybindList.Visible = not entries
                    keybindEntries = counter6 > 0 and counter6 * counter3 + (counter6 - 1) * counter4 or 18
                    calculatedValue = entries and counter2 or counter2 + math.min(5 + keybindEntries + 6, counter5)
                    size = UDim2.fromOffset(counter, calculatedValue)
                    if argument then
                        keybindFrame.Size = size
                    elseif keybindFrame.Visible then
                        tweenInstance(keybindFrame, "Base", { Size = size })
                    else
                        keybindFrame.Size = size
                    end
                end
            end
            return localization2
        end
        return (isActive())
    end)
    if not success or type(localization2) ~= "table" then
        warn("[GGH] failed to initialize: " .. tostring(localization2))
        return nil
    end
    Nova = localization2
end

-- =====================================================================
--  Public API layer
--  Thin, additive aliases over the original Nova methods. Every original
--  method (Window:Tab, Tab:Section, Section:Toggle, ...) keeps working
--  exactly as before; the Create* names below simply forward to them.
-- =====================================================================
local Library = Nova
local WindowClass = Nova.WindowClass
local TabClass = Nova.TabClass
local SectionClass = Nova.SectionClass
local nativeCreateWindow = Nova.CreateWindow
local nativeDestroy = WindowClass.Destroy

Library.Version = "1.0.0"
Library.Name = "GGH"
Library.Author = "AM_BRCR7"
Library.Debug = true
Library.KeybindIcons = Library.KeybindIcons or {}

local function copy(source)
    local result = {}
    for key, value in pairs(source) do
        result[key] = value
    end
    return result
end

-- Accepts either a plain string or an options table and returns a fresh
-- table in the shape the original elements expect (Text / Desc).

-- Console announcements: every window / tab / section / element created
-- prints a "[ggh]" line (set Library.Debug = false to silence them).
local function announce(kind, options)
    if not Library.Debug then
        return
    end
    local label = options
    if type(options) == "table" then
        label = options.Text or options.Title or options.Name
    end
    print(("[ggh] %s created: %s"):format(kind, tostring(label or "?")))
end

local function normalize(options)
    if type(options) == "string" then
        return { Text = options }
    end
    local result = copy(options or {})
    if result.Text == nil then
        result.Text = result.Name or result.Title
    end
    if result.Desc == nil then
        result.Desc = result.Description
    end
    return result
end

-- Theme names -------------------------------------------------------
local THEME_ALIASES = { Dark = "Midnight" }

local function resolveThemeName(name)
    if type(name) ~= "string" then
        return name
    end
    return THEME_ALIASES[name] or name
end

function Library:GetThemes()
    local names = {}
    for _, item in ipairs(Nova.Theme.Bases) do
        names[#names + 1] = item[1]
    end
    return names
end

-- Windows -----------------------------------------------------------
local function uniqueGuiName(wanted)
    local taken = {}
    for _, window in ipairs(Library.Windows) do
        if not window.Destroyed and window.Gui then
            taken[window.Gui.Name] = true
        end
    end
    if not taken[wanted] then
        return wanted
    end
    local counter = 2
    while taken[wanted .. "_" .. counter] do
        counter += 1
    end
    return wanted .. "_" .. counter
end

function Library.CreateWindow(self, options)
    if self ~= Library and type(self) == "table" and options == nil then
        options = self
    end
    local config = copy(options or {})
    if config.Theme ~= nil and config.Base == nil then
        config.Base = resolveThemeName(config.Theme)
    end
    if config.Subtitle == nil then
        config.Subtitle = config.SubTitle
    end
    config.GuiName = uniqueGuiName(config.GuiName or "GGH")
    local window = nativeCreateWindow(Library, config)
    announce("window", config.Title or "GGH")
    pcall(function()
        window:_installHeaderControls(config)
    end)
    return window
end

function WindowClass:CreateTab(options)
    announce("tab", options)
    if type(options) == "string" then
        return self:Tab({ Name = options })
    end
    return self:Tab(copy(options or {}))
end
WindowClass.AddTab = WindowClass.CreateTab

function WindowClass:SetTheme(name)
    return self:SetBase(resolveThemeName(name))
end

function WindowClass:CreateNotification(options)
    return self:Notify(options)
end

function WindowClass:Cleanup()
    return self:Destroy()
end

function WindowClass:Destroy()
    nativeDestroy(self)
    for index, window in ipairs(Library.Windows) do
        if window == self then
            table.remove(Library.Windows, index)
            break
        end
    end
end

-- =====================================================================
--  Header controls: minimize button + settings button
--  Both buttons are drawn from plain Frames (no image assets needed).
-- =====================================================================
local Theme = Nova.Theme
local Motion = Nova.Motion
local Util = Nova.U

local MINIMIZED_HEIGHT = 64
local GLYPH_BAR_Z = 9

local function drawBar(parent, name, width, height, offsetX, offsetY, themeToken)
    local bar = Util.new("Frame", {
        Name = name,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, offsetX or 0, 0.5, offsetY or 0),
        Size = UDim2.fromOffset(width, height),
        BorderSizePixel = 0,
        ZIndex = GLYPH_BAR_Z,
        Parent = parent,
    })
    Theme.bind(bar, "BackgroundColor3", themeToken or "Muted")
    Util.corner(bar, UDim.new(1, 0))
    return bar
end

-- Tints every bar of a glyph while the pointer is over the button.
local function bindGlyphHover(button, bars)
    button.MouseEnter:Connect(function()
        for _, bar in ipairs(bars) do
            Motion.tween(bar, "Quick", { BackgroundColor3 = Color3.new(1, 1, 1) })
        end
    end)
    Util.leave(button, function()
        for _, bar in ipairs(bars) do
            Motion.tween(bar, "Quick", { BackgroundColor3 = Theme.resolve("Muted") })
        end
    end)
end

local function hideDefaultIcon(button)
    local defaultIcon = button:FindFirstChild("Icon")
    if defaultIcon then
        defaultIcon.Visible = false
    end
end

function WindowClass:_buildMinimizeButton()
    local button = self:AddHeaderButton({
        Name = "Minimize",
        Image = "",
        Tip = "Minimize",
        Callback = function()
            self:SetMinimized(not self.Minimized)
        end,
    })
    if not button then
        return nil
    end
    hideDefaultIcon(button)

    local horizontalBar = drawBar(button, "GlyphHorizontal", 12, 2)
    local verticalBar = drawBar(button, "GlyphVertical", 2, 12)
    verticalBar.BackgroundTransparency = 1
    bindGlyphHover(button, { horizontalBar, verticalBar })

    self.MinimizeButton = button
    self._minimizeGlyph = verticalBar
    return button
end

function WindowClass:_buildSettingsButton()
    local button = self:AddHeaderButton({
        Name = "SettingsButton",
        Image = "",
        Tip = "Settings",
        Callback = function()
            self:ToggleSettingsTab()
        end,
    })
    if not button then
        return nil
    end
    hideDefaultIcon(button)

    -- Three slider rows: a line plus a knob on each.
    local lines, knobs = {}, {}
    local rows = { { y = -5, knobX = -3 }, { y = 0, knobX = 3 }, { y = 5, knobX = -1 } }
    for index, row in ipairs(rows) do
        lines[index] = drawBar(button, "SettingsLine" .. index, 14, 2, 0, row.y)
        local knob = drawBar(button, "SettingsKnob" .. index, 6, 6, row.knobX, row.y, "Accent")
        knob.ZIndex = GLYPH_BAR_Z + 1
        knobs[index] = knob
    end
    bindGlyphHover(button, lines)

    self.SettingsButton = button
    self._settingsLines = lines
    return button
end

function WindowClass:_installHeaderControls(config)
    if config.MinimizeButton ~= false then
        self:_buildMinimizeButton()
    end
    if config.SettingsButton ~= false then
        self:_buildSettingsButton()
    end
    self.SettingsTabName = config.SettingsTabName or "Settings"
end

-- Minimize ---------------------------------------------------------
-- While minimized, only the sidebar's brand block stays visible; the
-- search box, tab list and footer are hidden and brought back on restore.
local function hideSidebarContent(window)
    local sidebar = window.Sidebar
    if not sidebar then
        return
    end
    window._hiddenSidebarItems = {}
    for _, child in ipairs(sidebar:GetChildren()) do
        if child:IsA("GuiObject") and child.Visible then
            local offsetY = child.AbsolutePosition.Y - sidebar.AbsolutePosition.Y
            if offsetY >= 50 * (window.Scale and window.Scale.Scale or 1) then
                table.insert(window._hiddenSidebarItems, child)
                child.Visible = false
            end
        end
    end
end

local function restoreSidebarContent(window)
    for _, child in ipairs(window._hiddenSidebarItems or {}) do
        if child.Parent then
            child.Visible = true
        end
    end
    window._hiddenSidebarItems = nil
end

function WindowClass:SetMinimized(minimized, instant)
    minimized = minimized == true
    if self.Destroyed or self.Minimized == minimized then
        return
    end
    if minimized and not self.IsOpen then
        return
    end
    self.Minimized = minimized

    local root = self.Root
    local scale = self.Scale and self.Scale.Scale or 1
    local resizeHandle = self.Win and self.Win:FindFirstChild("Resize")
    local preset = instant and "Linear" or "Base"
    self:ClosePopups()
    self:HideTip()

    if minimized then
        self.RestoreSize = root.Size
        local fullHeight = root.Size.Y.Offset
        -- The root is centre-anchored, so shift it to keep the top edge fixed.
        self.MinimizeShift = (MINIMIZED_HEIGHT - fullHeight) * scale / 2
        local position = root.Position
        local target = {
            Size = UDim2.new(root.Size.X.Scale, root.Size.X.Offset, 0, MINIMIZED_HEIGHT),
            Position = UDim2.new(
                position.X.Scale, position.X.Offset,
                position.Y.Scale, position.Y.Offset + self.MinimizeShift
            ),
        }
        if resizeHandle then
            resizeHandle.Visible = false
        end
        hideSidebarContent(self)
        if self.Body then
            self.Body.Visible = false
        end
        Motion.tween(root, preset, target)
    else
        if self.Body then
            self.Body.Visible = true
        end
        restoreSidebarContent(self)
        local position = root.Position
        local shift = self.MinimizeShift or 0
        Motion.tween(root, preset, {
            Size = self.RestoreSize or UDim2.fromOffset(self.Size.X, self.Size.Y),
            Position = UDim2.new(
                position.X.Scale, position.X.Offset,
                position.Y.Scale, position.Y.Offset - shift
            ),
        })
        task.delay(instant and 0 or 0.26, function()
            if not self.Minimized and resizeHandle then
                resizeHandle.Visible = true
            end
        end)
    end

    if self._minimizeGlyph then
        -- The "-" turns into a "+" while minimized.
        Motion.tween(self._minimizeGlyph, "Quick", { BackgroundTransparency = minimized and 0 or 1 })
    end
end

-- Settings tab -------------------------------------------------------
-- The tab is built once, then attached to / detached from the sidebar so
-- it only exists while the settings button is toggled on.
local function paintSettingsGlyph(window, active)
    for _, line in ipairs(window._settingsLines or {}) do
        Motion.tween(line, "Quick", {
            BackgroundColor3 = active and Theme.resolve("Accent") or Theme.resolve("Muted"),
        })
    end
end

local function detachSettingsTab(window, tab)
    local group = tab.Group
    if group then
        local position = table.find(group.Tabs, tab)
        if position then
            table.remove(group.Tabs, position)
        end
    end
    local listPosition = table.find(window.TabList, tab)
    if listPosition then
        table.remove(window.TabList, listPosition)
    end
    if tab.Row then
        tab.Row.Visible = false
    end
    window:_layoutTabs(true)
end

local function attachSettingsTab(window, tab)
    local group = tab.Group or window:_ensureGroup()
    if not table.find(group.Tabs, tab) then
        table.insert(group.Tabs, tab)
    end
    if not table.find(window.TabList, tab) then
        table.insert(window.TabList, tab)
    end
    if tab.Row then
        tab.Row.Visible = true
    end
    window:_layoutTabs(true)
end

function WindowClass:_openSettingsTab()
    if self.SettingsOpen or self.Destroyed then
        return
    end
    if self.Minimized then
        self:SetMinimized(false)
    end
    local tab = self.SettingsTab
    if tab then
        attachSettingsTab(self, tab)
    else
        tab = self:Tab({
            Name = self.SettingsTabName or "Settings",
            Title = "Settings",
            Desc = "Interface and appearance",
            Icon = "settings",
        })
        self.SettingsTab = tab
        pcall(function()
            self:AddAppearance(tab, {})
        end)
    end
    self.SettingsReturnTab = self.Current ~= tab and self.Current or self.SettingsReturnTab
    self.SettingsOpen = true
    paintSettingsGlyph(self, true)
    self:SelectTab(tab)
end

function WindowClass:_closeSettingsTab()
    local tab = self.SettingsTab
    if not tab or not self.SettingsOpen then
        return
    end
    self.SettingsOpen = false
    paintSettingsGlyph(self, false)
    if self.Current == tab then
        local fallback = self.SettingsReturnTab
        if not fallback or fallback == tab or not table.find(self.TabList, fallback) then
            fallback = nil
            for _, candidate in ipairs(self.TabList) do
                if candidate ~= tab then
                    fallback = candidate
                    break
                end
            end
        end
        if fallback then
            self:SelectTab(fallback)
        end
    end
    detachSettingsTab(self, tab)
end

function WindowClass:ToggleSettingsTab()
    if self.SettingsOpen then
        self:_closeSettingsTab()
    else
        self:_openSettingsTab()
    end
end

-- Switching to any other tab removes the settings tab again.
local nativeSelectTab = WindowClass.SelectTab
function WindowClass:SelectTab(entry)
    local result = nativeSelectTab(self, entry)
    local tab = self.SettingsTab
    if tab and self.SettingsOpen and self.Current ~= tab then
        self.SettingsOpen = false
        paintSettingsGlyph(self, false)
        detachSettingsTab(self, tab)
    end
    return result
end

-- Tabs / Sections -----------------------------------------------------
function TabClass:CreateSection(options)
    announce("section", options)
    if type(options) == "string" then
        return self:Section({ Title = options })
    end
    local config = copy(options or {})
    if config.Title == nil then
        config.Title = config.Name
    end
    return self:Section(config)
end
TabClass.AddSection = TabClass.CreateSection

-- Elements --------------------------------------------------------------
function SectionClass:CreateButton(options)
    announce("button", options)
    return self:Button(normalize(options))
end

function SectionClass:CreateToggle(options)
    announce("toggle", options)
    return self:Toggle(normalize(options))
end

function SectionClass:CreateSlider(options)
    announce("slider", options)
    return self:Slider(normalize(options))
end

function SectionClass:CreateDropdown(options)
    announce("dropdown", options)
    local config = normalize(options)
    config.Values = config.Values or config.Options
    return self:Dropdown(config)
end

function SectionClass:CreateMultiDropdown(options)
    local config = normalize(options)
    config.Values = config.Values or config.Options
    config.Multi = true
    return self:Dropdown(config)
end

function SectionClass:CreateTextbox(options)
    announce("textbox", options)
    local config = normalize(options)
    if config.Placeholder == nil then
        config.Placeholder = config.PlaceholderText
    end
    return self:Input(config)
end
SectionClass.CreateInput = SectionClass.CreateTextbox

function SectionClass:CreateLabel(options)
    announce("label", options)
    return self:Label(normalize(options))
end

function SectionClass:CreateParagraph(options)
    announce("paragraph", options)
    if type(options) == "string" then
        return self:Paragraph({ Text = options })
    end
    local config = copy(options or {})
    if config.Title == nil then
        config.Title = config.Name
    end
    if config.Text == nil then
        config.Text = config.Content
    end
    return self:Paragraph(config)
end

function SectionClass:CreateKeybind(options)
    announce("keybind", options)
    local config = normalize(options)
    if config.Pressed == nil then
        config.Pressed = config.OnPress
    end
    return self:Keybind(config)
end

function SectionClass:CreateColorPicker(options)
    announce("colorpicker", options)
    return self:Colorpicker(normalize(options))
end
SectionClass.CreateColorpicker = SectionClass.CreateColorPicker

function SectionClass:CreateDivider(spacious)
    return self:Divider(spacious)
end

-- Notifications ---------------------------------------------------------
function Library:CreateNotification(options)
    return Library.Notify(self, options)
end

-- Global cleanup --------------------------------------------------------
function Library:Cleanup()
    local windows = {}
    for index, window in ipairs(Library.Windows) do
        windows[index] = window
    end
    for _, window in ipairs(windows) do
        pcall(function()
            window:Destroy()
        end)
    end
    for _, connection in ipairs(Library.Conns) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(Library.Conns)
end
Library.Destroy = Library.Cleanup
Library.Unload = Library.Cleanup

-- =====================================================================
--  KEY SYSTEM
--  Library:CreateKeySystem(config)  (alias: Library:KeySystem)
--  Returns: success (boolean), info (table)
--  Everything is optional and controlled from the config table.
-- =====================================================================
do
    local Services = Nova.Services
    local HttpService = Services.HttpService
    local Players = Services.Players
    local UserInputService = Services.UserInputService
    local U, ThemeM, MotionM, FontM = Nova.U, Nova.Theme, Nova.Motion, Nova.Font
    local new, bind = U.new, ThemeM.bind
    local mkLabel, mkIcon = Nova.label, Nova.icon
    local LocalPlayer = Players.LocalPlayer

    -- ------------------------------------------------------------------
    -- defaults
    -- ------------------------------------------------------------------
    local DEFAULT_TEXT = {
        Title = "Key System",
        Subtitle = "Enter your key to continue",
        Placeholder = "Paste your key here",
        Verify = "Verify Key",
        Checking = "Checking...",
        GetKey = "Get Key",
        Hwid = "HWID",
        Copy = "Copy",
        Copied = "Copied",
        Remember = "Remember key",
        Empty = "Enter your key first",
        Valid = "Key verified",
        Invalid = "Invalid key",
        Expired = "This key has expired",
        HwidMismatch = "This key belongs to another device",
        UserMismatch = "This key belongs to another account",
        Unreachable = "Could not reach the key server",
        NoSource = "No key source is configured",
        Wait = "Please wait %ds",
        Attempts = "Attempts left: %d",
        Locked = "Too many attempts",
        GetKeyCopied = "Link copied to clipboard",
        GetKeyFailed = "Could not get a key",
        NoClipboard = "Clipboard is not supported here",
        Requesting = "Contacting server...",
        Discord = "Discord",
    }

    -- fields that are sent when Send = nil / true
    local DEFAULT_SEND = { Hwid = true, Key = true, UserId = true, Username = true, PlaceId = true, Executor = true }
    local FIELD_NAMES = {
        Hwid = "hwid",
        Key = "key",
        UserId = "userid",
        Username = "username",
        DisplayName = "displayname",
        PlaceId = "placeid",
        GameId = "gameid",
        JobId = "jobid",
        GameName = "gamename",
        Executor = "executor",
        Time = "time",
    }

    -- ------------------------------------------------------------------
    -- small helpers
    -- ------------------------------------------------------------------
    local function shallowCopy(t)
        local r = {}
        for k, v in pairs(t or {}) do
            r[k] = v
        end
        return r
    end

    local function trim(s)
        return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
    end

    local function tryJson(s)
        if type(s) ~= "string" or s == "" then
            return nil
        end
        local ok, r = pcall(function()
            return HttpService:JSONDecode(s)
        end)
        if ok then
            return r
        end
        return nil
    end

    local function inList(list, value)
        if type(list) ~= "table" then
            return tostring(list) == tostring(value)
        end
        for _, v in pairs(list) do
            if tostring(v) == tostring(value) then
                return true
            end
        end
        return false
    end

    local function fmtDuration(sec)
        sec = math.max(0, math.floor(sec))
        local d = math.floor(sec / 86400)
        local h = math.floor((sec % 86400) / 3600)
        local m = math.floor((sec % 3600) / 60)
        if d > 0 then
            return ("%dd %dh"):format(d, h)
        elseif h > 0 then
            return ("%dh %dm"):format(h, m)
        end
        return ("%dm"):format(math.max(m, 1))
    end

    local function setClipboard(text)
        local getters = {
            function() return setclipboard end,
            function() return toclipboard end,
            function() return set_clipboard end,
            function() return Clipboard.set end,
        }
        for _, g in ipairs(getters) do
            local ok, fn = pcall(g)
            if ok and type(fn) == "function" then
                if pcall(fn, tostring(text)) then
                    return true
                end
            end
        end
        return false
    end

    local function readFileSafe(path)
        local ok, r = pcall(function()
            if isfile and isfile(path) then
                return readfile(path)
            end
            return nil
        end)
        if ok then
            return r
        end
        return nil
    end

    local function writeFileSafe(path, data)
        pcall(function()
            if not writefile then
                return
            end
            local dir = path:match("^(.*)/[^/]+$")
            if dir and makefolder then
                pcall(function()
                    if not (isfolder and isfolder(dir)) then
                        makefolder(dir)
                    end
                end)
            end
            writefile(path, data)
        end)
    end

    local function deleteFileSafe(path)
        pcall(function()
            if delfile and isfile and isfile(path) then
                delfile(path)
            end
        end)
    end

    -- ------------------------------------------------------------------
    -- device info / HWID
    -- ------------------------------------------------------------------
    local hwidCache
    function Library.GetHWID()
        if hwidCache then
            return hwidCache
        end
        local sources = {
            function() return gethwid() end,
            function() return get_hwid() end,
            function() return game:GetService("RbxAnalyticsService"):GetClientId() end,
        }
        for _, src in ipairs(sources) do
            local ok, r = pcall(src)
            if ok and type(r) == "string" and #r > 3 then
                hwidCache = r
                return r
            end
        end
        -- last resort: random id kept in a file so it stays the same
        local path = "GGH/hwid.txt"
        local saved = readFileSafe(path)
        if saved and #trim(saved) > 3 then
            hwidCache = trim(saved)
            return hwidCache
        end
        hwidCache = HttpService:GenerateGUID(false)
        writeFileSafe(path, hwidCache)
        return hwidCache
    end

    local function resolveHwid(cfg)
        local h = cfg.Hwid
        if h == false then
            return ""
        end
        if type(h) == "function" then
            local ok, r = pcall(h)
            if ok and r ~= nil then
                return tostring(r)
            end
        elseif type(h) == "string" and h ~= "" then
            return h
        end
        return Library.GetHWID()
    end

    function Library.GetDeviceInfo(cfg)
        cfg = cfg or {}
        local executor = "unknown"
        pcall(function()
            local n, v = identifyexecutor()
            executor = tostring(n) .. (v and (" " .. tostring(v)) or "")
        end)
        return {
            Hwid = resolveHwid(cfg),
            UserId = LocalPlayer and LocalPlayer.UserId or 0,
            Username = LocalPlayer and LocalPlayer.Name or "",
            DisplayName = LocalPlayer and LocalPlayer.DisplayName or "",
            PlaceId = game.PlaceId,
            GameId = game.GameId,
            JobId = game.JobId,
            Executor = executor,
        }
    end

    local gameNameCache
    local function getGameName()
        if gameNameCache then
            return gameNameCache
        end
        local ok, r = pcall(function()
            return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end)
        gameNameCache = ok and tostring(r) or ""
        return gameNameCache
    end

    -- Build the table of fields that gets sent to a website.
    -- send: nil/true = default fields, false = nothing, table = pick fields
    --   { Hwid=true, UserId=true, ..., All=true, Names={Hwid="hw"}, Extra={...}, Custom=function(payload) end }
    local function buildPayload(send, key, device, extraFields)
        local payload = {}
        if send == false then
            return payload
        end
        local pick = (send == nil or send == true) and DEFAULT_SEND or send
        local names = type(pick) == "table" and pick.Names or nil
        for field, defaultName in pairs(FIELD_NAMES) do
            if pick.All == true or pick[field] == true then
                local value
                if field == "Key" then
                    value = key
                elseif field == "Time" then
                    value = os.time()
                elseif field == "GameName" then
                    value = getGameName()
                else
                    value = device[field]
                end
                if value ~= nil and value ~= "" then
                    payload[(names and names[field]) or defaultName] = value
                end
            end
        end
        for k, v in pairs(pick.Extra or {}) do
            payload[k] = v
        end
        for k, v in pairs(extraFields or {}) do
            payload[k] = v
        end
        if type(pick.Custom) == "function" then
            local ok, r = pcall(pick.Custom, payload, device, key)
            if ok and type(r) == "table" then
                payload = r
            end
        end
        return payload
    end

    -- {key} {hwid} {userid} ... placeholders inside URLs / headers
    local function allVars(key, device)
        return {
            key = key or "",
            hwid = device.Hwid,
            userid = device.UserId,
            username = device.Username,
            displayname = device.DisplayName,
            placeid = device.PlaceId,
            gameid = device.GameId,
            jobid = device.JobId,
            executor = device.Executor,
            time = os.time(),
        }
    end

    local function fillVars(str, vars, raw)
        if type(str) ~= "string" then
            return str
        end
        return (str:gsub("{(%w+)}", function(name)
            local v = vars[name:lower()]
            if v == nil then
                return nil
            end
            if raw then
                return tostring(v)
            end
            return HttpService:UrlEncode(tostring(v))
        end))
    end

    -- ------------------------------------------------------------------
    -- http
    -- ------------------------------------------------------------------
    local function httpRequest(o)
        local getters = {
            function() return request end,
            function() return http_request end,
            function() return syn.request end,
            function() return http.request end,
            function() return fluxus.request end,
        }
        local fn
        for _, g in ipairs(getters) do
            local ok, f = pcall(g)
            if ok and type(f) == "function" then
                fn = f
                break
            end
        end
        local method = tostring(o.Method or "GET"):upper()
        if fn then
            local ok, res = pcall(fn, { Url = o.Url, Method = method, Headers = o.Headers, Body = o.Body })
            if ok and type(res) == "table" then
                local status = tonumber(res.StatusCode or res.Status) or 0
                local success = res.Success
                if type(success) ~= "boolean" then
                    success = status >= 200 and status < 300
                end
                return { Reached = true, Success = success, Status = status, Body = res.Body or "" }
            end
            return { Reached = false, Success = false, Status = 0, Body = "" }
        end
        if method == "GET" then
            local ok, body = pcall(function()
                return game:HttpGet(o.Url)
            end)
            if ok then
                return { Reached = true, Success = true, Status = 200, Body = body }
            end
        end
        return { Reached = false, Success = false, Status = 0, Body = "" }
    end

    local function encodeQuery(t)
        local keys = {}
        for k in pairs(t) do
            keys[#keys + 1] = k
        end
        table.sort(keys)
        local parts = {}
        for _, k in ipairs(keys) do
            parts[#parts + 1] = HttpService:UrlEncode(tostring(k)) .. "=" .. HttpService:UrlEncode(tostring(t[k]))
        end
        return table.concat(parts, "&")
    end

    local function withQuery(url, t)
        local q = encodeQuery(t)
        if q == "" then
            return url
        end
        return url .. (url:find("?", 1, true) and "&" or "?") .. q
    end

    -- rcfg = { Url, Method, Headers, Format = "json" | "query" | "form" }
    local function sendRequest(rcfg, payload, vars)
        local method = tostring(rcfg.Method or "POST"):upper()
        local url = fillVars(rcfg.Url, vars)
        local headers = {}
        for k, v in pairs(rcfg.Headers or {}) do
            headers[k] = fillVars(tostring(v), vars, true)
        end
        local fmt = tostring(rcfg.Format or (method == "GET" and "query" or "json")):lower()
        local body
        if method == "GET" or fmt == "query" then
            url = withQuery(url, payload)
        elseif fmt == "form" then
            body = encodeQuery(payload)
            headers["Content-Type"] = headers["Content-Type"] or "application/x-www-form-urlencoded"
        else
            body = HttpService:JSONEncode(payload)
            headers["Content-Type"] = headers["Content-Type"] or "application/json"
        end
        return httpRequest({ Url = url, Method = method, Headers = headers, Body = body })
    end

    -- ------------------------------------------------------------------
    -- key checking
    -- ------------------------------------------------------------------
    local function keysEqual(cfg, a, b)
        a, b = tostring(a), tostring(b)
        if cfg.CaseSensitive == false then
            return a:lower() == b:lower()
        end
        return a == b
    end

    -- entry = "KEY"  or  { Key=, Expires=unix, Hwid=str|list, UserIds={}, Usernames={} }
    -- returns matched, ok, message, data
    local function checkEntry(cfg, entry, key, device, T)
        if type(entry) == "string" then
            if keysEqual(cfg, entry, key) then
                return true, true, nil, {}
            end
            return false
        end
        if type(entry) ~= "table" then
            return false
        end
        local k = entry.Key or entry.key or entry[1]
        if k == nil or not keysEqual(cfg, k, key) then
            return false
        end
        local expires = tonumber(entry.Expires or entry.expires or entry.Expiry)
        if expires and expires > 0 and os.time() >= expires then
            return true, false, T.Expired, {}
        end
        local hw = entry.Hwid or entry.hwid
        if hw ~= nil and hw ~= "" and not inList(hw, device.Hwid) then
            return true, false, T.HwidMismatch, {}
        end
        local uids = entry.UserIds or entry.userids
        if uids and not inList(uids, device.UserId) then
            return true, false, T.UserMismatch, {}
        end
        local unames = entry.Usernames or entry.usernames
        if unames and not inList(unames, device.Username) then
            return true, false, T.UserMismatch, {}
        end
        return true, true, nil, { Expires = (expires and expires > 0) and expires or nil, Entry = entry }
    end

    local function checkEntries(cfg, entries, key, device, T)
        local lastMsg
        for _, entry in ipairs(entries) do
            local matched, ok, msg, data = checkEntry(cfg, entry, key, device, T)
            if matched then
                if ok then
                    return true, nil, data
                end
                lastMsg = msg
            end
        end
        return false, lastMsg, nil
    end

    -- keys downloaded from a link: plain text (one per line, "key|expires|hwid"),
    -- a JSON array, {"keys":[...]}, or a JSON object { "KEY": {...} }
    local function parseKeyList(body)
        local entries = {}
        local data = tryJson(body)
        if type(data) == "table" then
            local list = data.keys or data.Keys or data
            if #list > 0 then
                for _, item in ipairs(list) do
                    entries[#entries + 1] = item
                end
            else
                for k, v in pairs(list) do
                    if type(v) == "table" then
                        local e = shallowCopy(v)
                        e.Key = e.Key or e.key or k
                        entries[#entries + 1] = e
                    elseif v == true then
                        entries[#entries + 1] = tostring(k)
                    end
                end
            end
            return entries
        end
        for line in tostring(body or ""):gmatch("[^\r\n]+") do
            line = trim(line)
            if line ~= "" and line:sub(1, 1) ~= "#" and line:sub(1, 2) ~= "--" then
                if line:find("|", 1, true) then
                    local parts = {}
                    for p in line:gmatch("[^|]+") do
                        parts[#parts + 1] = trim(p)
                    end
                    entries[#entries + 1] = { Key = parts[1], Expires = tonumber(parts[2]), Hwid = parts[3] }
                else
                    entries[#entries + 1] = line
                end
            end
        end
        return entries
    end

    local function interpretServer(res, scfg, T)
        if not res.Reached then
            return false, T.Unreachable, nil
        end
        local body = tostring(res.Body or "")
        local data = tryJson(body)
        local value, message
        if type(data) == "table" then
            if scfg.SuccessField then
                value = data[scfg.SuccessField]
            else
                for _, f in ipairs({ "valid", "success", "ok", "authorized", "status", "result" }) do
                    if data[f] ~= nil then
                        value = data[f]
                        break
                    end
                end
            end
            message = data[scfg.MessageField or "message"] or data.error
        else
            value = trim(body):lower()
        end
        if value == nil and scfg.OkOnStatus then
            value = res.Success
        end
        local okValues = scfg.SuccessValues or { true, "true", "valid", "ok", "success", "authorized", 1, "1" }
        local ok = false
        for _, v in ipairs(okValues) do
            if value == v or (type(value) == "string" and type(v) == "string" and value:lower() == v:lower()) then
                ok = true
                break
            end
        end
        if ok then
            local expires = type(data) == "table" and tonumber(data.expires or data.Expires or data.expiry) or nil
            return true, type(message) == "string" and message or nil, { Expires = expires, Response = data }
        end
        if type(message) ~= "string" then
            message = (not res.Success and res.Status >= 500) and T.Unreachable or nil
        end
        return false, message, { Response = data }
    end

    -- returns ok, message, data, sourceName
    local function validateKey(cfg, key, device, T)
        if type(cfg.Validate) == "function" then
            local ok, a, b, c = pcall(cfg.Validate, key, device)
            if not ok then
                return false, "Validator error", nil, "custom"
            end
            if type(a) == "table" then
                local good = a.Valid ~= false and a.Success ~= false and a.Ok ~= false
                return good, a.Message, a, "custom"
            end
            return a and true or false, b, c, "custom"
        end

        local sources = {}
        local staticEntries = {}
        if type(cfg.Keys) == "table" then
            for _, k in ipairs(cfg.Keys) do
                staticEntries[#staticEntries + 1] = k
            end
            if #staticEntries == 0 then
                for k, v in pairs(cfg.Keys) do
                    if type(v) == "table" then
                        local e = shallowCopy(v)
                        e.Key = e.Key or k
                        staticEntries[#staticEntries + 1] = e
                    elseif v == true then
                        staticEntries[#staticEntries + 1] = tostring(k)
                    end
                end
            end
        end
        if type(cfg.Key) == "string" then
            staticEntries[#staticEntries + 1] = cfg.Key
        elseif type(cfg.Key) == "table" then
            for _, k in ipairs(cfg.Key) do
                staticEntries[#staticEntries + 1] = k
            end
        end
        if #staticEntries > 0 then
            sources[#sources + 1] = {
                Name = "keys",
                Run = function()
                    return checkEntries(cfg, staticEntries, key, device, T)
                end,
            }
        end
        if cfg.KeyUrl then
            sources[#sources + 1] = {
                Name = "url",
                Run = function()
                    local u = type(cfg.KeyUrl) == "table" and cfg.KeyUrl or { Url = cfg.KeyUrl }
                    local res = httpRequest({
                        Url = fillVars(u.Url, allVars(key, device)),
                        Method = "GET",
                        Headers = u.Headers,
                    })
                    if not res.Reached or not res.Success then
                        return false, T.Unreachable, nil
                    end
                    return checkEntries(cfg, parseKeyList(res.Body), key, device, T)
                end,
            }
        end
        if type(cfg.Server) == "table" and cfg.Server.Url then
            sources[#sources + 1] = {
                Name = "server",
                Run = function()
                    local scfg = cfg.Server
                    local payload = buildPayload(scfg.Send, key, device, nil)
                    local res = sendRequest(scfg, payload, allVars(key, device))
                    return interpretServer(res, scfg, T)
                end,
            }
        end

        if #sources == 0 then
            return false, T.NoSource, nil, "none"
        end

        local requireAll = tostring(cfg.Require or "any"):lower() == "all"
        local lastMsg, lastData
        local combined = {}
        for _, src in ipairs(sources) do
            local ok, a, b, c = pcall(src.Run)
            local good, msg, data
            if ok then
                good, msg, data = a, b, c
            else
                good, msg, data = false, T.Unreachable, nil
            end
            if good then
                if not requireAll then
                    return true, nil, data, src.Name
                end
                for k, v in pairs(data or {}) do
                    combined[k] = v
                end
            else
                if msg then
                    lastMsg = msg
                end
                lastData = data
                if requireAll then
                    return false, msg, data, src.Name
                end
            end
        end
        if requireAll then
            return true, nil, combined, "all"
        end
        return false, lastMsg, lastData, "none"
    end

    -- ------------------------------------------------------------------
    -- look: base theme / accent
    -- ------------------------------------------------------------------
    local function applyLook(cfg)
        local base = cfg.Base or cfg.Theme
        if type(base) == "string" then
            if base == "Dark" then
                base = "Midnight"
            end
            for _, item in ipairs(ThemeM.Bases) do
                if item[1] == base then
                    local map = {}
                    for k, hex in pairs(item[2]) do
                        if type(hex) == "string" then
                            pcall(function()
                                map[k] = Color3.fromHex(hex)
                            end)
                        elseif typeof(hex) == "Color3" then
                            map[k] = hex
                        end
                    end
                    ThemeM.setMany(map)
                    break
                end
            end
        end
        local accent = cfg.Accent
        if type(accent) == "string" then
            local preset = ThemeM.Presets[accent]
            if preset then
                accent = preset
            else
                local ok, c = pcall(Color3.fromHex, accent)
                accent = ok and c or nil
            end
        end
        if typeof(accent) == "Color3" then
            ThemeM.set("Accent", accent)
        end
    end

    -- ------------------------------------------------------------------
    -- main entry
    -- ------------------------------------------------------------------
    function Library.CreateKeySystem(self, options)
        if self ~= Library and type(self) == "table" and options == nil then
            options = self
        end
        local cfg = shallowCopy(options or {})
        local T = shallowCopy(DEFAULT_TEXT)
        for k, v in pairs(cfg.Text or cfg.Texts or {}) do
            T[k] = v
        end
        if cfg.Title then
            T.Title = tostring(cfg.Title)
        end
        if cfg.Subtitle or cfg.SubTitle then
            T.Subtitle = tostring(cfg.Subtitle or cfg.SubTitle)
        end

        local device = Library.GetDeviceInfo(cfg)
        local saveEnabled = cfg.SaveKey ~= false
        local safeId = tostring(cfg.Id or T.Title):gsub("[^%w_%-]", "_")
        local saveFile = cfg.SaveFile or ("GGH/key_" .. safeId .. ".txt")

        local function cleanKey(raw)
            local k = trim(raw):gsub("^[\"']", ""):gsub("[\"']$", "")
            if cfg.UpperCase then
                k = k:upper()
            end
            return k
        end

        local function finishInfo(key, msg, data, source)
            local info = { Key = key, Message = msg, Source = source, Hwid = device.Hwid, Data = data }
            if type(data) == "table" and data.Expires then
                info.Expires = data.Expires
            end
            return info
        end

        local function fireEvent(event, key, extra)
            if type(cfg.OnEvent) == "function" then
                task.spawn(cfg.OnEvent, event, key, extra)
            end
            local r = cfg.Report
            if type(r) ~= "table" or not r.Url then
                return
            end
            local events = r.Events
            if events == nil then
                events = { Success = true, Fail = true }
            end
            if not (events[event] == true or inList(events, event) and #events > 0) then
                return
            end
            task.spawn(function()
                local payload = buildPayload(r.Send, key, device, { event = event })
                if r.Discord then
                    local fields = {}
                    for k, v in pairs(payload) do
                        fields[#fields + 1] = { name = tostring(k), value = "`" .. tostring(v) .. "`", inline = true }
                    end
                    local color = event == "Success" and 4054167 or (event == "Fail" and 15749230 or 9145246)
                    local body = {
                        username = r.Username or T.Title,
                        embeds = {
                            {
                                title = T.Title .. " | " .. event,
                                color = color,
                                fields = fields,
                                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
                            },
                        },
                    }
                    httpRequest({
                        Url = r.Url,
                        Method = "POST",
                        Headers = { ["Content-Type"] = "application/json" },
                        Body = HttpService:JSONEncode(body),
                    })
                else
                    pcall(sendRequest, r, payload, allVars(key, device))
                end
            end)
        end

        local function kick(msg)
            pcall(function()
                LocalPlayer:Kick(tostring(msg or cfg.KickMessage or T.Locked))
            end)
        end

        -- saved key ------------------------------------------------------
        local savedKey
        if saveEnabled then
            local raw = readFileSafe(saveFile)
            if raw and trim(raw) ~= "" then
                savedKey = cleanKey(raw)
            end
        end

        -- headless mode (no UI): needs DefaultKey or a saved key
        if cfg.ShowUI == false then
            local key = cfg.DefaultKey and cleanKey(cfg.DefaultKey) or savedKey
            if not key or key == "" then
                if type(cfg.OnFail) == "function" then
                    task.spawn(cfg.OnFail, T.Empty, "")
                end
                if cfg.Kick then
                    kick()
                end
                return false, finishInfo("", T.Empty, nil, "none")
            end
            fireEvent("Attempt", key)
            local ok, msg, data, source = validateKey(cfg, key, device, T)
            if ok then
                if saveEnabled then
                    writeFileSafe(saveFile, key)
                end
                fireEvent("Success", key)
                local info = finishInfo(key, msg or T.Valid, data, source)
                if type(cfg.OnSuccess) == "function" then
                    task.spawn(cfg.OnSuccess, info)
                end
                return true, info
            end
            fireEvent("Fail", key)
            if type(cfg.OnFail) == "function" then
                task.spawn(cfg.OnFail, msg or T.Invalid, key)
            end
            if cfg.Kick then
                kick(cfg.KickMessage or msg)
            end
            return false, finishInfo(key, msg or T.Invalid, data, source)
        end

        -- auto login with the saved key (skips the window completely)
        if savedKey and cfg.AutoLogin ~= false then
            local ok, msg, data, source = validateKey(cfg, savedKey, device, T)
            if ok then
                fireEvent("Success", savedKey, "saved")
                local info = finishInfo(savedKey, msg or T.Valid, data, "saved")
                if type(cfg.OnSuccess) == "function" then
                    task.spawn(cfg.OnSuccess, info)
                end
                return true, info
            end
            -- saved key no longer valid: forget it and show the window
            if cfg.KeepInvalidSaved ~= true then
                deleteFileSafe(saveFile)
            end
        end

        -- ==================================================================
        --  UI
        -- ==================================================================
        applyLook(cfg)

        local width = tonumber(cfg.Width) or 420
        local conns = {}
        local finished = false
        local busy = false
        local attempts = 0
        local cooldownUntil = 0
        local locked = false
        local remember = saveEnabled and (cfg.Remember ~= false)
        local done = Instance.new("BindableEvent")
        local result = { false, finishInfo("", "", nil, "none") }

        local gui = new("ScreenGui", {
            Name = cfg.GuiName or "GGH_Key",
            IgnoreGuiInset = true,
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 1000000,
        })
        U.protect(gui)
        gui.Parent = cfg.Parent or U.hostGui()

        local dim = new("Frame", {
            Name = "Dim",
            Size = UDim2.fromScale(1, 1),
            BackgroundColor3 = Color3.new(0, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Active = cfg.Modal ~= false,
            ZIndex = 1,
            Parent = gui,
        })

        local root = new("Frame", {
            Name = "Root",
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.fromScale(0.5, 0.5),
            Size = UDim2.fromOffset(width, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            ZIndex = 2,
            Parent = gui,
        })
        local rootScale = new("UIScale", { Parent = root })
        pcall(function()
            local cam = workspace.CurrentCamera
            if cam then
                local vp = cam.ViewportSize
                rootScale.Scale = math.clamp(math.min((vp.X - 24) / width, (vp.Y - 24) / 460), 0.55, 1)
            end
        end)

        local card = new("CanvasGroup", {
            Name = "Card",
            Size = UDim2.fromOffset(width, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BorderSizePixel = 0,
            GroupTransparency = 1,
            ZIndex = 2,
            Parent = root,
        })
        bind(card, "BackgroundColor3", "Background")
        U.corner(card, 14)
        bind(U.stroke(card, Color3.new(1, 1, 1), 1, 0.88), "Color", "Glass")
        U.pad(card, 18)
        U.list(card, 12)
        local cardScale = new("UIScale", { Scale = 0.94, Parent = card })

        local order = 0
        local function nextOrder()
            order += 1
            return order
        end

        -- header ---------------------------------------------------------
        local header = new("Frame", {
            Name = "Header",
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundTransparency = 1,
            LayoutOrder = nextOrder(),
            ZIndex = 3,
            Parent = card,
        })
        local badge = new("Frame", {
            Name = "Badge",
            Size = UDim2.fromOffset(38, 38),
            BorderSizePixel = 0,
            BackgroundTransparency = 0.8,
            ZIndex = 4,
            Parent = header,
        })
        bind(badge, "BackgroundColor3", "Accent")
        U.corner(badge, 11)
        pcall(function()
            mkIcon({
                Parent = badge,
                Icon = cfg.Icon or "key-round",
                Size = 19,
                Pos = UDim2.fromScale(0.5, 0.5),
                Anchor = Vector2.new(0.5, 0.5),
                Color = "Accent",
                Z = 5,
            })
        end)
        mkLabel({
            Parent = header,
            Text = T.Title,
            Font = FontM.Semi(),
            Size = 17,
            Pos = UDim2.fromOffset(50, 2),
            Box = UDim2.new(1, -92, 0, 20),
            Truncate = true,
            Color = "Text",
            Z = 4,
        })
        mkLabel({
            Parent = header,
            Text = T.Subtitle,
            Font = FontM.Medium(),
            Size = 12,
            Pos = UDim2.fromOffset(50, 22),
            Box = UDim2.new(1, -92, 0, 16),
            Truncate = true,
            Color = "Muted",
            Z = 4,
        })

        local closeBtn
        if cfg.Closable ~= false then
            closeBtn = new("TextButton", {
                Name = "Close",
                Text = "",
                AutoButtonColor = false,
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.new(1, 0, 0, 6),
                Size = UDim2.fromOffset(28, 28),
                BorderSizePixel = 0,
                ZIndex = 5,
                Parent = header,
            })
            bind(closeBtn, "BackgroundColor3", "Surface2")
            U.corner(closeBtn, 9)
            mkLabel({
                Parent = closeBtn,
                Text = "×",
                Font = FontM.Medium(),
                Size = 20,
                Box = UDim2.fromScale(1, 1),
                AlignX = Enum.TextXAlignment.Center,
                Color = "Muted",
                Z = 6,
            })
        end

        -- optional description / note -------------------------------------
        if cfg.Note and tostring(cfg.Note) ~= "" then
            mkLabel({
                Parent = card,
                Text = tostring(cfg.Note),
                Font = FontM.Medium(),
                Size = 13,
                Box = UDim2.new(1, 0, 0, 0),
                Auto = Enum.AutomaticSize.Y,
                Wrap = true,
                AlignY = Enum.TextYAlignment.Top,
                Color = "Muted",
                Z = 3,
            }).LayoutOrder = nextOrder()
        end

        -- key input --------------------------------------------------------
        local inputFrame = new("Frame", {
            Name = "KeyInput",
            Size = UDim2.new(1, 0, 0, 42),
            BorderSizePixel = 0,
            LayoutOrder = nextOrder(),
            ZIndex = 3,
            Parent = card,
        })
        bind(inputFrame, "BackgroundColor3", "Elevated")
        U.corner(inputFrame, 10)
        local inputStroke = U.stroke(inputFrame, Color3.new(1, 1, 1), 1, 0.85)
        bind(inputStroke, "Color", "Glass")
        local box = new("TextBox", {
            Name = "Box",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -24, 1, 0),
            Position = UDim2.fromOffset(12, 0),
            ClearTextOnFocus = false,
            Text = (cfg.DefaultKey and cleanKey(cfg.DefaultKey)) or savedKey or "",
            PlaceholderText = T.Placeholder,
            FontFace = FontM.Medium(),
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 4,
            Parent = inputFrame,
        })
        bind(box, "TextColor3", "Text")
        bind(box, "PlaceholderColor3", "Faint")

        -- hwid row ---------------------------------------------------------
        local function showCopied(btnLabel, original)
            btnLabel.Text = T.Copied
            task.delay(1.2, function()
                if btnLabel.Parent then
                    btnLabel.Text = original
                end
            end)
        end

        local statusLabel -- forward
        local statusToken = 0
        local function setStatus(text, kind)
            if not statusLabel or not statusLabel.Parent then
                return
            end
            statusToken += 1
            statusLabel.Text = tostring(text or "")
            local tokenName = ({ ok = "Success", error = "Danger", warn = "Warning" })[kind or ""] or "Muted"
            bind(statusLabel, "TextColor3", tokenName)
        end

        if cfg.ShowHwid ~= false and device.Hwid ~= "" then
            local hwRow = new("Frame", {
                Name = "HwidRow",
                Size = UDim2.new(1, 0, 0, 40),
                BorderSizePixel = 0,
                LayoutOrder = nextOrder(),
                ZIndex = 3,
                Parent = card,
            })
            bind(hwRow, "BackgroundColor3", "Surface")
            U.corner(hwRow, 10)
            bind(U.stroke(hwRow, Color3.new(1, 1, 1), 1, 0.9), "Color", "Glass")
            mkLabel({
                Parent = hwRow,
                Text = T.Hwid,
                Font = FontM.Semi(),
                Size = 11,
                Pos = UDim2.fromOffset(12, 0),
                Box = UDim2.fromOffset(40, 40),
                Color = "Faint",
                Z = 4,
            })
            local canCopy = cfg.CopyHwid ~= false
            mkLabel({
                Parent = hwRow,
                Text = device.Hwid,
                Font = FontM.Medium(),
                Size = 12,
                Pos = UDim2.fromOffset(52, 0),
                Box = UDim2.new(1, canCopy and -126 or -64, 1, 0),
                Truncate = true,
                Color = "Muted",
                Z = 4,
            })
            if canCopy then
                local cp = new("TextButton", {
                    Name = "CopyHwid",
                    Text = "",
                    AutoButtonColor = false,
                    AnchorPoint = Vector2.new(1, 0.5),
                    Position = UDim2.new(1, -7, 0.5, 0),
                    Size = UDim2.fromOffset(60, 26),
                    BorderSizePixel = 0,
                    ZIndex = 5,
                    Parent = hwRow,
                })
                bind(cp, "BackgroundColor3", "Surface2")
                U.corner(cp, 8)
                local cpLabel = mkLabel({
                    Parent = cp,
                    Text = T.Copy,
                    Font = FontM.Semi(),
                    Size = 12,
                    Box = UDim2.fromScale(1, 1),
                    AlignX = Enum.TextXAlignment.Center,
                    Color = "Text",
                    Z = 6,
                })
                table.insert(conns, cp.MouseButton1Click:Connect(function()
                    if setClipboard(device.Hwid) then
                        showCopied(cpLabel, T.Copy)
                    else
                        setStatus(T.NoClipboard, "warn")
                    end
                end))
            end
        end

        -- remember toggle ----------------------------------------------------
        if saveEnabled and cfg.ShowRemember == true then
            local rowBtn = new("TextButton", {
                Name = "Remember",
                Text = "",
                AutoButtonColor = false,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 22),
                LayoutOrder = nextOrder(),
                ZIndex = 3,
                Parent = card,
            })
            local checkBox = new("Frame", {
                Size = UDim2.fromOffset(18, 18),
                Position = UDim2.fromOffset(0, 2),
                BorderSizePixel = 0,
                ZIndex = 4,
                Parent = rowBtn,
            })
            bind(checkBox, "BackgroundColor3", "Elevated")
            U.corner(checkBox, 5)
            bind(U.stroke(checkBox, Color3.new(1, 1, 1), 1, 0.85), "Color", "Glass")
            local tick = new("Frame", {
                AnchorPoint = Vector2.new(0.5, 0.5),
                Position = UDim2.fromScale(0.5, 0.5),
                Size = UDim2.fromOffset(10, 10),
                BorderSizePixel = 0,
                BackgroundTransparency = remember and 0 or 1,
                ZIndex = 5,
                Parent = checkBox,
            })
            bind(tick, "BackgroundColor3", "Accent")
            U.corner(tick, 3)
            mkLabel({
                Parent = rowBtn,
                Text = T.Remember,
                Font = FontM.Medium(),
                Size = 13,
                Pos = UDim2.fromOffset(28, 0),
                Box = UDim2.new(1, -28, 1, 0),
                Color = "Muted",
                Z = 4,
            })
            table.insert(conns, rowBtn.MouseButton1Click:Connect(function()
                remember = not remember
                MotionM.tween(tick, "Quick", { BackgroundTransparency = remember and 0 or 1 })
            end))
        end

        -- status line ----------------------------------------------------------
        statusLabel = mkLabel({
            Parent = card,
            Text = "",
            Font = FontM.Medium(),
            Size = 13,
            Box = UDim2.new(1, 0, 0, 16),
            Auto = Enum.AutomaticSize.Y,
            Wrap = true,
            AlignY = Enum.TextYAlignment.Top,
            Color = "Muted",
            Z = 3,
        })
        statusLabel.Name = "Status"
        statusLabel.LayoutOrder = nextOrder()

        -- buttons -----------------------------------------------------------
        local function makeButton(parent, text, primary, sizeX)
            local b = new("TextButton", {
                Name = primary and "Primary" or "Button",
                Text = "",
                AutoButtonColor = false,
                Size = sizeX or UDim2.new(1, 0, 0, 40),
                BorderSizePixel = 0,
                ZIndex = 5,
                Parent = parent,
            })
            bind(b, "BackgroundColor3", primary and "Accent" or "Surface2")
            U.corner(b, 10)
            bind(U.stroke(b, Color3.new(1, 1, 1), 1, primary and 0.78 or 0.88), "Color", "Glass")
            local lbl = mkLabel({
                Parent = b,
                Text = text,
                Font = FontM.Semi(),
                Size = 14,
                Box = UDim2.fromScale(1, 1),
                AlignX = Enum.TextXAlignment.Center,
                Color = primary and "OnAccent" or "Text",
                Z = 6,
            })
            local sc = new("UIScale", { Parent = b })
            table.insert(conns, b.MouseEnter:Connect(function()
                MotionM.tween(b, "Quick", { BackgroundTransparency = 0.14 })
            end))
            table.insert(conns, b.MouseLeave:Connect(function()
                MotionM.tween(b, "Quick", { BackgroundTransparency = 0 })
                MotionM.tween(sc, "Quick", { Scale = 1 })
            end))
            table.insert(conns, b.MouseButton1Down:Connect(function()
                MotionM.tween(sc, "Quick", { Scale = 0.97 })
            end))
            table.insert(conns, b.MouseButton1Up:Connect(function()
                MotionM.tween(sc, "Quick", { Scale = 1 })
            end))
            return b, lbl
        end

        local verifyBtn, verifyLabel = makeButton(card, T.Verify, true)
        verifyBtn.LayoutOrder = nextOrder()

        -- secondary buttons (Get Key, Discord, custom ...)
        local extra = {}
        local getKeyCfg = cfg.GetKey
        if getKeyCfg == true then
            getKeyCfg = {}
        end
        if type(getKeyCfg) == "table" and getKeyCfg.Enabled ~= false then
            extra[#extra + 1] = { Text = getKeyCfg.Text or T.GetKey, Kind = "getkey" }
        end
        if cfg.Discord then
            local d = type(cfg.Discord) == "table" and cfg.Discord or { Url = cfg.Discord }
            if d.Enabled ~= false and d.Url then
                extra[#extra + 1] = { Text = d.Text or T.Discord, Copy = d.Url }
            end
        end
        for _, b in ipairs(cfg.Buttons or {}) do
            extra[#extra + 1] = b
        end

        -- forward declarations used by button handlers
        local finish

        local ctx = {
            Device = device,
            Hwid = device.Hwid,
            SetStatus = setStatus,
            Fill = function(text)
                box.Text = tostring(text or "")
            end,
            GetKey = function()
                return cleanKey(box.Text)
            end,
            Copy = setClipboard,
            Request = httpRequest,
            Payload = function(send, key)
                return buildPayload(send, key or cleanKey(box.Text), device, nil)
            end,
            Close = function()
                finish(false, finishInfo("", "closed", nil, "closed"))
            end,
        }

        local function handleGetKey()
            local g = getKeyCfg
            if type(g.Callback) == "function" then
                local ok, text = pcall(g.Callback, ctx)
                if ok and type(text) == "string" and text ~= "" then
                    if setClipboard(text) then
                        setStatus(T.GetKeyCopied, "ok")
                    else
                        setStatus(text, "info")
                    end
                end
                return
            end
            local vars = allVars(cleanKey(box.Text), device)
            -- ask the website to create / return a key
            if type(g.Request) == "table" and g.Request.Url then
                setStatus(T.Requesting, "info")
                local payload = buildPayload(g.Request.Send, cleanKey(box.Text), device, nil)
                local res = sendRequest(g.Request, payload, vars)
                if not res.Reached then
                    setStatus(T.Unreachable, "error")
                    return
                end
                local data = tryJson(res.Body)
                local keyOut, linkOut, msgOut
                if type(data) == "table" then
                    keyOut = data.key or data.Key
                    linkOut = data.link or data.url or data.Link or data.Url
                    msgOut = data.message
                else
                    local raw = trim(res.Body)
                    if raw:match("^https?://") then
                        linkOut = raw
                    elseif raw ~= "" then
                        keyOut = raw
                    end
                end
                if not res.Success and not keyOut and not linkOut then
                    setStatus(type(msgOut) == "string" and msgOut or T.GetKeyFailed, "error")
                    return
                end
                local action = tostring(g.Request.Action or "Auto"):lower()
                local shown = false
                if keyOut and (action == "auto" or action == "fill" or action == "both") then
                    box.Text = tostring(keyOut)
                    setStatus(type(msgOut) == "string" and msgOut or T.Valid, "ok")
                    shown = true
                end
                if linkOut and (action == "auto" or action == "copy" or action == "both") then
                    if setClipboard(linkOut) then
                        setStatus(type(msgOut) == "string" and msgOut or T.GetKeyCopied, "ok")
                    else
                        setStatus(tostring(linkOut), "info")
                    end
                    shown = true
                end
                if keyOut and action == "copy" then
                    setClipboard(keyOut)
                    setStatus(T.GetKeyCopied, "ok")
                    shown = true
                end
                if not shown then
                    setStatus(type(msgOut) == "string" and msgOut or T.GetKeyFailed, "warn")
                end
                return
            end
            -- plain link (optionally with hwid etc. appended)
            if g.Url then
                local url = fillVars(g.Url, vars)
                local params = {}
                if g.AppendHwid then
                    params.hwid = device.Hwid
                end
                if g.Send ~= nil then
                    for k, v in pairs(buildPayload(g.Send, "", device, nil)) do
                        params[k] = v
                    end
                end
                url = withQuery(url, params)
                if setClipboard(url) then
                    setStatus(T.GetKeyCopied, "ok")
                else
                    setStatus(url, "info")
                end
                if type(g.OnClick) == "function" then
                    task.spawn(g.OnClick, ctx, url)
                end
            end
        end

        if #extra > 0 then
            local perRow = math.min(#extra, 3)
            local idx = 1
            while idx <= #extra do
                local count = math.min(perRow, #extra - idx + 1)
                local row = new("Frame", {
                    Name = "ButtonRow",
                    Size = UDim2.new(1, 0, 0, 38),
                    BackgroundTransparency = 1,
                    LayoutOrder = nextOrder(),
                    ZIndex = 3,
                    Parent = card,
                })
                U.list(row, 8, Enum.FillDirection.Horizontal)
                for i = 0, count - 1 do
                    local item = extra[idx + i]
                    local b = makeButton(
                        row,
                        tostring(item.Text or "Button"),
                        item.Primary == true,
                        UDim2.new(1 / count, -8 * (count - 1) / count, 1, 0)
                    )
                    b.LayoutOrder = i
                    table.insert(conns, b.MouseButton1Click:Connect(function()
                        if item.Kind == "getkey" then
                            task.spawn(handleGetKey)
                        elseif type(item.Callback) == "function" then
                            task.spawn(item.Callback, ctx)
                        elseif item.Copy then
                            if setClipboard(item.Copy) then
                                setStatus(item.CopiedText or T.GetKeyCopied, "ok")
                            else
                                setStatus(tostring(item.Copy), "info")
                            end
                        end
                    end))
                end
                idx += count
            end
        end

        -- attempts / footer
        local footer
        if (tonumber(cfg.MaxAttempts) or 0) > 0 or (cfg.Footer and tostring(cfg.Footer) ~= "") then
            footer = mkLabel({
                Parent = card,
                Text = (tonumber(cfg.MaxAttempts) or 0) > 0 and T.Attempts:format(cfg.MaxAttempts) or tostring(cfg.Footer),
                Font = FontM.Medium(),
                Size = 11,
                Box = UDim2.new(1, 0, 0, 14),
                AlignX = Enum.TextXAlignment.Center,
                Color = "Faint",
                Z = 3,
            })
            footer.LayoutOrder = nextOrder()
        end

        -- animations ------------------------------------------------------------
        local function shake()
            for _, dx in ipairs({ 10, -8, 6, -4, 0 }) do
                MotionM.tween(card, TweenInfo.new(0.05, Enum.EasingStyle.Quad), { Position = UDim2.fromOffset(dx, 0) })
                task.wait(0.05)
            end
        end

        finish = function(success, info)
            if finished then
                return
            end
            finished = true
            result = { success, info }
            for _, c in ipairs(conns) do
                pcall(function()
                    c:Disconnect()
                end)
            end
            MotionM.tween(card, "Exit", { GroupTransparency = 1 })
            MotionM.tween(cardScale, "Exit", { Scale = 0.95 })
            MotionM.tween(dim, "Exit", { BackgroundTransparency = 1 })
            task.delay(0.25, function()
                pcall(function()
                    gui:Destroy()
                end)
            end)
            if success then
                if type(cfg.OnSuccess) == "function" then
                    task.spawn(cfg.OnSuccess, info)
                end
            else
                if type(cfg.OnClose) == "function" then
                    task.spawn(cfg.OnClose, info)
                end
                if cfg.KickOnClose then
                    kick(cfg.KickMessage)
                end
            end
            done:Fire()
        end

        -- verify -------------------------------------------------------------------
        local function setBusy(state)
            busy = state
            verifyLabel.Text = state and T.Checking or T.Verify
            MotionM.tween(verifyBtn, "Quick", { BackgroundTransparency = state and 0.45 or 0 })
        end

        local function submit()
            if busy or finished or locked then
                return
            end
            local waitLeft = cooldownUntil - os.clock()
            if waitLeft > 0 then
                setStatus(T.Wait:format(math.ceil(waitLeft)), "warn")
                return
            end
            local key = cleanKey(box.Text)
            if key == "" then
                setStatus(T.Empty, "warn")
                task.spawn(shake)
                return
            end
            setBusy(true)
            setStatus(T.Checking, "info")
            fireEvent("Attempt", key)
            local ok, msg, data, source = validateKey(cfg, key, device, T)
            if finished then
                return
            end
            setBusy(false)
            if ok then
                if saveEnabled then
                    if remember then
                        writeFileSafe(saveFile, key)
                    else
                        deleteFileSafe(saveFile)
                    end
                end
                local text = msg or T.Valid
                if type(data) == "table" and data.Expires then
                    text = text .. " (" .. fmtDuration(data.Expires - os.time()) .. ")"
                end
                setStatus(text, "ok")
                fireEvent("Success", key, source)
                task.wait(tonumber(cfg.CloseDelay) or 0.6)
                finish(true, finishInfo(key, msg or T.Valid, data, "input"))
                return
            end
            attempts += 1
            fireEvent("Fail", key, source)
            setStatus(msg or T.Invalid, "error")
            task.spawn(shake)
            if type(cfg.OnFail) == "function" then
                task.spawn(cfg.OnFail, msg or T.Invalid, key)
            end
            local maxA = tonumber(cfg.MaxAttempts) or 0
            if maxA > 0 then
                local left = maxA - attempts
                if footer then
                    footer.Text = T.Attempts:format(math.max(left, 0))
                end
                if left <= 0 then
                    locked = true
                    setStatus(T.Locked, "error")
                    if type(cfg.OnLockout) == "function" then
                        task.spawn(cfg.OnLockout, attempts)
                    end
                    if cfg.Kick or cfg.KickOnLockout then
                        task.wait(0.6)
                        kick(cfg.KickMessage or T.Locked)
                    end
                    local lockSeconds = tonumber(cfg.LockSeconds) or 0
                    if lockSeconds > 0 then
                        task.delay(lockSeconds, function()
                            locked = false
                            attempts = 0
                            if footer and footer.Parent then
                                footer.Text = T.Attempts:format(maxA)
                            end
                            setStatus("", "info")
                        end)
                    elseif cfg.CloseOnLockout then
                        task.wait(0.8)
                        finish(false, finishInfo(key, T.Locked, nil, "locked"))
                    end
                    return
                end
            end
            local cd = tonumber(cfg.Cooldown) or 0
            if cd > 0 then
                cooldownUntil = os.clock() + cd
            end
        end

        table.insert(conns, verifyBtn.MouseButton1Click:Connect(function()
            task.spawn(submit)
        end))
        table.insert(conns, box.FocusLost:Connect(function(enterPressed)
            if enterPressed then
                task.spawn(submit)
            end
            bind(inputStroke, "Color", "Glass")
            MotionM.tween(inputStroke, "Quick", { Transparency = 0.85 })
        end))
        table.insert(conns, box.Focused:Connect(function()
            bind(inputStroke, "Color", "Accent")
            MotionM.tween(inputStroke, "Quick", { Transparency = 0.3 })
        end))
        if closeBtn then
            table.insert(conns, closeBtn.MouseButton1Click:Connect(function()
                finish(false, finishInfo("", "closed", nil, "closed"))
            end))
        end

        -- dragging -------------------------------------------------------------------
        if cfg.Draggable ~= false then
            local dragging, dragStart, startPos
            table.insert(conns, header.InputBegan:Connect(function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch
                then
                    dragging = true
                    dragStart = input.Position
                    startPos = root.Position
                end
            end))
            table.insert(conns, UserInputService.InputChanged:Connect(function(input)
                if
                    dragging
                    and (
                        input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch
                    )
                then
                    local delta = input.Position - dragStart
                    root.Position = UDim2.new(
                        startPos.X.Scale,
                        startPos.X.Offset + delta.X,
                        startPos.Y.Scale,
                        startPos.Y.Offset + delta.Y
                    )
                end
            end))
            table.insert(conns, UserInputService.InputEnded:Connect(function(input)
                if
                    input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch
                then
                    dragging = false
                end
            end))
        end

        -- open animation
        if cfg.Dim ~= false and cfg.Modal ~= false then
            MotionM.tween(dim, "Base", { BackgroundTransparency = 0.45 })
        end
        MotionM.tween(card, "Base", { GroupTransparency = 0 })
        MotionM.tween(cardScale, "Pop", { Scale = 1 })
        fireEvent("Open", "")

        if cfg.Wait == false then
            return nil, nil
        end
        done.Event:Wait()
        return result[1], result[2]
    end

    Library.KeySystem = Library.CreateKeySystem

    function Library:ClearSavedKey(options)
        local cfg = options or {}
        local safeId = tostring(cfg.Id or cfg.Title or DEFAULT_TEXT.Title):gsub("[^%w_%-]", "_")
        deleteFileSafe(cfg.SaveFile or ("GGH/key_" .. safeId .. ".txt"))
    end
end


return Library
