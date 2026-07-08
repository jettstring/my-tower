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
type ColumnData = ProfileTemplate.ColumnData
type ElevatorData = ProfileTemplate.ElevatorData
type SerializedRoom = ProfileTemplate.SerializedRoom

type Tower = Tower.Tower
type Room = Room.Room

type RoomDefinition = RoomDefinitions.RoomDefinition

--------------------------------------------------
-- MAIN -- 
--------------------------------------------------

local Commercial = {}
Commercial.__index = Commercial

function Commercial.new(room: Room)
	local self = setmetatable({}, Commercial)

	self.Trove = room.Trove:Extend()
	self.Services = room.Services

	self.Room = room


	return self
end


--------------------------------------------------
-- SETUP -- 
--------------------------------------------------


--------------------------------------------------
-- ACTIONS -- 
--------------------------------------------------

function Commercial:Destroy()
	self.Trove:Destroy()
end

export type Commercial = typeof(setmetatable({} :: {}, Commercial))

return Commercial
