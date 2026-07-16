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


--------------------------------------------------
-- MAIN -- 
--------------------------------------------------

local Elevator = {}
Elevator.__index = Elevator

function Elevator.new(column, towerData: ColumnData, services)
	local self = setmetatable({}, Elevator)
	
	self.Trove = Trove.new()
	self.Services = services
	
	self.Column = column
	self.ColumnData = columnData :: ColumnData
	
	print("[Elevator] Created Elevator:", self)
	return self
end

--------------------------------------------------
-- SETUP -- 
--------------------------------------------------

function Elevator:_Setup()
	local columnData: ColumnData = self.ColumnData
	local elevatorData: ElevatorData = columnData.elevatorData
	if not elevatorData then warn("[_Setup] No elevator data found") return end
	
end

--------------------------------------------------
-- ACTIONS -- 
--------------------------------------------------

function Elevator:TravelToRoom(floor: number)
	
end

function Elevator:Destroy()
	self.Trove:Destroy()
end

export type Elevator = typeof(setmetatable({} :: {}, Elevator))

return Elevator
