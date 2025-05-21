local suc, res = pcall(function()
    return typeof(loadstring("return 1")()) == "number" and typeof(game.HttpGet) == "function" and typeof(getgenv) == "function" and typeof(getgc) == "function" and type(getgc(true)) == "table" and rawget({x = 1}, "x") == 1 and typeof(game:GetService("VirtualInputManager").SendKeyEvent) == "function" and typeof(run_on_actor) == "function"
end)
if suc and res then
    print("supported executor")
else
    game.Players.LocalPlayer:Kick("This script only works on high UNC executors; please use AWP if this doesn't work.")
end
local Luna = loadstring(game:HttpGet("https://raw.githubusercontent.com/Nebula-Softworks/Luna-Interface-Suite/refs/heads/main/source.lua", true))()
pcall(function() repeat task.wait() until Luna.CreateWindow end)
local Window = Luna:CreateWindow({
	Name = "Lergic Hub - Funky Friday - By relevant500",
	Subtitle = nil,
	LogoID = "82795327169782",
	LoadingEnabled = true,
	LoadingTitle = "Funky friday autoplayer",
	LoadingSubtitle = "by relevant500",

	ConfigSettings = {
		RootFolder = nil,
		ConfigFolder = "Big Hub"
	},

	KeySystem = false
})
local Tab = Window:CreateTab({
	Name = "Main",
	Icon = "view_in_ar",
	ImageSource = "Material",
	ShowTitle = true
})
Tab:CreateSection("Main")
local function startautoplay()
    task.spawn(function()
        run_on_actor(game:GetService("Players").LocalPlayer.PlayerScripts.ClientActor, [=[
            getgenv().autoplayer = true

            local function presskey(key, state)
                game:GetService("VirtualInputManager"):SendKeyEvent(state, key, false, nil)
            end

            local gameTable = nil
            local maingame
            local mode
            local modetbl
            local hitboxOffset = -23 / 1000
            local lanes
            local keyMap = {}
            for _, enum in next, Enum.KeyCode:GetEnumItems() do
                keyMap[enum.Value] = enum
            end

            function getchances()
                local sick = tonumber(getgenv().chanceSick or 90)
                local good = tonumber(getgenv().chanceGood or 9)
                local ok = tonumber(getgenv().chanceOk or 0)
                local bad = tonumber(getgenv().chanceBad or 0)
                local miss = tonumber(getgenv().chanceMiss or 1)
                local total = sick + good + ok + bad + miss
                if total <= 0 then return 96 end
                local roll = math.random(1, total)
                local acc = 0
                acc += sick
                if roll <= acc then return 96 end
                acc += good
                if roll <= acc then return 92 end
                acc += ok
                if roll <= acc then return 87 end
                acc += bad
                if roll <= acc then return 75 end
                return nil
            end
            function extract(block)
                if type(block) ~= "string" then
                    return ""
                end
                local firstLine = block:match("^[^\n]+") or ""
                firstLine = firstLine:gsub("<[^>]->", ""):match("^%s*(.-)%s*$")
                return firstLine
            end
            repeat task.wait() until pcall(function() return game.Players.LocalPlayer.PlayerGui.Window end)
            task.wait(0.1)

            for _, v in next, getgc(true) do
                if type(v) == "table" and rawget(v, "Game") and v.AutoPlay == false and type(v.Game.TopbarText) == "string" then
                    if not (v.Game.Teams and v.Game.Teams.Left and v.Game.Teams.Right and v.Game) then
                        continue
                    end
                    if getgenv().gameuid and v.Game and v.Game.GUID and getgenv().gameuid == v.Game.GUID then
                        continue
                    end
                    if extract(game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.TopLabel.Label.Text) ~= extract(v.Game.TopbarText) then
                        continue
                    end
                    print("Extracted TopLabel == TopbarText:", extract(game:GetService("Players").LocalPlayer.PlayerGui.GameGui.Screen.TopLabel.Label.Text) == extract(v.Game.TopbarText))
                    gameTable = v.Game
                    for _, p in pairs(v.Game.Teams.Left.Players) do if p == game.Players.LocalPlayer then getgenv().gameside = "Left" end end
                    for _, p in pairs(v.Game.Teams.Right.Players) do if p == game.Players.LocalPlayer then getgenv().gameside = "Right" end end
                    mode = v.Keys .. "Key"
                    maingame = v
                    getgenv().gameuid = v.Game.GUID
                    break
                end
            end

            if not maingame then
                warn("maingame not found, aborting autoplayer loop")
                return
            end

            for _, v in next, getgc(true) do
                if type(v) == "table" and rawget(v, "Lanes") and v.Position == getgenv().gameside then
                    lanes = v
                    break
                end
            end

            for _, v in next, getgc(true) do
                if type(v) == "table" and rawget(v, mode) and v[mode].Arrows then
                    modetbl = v
                    break
                end
            end

            if not lanes then
                warn("lanes not found, aborting autoplayer loop")
                return
            end

            local directionToKeyCode = {}
            for direction, arrowData in pairs(modetbl[mode].Arrows) do
                local keycode = arrowData.Keybinds and arrowData.Keybinds.Keyboard and arrowData.Keybinds.Keyboard[1]
                if keycode then
                    local correctdir = tonumber(direction) + 1
                    directionToKeyCode[correctdir] = keyMap[keycode]
                end
            end

            print("Started autoplayer:", gameTable, lanes.Position, getgenv().gameside)

            while task.wait() do
                local songTime, timeLength
                pcall(function()
                    songTime = gameTable.TimePosition
                    timeLength = gameTable.TimeLength
                    game:GetService("Players").LocalPlayer.PlayerGui.TopBar.Frame.Right.Version.Text = "Autoplayer: " .. (getgenv().autoplayer and "enabled" or "disabled")

                end)

                if typeof(songTime) ~= "number" or typeof(timeLength) ~= "number" then continue end
                if timeLength <= songTime or songTime <= 0 then continue end

                for _, arrow in pairs(gameTable.Notes or {}) do
                    pcall(function()
                        if typeof(arrow) ~= "table" or arrow.Marked then return end
                        if getgenv().autoplayer == false then return end
                        if arrow.Field ~= getgenv().gameside then return end

                        local arrowTime = tonumber(arrow.Time or 0)
                        local noteTime = math.clamp((1 - math.abs(arrowTime - (songTime + hitboxOffset))) * 100, 0, 100)

                        if noteTime >= (getchances() or 96) then
                            local direction = arrow.Direction

                            local key = directionToKeyCode[direction]

                            if key then
                                task.spawn(function()
                                    pcall(function()
                                        arrow.Marked = true
                                        local method = getgenv().hitmethod
                                        local lane = lanes.Lanes and lanes.Lanes[direction]

                                        if method == "vinput" then
                                            presskey(key, true)
                                        elseif method == "firefunc" and lane then
                                            lane:Hit(true)
                                        elseif lane then
                                            lane:Hit(true)
                                        end

                                        local length = tonumber(arrow.Length or 0.03)
                                        if length <= 0 then length = 0.03 end
                                        if length then length = length / gameTable.AdjustedPlayback end
                                        task.wait(length)

                                        if method == "vinput" then
                                            presskey(key, false)
                                        elseif method == "firefunc" and lane then
                                            lane:Hit(false)
                                        elseif lane then
                                            lane:Hit(false)
                                        end
                                    end)
                                end)
                            end
                        end
                    end)
                end
            end
        ]=])
    end)
end
local runconnection
Tab:CreateToggle({
    Name = "Toggle autoplayer",
    Description = nil,
    CurrentValue = false,
    Callback = function(Value)
        task.spawn(function()
            if Value then
                if game.Players.LocalPlayer.PlayerGui:FindFirstChild("Window") then
                    task.wait(0.06)
                    startautoplay()
                end
                runconnection = game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
                    if child.Name == "Window" then
                        task.wait(0.6)
                        startautoplay()
                    end
                end)
            else
                runconnection:Disconnect()
                runconnection = nil
                run_on_actor(game:GetService("Players").LocalPlayer.PlayerScripts.ClientActor, [[
                    getgenv().autoplayer = false
                ]])
            end
        end)
    end
}, "Toggel")
Tab:CreateKeybind({
    Name = "keybind autoplay",
    DefaultKey = "P",
    Callback = function(Value)
        task.spawn(function()
            run_on_actor(game.Players.LocalPlayer.PlayerScripts.ClientActor, [[
                getgenv().autoplayer = not getgenv().autoplayer
            ]])
            Luna:Notification({ 
                Title = "Toggled Autoplayer!",
                Icon = "notifications_active",
                ImageSource = "Material",
                Content = "Autoplayer toggled"
            })
        end)
    end
})
Tab:CreateSection("Chances")
Tab:CreateSlider({
    Name = "Sick",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 94,
    Callback = function(Value)
        task.spawn(function()
            run_on_actor(game.Players.LocalPlayer.PlayerScripts.ClientActor, [[
                getgenv().chanceSick = ]] .. Value .. [[
            ]])
        end)
    end
})
Tab:CreateSlider({
    Name = "Good",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 6,
    Callback = function(Value)
        task.spawn(function()
            run_on_actor(game.Players.LocalPlayer.PlayerScripts.ClientActor, [[
                getgenv().chanceGood = ]] .. Value .. [[
            ]])
        end)
    end
})
Tab:CreateSlider({
    Name = "Ok",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 0,
    Callback = function(Value)
        task.spawn(function()
            run_on_actor(game.Players.LocalPlayer.PlayerScripts.ClientActor, [[
                getgenv().chanceOk = ]] .. Value .. [[
            ]])
        end)
    end
})
Tab:CreateSlider({
    Name = "Bad",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 0,
    Callback = function(Value)
        task.spawn(function()
            run_on_actor(game.Players.LocalPlayer.PlayerScripts.ClientActor, [[
                getgenv().chanceBad = ]] .. Value .. [[
            ]])
        end)
    end
})
Tab:CreateSlider({
    Name = "Miss",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 0,
    Callback = function(Value)
        task.spawn(function()
            run_on_actor(game.Players.LocalPlayer.PlayerScripts.ClientActor, [[
                getgenv().chanceMiss = ]] .. Value .. [[
            ]])
        end)
    end
})
Tab:CreateSection("Hit Method")
Tab:CreateDropdown({
    Name = "Hit Method",
    Options = {"virtual input", "fire function"},
    CurrentOption = "fire function",
    Callback = function(Value)
        task.spawn(function()
            if Value == "virtual input" then
                run_on_actor(game.Players.LocalPlayer.PlayerScripts.ClientActor, [[
                    getgenv().hitmethod = "vinput"
                ]])
            elseif Value == "fire function" then
                run_on_actor(game.Players.LocalPlayer.PlayerScripts.ClientActor, [[
                    getgenv().hitmethod = "firefunc"
                ]])
            end
        end)
    end
})

Luna:LoadAutoloadConfig()
task.wait(0.1)
Tab:BuildConfigSection()
