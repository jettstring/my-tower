local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Trove = require(ReplicatedStorage.Packages.Trove)

--------------------------------------------------
-- DEPENDENCIES -- 
--------------------------------------------------

local GameAssets = ReplicatedStorage:WaitForChild("GameAssets")

-- Plot Assets
local BaseAssets = GameAssets.Plot

--------------------------------------------------
-- TYPES -- 
--------------------------------------------------


--------------------------------------------------
-- MAIN -- 
--------------------------------------------------

local Plot = {}
Plot.__index = Plot

function Plot.new(ownerPlayer: Player, PlotFolder: Folder, services: any)
	local self = setmetatable({}, Plot)
	self.Services = services

	self.Owner = ownerPlayer
	self.PlotFolder = PlotFolder
	self.Trove = Trove.new()

	self.State = {
		Active = false,
	}

	self:_Setup()
	if not self.State.Active then
		warn("Plot is not active, destroying")
		self:Destroy()
		return nil
	end

	return self
end

--------------------------------------------------
-- SETUP -- 
--------------------------------------------------

function Plot:_Setup()
	local owner: Player = self.Owner
	local PlotModel = self.PlotFolder:FindFirstChild("Plot")
	
	
	
	self.PlotFolder:SetAttribute("Owner", owner.UserId)
	self.State.Active = true
end

--------------------------------------------------
-- ACTIONS -- 
--------------------------------------------------


function Plot:Destroy()
	self.Trove:Destroy()
	self.PlotFolder:SetAttribute("Owner", nil)
	print("[Plot] Plot destroyed:", self.PlotFolder.Name)
end

--------------------------------------------------
-- HELPERS -- 
--------------------------------------------------



export type PlotObject = typeof(setmetatable({} :: {
	Owner: Player,
	PlotFolder: Folder,
	State: {},
}, Plot))

return Plot