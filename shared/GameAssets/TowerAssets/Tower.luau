local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local Trove = require(ReplicatedStorage.Packages.Trove)

--------------------------------------------------
-- DEPENDENCIES -- 
--------------------------------------------------

local ProfileTemplate = require(ReplicatedStorage.Modules.ProfileTemplate)

local GameAssets = ReplicatedStorage.GameAssets

-- Tower Assets
local TowersFolder = workspace.PlayerTowers
local TowerAssets = GameAssets.TowerAssets
local TowerUtil = require(TowerAssets.TowerUtil)
local Room = require(TowerAssets.Room)
local Elevator = require(TowerAssets.Elevator)
local Lobby = require(TowerAssets.Lobby)

-- Room Assets
local RoomAssets = GameAssets.RoomAssets
local RoomDefinitions = require(RoomAssets.RoomDefinitions)
local RoomModels = RoomAssets.RoomModels
local LobbyModels = RoomAssets.LobbyModels

--------------------------------------------------
-- TYPES -- 
--------------------------------------------------

type Profile = ProfileTemplate.ProfileTemplate
type TowerData = ProfileTemplate.TowerData
type ElevatorData = ProfileTemplate.ElevatorData
type SerializedRoom = ProfileTemplate.SerializedRoom

type Room = Room.Room
type Elevator = Elevator.Elevator
type Lobby = Lobby.Lobby

type RoomDefinition = RoomDefinitions.RoomDefinition

--------------------------------------------------
-- MAIN -- 
--------------------------------------------------

local Tower = {}
Tower.__index = Tower

function Tower.new(ownerPlayer: Player, TowerFolder: Folder, services: any)
	local self = setmetatable({}, Tower)
	self.Services = services
	self.Trove = Trove.new()

	self.Owner = ownerPlayer
	self.TowerFolder = TowerFolder
	self.TowerData = nil

	self.State = {
		Active = false,
	}
	
	self.Rooms = {}       -- { [id]: Room } -- flat table of all rooms
	self.Lobby = nil
	self.Elevator = nil
	self.BuildFloors = {} :: {[number]: Model} -- { [columnIndex]: model }
	

	self:_Setup()
	if not self.State.Active then
		warn("Tower is not active, destroying")
		self:Destroy()
		return nil
	end

	print("[Tower] Created tower:", self)
	return self
end

--------------------------------------------------
-- SETUP -- 
--------------------------------------------------

function Tower:_Setup()
	local owner: Player = self.Owner
	local towerModel: Model = self.TowerFolder:FindFirstChild("Tower")
	
	-- Assign spawn to owner
	local spawnLocation = towerModel:WaitForChild("SpawnLocation")
	owner.RespawnLocation = spawnLocation
	if owner.Character then
		owner.Character:MoveTo(spawnLocation.Position + Vector3.new(0, 5, 0))
	end

	-- setup components
	self:_SetupSpawn()
	self:UpdateOwnerDisplay()
	
	-- hydrate tower from profile
	local profile: Profile = self.Services.DataService:GetProfile(owner)
	if not profile then warn("[_Setup] No profile found for player") return end
	local towerData: TowerData = profile.TowerData
	self.TowerData = towerData
	self:_SetupRooms(towerData)
	
	self.Lobby = self.Trove:Add(Lobby.new(self, self.ColumnData, self.Services))
	self.Elevator = self.Trove:Add(Elevator.new(self, self.ColumnData, self.Services))
	
	self:RefreshBuildFloors()
		
	self.TowerFolder:SetAttribute("Owner", owner.UserId)
	self.State.Active = true
end


function Tower:_SetupRooms(towerData: TowerData)
	-- rooms
	for _, serializedRoomData: SerializedRoom in towerData.rooms do
		self:CreateRoom(serializedRoomData)
	end
end


function Tower:_SetupSpawn()
	local owner: Player = self.Owner
	local towerModel: Model = self.TowerFolder:FindFirstChild("Tower")
	local spawnLocation = towerModel:WaitForChild("SpawnLocation")
	owner.RespawnLocation = spawnLocation
	if owner.Character then
		owner.Character:MoveTo(spawnLocation.Position + Vector3.new(0, 5, 0))
	end
end


--------------------------------------------------
-- ACTIONS -- 
--------------------------------------------------

function Tower:CreateRoom(roomData: SerializedRoom)
	local roomId = roomData.id 
	if self.Rooms[roomId] then
		warn("[AddRoom] roomID already exists:", roomId, "for", roomData)
		return
	end
	
	local room: Room = Room.new(self, roomData, self.Services)
	if not room then
		warn("[AddRoom] Failed to create room:", roomData)
		return
	end	
	
	self.Trove:Add(room)
	self.Rooms[roomId] = room
	
	print("[AddRoom] Added room:", roomId, room)
end

function Tower:AddRoom(columnIndex: number): Room?
	-- valid column check
	if not table.find(self:GetBuildableColumns(), columnIndex) then
		warn("[AddRoom] Invalid column index:", columnIndex)
		return
	end
	
	local roomData: SerializedRoom = {
		id = HttpService:GenerateGUID(false),
		floor = self:GetColumnTopFloor(columnIndex) + 1,
		column = columnIndex,
		state = "Empty"
	}
	table.insert(self.TowerData.rooms, roomData)
	self:CreateRoom(roomData)
	self:RefreshColumnBuildFloor(columnIndex)
	
	return self.Rooms[roomData.id]
end


function Tower:RefreshColumnBuildFloor(columnIndex: number)
	print("[RefreshColumnBuildFloor] Refreshing build floor for column:", columnIndex)
	local nextFloor = self:GetColumnTopFloor(columnIndex) + 1
	local floorCap = 10 -- TODO: derive 
	
	local columnBoundsPart = self.TowerFolder.Tower.ColumnBoundParts:FindFirstChild(tostring(columnIndex))
	if not columnBoundsPart then warn("[_Setup] No columnBoundsPart found for column:", columnIndex) return end

	local slot = self.BuildFloors[columnIndex]
	if nextFloor > floorCap then
		warn("Floor cap reached for column:", columnIndex)
		if slot then
			slot:Destroy()
			self.BuildFloors[columnIndex] = nil
		end
		return
	end

	local towerModel: Model = self.TowerFolder.Tower
	if not slot then
		slot = RoomAssets.RoomCellTemplate:Clone()
		slot.Name = "BuildFloor"
		slot:AddTag("BuildFloor")
		slot:SetAttribute("Column", columnIndex)
		slot.Parent = towerModel.Rooms
		self.Trove:Add(slot)
		self.BuildFloors[columnIndex] = slot
	end

	-- position
	slot:PivotTo(TowerUtil.getCellPivot(columnBoundsPart, nextFloor))

	slot:SetAttribute("Floor", nextFloor)
	slot:SetAttribute("Price", self.Services.TowerService:GetFloorPrice(self.Owner, columnIndex, nextFloor))
end




function Tower:RefreshBuildFloors()
	for _, columnIndex in self:GetBuildableColumns() do
		self:RefreshColumnBuildFloor(columnIndex)
	end
end

function Tower:UpdateOwnerDisplay()
	local owner: Player = self.Owner
	local towerModel: Model = self.TowerFolder:FindFirstChild("Tower")
	local towerComponents = towerModel:WaitForChild("Components")

	-- 
	local NUMERALS = {"I", "II", "III"}
	local playerRank, rankTier = "Bronze", 1 -- TODO: read player ranking info
	local rankColor = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(209, 49, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(93, 52, 25))
	}


	-- billboard
	local billboardGui = towerComponents.OwnerBillboard.BillboardGui
	local nameLabel = billboardGui.Display.NameLabel
	local avatarDisplay = billboardGui.Display.AvatarDisplay
	local rankDisplay = billboardGui.Display.RankDisplay
	local rankLabel = rankDisplay.RankLabel

	nameLabel.Text = owner.DisplayName

	local playerUserId = owner.UserId
	if playerUserId < 0 then playerUserId = 1 end -- fallback
	local success, playerThumbnail = pcall(function()
		return Players:GetUserThumbnailAsync(playerUserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	end)
	if success then
		avatarDisplay.Image = playerThumbnail
		avatarDisplay.Visible = true
	end

	rankLabel.Text = string.format("%s %s", playerRank, NUMERALS[rankTier])
	rankLabel.UIGradient.Color = rankColor

	-- tower sign

end

--------------------------------------------------
-- HELPERS -- 
--------------------------------------------------

function Tower:GetColumnTopFloor(columnIndex: number): number
	local topFloor = 0
	for _, roomData: SerializedRoom in self.TowerData.rooms do
		if roomData.column == columnIndex and roomData.floor > topFloor then
			topFloor = roomData.floor
		end
	end
	return topFloor
end

function Tower:GetBuildableColumns(): {number}
	return {-1, 1} -- TODO: lane unlock rule (adjacency / purchases) lands here, one place
end


function Tower:Destroy()
	self.Trove:Destroy()
	self.TowerFolder:SetAttribute("Owner", nil)
	print("[Tower] Tower destroyed:", self.TowerFolder.Name)
end


export type Tower = typeof(setmetatable({} :: {
	Services: {},
	Owner: Player,
	TowerFolder: Folder,
	TowerData: TowerData,
	State: {},
	Rooms: {[string]: Room},
	Lobby: Lobby,
	Elevator: Elevator,
	
}, Tower))

return Tower