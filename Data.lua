local SERVER_URL = "http://192.168.0.104:3000/update-data" -- IP เดิมของคุณ

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local function sendData(data)
    local jsonData = HttpService:JSONEncode(data)
    local success, response = pcall(function()
        return request({
            Url = SERVER_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = jsonData
        })
    end)
    if success then
        print("Data sent!!!!")
    else
        warn("Failed to send data")
    end
end

local function getData()
    local level = "Loading..."
    local gold = "Loading..."
    local capacity = "N/A"

    pcall(function() 
        local gui = LocalPlayer:WaitForChild("PlayerGui")
        
        -- 1. ดึง HUD
        if gui:FindFirstChild("Main") then
            local hud = gui.Main.Screen.Hud
            level = hud.Level.Text 
            gold = hud.Gold.Text
        end
        
        -- 2. ดึง Capacity (แก้ Path ให้ถูกตามรูป)
        -- Path: ...Menus.Stash.Capacity.Text
        local menu = gui.Menu.Frame.Frame.Menus
        if menu:FindFirstChild("Stash") and menu.Stash:FindFirstChild("Capacity") then
            local capFrame = menu.Stash.Capacity
            
            -- เข้าไปเอาข้อความในลูกที่ชื่อว่า "Text"
            if capFrame:FindFirstChild("Text") then
                local rawText = capFrame.Text.Text -- .Text ตัวแรกคือชื่อ, .Text ตัวหลังคือข้อความ
                
                -- ตัดคำว่า "Stash Capacity: " ออก ให้เหลือแค่ตัวเลขสวยๆ
                if rawText then
                    capacity = string.gsub(rawText, "Stash Capacity: ", "")
                end
            end
        end
    end)

    -- 3. ดึงไอเทม (เหมือนเดิม)
    local itemList = {}
    pcall(function()
        local stashFrame = LocalPlayer.PlayerGui.Menu.Frame.Frame.Menus.Stash.Background
        for _, child in pairs(stashFrame:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible == true then
                if child:FindFirstChild("Main") and child.Main:FindFirstChild("ItemName") then
                    local mainFolder = child.Main
                    local nameText = mainFolder.ItemName.Text 
                    if nameText == "" or nameText == nil then nameText = mainFolder.ItemName:GetAttribute("Text") end
                    
                    local qtyText = "x1"
                    if mainFolder:FindFirstChild("Quantity") then
                        local q = mainFolder.Quantity.Text
                        if q ~= "" then qtyText = q end
                    end

                    if nameText and nameText ~= "" then
                        table.insert(itemList, { name = nameText, qty = qtyText })
                    end
                end
            end
        end
    end)
    
    return {
        username = LocalPlayer.Name,
        userId = LocalPlayer.UserId,
        level = level,
        gold = gold,
        capacity = capacity,
        items = itemList
    }
end

-- เร็วสุดที่แนะนำคือ 0.5 (ครึ่งวินาที)
while wait(0.5) do
    local success, data = pcall(getData)
    if success then
        sendData(data)
    end
end