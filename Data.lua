local SERVER_URL = "https://roblox-theforge-dashboard.onrender.com/update-data" -- IP เดิมของคุณ

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

local function sendData(data)
    local jsonData = HttpService:JSONEncode(data)
    pcall(function()
        request({
            Url = SERVER_URL,
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = jsonData
        })
    end)
end

local function getData()
    local level = "Loading..."
    local gold = "Loading..."
    local capacity = "N/A"

    pcall(function() 
        local gui = LocalPlayer:WaitForChild("PlayerGui")
        
        if gui:FindFirstChild("Main") then
            local hud = gui.Main.Screen.Hud
            level = hud.Level.Text 
            gold = hud.Gold.Text
        end
        
        -- Path เดิมที่ถูกต้องแล้ว
        local menu = gui.Menu.Frame.Frame.Menus
        if menu:FindFirstChild("Stash") and menu.Stash:FindFirstChild("Capacity") then
            local capFrame = menu.Stash.Capacity
            
            if capFrame:FindFirstChild("Text") then
                local rawText = capFrame.Text.Text 
                
                -- [[ เพิ่มส่วนนี้: ล้าง RichText Tag (<font...>) ออก ]] --
                -- ลบทุกอย่างที่อยู่ในเครื่องหมาย <...>
                local cleanText = string.gsub(rawText, "<[^>]+>", "")
                
                -- ลบคำว่า "Stash Capacity:" ออก (เผื่อมี)
                cleanText = string.gsub(cleanText, "Stash Capacity: ", "")
                cleanText = string.gsub(cleanText, "Stash Capacity:", "")
                
                -- ตัดช่องว่างหัวท้ายออก
                capacity = string.match(cleanText, "^%s*(.-)%s*$")
            end
        end
    end)

    -- ส่วนดึงไอเทม (คงเดิม)
    local itemList = {}
    pcall(function()
        local stashFrame = LocalPlayer.PlayerGui.Menu.Frame.Frame.Menus.Stash.Background
        for _, child in pairs(stashFrame:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible == true then
                if child:FindFirstChild("Main") and child.Main:FindFirstChild("ItemName") then
                    local main = child.Main
                    local name = main.ItemName.Text 
                    if name == "" or name == nil then name = main.ItemName:GetAttribute("Text") end
                    
                    local qty = "x1"
                    if main:FindFirstChild("Quantity") and main.Quantity.Text ~= "" then
                        qty = main.Quantity.Text
                    end

                    if name and name ~= "" then
                        table.insert(itemList, { name = name, qty = qty })
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

while wait(0.5) do
    pcall(function() sendData(getData()) end)
end
