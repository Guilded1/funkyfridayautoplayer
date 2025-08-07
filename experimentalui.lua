local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
Rayfield:LoadConfiguration()
local Window = Rayfield:CreateWindow({
    Name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name.." - By relevant500 on discord",
    LoadingTitle = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name,
    LoadingSubtitle = "Loading...",
})

task.spawn(function()
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
task.spawn(function()
    run_on_actor(game:GetService("Players").LocalPlayer.PlayerScripts.ClientActor, [=[
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
        game:GetService("RunService").RenderStepped:Connect(function()
            if not (pcall(function() return getgenv().autoplayer and framework.VSRG.GameHandler.Field.Game.TimePosition and framework.VSRG.GameHandler.Field.Game.Notes end)) then return end
            pcall(function()
                game:GetService("Players").LocalPlayer.PlayerGui.TopBar.Frame.Right.Version.Text = "Autoplayer: " .. (getgenv().autoplayer and "enabled" or "disabled")
            end)
            local timepos = framework.VSRG.GameHandler.Field.Game.TimePosition
            local offset = getgenv().hitboxoffset
            if not pcall(function() return timepos + offset end) then return end
            local threshold = timepos + offset
            pcall(function() getgenv().updatekeybinds(tostring(framework.VSRG.GameHandler.Field.Keys).."Key") end)
            for _, arrow in next, framework.VSRG.GameHandler.Field.Game.Notes do
                if not arrow or arrow.Marked or not getgenv().autoplayer then continue end
                if arrow.Field ~= framework.VSRG.GameHandler.Field.Side then continue end
                if not tonumber(arrow.Time) then continue end
                local accuracymath = math.clamp((1 - math.abs(tonumber(arrow.Time) - threshold)) * 100, 0, 100) -- yes i took this from the original script, im lazy and pretty sure the logic is the same pre-rewrite and post-rewrite
                if accuracymath >= (getchances() or 96) then
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
        end)
    ]=])
end)
local runconnection
local WorldTab = Window:CreateTab("World", 13350796199)
local autoplayertoggle = false
local autoplayertoggle = WorldTab:CreateToggle({
    Name = "Autoplayer",
    CurrentValue = false,
    Flag = "autoplayertoggle",
    Callback = function(state)
        autoplayertoggle = state
        if autoplayertoggle then
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
    end
})

local ChancesTab = Window:CreateTab("Partially broken", 13350796199)
local SickChance = ChancesTab:CreateSlider({
    Name = "Sick Chance",
    Range = {0, 100},
    Increment = 1,
    Suffix = " %",
    CurrentValue = 90,
    Flag = "SickChance",
    Callback = function(value)
        task.spawn(function()
            run_on_actor(game.Players.LocalPlayer.PlayerScripts.ClientActor, [[
                getgenv().chanceSick = ]] .. value .. [[
                print(getgenv().chanceSick)
            ]])
        end)
    end
})
local GoodChance = ChancesTab:CreateSlider({
    Name = "Good Chance",
    Range = {0, 100},
    Increment = 1,
    Suffix = " %",
    CurrentValue = 10,
    Flag = "GoodChance",
    Callback = function(value)
        task.spawn(function()
            run_on_actor(game.Players.LocalPlayer.PlayerScripts.ClientActor, [[
                getgenv().chanceGood = ]] .. value .. [[
                print(getgenv().chanceGood)
            ]])
        end)
    end
})
local OkChance = ChancesTab:CreateSlider({
    Name = "Ok Chance",
    Range = {0, 100},
    Increment = 1,
    Suffix = " %",
    CurrentValue = 0,
    Flag = "OkChance",
    Callback = function(value)
        task.spawn(function()
            run_on_actor(game.Players.LocalPlayer.PlayerScripts.ClientActor, [[
                getgenv().chanceOk = ]] .. value .. [[
                print(getgenv().chanceOk)
            ]])
        end)
    end
})
local BadChance = ChancesTab:CreateSlider({
    Name = "Bad Chance",
    Range = {0, 100},
    Increment = 1,
    Suffix = " %",
    CurrentValue = 0,
    Flag = "BadChance",
    Callback = function(value)
        task.spawn(function()
            run_on_actor(game.Players.LocalPlayer.PlayerScripts.ClientActor, [[
                getgenv().chanceBad = ]] .. value .. [[
                print(getgenv().chanceBad)
            ]])
        end)
    end
})
local MissChance = ChancesTab:CreateSlider({
    Name = "Miss Chance",
    Range = {0, 100},
    Increment = 1,
    Suffix = " %",
    CurrentValue = 0,
    Flag = "MissChance",
    Callback = function(value)
        task.spawn(function()
            run_on_actor(game.Players.LocalPlayer.PlayerScripts.ClientActor, [[
                getgenv().chanceMiss = ]] .. value .. [[
                print(getgenv().chanceMiss)
            ]])
        end)
    end
})
local HitMethod = ChancesTab:CreateDropdown({
    Name = "Hit Method",
    Options = {"firefunc", "vinput"},
    CurrentOption = "firefunc",
    Flag = "HitMethod",
    Callback = function(option)
        task.spawn(function()
            run_on_actor(game.Players.LocalPlayer.PlayerScripts.ClientActor, [[
                getgenv().hitmethod = "]] .. option .. [["
            ]])
        end)
    end
})

