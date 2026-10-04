local GGH = loadstring(game:HttpGet("https://raw.githubusercontent.com/abrahim44ali55-dev/Library-GGH/refs/heads/main/Main"))()

local Window = GGH:CreateWindow({
    Title = "GGH Full Elements Test",
    SubTitle = "all Elements + all ",
    Theme = "Dark",
    Icon = "layout-panel-top",
    Width = 650,
    Height = 520,
    SaveDefault = true,
    ConfigName = "GGH_Full_Test",
})

-- 1: Section
do local Tab = Window:CreateTab("1- Section", "layout-panel-top")
Tab:Section({Title = "SECTIONS 30x"})
for i = 1, 30 do Tab:Section({Title = "Section " .. i .. " -  " .. i}) end end

-- 2: Paragraph
do local Tab = Window:CreateTab("2- Paragraph", "pilcrow")
Tab:Section({Title = "PARAGRAPHS 30x"})
for i = 1, 30 do Tab:Paragraph({Title = "Paragraph " .. i, Content = "   " .. i .. "    "}) end end

-- 3: Label (  )
do local Tab = Window:CreateTab("3- Label", "type")
Tab:Section({Title = "LABELS 30x"})
local aligns = {"Left", "Center", "Right"}
for i = 1, 30 do
    Tab:Label({
        Title = "Label " .. i .. " -  " .. i,
        Alignment = aligns[(i % 3) + 1],
        TextSize = 13,
        Color = Color3.fromHSV(i / 30, 0.5, 1),
    })
end end

-- 4: Separator
do local Tab = Window:CreateTab("4- Separator", "minus")
Tab:Section({Title = "SEPARATORS 30x"})
for i = 1, 30 do
    if i % 2 == 0 then Tab:Separator({Thickness = 2, Transparency = 0.4})
    else Tab:Section({Title = "Separator " .. i}) end
end end

-- 5: Button
do local Tab = Window:CreateTab("5- Button", "mouse-pointer-click")
Tab:Section({Title = "BUTTONS 30x"})
for i = 1, 30 do Tab:Button({Title = "Button " .. i, Callback = function() print("Btn " .. i) end}) end end

-- 6: Toggle
do local Tab = Window:CreateTab("6- Toggle", "toggle-right")
Tab:Section({Title = "TOGGLES 30x"})
for i = 1, 30 do Tab:Toggle({Title = "Toggle " .. i, Default = i % 2 == 0, Callback = function(v) print("Toggle", i, v) end}) end end

-- 7: Toggle + API
do local Tab = Window:CreateTab("7- Toggle API", "save")
Tab:Section({Title = "TOGGLE API"})
local master = Tab:Toggle({Title = "Master Toggle", Default = false})
Tab:Button({Title = "Turn Master ON", Callback = function() master:SetValue(true) end})
Tab:Button({Title = "Print Master value", Callback = function() print("Master =", master:GetValue()) end})
for i = 1, 27 do Tab:Toggle({Title = "Save Toggle " .. i, Default = false}) end end

-- 8: Slider - Int
do local Tab = Window:CreateTab("8- Slider Int", "sliders-vertical")
Tab:Section({Title = "SLIDER INT 30x"})
for i = 1, 30 do Tab:Slider({Title = "Int Slider " .. i, Min = 0, Max = 100, Default = i * 3, Callback = function(v) end}) end end

-- 9: Slider - Float
do local Tab = Window:CreateTab("9- Slider Float", "sliders-horizontal")
Tab:Section({Title = "SLIDER FLOAT 30x"})
for i = 1, 30 do Tab:Slider({Title = "Float Slider " .. i, Min = 0, Max = 10, Default = i / 3, Float = true, Decimals = 2, Callback = function(v) end}) end end

-- 10: Slider - Increment
do local Tab = Window:CreateTab("10- Slider Inc", "ruler")
Tab:Section({Title = "SLIDER INCREMENT 30x"})
for i = 1, 30 do Tab:Slider({Title = "Inc Slider " .. i, Min = 0, Max = 100, Default = 50, Increment = 5, Callback = function(v) end}) end end

-- 11: SliderInput - Int
do local Tab = Window:CreateTab("11- SliderInput Int", "sliders-horizontal")
Tab:Section({Title = "SLIDERINPUT INT 30x"})
for i = 1, 30 do Tab:SliderInput({Title = "S-Input Int " .. i, Min = 0, Max = 100, Default = 50 + i > 100 and 100 or 50 + i, Callback = function(v) end}) end end

-- 12: SliderInput - Float
do local Tab = Window:CreateTab("12- SliderInput Float", "ruler")
Tab:Section({Title = "SLIDERINPUT FLOAT 30x"})
for i = 1, 30 do Tab:SliderInput({Title = "S-Input Float " .. i, Min = 0, Max = 10, Default = 5.5, Float = true, Decimals = 2, Callback = function(v) end}) end end

-- 13: Input
do local Tab = Window:CreateTab("13- Input", "text-cursor-input")
Tab:Section({Title = "INPUTS 30x"})
for i = 1, 30 do Tab:Input({Title = "Input " .. i, Placeholder = " " .. i, Default = "", Callback = function(t) end}) end end

-- 14: Dropdown - Single
do local Tab = Window:CreateTab("14- Drop Single", "chevron-down")
Tab:Section({Title = "DROPDOWN SINGLE 30x"})
for i = 1, 30 do Tab:Dropdown({Title = "Single Drop " .. i, Options = {"GGH", "Option 1", "Option 2", "Option 3", "Test " .. i}, Default = "GGH", Callback = function(v) end}) end end

-- 15: Dropdown - Multi
do local Tab = Window:CreateTab("15- Drop Multi", "chevrons-up-down")
Tab:Section({Title = "DROPDOWN MULTI 30x"})
for i = 1, 30 do Tab:Dropdown({Title = "Multi Drop " .. i, Options = {"A", "B", "C", "D", "E", "F"}, Default = {"A", "C"}, Multi = true, Callback = function(v) end}) end end

-- 16: Dropdown - 100  ( ) + API
do local Tab = Window:CreateTab("16- Drop Big", "list")
Tab:Section({Title = "DROPDOWN 100 OPTIONS"})
local bigOpts = {}
for k = 1, 100 do table.insert(bigOpts, "Option " .. k) end
local big = Tab:Dropdown({Title = "Big Drop (API)", Options = bigOpts, Default = "Option 1"})
Tab:Button({Title = "AddOption: NEW", Callback = function() big:AddOption("NEW") end})
Tab:Button({Title = "RemoveOption: NEW", Callback = function() big:RemoveOption("NEW") end})
Tab:Button({Title = "Print selected", Callback = function() print(big:Get()) end})
for i = 1, 9 do Tab:Dropdown({Title = "Big Drop " .. i, Options = bigOpts, Default = "Option 1"}) end end

-- 17: Colorpicker
do local Tab = Window:CreateTab("17- Colorpicker", "palette")
Tab:Section({Title = "COLORPICKERS 30x"})
for i = 1, 30 do Tab:Colorpicker({Title = "Color " .. i, Default = Color3.fromHSV(i / 30, 1, 1), Callback = function(c) end}) end end

-- 18: Keybind
do local Tab = Window:CreateTab("18- Keybind", "keyboard")
Tab:Section({Title = "KEYBINDS 30x"})
for i = 1, 30 do Tab:Keybind({Title = "Keybind " .. i, Default = Enum.KeyCode.F, Callback = function(k) end}) end end

-- 19: Keybind Mix
do local Tab = Window:CreateTab("19- Keybinds Mix", "command")
Tab:Section({Title = "KEYBINDS MIX"})
local keys = {Enum.KeyCode.Q, Enum.KeyCode.E, Enum.KeyCode.R, Enum.KeyCode.F, Enum.KeyCode.G}
for i = 1, 30 do Tab:Keybind({Title = "Key Mix " .. i, Default = keys[(i % 5) + 1]}) end end

-- 20: Code
do local Tab = Window:CreateTab("20- Code", "code")
Tab:Section({Title = "CODE BLOCKS 30x"})
for i = 1, 30 do Tab:Code({Code = "print('Test " .. i .. "')\n-- GGH Library"}) end end

-- 21: Image
do local Tab = Window:CreateTab("21- Image ID", "image")
Tab:Section({Title = "IMAGES 30x"})
for i = 1, 30 do Tab:Image({Title = "Image " .. i, Image = "rbxassetid://4483362458", Size = Vector2.new(80, 80)}) end end

-- 22: Image + Input
do local Tab = Window:CreateTab("22- Image Input", "image-plus")
Tab:Section({Title = "IMAGE WITH INPUT 15x"})
for i = 1, 15 do Tab:Image({Title = "Img Input " .. i, Image = "rbxassetid://4483362458", Placeholder = " URL or ID", AllowInput = true}) end end

-- 23: LinkButton - Copy
do local Tab = Window:CreateTab("23- Link Copy", "link")
Tab:Section({Title = "LINK COPY 30x"})
for i = 1, 30 do Tab:LinkButton({Title = "Copy Link " .. i, Link = "https://discord.gg/test" .. i, ButtonText = "Copy " .. i}) end end

-- 24: LinkButton + Image
do local Tab = Window:CreateTab("24- Link Image", "external-link")
Tab:Section({Title = "LINK WITH IMAGE 30x"})
for i = 1, 30 do Tab:LinkButton({Title = "Discord " .. i, Link = "https://discord.gg/test", Image = "rbxassetid://4483362458", ButtonText = "Join"}) end end

-- 25: PlayerStats - LocalPlayer
do local Tab = Window:CreateTab("25- Stats Local", "user")
Tab:Section({Title = "PLAYER STATS LOCAL"})
for i = 1, 10 do Tab:PlayerStats({Title = "My Stats " .. i, Player = "LocalPlayer", Stats = {{Name = "Test " .. i, Value = i * 100}}}) end end

-- 26: PlayerStats -   + API
do local Tab = Window:CreateTab("26- Stats Custom", "users")
Tab:Section({Title = "PLAYER STATS CUSTOM"})
local st = Tab:PlayerStats({Title = "Stats API", Player = "LocalPlayer", Image = "rbxassetid://4483362458", Stats = {{Name = "Coins", Value = 500}, {Name = "Level", Value = 1}}})
Tab:Button({Title = "Level +1", Callback = function() st:SetStat("Level", (tonumber(st:GetStat("Level")) or 0) + 1) end})
for i = 1, 9 do Tab:PlayerStats({Title = "Custom Stats " .. i, Player = "LocalPlayer", Image = "rbxassetid://4483362458", Stats = {{Name = "Coins", Value = 500}, {Name = "Level", Value = i}}}) end end

-- 27: FloatButton (all )
do local Tab = Window:CreateTab("27- FloatButton", "circle-dot")
Tab:Section({Title = "FLOAT BUTTON - "})
Tab:FloatButton({Title = "Default", FloatText = "GGH", Callback = function() print("Default float") end})
Tab:FloatButton({Title = "Custom size 80x40 + user can't resize", FloatText = "WIDE", FloatSize = Vector2.new(80, 40), AllowSizeControl = false, Callback = function() print("Wide float") end})
Tab:FloatButton({Title = "With Keybind (G)", FloatText = "KEY", Keybind = Enum.KeyCode.G, Callback = function() print("Key float") end})
Tab:FloatButton({Title = "Locked + 40% transparency", FloatText = "LOCK", FloatLocked = true, FloatTransparency = 40, Callback = function() print("Locked float") end})
Tab:FloatButton({Title = "Image + ON by default", FloatImage = "rbxassetid://4483362458", FloatSize = Vector2.new(60, 60), FloatDefault = true, FloatPosition = "TopRight", Callback = function() print("Image float") end})
for i = 1, 25 do Tab:FloatButton({Title = "Float Btn " .. i, FloatText = "GGH " .. i, Callback = function() print("Float " .. i) end}) end end

-- 28: Mix
do local Tab = Window:CreateTab("28- Mix All", "layers")
Tab:Section({Title = "MIX ALL ELEMENTS"})
for i = 1, 5 do
    Tab:Button({Title = "Mix Btn " .. i})
    Tab:Toggle({Title = "Mix Tog " .. i})
    Tab:Slider({Title = "Mix Slider " .. i, Min = 0, Max = 100, Default = 50})
    Tab:Input({Title = "Mix Input " .. i})
end end

-- 29: Themes + Window API
do local Tab = Window:CreateTab("29- Themes", "paintbrush")
Tab:Section({Title = "THEMES TEST"})
Tab:Button({Title = "Set Dark", Callback = function() Window:SetTheme("Dark") end})
Tab:Button({Title = "Set Light", Callback = function() Window:SetTheme("Light") end})
Tab:Button({Title = "Set Crimson Red", Callback = function() Window:SetTheme("Crimson Red") end})
Tab:Button({Title = "Set Cyberpunk", Callback = function() Window:SetTheme("Cyberpunk") end})
Tab:Section({Title = "WINDOW API"})
Tab:Button({Title = "Update SubTitle", Callback = function() Window:Update({SubTitle = "Updated " .. os.date("%X")}) end})
Tab:Button({Title = "Transparency 30% / 10%", Callback = function() Window:SetTransparency(0.3, 0.1) end})
Tab:Button({Title = "Hide window for 2s", Callback = function() Window:Hide() task.wait(2) Window:Show() end})
Tab:Button({Title = "Save settings now", Callback = function() Window:SaveNow() end})
for i = 1, 20 do Tab:Toggle({Title = "Theme Toggle " .. i}) end end

-- 30: Ultimate Stress
do local Tab = Window:CreateTab("30- ULTIMATE 900", "zap")
Tab:Section({Title = "ULTIMATE STRESS TEST - 30x EACH"})
for i = 1, 30 do Tab:Button({Title = "Ult Btn " .. i}) end
for i = 1, 30 do Tab:Toggle({Title = "Ult Tog " .. i}) end
for i = 1, 30 do Tab:Slider({Title = "Ult Slider " .. i, Min = 0, Max = 100, Default = 50}) end
for i = 1, 30 do Tab:Dropdown({Title = "Ult Drop " .. i, Options = {"A", "B", "C"}}) end
Tab:Section({Title = "TOTAL: 120 Elements in 1 Tab"})
end

print("GGH COMPLETE: 30 Tabs - All Elements + All Variants Loaded!")