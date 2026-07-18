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
type SlotStockData  = ProfileTemplate.SlotStockData

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
-- ACTIONS -- 
--------------------------------------------------

function Commercial:_UpdateAttributes()
	local room: Room = self.Room
	local roomData: SerializedRoom = room.RoomData
	local cellModel = room.CellModel

	for slot = 1, 3 do
		local stockSlot: SlotStockData = roomData.stockSlots[slot]
		cellModel:SetAttribute("StockAmount" .. slot, stockSlot.amount)
		cellModel:SetAttribute("RestockEndsAt" .. slot, stockSlot.restockEndsAt)
		cellModel:SetAttribute("SlotStaffed" .. slot, room.Tower:GetWorkerAtSlot(room.RoomId, slot))
	end
end


--------------------------------------------------
-- HELPERS -- 
--------------------------------------------------

function Commercial:Destroy()
	local room: Room = self.Room
	local cellModel = room.CellModel
	for slot = 1, 3 do
		cellModel:SetAttribute("StockAmount" .. slot, nil)
		cellModel:SetAttribute("RestockEndsAt" .. slot, nil)
		cellModel:SetAttribute("SlotStaffed" .. slot, nil)
	end

	self.Trove:Destroy()
end


export type Commercial = typeof(setmetatable({} :: {}, Commercial))

return Commercial
