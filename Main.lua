local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local Options = Fluent.Options


getgenv().AutoFarm = false
getgenv().AutoFarmTool = ""
getgenv().AutoParry = false
getgenv().AutoBankMoney = false
getgenv().Speed = 4
getgenv().Distance = 5
getgenv().Weapons = {}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Debugging function
local function log(message)
	rconsoleprint(message .. "\n") -- Logs to a separate exploit console (if supported)
	print(message) -- Logs to the in-game console
end

-- Prevent idling
local GC = getconnections or get_signal_cons
if GC then
	for _, v in pairs(GC(LocalPlayer.Idled)) do
		if v["Disable"] then
			v["Disable"](v)
			log("Idle connection disabled.")
		elseif v["Disconnect"] then
			v["Disconnect"](v)
			log("Idle connection disconnected.")
		end
	end
else
	local VirtualUser = cloneref(game:GetService("VirtualUser"))
	LocalPlayer.Idled:Connect(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
		log("VirtualUser handled idle event.")
	end)
end

-- Main loops
spawn(function()
	while wait() do
		if getgenv().AutoParry then
			game:GetService("ReplicatedStorage").Remotes.Block:FireServer(true)
			game:GetService("ReplicatedStorage").Remotes.Block:FireServer(false)
			game:GetService("ReplicatedStorage").Remotes.Roll:FireServer()
		end
		if getgenv().AutoBankMoney == true then
			game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Bank"):InvokeServer(true, math.huge)
		end
	end
end)
spawn(function()
	while wait() do
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		if not getgenv().AutoFarm or getgenv().AutoFarmTool == "" then
			log("AutoFarm disabled. Skipping this cycle.")
			continue -- Skip the current iteration but continue the loop
		end

		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		local Backpack = LocalPlayer:WaitForChild("Backpack")
		if Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 and Backpack then
			log("Character and Humanoid are valid.")
			if Backpack:FindFirstChild(getgenv().AutoFarmTool) and not Character:FindFirstChild(getgenv().AutoFarmTool) then
				local tool = Backpack:FindFirstChild(getgenv().AutoFarmTool)
				tool.Parent = Character
				log("'Ceremonial Greatblade' equipped.")
				wait(2)
			else
				log("Found 'Ceremonial Greatblade' in Backpack.")
			end
			local ToolInstance = Character:FindFirstChild(getgenv().AutoFarmTool)
			if ToolInstance and ToolInstance:FindFirstChild("Slash") then
				local SlashEvent = ToolInstance:FindFirstChild("Slash")
				for i = 1, 4 do
					SlashEvent:FireServer(i)
					log("SlashEvent:FireServer(" .. i .. ") called.")
				end


				local mob
				for _, MOBB in pairs(workspace.Mobs:GetChildren()) do
					if MOBB:GetAttribute("Tower") == true and MOBB:FindFirstChildOfClass("Humanoid") and MOBB:FindFirstChildOfClass("Humanoid").Health > 0 then
						mob = MOBB
						log("Found mob with Tower attribute.")
						break
					end
				end

				if mob and mob:FindFirstChildOfClass("Humanoid").Health > 0 then
					spawn(function()
						if Character:FindFirstChild("HumanoidRootPart") then
							Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0,0,getgenv().Distance)
							log("Teleported to mob.")
						end
					end)
				else
					if Character:FindFirstChild("HumanoidRootPart") then
						Character.HumanoidRootPart.CFrame = CFrame.new(4150, 403, -2380)
						log("Teleported to default position.")
					end
					if LocalPlayer.PlayerGui:FindFirstChild("ScreenGui") and LocalPlayer.PlayerGui.ScreenGui:FindFirstChild("Dialog") then
						wait(2)
						pcall(function()
							for i = 4, 1, -1 do
								workspace:WaitForChild("Map"):WaitForChild("TowerIsland"):WaitForChild("Plate"):WaitForChild("RemoteEvent"):FireServer(i)
								wait()
							end
							log("Plate remote event fired.")
						end)
					end
				end
			else
				log("Tool or SlashEvent missing.")
				Character:FindFirstChild("Humanoid").Health = 0
			end
		else
			wait(7)
			log("Character or Humanoid invalid.")
		end
	end
end)

function refreshWeapons()
	local Weapons = {}
	for _, Tool in pairs(LocalPlayer.Backpack:GetChildren()) do
		if Tool:IsA("Tool") and Tool:GetAttribute("Type") == "Sword" then
			table.insert(Weapons, Tool.Name)
		end
	end
	for _, Tool in pairs(LocalPlayer.Character:GetChildren()) do
		if Tool:IsA("Tool") and Tool:GetAttribute("Type") == "Sword" then
			table.insert(Weapons, Tool.Name)
		end
	end
	getgenv().Weapons = Weapons
end
refreshWeapons()

local Window = Fluent:CreateWindow({
	Title = "Prodox sigma script 1.2.0",
	SubTitle = "by prodox",
	TabWidth = 130,
	Size = UDim2.fromOffset(580, 460),
	Acrylic = true, -- The blur may be detectable, setting this to false disables blur entirely
	Theme = "Dark",
	MinimizeKey = Enum.KeyCode.RightControl -- Used when theres no MinimizeKeybind
})

local Tabs = {
	Main = Window:AddTab({ Title = "Main", Icon = "" }),
	Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

do
	
	local WeaponsDropdown = Tabs.Main:AddDropdown("WeaponsDropdown", {
		Title = "Select weapon",
		Values = getgenv().Weapons,
		Multi = false,
		Default = nil,
	})
	WeaponsDropdown:OnChanged(function(Value)
		getgenv().AutoFarmTool = Value
	end)
	
	Tabs.Main:AddButton({
		Title = "Refresh weapons",
		Description = "Refresh weapons",
		Callback = function()
			refreshWeapons()
		end
	})
	
	local AutofarmToggle = Tabs.Main:AddToggle("Autofarm", {Title = "Autofarm XP/Money", Default = getgenv().AutoFarm })
	AutofarmToggle:OnChanged(function()
		getgenv().AutoFarm = Options.Autofarm.Value
	end)

	local AutoParryToggle = Tabs.Main:AddToggle("AutoParry", {Title = "Auto Parry (Semi-godmode)", Default = getgenv().AutoParry })
	AutoParryToggle:OnChanged(function()
		getgenv().AutoParry = Options.AutoParry.Value
	end)

	local AutoBankMoneyToggle = Tabs.Main:AddToggle("AutoBankMoney", {Title = "Auto Bank Money", Default = getgenv().AutoBankMoney })
	AutoBankMoneyToggle:OnChanged(function()
		getgenv().AutoBankMoney = Options.AutoBankMoney.Value
	end)

	--local AutofarmSpeedSlider = Tabs.Main:AddSlider("AutofarmSpeed", {
	--	Title = "Speed",
	--	Description = "AutoFarm speed",
	--	Default = getgenv().Speed,
	--	Min = 1,
	--	Max = 100,
	--	Rounding = 1,
	--	Callback = function(Value)
	--		print("Slider was changed:", Value)
	--		getgenv().Speed = Value
	--	end
	--})
	local AutofarmDistanceSlider = Tabs.Main:AddSlider("AutofarmDistance", {
		Title = "Distance",
		Description = "AutoFarm Distance",
		Default = getgenv().Distance,
		Min = 0,
		Max = 20,
		Rounding = 1,
		Callback = function(Value)
			getgenv().Distance = Value
		end
	})
end
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("FluentScriptHub")
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
Window:SelectTab(1)
Fluent:Notify({
	Title = "Prodox:",
	Content = "Script has been loaded.",
	Duration = 8
})

