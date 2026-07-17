local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)


--------------------------------------------------
-- DEPENDENCIES -- 
--------------------------------------------------

local ProfileTemplate = require(ReplicatedStorage.Modules.ProfileTemplate)

local TowersFolder = workspace.PlayerTowers

-- Tower Assets
local GameAssets = ReplicatedStorage:WaitForChild("GameAssets")
local TowerAssets = GameAssets.TowerAssets
local Tower = require(TowerAssets.Tower)
local Room = require(TowerAssets.Room)

-- Room Assets
local RoomAssets = GameAssets.RoomAssets
local RoomDefinitions = require(RoomAssets.RoomDefinitions)

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local remotes = {
	BuildFloor = remotesFolder.Tower.BuildFloor,
	AssignRoomType = remotesFolder.Tower.AssignRoomType,
	DemolishRoom = remotesFolder.Tower.DemolishRoom,
	
	
	-- RFs
	GetTower = remotesFolder.Tower.GetTower,
}

--------------------------------------------------
-- TYPES -- 
--------------------------------------------------

type Profile = ProfileTemplate.ProfileTemplate
type TowerData = ProfileTemplate.TowerData
type ElevatorData = ProfileTemplate.ElevatorData
type SerializedRoom = ProfileTemplate.SerializedRoom

type RoomDefinition = RoomDefinitions.RoomDefinition

type Tower = Tower.Tower
type Room = Room.Room

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

local function attemptBuildFloor(player: Player, columnIndex: number)
	if type(columnIndex) ~= "number" then return end
	
	local tower: Tower = TowerService:GetTower(player)
	if not tower then warn("No tower found for player", player) return end
	
	local validColumn = table.find(tower:GetBuildableColumns(), columnIndex)
	if not validColumn then warn("[attemptBuildFloor] Invalid column index", columnIndex) return end
	
	local nextFloor = tower:GetColumnTopFloor(columnIndex) + 1
	local floorPrice = TowerService:GetFloorPrice(player, columnIndex, nextFloor)
	if not nextFloor then
		warn("No next floor found for column index", columnIndex)
		return
	end
	
	local profile: Profile = TowerService.Services.DataService:GetProfile(player)
	if not profile then warn("No profile found for player", player) return end
	if profile.Money < floorPrice then
		TowerService.Services.NotificationService:Error(player, "Cannot afford floor!")
		return
	end
	
	TowerService.Services.DataService:IncrementCurrency(player, "Money", -floorPrice, "Build Floor")
	tower:AddFloor(columnIndex)
end

local function attemptAssignRoomType(player: Player, roomId: string, roomType: string)
	if type(roomId) ~= "string" or type(roomType) ~= "string" then return end

	local tower: Tower = TowerService:GetTower(player)
	local room: Room = tower and tower.Rooms[roomId]
	if not room then warn("[attemptAssignRoomType] No room found for roomId", roomId) return end
	if room.BehaviorName ~= "Construction" then return end

	local randomKey = TowerService:RollRoomKeyFromType(player, roomType)
	if not randomKey then
		warn("[attemptAssignRoomType] No randomRoomKey found for roomType", roomType)
		return
	end
	
	room.Behavior:StartConstruction(randomKey)
end

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

function TowerService:GetFloorPrice(player: Player, columnIndex: number, floor: number): number
	local price = 100 * floor 
	
	-- TODO: price modifiers
	
	return price
end

function TowerService:GetUnlockedColumns(player: Player): {number}
	local unlocked = {-2, -1, 1, 2} -- default center columns
	
	-- TODO: read extra unlocks from future expansion upgrades, gamepasses, etc
	
	return unlocked
end

function TowerService:RollRoomKeyFromType(player: Player, roomType: string): string?
	local typeBucket = RoomDefinitions.RollBuckets[roomType]
	if not typeBucket or #typeBucket == 0 then return nil end
	
	local randomRoomKey: string = typeBucket[math.random(#typeBucket)]

	return randomRoomKey
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
	
	
	remotes.BuildFloor.OnServerEvent:Connect(attemptBuildFloor)
	remotes.AssignRoomType.OnServerEvent:Connect(attemptAssignRoomType)
	
end


return TowerService