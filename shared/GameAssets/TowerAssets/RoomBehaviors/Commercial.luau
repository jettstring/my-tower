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
	self.StockItemFolder = self:_SetupStockItemFolder()
	
	-- write empty stock slots
	room.RoomData.stockSlots = room.RoomData.stockSlots or {}
	for slot = 1, 3 do
		if not room.RoomData.stockSlots[slot] then
			room.RoomData.stockSlots[slot] = {
				amount = 0,
			}
		end
	end
	
	-- start commercial loop
	self.Trove:Add(task.spawn(function()
		while true do
			task.wait(1)
			self:_Tick()
		end
	end))

	self:_UpdateAttributes()

	return self
end
--------------------------------------------------
-- ACTIONS -- 
--------------------------------------------------

function Commercial:_SetupStockItemFolder(): Folder
	local folder = self.Trove:Add(Instance.new("Folder"))
	folder.Name = "StockItems"
	folder.Parent = self.Room.CellModel
	
	for slotIndex = 1, 3 do
		local slotFolder = Instance.new("Folder")
		slotFolder.Name = slotIndex
		slotFolder.Parent = folder
	end
	
	return folder
end

function Commercial:_UpdateAttributes()
	local room: Room = self.Room
	local tower: Tower = room.Tower
	local roomData: SerializedRoom = room.RoomData
	local cellModel = room.CellModel

	local workers = tower:GetWorkers(room.RoomId)
	for slotIndex = 1, 3 do
		local stockFolder = self.StockItemFolder:FindFirstChild(slotIndex)
		if not stockFolder then warn("[_UpdateAttributes] missing stock folder for slot:", slotIndex) continue end
		
		local stockSlot: SlotStockData = roomData.stockSlots[slotIndex]
		local worker = workers[slotIndex]
		
		stockFolder:SetAttribute("SlotWorkerId", worker and worker.ResidentData.id or nil)
		stockFolder:SetAttribute("StockAmount", stockSlot.amount)
		stockFolder:SetAttribute("RestockEndsAt", stockSlot.restockEndsAt)
		stockFolder:SetAttribute("RestockTime", self.Services.TowerService:GetRestockTime(tower.Owner, room.RoomId, slotIndex))
		stockFolder:SetAttribute("RestockQuantity", self.Services.TowerService:GetRestockQuantity(tower.Owner, room.RoomId, slotIndex))
		stockFolder:SetAttribute("RestockCost", self.Services.TowerService:GetRestockCost(tower.Owner, room.RoomId, slotIndex))
		stockFolder:SetAttribute("Earnings", self.Services.TowerService:GetStockEarnings(tower.Owner, room.RoomId, slotIndex))
	end
end

function Commercial:_Tick()
	local room: Room = self.Room
	local tower: Tower = room.Tower
	local roomData: SerializedRoom = room.RoomData
	
	local now = os.time()
	local changed = false
	
	for slotIndex = 1, 3 do
		local stockSlotData: SlotStockData = roomData.stockSlots[slotIndex]
		
		-- restock check
		if stockSlotData.restockEndsAt and now >= stockSlotData.restockEndsAt then
			self:RestockItem(slotIndex)
			changed = true
		end
		
		-- stock sale
		if stockSlotData.amount > 0 and not stockSlotData.restockEndsAt and tower:GetWorkers(room.RoomId)[slotIndex] then
			self:SellStock(slotIndex, 1)
			changed = true
		end
		
	end
	
	if changed then 
		self:_UpdateAttributes()
	end
end

function Commercial:SellStock(slotIndex: number, amount: number)
	local room: Room = self.Room
	local tower: Tower = room.Tower
	local roomData: SerializedRoom = room.RoomData
	
	local stockSlotData: SlotStockData = roomData.stockSlots[slotIndex]
	if not stockSlotData then warn("[SellStock] invalid slot") return end
	
	local amount = math.min(amount, stockSlotData.amount)
	stockSlotData.amount -= amount
	self:_UpdateAttributes()
	
	local earnings = self.Services.TowerService:GetStockEarnings(tower.Owner, room.RoomId, slotIndex) 
	self.Services.DataService:IncrementCurrency(tower.Owner, "Money", earnings, "Stock Sold", true)
end

function Commercial:RestockItem(slotIndex: number)
	local room: Room = self.Room
	local tower: Tower = room.Tower
	local roomData: SerializedRoom = room.RoomData
	
	local stockSlotData: SlotStockData = roomData.stockSlots[slotIndex]
	if not stockSlotData then warn("[Restock] invalid slot") return end
	
	local restockQuantity = self.Services.TowerService:GetRestockQuantity(tower.Owner, room.RoomId, slotIndex)
	if not restockQuantity then warn("[Restock] invalid restock quantity") return end
	
	stockSlotData.amount = restockQuantity
	if stockSlotData.restockEndsAt then stockSlotData.restockEndsAt = nil end
	
	self:_UpdateAttributes()
end

--------------------------------------------------
-- HELPERS -- 
--------------------------------------------------

function Commercial:Destroy()
	local room: Room = self.Room
	local cellModel = room.CellModel
	--for slot = 1, 3 do
	--	cellModel:SetAttribute("StockAmount" .. slot, nil)
	--	cellModel:SetAttribute("RestockEndsAt" .. slot, nil)
	--	cellModel:SetAttribute("SlotWorkerId" .. slot, nil)
	--end

	self.Trove:Destroy()
end


export type Commercial = typeof(setmetatable({} :: {
	StockItemFolder: Folder
}, Commercial))

return Commercial
