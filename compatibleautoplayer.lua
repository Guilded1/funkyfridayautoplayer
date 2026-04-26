local Starlight = loadstring(game:HttpGet("https://raw.nebulasoftworks.xyz/starlight"))() 
pcall(function() repeat task.wait() until Starlight.CreateWindow end)
local runService = game:GetService("RunService")
local lplr = game:GetService("Players").LocalPlayer
local inputManager = game:GetService("VirtualInputManager")


local keys = {
    ln1 = "Left", 
    ln2 = "Down", 
    ln3 = "Up", 
    ln4 = "Right"
}
local autoplayToggle = false
local connections = {}
local Marked = {}
local currentSide = "Left"
local accuracy = 100
local timewindow = 25


local function getMissChance()
    return (100 - accuracy) * 0.6 / 100
end

local function getOffsetPixels()
    local maxOffset = 100
    local factor = (100 - accuracy) / 100
    return math.random(-maxOffset * factor, maxOffset * factor)
end

local function getCenterY(frame)
    return frame.AbsolutePosition.Y + (frame.AbsoluteSize.Y / 2)
end

local function fetchLanes()
    local pg = lplr:FindFirstChild("PlayerGui")
    if not pg then return end
    local win = pg:FindFirstChild("Window")
    if not win then return end
    local gameField = win:FindFirstChild("Game")
    if not gameField then return end
    local fields = gameField:FindFirstChild("Fields")
    if not fields then return end
    local side = fields:FindFirstChild(currentSide)
    if not side then return end
    return side:FindFirstChild("Inner")
end


local Window = Starlight:CreateWindow({
	Name = "Lergic Hub - Funky Friday",
	Subtitle = "Made by relevant500.",
	Icon = 82795327169782,
	LoadingSettings = {
        Title = "Funky friday autoplayer - UNC friendly",
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
local Mainplayer = AutoGroup:CreateToggle({
    Name = "Toggle autoplayer",
    CurrentValue = false,
    Style = 2,
    Callback = function(Value)
        if Value then
            repeat task.wait() until fetchLanes()
            currentSide = lplr:GetAttribute("QueuedStageTeam") or "Left"
            local lanes = fetchLanes()
            if not lanes then return end
            connections = {}

            for i = 1, 4 do
                local lane = lanes:FindFirstChild("Lane" .. i)
                if not lane then continue end

                local notes = lane:FindFirstChild("Notes")
                local splash = lane:FindFirstChild("Splash")
                if not notes or not splash then continue end

                local splashCenterY = getCenterY(splash)
                local key = keys["ln" .. i]

                connections[i] = runService.Stepped:Connect(function()
                    for pfse, note in next, notes:GetChildren() do
                        if not note:IsA("Frame") then return end
                        local delay = 0
                        if accuracy < 100 then
                            delay = (math.random(0, (100 - accuracy) * 0.8)) / 1000
                        end
    
                        task.delay(delay, function()
                            if not note.Parent then return end
                            local offsetPixels = getOffsetPixels()
                            local trueYcenter = getCenterY(note) + offsetPixels
                            if math.abs(trueYcenter - splashCenterY) <= timewindow * 1.5 then
                                inputManager:SendKeyEvent(true, key, false, game)
                            end
                        end)
                        task.spawn(function()
                            while note.Parent do
                                local bottom = note.AbsolutePosition.Y + note.AbsoluteSize.Y
                                if bottom < splashCenterY then
                                    break
                                end
                                task.wait()
                            end
                            inputManager:SendKeyEvent(false, key, false, game)
                        end)
                    end
                end)
            end
        else
            for _, conn in pairs(connections) do
                if conn then
                    conn:Disconnect()
                end
            end
            table.clear(connections)
        end
    end
}, "Toggel")
local SliderGroup = Tab:CreateGroupbox({
    Name = "Autoplayer Settings",
    Column = 2,
}, "ALLAHAKBAR")
SliderGroup:CreateSlider({
    Name = "Accuracy",
    Icon = 8834748103,
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 100,
    Callback = function(Value)
        task.spawn(function()
            accuracy = tonumber(Value)
        end)
    end
}, "Yours truly, lergic")
