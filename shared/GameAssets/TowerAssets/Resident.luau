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
local Room = require(TowerAssets.Room)

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

type Room = Room.Room

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
	
	-- skills
	for skillName, value in pairs(residentData.skills) do
		residentFolder:SetAttribute(skillName, value)
	end
end

--------------------------------------------------
-- ACTIONS -- 
--------------------------------------------------

function Resident:AssignHome(roomId: string)
	local residentData: ResidentData = self.ResidentData
	
	if roomId == residentData.homeRoomId then return end

	if roomId == nil or roomId == "" then
		warn("[AssignHome] Invalid room ID for home assignment")
		return
	end
	
	-- validate new room
	local newRoom: Room = self.Tower.Rooms[roomId]
	if not newRoom then warn("[AssignHome] Room not found for ID: " .. roomId) return end
	
	-- cap check
	if #self.Tower:GetOccupants(roomId) >= 5 then warn("[AssignHome] Room is full") return end
	
	local oldRoomId = residentData.homeRoomId
	local oldRoom: Room? = oldRoomId and self.Tower.Rooms[oldRoomId]
	
	-- update
	residentData.homeRoomId = roomId
	self:_UpdateAttributes()
	if oldRoom then oldRoom:_UpdateAttributes() end
	newRoom:_UpdateAttributes()
end

function Resident:AssignJob(roomId: string | nil)
	local residentData: ResidentData = self.ResidentData

end


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
