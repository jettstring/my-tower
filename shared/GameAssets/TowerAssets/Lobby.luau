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

type Elevator = Elevator.Elevator

--------------------------------------------------
-- MAIN -- 
--------------------------------------------------


local Lobby = {}
Lobby.__index = Lobby

function Lobby.new(column, columnData, services)
	local self = setmetatable({}, Lobby)
	
	self.Trove = Trove.new()
	
	self.Column = column
	self.ColumnData = columnData
	self.Services = services
	
	print("[Lobby] Created Lobby:", self)
	return self
end


--------------------------------------------------
-- SETUP -- 
--------------------------------------------------


--------------------------------------------------
-- ACTIONS -- 
--------------------------------------------------

function Lobby:Destroy()
	self.Trove:Destroy()
end

export type Lobby = typeof(setmetatable({} :: {}, Lobby))

return Lobby
