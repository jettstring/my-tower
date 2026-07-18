local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

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
local assignTypePromptConnections = {} :: {RBXScriptConnection}

--------------------------------------------------
-- VARIABLES --
--------------------------------------------------

-- Constants

--------------------------------------------------
-- PRIVATE FUNCTIONS --
--------------------------------------------------

local function promptAssignType(roomCell: Model)
	-- cleanup
	for _, connection in assignTypePromptConnections do
		connection:Disconnect()
	end
	table.clear(assignTypePromptConnections)

	-- check if this is a empty room cell
	if not roomCell:HasTag("RoomCell") or roomCell:GetAttribute("State") ~= "Empty" then warn("[promptAssignType] This is not a empty rom") return end

	local roomId = roomCell:GetAttribute("RoomId")
	if not roomId then warn("[promptAssignType] No room ID found for room cell: ", roomCell) return end
	
	local assignRoomTypeFrame = Popups.AssignRoomType
	local closeButton = assignRoomTypeFrame.Close
	local typeButtons = assignRoomTypeFrame.RoomTypeButtons
	local residentialButton = typeButtons.Residential
	local commercialButtonsContainer = typeButtons.Commercial.ButtonContainer
	
	local buttonContainers = { residentialButton }
	for _, typeContainer in commercialButtonsContainer:GetChildren() do
		if typeContainer:IsA("Frame") then table.insert(buttonContainers, typeContainer) end
	end
	
	for _, buttonContainer in buttonContainers do
		local button = buttonContainer.Button
		table.insert(assignTypePromptConnections, button.Activated:Connect(function()
			remotes.AssignRoomType:FireServer(roomId, buttonContainer.Name)
			assignRoomTypeFrame.Visible = false
		end))
	end
	
	table.insert(assignTypePromptConnections, closeButton.Activated:Connect(function()
		assignRoomTypeFrame.Visible = false
	end))
	
	assignRoomTypeFrame.Visible = true	
end

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

	local columnIndex = roomCell:GetAttribute("Column")
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

local function mountAssignTypeButton(roomCell: Model)
	local trove = Trove.new()

	local assignRoomTypeBillboard = RoomBillboards.AssignRoomType:Clone()
	local roomBoundsPart: Part = roomCell:WaitForChild("RoomBoundsPart")
	assignRoomTypeBillboard.Adornee = roomBoundsPart
	assignRoomTypeBillboard.Parent = player.PlayerGui
	trove:Add(assignRoomTypeBillboard)

	local button = assignRoomTypeBillboard:WaitForChild("Button")

	trove:Connect(button.Activated, function()
		promptAssignType(roomCell)
	end)

	return function() trove:Destroy() end 
end

local function mountConstructionTimer(roomCell: Model, isOwner: boolean)
	return Observers.observeAttribute(roomCell, "ConstructionEndsAt", function(endsAt: number)
		local trove = Trove.new()

		local billboard = trove:Add(RoomBillboards.ConstructionProgressDisplay:Clone())
		billboard.Adornee = roomCell:WaitForChild("RoomBoundsPart")
		billboard.Parent = playerGui

		local timerLabel = billboard.TimerLabel
		local skipButton = billboard.SkipButton

		if isOwner then
			trove:Connect(skipButton.Activated, function()
				remotes.SkipConstruction:FireServer(roomCell:GetAttribute("RoomId"))
			end)
		else
			skipButton:Destroy()
		end

		local lastShown = -1
		trove:Connect(RunService.Heartbeat, function()
			local remaining = math.max(0, math.floor(endsAt - workspace:GetServerTimeNow()))
			if remaining ~= lastShown then
				lastShown = remaining
				timerLabel.Text = string.format("%02dM %02dS", math.floor(remaining / 60), remaining % 60)
			end
		end)

		return function() trove:Destroy() end
	end)
end

local function mountStockSlots(roomCell: Model, roofDisplay: SurfaceGui)
	local trove = Trove.new()
	
	local stockStatusDisplay = trove:Add(RoomAssets.RoofDisplay.StockStatusDisplay:Clone())
	stockStatusDisplay.Parent = roofDisplay
	stockStatusDisplay.Visible = true
	
	-- remove existing ui instances
	for _, imageLabel in stockStatusDisplay:QueryDescendants("ImageLabel") do imageLabel:Destroy() end
	
	for slotIndex = 1, 3 do
		local currentIconState: string? = nil
		local iconTrove = trove:Extend()
		
		local function updateStockIcon()
			local stockAmount = roomCell:GetAttribute("StockAmount" .. slotIndex) or 0
			local restocking = roomCell:GetAttribute("RestockEndsAt" .. slotIndex) ~= nil
			local iconState = restocking and "Restocking" or (stockAmount > 0 and "Selling" or "OutOfStock")
			
			if iconState == currentIconState then return end
			if iconTrove then iconTrove:Clean() end
			currentIconState = iconState
			
			local slotFrame = iconTrove:Add(RoomAssets.RoofDisplay.StockStatusDisplay.UIListLayout.StockSlotTemplate:Clone())
			slotFrame.Name = slotIndex
			slotFrame.Parent = stockStatusDisplay
			slotFrame.LayoutOrder = slotIndex
			slotFrame.Visible = true
		end
		
		trove:Connect(roomCell:GetAttributeChangedSignal("RestockEndsAt" .. slotIndex), updateStockIcon)
		trove:Connect(roomCell:GetAttributeChangedSignal("StockAmount" .. slotIndex), updateStockIcon)
		updateStockIcon()
	end
	
	return function() trove:Destroy() end
end

local function mountRoofDisplay(roomCell: Model, isOwner: boolean)
	return Observers.observeAttribute(roomCell, "State", function(state: string)
		
		local roofPart = roomCell:FindFirstChild("Roof")
		if not roofPart then return end
		
		local trove = Trove.new()
		local roofDisplay = trove:Add(RoomAssets.RoofDisplay:Clone())
		roofDisplay.Parent = roofPart
		roofDisplay.Adornee = roofPart
		roofDisplay.Enabled = true
		
		local roomNameLabel = roofDisplay.RoomNameLabel
		local residentsCountDisplay = roofDisplay.ResidentsCountDisplay
		local stockStatusDisplay = roofDisplay.StockStatusDisplay
		
		stockStatusDisplay:Destroy()
		residentsCountDisplay:Destroy()
		
		if state == "Constructing" then
			
		elseif state ~= "Empty" then
			trove:Add(Observers.observeAttribute(roomCell, "RoomDefKey", function(roomDefKey: string)
				local roomDef: RoomDefinition = RoomDefinitions.ByName[roomDefKey]
				if not roomDef then warn("No roomDef found for key", roomDefKey) return end
				
				local defTrove = Trove.new()
				
				-- custom name
				roomNameLabel.Text = roomDef.displayName
				defTrove:Add(Observers.observeAttribute(roomCell, "CustomName", function(customName: string)
					roomNameLabel.Text = customName or roomDef.displayName
					return function()
						roomNameLabel.Text = roomDef.displayName
					end
				end))
				
				if roomDef.roomType == "Residential" then
					
				elseif roomDef.roomType == "Commercial" then
					defTrove:Add(mountStockSlots(roomCell, roofDisplay))
				end
				
				return function () defTrove:Destroy() end
			end))
		end


		return function() trove:Destroy() end 
	end)
end

local function mountRoom(roomCell: Model, isOwner: boolean)
	local trove = Trove.new()
	
	-- show room roof info display
	trove:Add(mountRoofDisplay(roomCell, isOwner))
	trove:Add(mountConstructionTimer(roomCell, isOwner))

	
	trove:Add(Observers.observeAttribute(roomCell, "State", function(state)
		if state == "Empty" then
			if isOwner then
				return mountAssignTypeButton(roomCell)
			end
		elseif state == "Constructing" then
		elseif state == "Occupied" then
		end
	end))

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
			
			return function() trove:Destroy() end 
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