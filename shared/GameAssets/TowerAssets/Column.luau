local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Trove = require(ReplicatedStorage.Packages.Trove)

--------------------------------------------------
-- DEPENDENCIES -- 
--------------------------------------------------

local ProfileTemplate = require(ReplicatedStorage.Modules.ProfileTemplate)


local GameAssets = ReplicatedStorage.GameAssets

-- Tower Assets
local TowersFolder = workspace.PlayerTowers
local TowerAssets = GameAssets.TowerAssets
local Elevator = require(TowerAssets.Elevator)
local Lobby = require(TowerAssets.Lobby)
local TowerUtil = require(TowerAssets.TowerUtil)
local Room = require(TowerAssets.Room)

-- Room Assets
local RoomAssets = GameAssets.RoomAssets
local RoomDefinitions = require(RoomAssets.RoomDefinitions)
local RoomModels = RoomAssets.RoomModels
local LobbyModels = RoomAssets.LobbyModels
local RoomUtil = require(RoomAssets.RoomUtil)


--------------------------------------------------
-- TYPES -- 
--------------------------------------------------

type Profile = ProfileTemplate.ProfileTemplate
type TowerData = ProfileTemplate.TowerData
type ColumnData = ProfileTemplate.ColumnData
type LobbyData = ProfileTemplate.LobbyData
type ElevatorData = ProfileTemplate.ElevatorData
type SerializedRoom = ProfileTemplate.SerializedRoom

type Lobby = Lobby.Lobby
type Elevator = Elevator.Elevator
type Room = Room.Room

--------------------------------------------------
-- MAIN -- 
--------------------------------------------------

local Column = {}
Column.__index = Column

function Column.new(tower, columnIndex: number, columnData: ColumnData, services)
	local self = setmetatable({}, Column)
	self.Services = services
	self.Trove = Trove.new()
	
	self.Tower = tower
	self.ColumnIndex = columnIndex
	self.ColumnData = columnData
	
	self.Lobby = Lobby.new(self, self.ColumnData, self.Services)
	self.Elevator = Elevator.new(self, self.ColumnData, self.Services)
	self.Trove:Add(self.Lobby)
	self.Trove:Add(self.Elevator)
	
	self:RefreshBuildFloor()

	print("[Column] Created column:", self)
	return self
end


--------------------------------------------------
-- SETUP -- 
--------------------------------------------------


--------------------------------------------------
-- ACTIONS -- 
--------------------------------------------------

function Column:RefreshBuildFloor()
	local nextFloor = self:GetTopFloor() + 1
	local floorCap = 10 -- TODO: Derive floor cap
	
	if nextFloor > floorCap then
		warn("[Column] Floor cap reached:", nextFloor)
		return
	end
	
	
	local towerFolder: Folder = self.Tower.TowerFolder
	local towerModel: Model = towerFolder.Tower
	local columnFolder = towerModel.Columns:FindFirstChild(self.ColumnIndex)
	local lobbyModel: Model = columnFolder.Lobby
	
	local buildFloor = self.BuildFloor
	if not buildFloor then
		local cellModel = RoomAssets.RoomCellTemplate:Clone()
		cellModel.Name = "BuildFloor"
		cellModel.Parent = columnFolder.Rooms
		cellModel:AddTag("BuildFloor")
		self.Trove:Add(cellModel)
		self.BuildFloor = cellModel
		buildFloor = cellModel
		
		
		-- get construction room model
	end
	
	-- position in tower column
	local roomBoundsPart = buildFloor.RoomBoundsPart
	local roomHeight = roomBoundsPart.Size.Y
	local position = TowerUtil.getCellPivot(lobbyModel, nextFloor, roomHeight)
	buildFloor:PivotTo(position)
	
	local floorPrice = self.Services.TowerService:GetFloorPrice(self.Tower.Owner, self.ColumnIndex, nextFloor)
	buildFloor:SetAttribute("Price", floorPrice)
end

--------------------------------------------------
-- HELPERS -- 
--------------------------------------------------

function Column:GetTopFloor(): number
	local topFloor = 0
	for _, roomData: SerializedRoom in self.Tower.TowerData.rooms do
		if roomData.column == self.ColumnIndex and roomData.floor > topFloor then
			topFloor = roomData.floor
		end
	end
	return topFloor
end

function Column:GetColumnRooms(): {Room}
	local columnIndex = self.ColumnIndex
	
	local columnRooms = {}
	for _, room: Room in self.Tower.Rooms do
		if room.RoomData and room.RoomData.column == columnIndex then
			table.insert(columnRooms, room)
		end
	end
	
	table.sort(columnRooms, function(a, b)
		return a.RoomData.floor < b.RoomData.floor
	end)

	return columnRooms
end


export type Column = typeof(setmetatable({} :: {
	ColumnData: ColumnData,
	ColumnIndex: number,
	Tower: any,
	Lobby: Lobby,
	Elevator: Elevator,
}, Column))

return Column
