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


-- Prevent idling
local GC = getconnections or get_signal_cons
if GC then
	for _, v in pairs(GC(LocalPlayer.Idled)) do
		if v["Disable"] then
			v["Disable"](v)
			print("Idle connection disabled.")
		elseif v["Disconnect"] then
			v["Disconnect"](v)
			print("Idle connection disconnected.")
		end
	end
else
	local VirtualUser = cloneref(game:GetService("VirtualUser"))
	LocalPlayer.Idled:Connect(function()
		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.new())
		print("VirtualUser handled idle event.")
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
	game:GetService("RunService").RenderStepped:Connect(function()
		local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
		if getgenv().AutoFarm and getgenv().AutoFarmTool ~= "" then
			local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
			local Backpack = LocalPlayer:WaitForChild("Backpack")
			if Character and Character:FindFirstChild("Humanoid") and Character.Humanoid.Health > 0 and Backpack then
				print("Character and Humanoid are valid.")
				if Backpack:FindFirstChild(getgenv().AutoFarmTool) and not Character:FindFirstChild(getgenv().AutoFarmTool) then
					local tool = Backpack:FindFirstChild(getgenv().AutoFarmTool)
					tool.Parent = Character
					print("'Ceremonial Greatblade' equipped.")
					wait(2)
				else
					print("Found 'Ceremonial Greatblade' in Backpack.")
				end
				local ToolInstance = Character:FindFirstChild(getgenv().AutoFarmTool)
				if ToolInstance and ToolInstance:FindFirstChild("Slash") then
					local SlashEvent = ToolInstance:FindFirstChild("Slash")
					for i = 1, 4 do
						SlashEvent:FireServer(i)
						print("SlashEvent:FireServer(" .. i .. ") called.")
					end


					local mob
					for _, MOBB in pairs(workspace.Mobs:GetChildren()) do
						if MOBB:GetAttribute("Tower") == true and MOBB:FindFirstChildOfClass("Humanoid") and MOBB:FindFirstChildOfClass("Humanoid").Health > 0 then
							mob = MOBB
							print("Found mob with Tower attribute.")
							break
						end
					end

					if mob and mob:FindFirstChildOfClass("Humanoid").Health > 0 then
						spawn(function()
							if Character:FindFirstChild("HumanoidRootPart") then
								Character.HumanoidRootPart.CFrame = mob.HumanoidRootPart.CFrame * CFrame.new(0,0,getgenv().Distance)
								print("Teleported to mob.")
							end
						end)
					else
						if Character:FindFirstChild("HumanoidRootPart") then
							Character.HumanoidRootPart.CFrame = CFrame.new(4150, 403, -2380)
							print("Teleported to default position.")
						end
						if LocalPlayer.PlayerGui:FindFirstChild("ScreenGui") and LocalPlayer.PlayerGui.ScreenGui:FindFirstChild("Dialog") then
							wait(2)
							pcall(function()
								if game:GetService("Players").LocalPlayer.Statistics.SkyArenaRecord.Value >= 200 then
									workspace:WaitForChild("Map"):WaitForChild("TowerIsland"):WaitForChild("Plate"):WaitForChild("RemoteEvent"):FireServer(4)
								elseif game:GetService("Players").LocalPlayer.Statistics.SkyArenaRecord.Value >= 100 and game:GetService("Players").LocalPlayer.Statistics.SkyArenaRecord.Value < 200 then
									workspace:WaitForChild("Map"):WaitForChild("TowerIsland"):WaitForChild("Plate"):WaitForChild("RemoteEvent"):FireServer(3)
								elseif game:GetService("Players").LocalPlayer.Statistics.SkyArenaRecord.Value >= 50 and game:GetService("Players").LocalPlayer.Statistics.SkyArenaRecord.Value < 100 then
									workspace:WaitForChild("Map"):WaitForChild("TowerIsland"):WaitForChild("Plate"):WaitForChild("RemoteEvent"):FireServer(2)
								else
									workspace:WaitForChild("Map"):WaitForChild("TowerIsland"):WaitForChild("Plate"):WaitForChild("RemoteEvent"):FireServer(1)
								end
								print("Plate remote event fired.")
							end)
						end
					end
				else
					print("Tool or SlashEvent missing.")
					Character:FindFirstChild("Humanoid").Health = 0
				end
			else
				wait(7)
				print("Character or Humanoid invalid.")
			end
		end
	end)
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
