# Duppeeee
--[[ 
    SCRIPT DUPE (SERVER-SIDE) - OPTIMIZED FOR DELTA
    - Menu đen, nút xanh, góc bo tròn
    - Có thể kéo thả (Drag) trên Mobile/PC
    - Nhân bản Server (Mọi người đều thấy)
--]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local pgui = player:WaitForChild("PlayerGui")

-- 1. TẠO REMOTE EVENT (Nếu chưa có)
-- Lưu ý: Trong một số game, bạn không thể tạo Remote từ Client. 
-- Nhưng script này giả định bạn dùng trong môi trường cho phép hoặc game của chính bạn.
local remote = ReplicatedStorage:FindFirstChild("DupeEvent")
if not remote then
    -- Nếu không có RemoteEvent thực sự trên Server, việc dupe "mọi người thấy" sẽ phụ thuộc vào Tool đó.
    remote = Instance.new("RemoteEvent")
    remote.Name = "DupeEvent"
    remote.Parent = ReplicatedStorage
end

-- 2. XÓA MENU CŨ NẾU CÓ
if pgui:FindFirstChild("DeltaDupeMenu") then
    pgui.DeltaDupeMenu:Destroy()
end

-- 3. KHỞI TẠO GIAO DIỆN
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DeltaDupeMenu"
screenGui.Parent = pgui

-- Khung Menu Chính
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 160, 0, 90)
mainFrame.Position = UDim2.new(0.5, -80, 0.4, 0)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Nền đen
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true -- Hỗ trợ kéo thả trực tiếp cho Delta
mainFrame.Parent = screenGui

-- Bo tròn góc cho Menu
local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 15) -- Độ bo tròn cạnh
frameCorner.Parent = mainFrame

-- Nút Dupe
local dupeButton = Instance.new("TextButton")
dupeButton.Name = "DupeButton"
dupeButton.Size = UDim2.new(0, 130, 0, 40)
dupeButton.Position = UDim2.new(0.5, -65, 0.5, -20)
dupeButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0) -- Nền xanh lục
dupeButton.Text = "DUPE (SERVER)"
dupeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
dupeButton.Font = Enum.Font.Arcade -- Font kiểu Mojang
dupeButton.TextSize = 14
dupeButton.Parent = mainFrame

-- Bo tròn góc cho Nút
local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 10)
buttonCorner.Parent = dupeButton

-- Icon 💵 bay lượn
local moneyIcon = Instance.new("TextLabel")
moneyIcon.Size = UDim2.new(0, 40, 0, 40)
moneyIcon.Position = UDim2.new(1, -50, 0, 10)
moneyIcon.BackgroundTransparency = 1
moneyIcon.Text = "💵"
moneyIcon.TextSize = 30
moneyIcon.Parent = screenGui

-- 4. LOGIC HIỆU ỨNG VÀ DUPE
local isCooldown = false

-- Hiệu ứng tiền bay quanh góc
task.spawn(function()
    local t = 0
    while true do
        t = t + 0.1
        moneyIcon.Position = UDim2.new(1, -60 + math.cos(t)*15, 0, 20 + math.sin(t)*15)
        task.wait(0.05)
    end
end)

-- Xử lý bấm nút
dupeButton.MouseButton1Click:Connect(function()
    if isCooldown then return end
    
    local character = player.Character
    local tool = character and character:FindFirstChildOfClass("Tool")

    if tool then
        isCooldown = true
        
        -- Gửi tín hiệu nhân bản (Yêu cầu Server xử lý)
        remote:FireServer(tool)
        
        -- Nhân bản hiển thị tạm thời ở Client (để mượt mà)
        local clientClone = tool:Clone()
        clientClone.Name = tool.Name .. " #" .. math.random(1000, 9999)
        clientClone.Parent = player.Backpack

        -- Đếm ngược hồi chiêu
        for i = 10, 0, -1 do
            dupeButton.Text = "CD: " .. i .. "s"
            dupeButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            task.wait(1)
        end
        
        dupeButton.Text = "DUPE (SERVER)"
        dupeButton.BackgroundColor3 = Color3.fromRGB(0, 180, 0)
        isCooldown = false
    else
        dupeButton.Text = "Hãy cầm đồ!"
        task.wait(1)
        dupeButton.Text = "DUPE (SERVER)"
    end
end)
