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
local RoomObjects = TowerAssets.RoomObjects

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

--------------------------------------------------
-- MAIN -- 
--------------------------------------------------

local Tower = {}
Tower.__index = Tower

function Tower.new(ownerPlayer: Player, TowerFolder: Folder, services: any)
	local self = setmetatable({}, Tower)
	self.Services = services

	self.Owner = ownerPlayer
	self.TowerFolder = TowerFolder
	self.Trove = Trove.new()

	self.State = {
		Active = false,
	}
	
	self.Rooms = {}       -- { [id]: Room } -- flat table of all rooms
	self.RoomsByCell = {} -- { [floor]: { [column]: Room } } derived spatial index of rooms
	self.Columns = {}     -- { [number]: Column }


	self:_Setup()
	if not self.State.Active then
		warn("Tower is not active, destroying")
		self:Destroy()
		return nil
	end

	return self
end

--------------------------------------------------
-- SETUP -- 
--------------------------------------------------

function Tower:_Setup()
	local owner: Player = self.Owner
	local towerModel: Model = self.TowerFolder:FindFirstChild("Tower")
	
	-- Assign spawn to owner
	local spawnLocation = towerModel:WaitForChild("SpawnLocation")
	owner.RespawnLocation = spawnLocation
	if owner.Character then
		owner.Character:MoveTo(spawnLocation.Position + Vector3.new(0, 5, 0))
	end

	-- setup components
	self:_SetupSpawn()
	self:UpdateOwnerDisplay()
	
	
	-- hydrate tower from profile
	local profile: Profile = self.Services.DataService:GetProfile(owner)
	if not profile then warn("[_Setup] No profile found for player") return end
	local towerData: TowerData = profile.TowerData
	self:_SetupColumns(towerData)
	self:_SetupRooms(towerData)
	
	
	self.TowerFolder:SetAttribute("Owner", owner.UserId)
	self.State.Active = true
end


function Tower:_SetupColumns(towerData: TowerData)
	
end

function Tower:_SetupRooms(towerData: TowerData)

end

function Tower:_SetupSpawn()
	local owner: Player = self.Owner
	local towerModel: Model = self.TowerFolder:FindFirstChild("Tower")
	local spawnLocation = towerModel:WaitForChild("SpawnLocation")
	owner.RespawnLocation = spawnLocation
	if owner.Character then
		owner.Character:MoveTo(spawnLocation.Position + Vector3.new(0, 5, 0))
	end
end


--------------------------------------------------
-- ACTIONS -- 
--------------------------------------------------

function Tower:AddRoom(serializedRoom: SerializedRoom)
	
end

function Tower:UpdateOwnerDisplay()
	local owner: Player = self.Owner
	local towerModel: Model = self.TowerFolder:FindFirstChild("Tower")
	local towerComponents = towerModel:WaitForChild("Components")
	
	-- 
	local NUMERALS = {"I", "II", "III"}
	local playerRank, rankTier = "Bronze", 1 -- TODO: read player ranking info
	local rankColor = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(209, 49, 0)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(93, 52, 25))
	}
	
	
	-- billboard
	local billboardGui = towerComponents.OwnerBillboard.BillboardGui
	local nameLabel = billboardGui.Display.NameLabel
	local avatarDisplay = billboardGui.Display.AvatarDisplay
	local rankDisplay = billboardGui.Display.RankDisplay
	local rankLabel = rankDisplay.RankLabel
	
	nameLabel.Text = owner.DisplayName
	
	local playerUserId = owner.UserId
	if playerUserId < 0 then playerUserId = 1 end -- fallback
	local success, playerThumbnail = pcall(function()
		return Players:GetUserThumbnailAsync(playerUserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	end)
	if success then
		avatarDisplay.Image = playerThumbnail
		avatarDisplay.Visible = true
	end

	rankLabel.Text = string.format("%s %s", playerRank, NUMERALS[rankTier])
	rankLabel.UIGradient.Color = rankColor
	
	
	-- tower sign
	
end

function Tower:Destroy()
	self.Trove:Destroy()
	self.TowerFolder:SetAttribute("Owner", nil)
	print("[Tower] Tower destroyed:", self.TowerFolder.Name)
end

--------------------------------------------------
-- HELPERS -- 
--------------------------------------------------

export type Tower = typeof(setmetatable({} :: {
	Services: {},
	Owner: Player,
	TowerFolder: Folder,
	State: {},
}, Tower))

return Tower