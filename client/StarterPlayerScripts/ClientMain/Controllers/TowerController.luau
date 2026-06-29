local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Signal = require(ReplicatedStorage.Packages.Signal)

--------------------------------------------------
-- DEPENDENCIES -- 
--------------------------------------------------

local player = Players.LocalPlayer

-- Tower Assets
local TowersFolder = workspace.PlayerTowers
local GameAssets = ReplicatedStorage:WaitForChild("GameAssets")
local TowerAssets = GameAssets.TowerAssets


local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local remotes = {
	
}

--------------------------------------------------
-- TYPES -- 
--------------------------------------------------


--------------------------------------------------
-- STATE --
--------------------------------------------------
local TowerController = {}
TowerController.Controllers = {}
TowerController.Signals = {
	TowerAssigned = Signal.new(),
}

--------------------------------------------------
-- VARIABLES --
--------------------------------------------------

-- Constants

--------------------------------------------------
-- PRIVATE FUNCTIONS --
--------------------------------------------------

local function _setup()
	local towerFolder = TowerController:GetTowerFolder()
	if not towerFolder then
		warn("[_setup] No tower folder found")
		return
	end
	
	
	-- fire tower assignment signal
	TowerController.Signals.TowerAssigned:Fire()
	
	print(towerFolder)
end

--------------------------------------------------
-- PUBLIC FUNCTIONS --
--------------------------------------------------

function TowerController:GetTowerFolder(): Folder
	local towerAssigned: number = player:GetAttribute("TowerAssigned")
	if not towerAssigned then
		warn("[GetTowerFolder] No tower number assigned")
		return
	end
	
	local towerFolder = TowersFolder:FindFirstChild(tostring(towerAssigned))
	if not towerFolder then
		warn("[GetTowerFolder] No tower folder found for", towerAssigned)
	end
	
	return towerFolder
end

--------------------------------------------------
-- MAIN --
--------------------------------------------------

function TowerController:Init(controllers)
	self.Controllers = controllers

end

function TowerController:Start()
	-- wait for tower to be assigned
	player:GetAttributeChangedSignal("TowerAssigned"):Connect(_setup)
	if player:GetAttribute("TowerAssigned") then _setup() end
		
	
	
end


return TowerController