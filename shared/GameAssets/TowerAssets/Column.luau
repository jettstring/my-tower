local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Trove = require(ReplicatedStorage.Packages.Trove)

--------------------------------------------------
-- DEPENDENCIES -- 
--------------------------------------------------

local ProfileTemplate = require(ReplicatedStorage.Modules.ProfileTemplate)


local GameAssets = ReplicatedStorage.GameAssets

-- Build Assets
local BuildAssets = GameAssets.BuildAssets
local BuildUtil = require(BuildAssets.BuildUtil)

-- Tower Assets
local TowersFolder = workspace.PlayerTowers
local TowerAssets = GameAssets.TowerAssets
local Tower = require(TowerAssets.Tower)
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
type Lobby = Lobby.Lobby

--------------------------------------------------
-- MAIN -- 
--------------------------------------------------

local Column = {}
Column.__index = Column

function Column.new(tower: Tower, columnIndex: number, columnData: ColumnData, services)
	local self = setmetatable({}, Column)
	
	return self
end

export type Column = typeof(setmetatable({} :: {}, Column))

return Column
