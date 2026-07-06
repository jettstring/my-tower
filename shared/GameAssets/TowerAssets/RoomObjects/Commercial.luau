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
local Tower = require(TowerAssets.Tower)
local Column = require(TowerAssets.Column)
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
type ElevatorData = ProfileTemplate.ElevatorData
type SerializedRoom = ProfileTemplate.SerializedRoom

type Tower = Tower.Tower
type Column = Column.Column
type Elevator = Elevator.Elevator
type Lobby = Lobby.Lobby

type RoomDefinition = RoomDefinitions.RoomDefinition

--------------------------------------------------
-- MAIN -- 
--------------------------------------------------

local ResidentialRoom = {}
ResidentialRoom.__index = ResidentialRoom

function ResidentialRoom.new(tower: Tower, serializedRoomData: SerializedRoom, services)
	local self = setmetatable({}, ResidentialRoom)
	
	self.Trove = Trove.new()
	self.Services = services
	
	self.Tower = tower
	self.RoomData = serializedRoomData

	self:_Setup()
	
	return self
end


--------------------------------------------------
-- SETUP -- 
--------------------------------------------------

function ResidentialRoom:_Setup()
	
end

--------------------------------------------------
-- ACTIONS -- 
--------------------------------------------------


--------------------------------------------------
-- HELPERS -- 
--------------------------------------------------

export type ResidentialRoom = typeof(setmetatable({} :: {}, ResidentialRoom))

return ResidentialRoom
