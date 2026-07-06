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

-- Room Assets
local RoomAssets = GameAssets.RoomAssets
local RoomDefinitions = require(RoomAssets.RoomDefinitions)
local RoomModels = RoomAssets.RoomModels
local LobbyModels = RoomAssets.LobbyModels

-- Utils
local RoomUtil = require(ReplicatedStorage.GameAssets.RoomAssets.RoomUtil)

--------------------------------------------------
-- TYPES -- 
--------------------------------------------------

type Profile = ProfileTemplate.ProfileTemplate
type TowerData = ProfileTemplate.TowerData
type ColumnData = ProfileTemplate.ColumnData
type ElevatorData = ProfileTemplate.ElevatorData
type SerializedRoom = ProfileTemplate.SerializedRoom

type Tower = Tower.Tower

--------------------------------------------------
-- MAIN -- 
--------------------------------------------------


ResidentialRoom = {}
ResidentialRoom.__index = ResidentialRoom

function ResidentialRoom.new(tower: Tower, serializedRoom: SerializedRoom, services)
	local self = setmetatable({}, ResidentialRoom)
	
	self.Trove = Trove.new()
	self.Services = services
	self.Tower = tower
	self.SerializedRoomData = serializedRoom
	
	self:_Setup()
	
	return self
end


--------------------------------------------------
-- SETUP -- 
--------------------------------------------------

function ResidentialRoom:_Setup()
	local towerFolder: Folder = self.Tower.TowerFolder
	local towerModel: Model = towerFolder.Tower
	local roomData: SerializedRoom = self.SerializedRoomData
	
	local roomCellModel = RoomAssets.RoomTemplate:Clone()
	
	local roomModel = RoomUtil.getRoomModel(roomData.roomDefKey)
	if not roomModel then
		warn("[ResidentialRoom] No room model found for key: " .. roomData.roomDefKey)
		return
	end
	
	-- place room model
	local roomClone = roomModel:Clone()
	
end

--------------------------------------------------
-- ACTIONS -- 
--------------------------------------------------

function ResidentialRoom:Destroy()
	self.Trove:Destroy()
end

export type ResidentialRoom = typeof(setmetatable({} :: {}, ResidentialRoom))

return ResidentialRoom
