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

local Construction = {}
Construction.__index = Construction

function Construction.new(room: Room)
	local self = setmetatable({}, Construction)

	self.Trove = room.Trove:Extend()
	self.Services = room.Services

	self.Room = room
	
	self:_UpdateAttributes()
	
	if room.RoomData.state == "Constructing" and room.RoomData.constructionEndTime then
		self:_RunTimer(room.RoomData.constructionEndTime)
	end

	return self
end

--------------------------------------------------
-- ACTIONS -- 
--------------------------------------------------

function Construction:_UpdateAttributes()
	local room: Room = self.Room
	local roomData: SerializedRoom = room.RoomData
	local cellModel = room.CellModel
	
	cellModel:SetAttribute("ConstructionEndsAt", roomData.constructionEndTime)
end

function Construction:StartConstruction(roomDefKey: string)
	local room: Room = self.Room
	if room.RoomData.state ~= "Empty" then warn("Room is not empty") return end
	
	local roomDef: RoomDefinition? = RoomDefinitions.ByName[roomDefKey]
	if not roomDef then warn("No room def for key: " .. roomDefKey) return end
		
	room.RoomData.roomDefKey = roomDefKey
	room.RoomData.constructionEndTime = os.time() + 10 -- TODO: derive build time
	room:SetState("Constructing")
	
	self:_RunTimer(room.RoomData.constructionEndTime)
end

function Construction:CompleteConstruction()
	local room: Room = self.Room
	room.RoomData.constructionEndTime = nil
	room:SetState("Occupied")
end

--------------------------------------------------
-- PRIVATE -- 
--------------------------------------------------

function Construction:_RunTimer(endTimestamp: number)
	local remaining = endTimestamp - os.time()
	if remaining <= 0 then
		self:CompleteConstruction()
		return
	end
	
	self.Trove:Add(task.delay(remaining, function()
		self:CompleteConstruction()
	end))
end


function Construction:Destroy()
	local room: Room = self.Room
	local cellModel = room.CellModel
	cellModel:SetAttribute("ConstructionEndsAt", nil)
	
	self.Trove:Destroy()
end

export type Construction = typeof(setmetatable({} :: {
    Room: Room,
}, Construction))

return Construction
