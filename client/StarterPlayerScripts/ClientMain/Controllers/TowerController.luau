local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Observers = require(ReplicatedStorage.Packages.Observers)
local Trove = require(ReplicatedStorage.Packages.Trove)
local Abbreviate = require(ReplicatedStorage.Packages.Abbreviate)

--------------------------------------------------
-- DEPENDENCIES -- 
--------------------------------------------------

local player = Players.LocalPlayer
local playerGui = player.PlayerGui

-- UI
local Popups = playerGui:WaitForChild("Popups")


-- Tower Assets
local TowersFolder = workspace.PlayerTowers
local GameAssets = ReplicatedStorage:WaitForChild("GameAssets")
local TowerAssets = GameAssets.TowerAssets

local RoomAssets = GameAssets.RoomAssets
local RoomUtil = require(RoomAssets.RoomUtil)
local RoomDefinitions = require(RoomAssets.RoomDefinitions)
local RoomModels = RoomAssets.RoomModels
local RoomDisplays = RoomAssets.RoomDisplays
local RoomBillboards = RoomAssets.RoomBillboards


local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local remotes = {
	BuildFloor = remotesFolder.Tower.BuildFloor,
	AssignRoomType = remotesFolder.Tower.AssignRoomType,
	DemolishRoom = remotesFolder.Tower.DemolishRoom,


	-- RFs
	GetTower = remotesFolder.Tower.GetTower,
}

--------------------------------------------------
-- TYPES -- 
--------------------------------------------------

type RoomDefinition = RoomDefinitions.RoomDefinition

--------------------------------------------------
-- STATE --
--------------------------------------------------
local TowerController = {}
TowerController.Controllers = {}
TowerController.Signals = {
	TowerAssigned = Signal.new(),
}


local buildPromptConnections = {} :: {RBXScriptConnection}

--------------------------------------------------
-- VARIABLES --
--------------------------------------------------

-- Constants

--------------------------------------------------
-- PRIVATE FUNCTIONS --
--------------------------------------------------

local function promptBuildFloor(roomCell: Model)
	-- cleanup
	for _, connection in buildPromptConnections do
		connection:Disconnect()
	end
	table.clear(buildPromptConnections)

	-- check if this is a build floor
	if not roomCell:HasTag("BuildFloor") then warn("[promptBuildFloor] This is not a build floor") return end
	
	local price = roomCell:GetAttribute("Price")
	if not price then warn("[promptBuildFloor] No floor price found for room cell: " .. roomCell) return end

	local columnIndex = tonumber(roomCell.Parent.Parent.Name)
	if not columnIndex then warn("[promptBuildFloor] No column index found for room cell: " .. roomCell) return end

	local buildFloorFrame = Popups.BuildFloor
	local priceLabel = buildFloorFrame.PriceLabel
	local optionsDisplay = buildFloorFrame.Options
	local confirmButton = optionsDisplay.ConfirmButton
	local cancelButton = optionsDisplay.CancelButton

	priceLabel.Text = string.format("Cost: $%s", Abbreviate.AbbreviateNumber(price, 1))
	
	table.insert(buildPromptConnections, confirmButton.Activated:Connect(function()
		remotes.BuildFloor:FireServer(columnIndex)
		buildFloorFrame.Visible = false
	end))
	
	table.insert(buildPromptConnections, cancelButton.Activated:Connect(function()
		buildFloorFrame.Visible = false
	end))
	
	buildFloorFrame.Visible = true
end

local function mountBuildFloor(roomCell: Model, isOwner: boolean)
	local trove = Trove.new()
	
	if isOwner then
		local buildRoomBillboard = RoomBillboards.BuildRoom:Clone()
		local roomBoundsPart: Part = roomCell:WaitForChild("RoomBoundsPart")
		buildRoomBillboard.Adornee = roomBoundsPart
		buildRoomBillboard.Parent = player.PlayerGui
		trove:Add(buildRoomBillboard)
		
		local button = buildRoomBillboard:WaitForChild("Button")
		
		trove:Connect(button.Activated, function()
			promptBuildFloor(roomCell)
			print("Build Floor")
		end)
	end
	
	return function() trove:Destroy() end 
end

local function mountRoofDisplay(roomCell: Model, isOwner: boolean)
	local trove = Trove.new()


	return function() trove:Destroy() end 
end

local function mountAssignTypeButton(roomCell: Model)
	local trove = Trove.new()
	
	local assignRoomTypeBillboard = RoomBillboards.AssignRoomType:Clone()
	local roomBoundsPart: Part = roomCell:WaitForChild("RoomBoundsPart")
	assignRoomTypeBillboard.Adornee = roomBoundsPart
	assignRoomTypeBillboard.Parent = player.PlayerGui
	trove:Add(assignRoomTypeBillboard)

	local button = assignRoomTypeBillboard:WaitForChild("Button")

	trove:Connect(button.Activated, function()
		-- TODO: show room type selection UI
		print("Assign Room Type")
	end)
	
	return function() trove:Destroy() end 
end

local function mountRoom(roomCell: Model, isOwner: boolean)
	local trove = Trove.new()
	
	-- show room roof info display
	trove:Add(mountRoofDisplay(roomCell, isOwner))

	if isOwner then
		trove:Add(Observers.observeAttribute(roomCell, "State", function(state)
			if state == "Empty" then
				return mountAssignTypeButton(roomCell)
			end
		end))
	end

	return function() trove:Destroy() end 
end

local function _setupTowers()
	Observers.observeTag("TowerFolder", function(towerFolder: Folder)
		
		return Observers.observeAttribute(towerFolder, "Owner", function(ownerUserId)
			local trove = Trove.new()
			local isOwner = ownerUserId == player.UserId
			
			trove:Add(Observers.observeTag("RoomCell", function(roomCell: Model)
				return mountRoom(roomCell, isOwner)
			end, {towerFolder}))
			
			trove:Add(Observers.observeTag("BuildFloor", function(roomCell: Model)
				return mountBuildFloor(roomCell, isOwner)
			end, {towerFolder}))
		end)
	end)
end

--------------------------------------------------
-- PUBLIC FUNCTIONS --
--------------------------------------------------

function TowerController:GetTowerFolder(): Folder
	local towerAssigned: number = player:GetAttribute("TowerAssigned")
	if not towerAssigned then
		warn("[GetTowerFolder] No tower number assigned")
		return
	end
	
	local towerFolder = TowersFolder:FindFirstChild(tostring(towerAssigned))
	if not towerFolder then
		warn("[GetTowerFolder] No tower folder found for", towerAssigned)
	end
	
	return towerFolder
end

--------------------------------------------------
-- MAIN --
--------------------------------------------------

function TowerController:Init(controllers)
	self.Controllers = controllers

end

function TowerController:Start()
	_setupTowers()
	
	
	
end


return TowerController