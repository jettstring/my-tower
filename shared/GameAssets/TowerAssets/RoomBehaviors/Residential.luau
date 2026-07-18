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
local TowerUtil = require(TowerAssets.TowerUtil)
local Room = require(TowerAssets.Room)

-- Room Assets
local RoomAssets = GameAssets.RoomAssets
local RoomDefinitions = require(RoomAssets.RoomDefinitions)
local RoomUtil = require(RoomAssets.RoomUtil)

--------------------------------------------------
-- TYPES -- 
--------------------------------------------------

type Profile = ProfileTemplate.ProfileTemplate
type TowerData = ProfileTemplate.TowerData
type ElevatorData = ProfileTemplate.ElevatorData
type SerializedRoom = ProfileTemplate.SerializedRoom

type Tower = Tower.Tower
type Room = Room.Room

type RoomDefinition = RoomDefinitions.RoomDefinition

--------------------------------------------------
-- MAIN -- 
--------------------------------------------------

local Residential = {}
Residential.__index = Residential

function Residential.new(room: Room)
	local self = setmetatable({}, Residential)
	
	self.Trove = room.Trove:Extend()
	self.Services = room.Services
	
	self.Room = room
	
	return self
end

--------------------------------------------------
-- ACTIONS -- 
--------------------------------------------------

function Residential:_UpdateAttributes()
	local room: Room = self.Room
	local roomData: SerializedRoom = room.RoomData
	local cellModel = room.CellModel
	
	cellModel:SetAttribute("OccupantCount", #room.Tower:GetOccupants(room.RoomId))
end


--------------------------------------------------
-- HELPERS -- 
--------------------------------------------------

function Residential:Destroy()
	local room: Room = self.Room
	local cellModel = room.CellModel
	cellModel:SetAttribute("OccupantCount", nil)
	
	self.Trove:Destroy()
end

export type Residential = typeof(setmetatable({} :: {}, Residential))

return Residential
