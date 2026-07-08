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
local RoomBehaviors = TowerAssets.RoomBehaviors

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

type RoomDefinition = RoomDefinitions.RoomDefinition


--------------------------------------------------
-- MAIN -- 
--------------------------------------------------


local Room = {}
Room.__index = Room

function Room.new(tower, roomData: SerializedRoom, services)
	local self = setmetatable({}, Room)
	
	self.Services = services
	self.Trove = Trove.new()
	
	self.Tower = tower
	self.RoomData = roomData
	self.RoomId = roomData.id
	
	self.Behavior = nil
	self.BehaviorName = nil
	
	self:_SetupCell()
	self:_RefreshModel()
	self:SetBehavior(Room.behaviorNameFor(roomData))
	
	return self
end


function Room.behaviorNameFor(roomData: SerializedRoom): string
	if roomData.state ~= "Occupied" then
		return "Construction" -- in-construction & empty rooms
	end
	
	local roomDef: RoomDefinition = RoomDefinitions.ByName[roomData.roomDefKey]
	if not roomDef then
		warn("No room def for key: " .. roomData.roomDefKey)
		return "Construction" -- fallback 
	end
	
	return roomDef.roomType -- Residential | Commercial
end

--------------------------------------------------
-- SETUP -- 
--------------------------------------------------

function Room:_SetupCell()
	local towerFolder: Folder = self.Tower.TowerFolder
	local towerModel: Model = towerFolder.Tower
	local columnFolder = towerModel.Columns:FindFirstChild(self.RoomData.column)
	local lobbyModel: Model = columnFolder.Lobby
	
	local cellModel = RoomAssets.RoomCellTemplate:Clone()
	cellModel.Name = self.RoomId
	cellModel.Parent = columnFolder.Rooms
	self.Trove:Add(cellModel)
	self.CellModel = cellModel
	
	-- position
	local roomBoundsPart = cellModel.RoomBoundsPart
	local roomHeight = roomBoundsPart.Size.Y
	local position = lobbyModel:GetPivot() * CFrame.new(0, roomHeight * self.RoomData.floor, 0)
	cellModel:PivotTo(position)
	
	self:_UpdateAttributes()
end

function Room:_RefreshModel()
	if self.InteriorModel then
		self.InteriorModel:Destroy()
		self.InteriorModel = nil
	end
	
	local cellModel = self.CellModel
	local roomBoundsPart = cellModel.RoomBoundsPart
	
	local defKey = self.RoomData.roomDefKey
	if not defKey or self.RoomData.state ~= "Occupied" then
		return
	end
	
	local roomModel = RoomUtil.getRoomModel(defKey)
	if not roomModel then warn("No room model found for key: " .. defKey) return end
	
	local clone = roomModel:Clone()
	clone.Parent = self.CellModel
	clone:PivotTo(roomBoundsPart:GetPivot())
	self.InteriorModel = clone
end

--------------------------------------------------
-- STATE --
--------------------------------------------------

function Room:SetState(newState: string)
	local oldState = self.RoomData.state
	if oldState == newState then
		warn("Room is already in state: " .. newState)
		return
	end
	
	self.RoomData.state = newState
	self:_RefreshModel()
	self:_UpdateAttributes()
	
	local behaviorName = Room.behaviorNameFor(self.RoomData)
	if behaviorName ~= self.BehaviorName then
		self:SetBehavior(behaviorName)
	end
end


function Room:SetBehavior(behaviorName: string)
	if self.Behavior then
		self.Behavior:Destroy()
		self.Behavior = nil
	end
	
	local behaviorModule = RoomBehaviors:FindFirstChild(behaviorName)
	if not behaviorModule then
		warn("No room behavior found for: " .. behaviorName)
		return
	end
	
	self.Behavior = require(behaviorModule).new(self)
	self.BehaviorName = behaviorName
end


function Room:_UpdateAttributes()
	self.CellModel:SetAttribute("State", self.RoomData.state)
end

--------------------------------------------------
-- ACTIONS -- 
--------------------------------------------------

function Room:Demolish()
	self.RoomData.roomDefKey = nil
	self:SetState("Empty")
end

function Room:Destroy()
	self.Trove:Destroy()
end

export type Room = typeof(setmetatable({} :: {
	Services: any,
	Tower: any,
	RoomData: SerializedRoom,
	RoomId: string,
}, Room))

return Room
