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
type ColumnData = ProfileTemplate.ColumnData
type LobbyData = ProfileTemplate.LobbyData
type ElevatorData = ProfileTemplate.ElevatorData
type SerializedRoom = ProfileTemplate.SerializedRoom

type Lobby = Lobby.Lobby
type Elevator = Elevator.Elevator

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
	

	print("[Column] Created column:", self)
	return self
end


--------------------------------------------------
-- HELPERS -- 
--------------------------------------------------

function Column:Refresh()
	
end

function Column:GetColumnRooms(): {}
	local columnIndex = self.ColumnIndex
	
	local columnRooms = {}
	for _, room in self.Tower.Rooms do
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
