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
local TowerUtil = require(TowerAssets.TowerUtil)

-- Room Assets
local RoomAssets = GameAssets.RoomAssets
local RoomDefinitions = require(RoomAssets.RoomDefinitions)

-- NPC Assets
local NPCAssets = GameAssets.NPCAssets

--------------------------------------------------
-- TYPES -- 
--------------------------------------------------

type Profile = ProfileTemplate.ProfileTemplate
type ResidentData = ProfileTemplate.ResidentData
type TowerData = ProfileTemplate.TowerData
type ElevatorData = ProfileTemplate.ElevatorData
type SerializedRoom = ProfileTemplate.SerializedRoom

type RoomDefinition = RoomDefinitions.RoomDefinition

--------------------------------------------------
-- MAIN -- 
--------------------------------------------------


local Resident = {}
Resident.__index = Resident

function Resident.new(tower, residentData: ResidentData, services)
	local self = setmetatable({}, Resident)
	
	self.Services = services
	self.Trove = Trove.new()

	self.Tower = tower
	self.ResidentData = residentData
	self.Folder = self:_SetupFolder()
	
	self:_UpdateAttributes()
	
	return self
end



--------------------------------------------------
-- SETUP -- 
--------------------------------------------------

function Resident:_SetupFolder(): Folder
	local residentData: ResidentData =  self.ResidentData
	local residentFolder = self.Trove:Add(Instance.new("Folder"))
	residentFolder.Name = residentData.id
	residentFolder.Parent = workspace.NPCs.Residents
	
	return residentFolder
end

--------------------------------------------------
-- STATE --
--------------------------------------------------

function Resident:_UpdateAttributes()
	local residentData: ResidentData = self.ResidentData
	local residentFolder: Folder = self.Folder
	
	residentFolder:SetAttribute("Name", residentData.name)
	residentFolder:SetAttribute("DreamJob", residentData.dreamJob)
	residentFolder:SetAttribute("HomeRoomId", residentData.homeRoomId)
	residentFolder:SetAttribute("JobRoomId", residentData.jobRoomId)
	residentFolder:SetAttribute("JobSlot", residentData.jobSlot)
	
	-- stats
	for statName, statValue in pairs(residentData.stats) do
		residentFolder:SetAttribute(statName, statValue)
	end
end

--------------------------------------------------
-- ACTIONS -- 
--------------------------------------------------

function Resident:Destroy()
	self.Trove:Destroy()
end

export type Resident = typeof(setmetatable({} :: {
	Services: any,
	Tower: any,
	ResidentData: ResidentData,
	Folder: Folder,
	
}, Resident))

return Resident
