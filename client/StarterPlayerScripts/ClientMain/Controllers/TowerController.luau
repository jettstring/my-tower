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
	ConstructRoom = remotesFolder.Tower.ConstructRoom,
	BuildRoom = remotesFolder.Tower.BuildRoom,
	DemolishRoom = remotesFolder.Tower.DemolishRoom,


	-- RFs
	GetTower = remotesFolder.Tower.GetTower,
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

local function _setupTowers()
	for i = 1, #TowersFolder:GetChildren() do
		local towerFolder = TowersFolder:FindFirstChild(tostring(i))
		if not towerFolder then warn("[_setupTowers] No tower folder found for", i) continue end
		
		local towerModel = towerFolder:WaitForChild("Tower")
		if not towerModel then warn("[_setupTowers] No tower model found for", towerFolder) continue end
		
		local componentsFolder = towerModel:WaitForChild("Components")
		
		-- Setup columns / rooms
		local columnsFolder = towerModel:WaitForChild("Columns")
		local roomsFolder = componentsFolder:WaitForChild("Rooms")
		for _, columnContainer in columnsFolder:GetChildren() do

			-- rooms
			local roomsContainer = columnContainer:WaitForChild("Rooms")
			for _, roomModel in roomsContainer:GetChildren() do
				
			end
			
			-- lobby
			local lobby = columnContainer:WaitForChild("Lobby")
		end
	end
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