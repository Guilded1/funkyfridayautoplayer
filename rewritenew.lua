local suc, res = pcall(function()
    return typeof(loadstring("return 1")()) == "number" and typeof(game.HttpGet) == "function" and typeof(getgenv) == "function" and typeof(getgc) == "function" and type(getgc(true)) == "table" and rawget({x = 1}, "x") == 1 and typeof(game:GetService("VirtualInputManager").SendKeyEvent) == "function" and typeof(run_on_actor) == "function"
end)
if suc and res then
    print("supported executor")
else
    game.Players.LocalPlayer:Kick("This script only works on high UNC executors; please use a better executor.")
end
local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))() 
pcall(function() repeat task.wait() until Starlight.CreateWindow end)
task.spawn(function()
    run_on_actor(game:GetService("Players").LocalPlayer.PlayerScripts.ClientActor, [=[
        local RunService = game:GetService("RunService")
        local function getchances()
            local sick = tonumber(getgenv().chanceSick or 90)
            local good = tonumber(getgenv().chanceGood or 9)
            local ok   = tonumber(getgenv().chanceOk or 0)
            local bad  = tonumber(getgenv().chanceBad or 0)
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
        getgenv().autoplayer = true
        getgenv().hitmethod = "firefunc"
        getgenv().hitboxoffset = 0
        getgenv().framework = nil
        local keyMap = {}
        for _, enum in next, Enum.KeyCode:GetEnumItems() do
            keyMap[enum.Value] = enum
        end
        for _, obj in pairs(getgc(true)) do
            if type(obj) == "table" and type(rawget(obj, "VSRG")) == "table" and type(rawget(obj, "Songs")) == "table" and type(rawget(obj, "IsStudio")) == "boolean" then
                getgenv().framework = obj
                break
            end
        end
        local framework = getgenv().framework
        if not framework then warn("framework not found") return end
        getgenv().keybindtbl = {}
        getgenv().updatekeybinds = function(sillykey)
            for i, arrowData in pairs(framework.VSRG.Arrows[sillykey].Arrows) do
                table.clear(getgenv().keybindtbl)
                local dir = tonumber(i) + 1
                getgenv().keybindtbl[dir] = keyMap[arrowData.Keybinds.Keyboard[1]]
            end
        end
        getgenv().updatekeybinds("4Key")
        getgenv().presskey = function(method, lane, state)
            if method == "firefunc" then
                framework.VSRG.GameHandler.Field.HitLane(framework.VSRG.GameHandler.Field, lane, state, nil)
            elseif method == "vinput" then
                game:GetService("VirtualInputManager"):SendKeyEvent(state, getgenv().keybindtbl[lane], false, nil)
            end
        end
        RunService.RenderStepped:Connect(function()
            if not getgenv().autoplayer then return end
            if not pcall(function()
                return framework.VSRG.GameHandler.Field.Game.TimePosition 
            end) then return end
            -- You might say "just add the 2 together" but for SOME reason, when i do that it just breaks the statement so i use this as a fallback
            local field = framework.VSRG.GameHandler.Field
            local timepos = field.Game.TimePosition
            local playback = field.Game.AdjustedPlayback or 1
            for _, arrow in next, field.NoteCache do
                if not arrow or arrow.Marked or arrow.Field ~= field.Side then continue end
                if (arrow.NoteData and arrow.NoteData.Type) then continue end
                local arrowtime = tonumber(arrow.Time)
                if not arrowtime then continue end
                local diff = (arrowtime - timepos) / playback
                -- small buffer so it isnt hitting 0.00ms 24/7
                if diff > -0.05 and diff < 0.8 then 
                    arrow.Marked = true
                    task.delay(diff, function()
                        local lane = arrow.Direction or arrow.Lane
                        local method = getgenv().hitmethod
                        getgenv().presskey(method, lane, true)
                        local len = (tonumber(arrow.Length) or 0.03) / playback
                        task.delay(len, function()
                            getgenv().presskey(method, lane, false)
                        end)
                    end)
                end
            end
        end)
    ]=])
end)

local Window = Starlight:CreateWindow({
	Name = "Lergic Hub - Funky Friday",
	Subtitle = "Made by relevant500.",
	Icon = 82795327169782,
	LoadingSettings = {
        Title = "Funky friday autoplayer",
        Subtitle = "by relevant500",
    },
})
local TabSection = Window:CreateTabSection("Autoplayer")
local Tab = TabSection:CreateTab({
	Name = "Main",
	Icon = 13300918120,
	Columns = 2
}, "MainSection")
local AutoGroup = Tab:CreateGroupbox({
    Name = "Autoplayer",
    Column = 2,
}, "IGJHERW")
local runconnection
local Mainplayer = AutoGroup:CreateToggle({
    Name = "Toggle autoplayer",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        task.spawn(function()
            if Value then
                if game.Players.LocalPlayer.PlayerGui:FindFirstChild("Window") then
                    task.wait(0.06)
                    run_on_actor(game:GetService("Players").LocalPlayer.PlayerScripts.ClientActor, [=[
                        getgenv().autoplayer = true
                    ]=])
                end
                runconnection = game.Players.LocalPlayer.PlayerGui.ChildAdded:Connect(function(child)
                    if child.Name == "Window" then
                        task.wait(0.6)
                        run_on_actor(game:GetService("Players").LocalPlayer.PlayerScripts.ClientActor, [=[
                            getgenv().autoplayer = true
                        ]=])
                    end
                end)
            else
                if runconnection then
                    runconnection:Disconnect()
                    runconnection = nil
                end
                run_on_actor(game:GetService("Players").LocalPlayer.PlayerScripts.ClientActor, [[
                    getgenv().autoplayer = false
                ]])
            end
        end)
    end
}, "Toggel")

Mainplayer:AddDropdown({
    Name = "Hit Method",
    Options = {"virtual input", "fire function"},
    CurrentOptions = {"fire function"},
    MultipleOptions = false,
    Placeholder = "None Selected",
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
}, "YEAH")

local SliderGroup = Tab:CreateGroupbox({
    Name = "Autoplayer Settings",
    Column = 2,
}, "maybeperchance")
SliderGroup:CreateSlider({
    Name = "Sick Chance",
    Icon = 8834748103,
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 100,
    Callback = function(Value)
        task.spawn(function()
            run_on_actor(game.Players.LocalPlayer.PlayerScripts.ClientActor, [[
                getgenv().chanceSick = ]] .. Value .. [[
            ]])
        end)
    end
}, "SickChance")
SliderGroup:CreateSlider({
    Name = "Good Chance",
    Icon = 8834748103,
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 0,
    Callback = function(Value)
        task.spawn(function()
            run_on_actor(game.Players.LocalPlayer.PlayerScripts.ClientActor, [[
                getgenv().chanceGood = ]] .. Value .. [[
            ]])
        end)
    end
}, "GoodChance")
SliderGroup:CreateSlider({
    Name = "Ok Chance",
    Icon = 8834748103,
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
}, "OkChance")
SliderGroup:CreateSlider({
    Name = "Bad Chance",
    Icon = 8834748103,
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
}, "BadChance")
SliderGroup:CreateSlider({
    Name = "Miss Chance",
    Icon = 8834748103,
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
}, "Yours truly, relevant500")
