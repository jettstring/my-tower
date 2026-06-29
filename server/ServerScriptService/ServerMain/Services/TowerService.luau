local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)


--------------------------------------------------
-- DEPENDENCIES -- 
--------------------------------------------------

local TowersFolder = workspace.PlayerTowers

-- Tower Assets
local GameAssets = ReplicatedStorage:WaitForChild("GameAssets")
local TowerAssets = GameAssets.TowerAssets
local Tower = require(TowerAssets.Tower)


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

type Tower = Tower.Tower

--------------------------------------------------
-- STATE --
--------------------------------------------------
local TowerService = {} 
TowerService.Services = {}
TowerService.Signals = {
	TowerAssigned = Signal.new(),
}

TowerService.ClaimedTowers = {} :: {[Folder]: Player}
TowerService.PlayerTowers = {} :: {[Player]: Tower}

--------------------------------------------------
-- VARIABLES --
--------------------------------------------------

-- Constants

--------------------------------------------------
-- PRIVATE FUNCTIONS --
--------------------------------------------------

local function cleanupTower(towerFolder: Folder) 
	
end

local function _setupTowers() 

end

local function _playerRemoved(player: Player)
	local tower: Tower = TowerService.PlayerTowers[player]
	if tower then
		local towerFolder = tower.TowerFolder
		cleanupTower(towerFolder)
		tower:Destroy()
		TowerService.PlayerTowers[player] = nil
	end
end

--------------------------------------------------
-- PUBLIC FUNCTIONS --
--------------------------------------------------

function TowerService:AssignTower(player: Player)
	if not player then return end
	
	-- already assigned guard
	if self.ClaimedTowers[player] then
		warn("Player already has a tower")
		return
	end
	
	
	-- find first available tower folder
	for i = 1, #TowersFolder:GetChildren() do
		local towerFolder = TowersFolder:FindFirstChild(tostring(i))
		if not towerFolder then continue end
		if self.ClaimedTowers[towerFolder] then continue end

		-- create new tower object for player
		local playerTower: Tower = Tower.new(player, towerFolder, self.Services)
		if playerTower == nil then 
			warn("[AssignTower] Failed to create tower for player:", player.Name)
			return
		end
		self.ClaimedTowers[towerFolder] = player
		self.PlayerTowers[player] = playerTower

		self.Signals.TowerAssigned:Fire(player, playerTower)
		player:SetAttribute("TowerAssigned", i)
		
		print("[AssignTower] Assigned tower to player:", player.Name, "Tower:", towerFolder.Name)
		return 
	end
end

function TowerService:GetTower(player: Player): Tower?
	return self.PlayerTowers[player]
end


--------------------------------------------------
-- MAIN --
--------------------------------------------------

function TowerService:Init(services)
	self.Services = services
	
	_setupTowers()
end

function TowerService:Start()
	
	self.Services.DataService.Signals.DataLoaded:Connect(function(player: Player)
		TowerService:AssignTower(player)
	end)
	
	Players.PlayerRemoving:Connect(_playerRemoved)
	
end


return TowerService