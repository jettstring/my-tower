local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Signal = require(ReplicatedStorage.Packages.Signal)
local Trove = require(ReplicatedStorage.Packages.Trove)


--------------------------------------------------
-- DEPENDENCIES -- 
--------------------------------------------------

local GameAssets = ReplicatedStorage:WaitForChild("GameAssets")

local PlotFolder = workspace.PlotFolder

-- Plot Assets
local BaseAssets = GameAssets.Plot
local Plot = require(BaseAssets.Plot)

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local remotes = {
	
	-- RFs
	GetPlot = remotesFolder.Plot.GetPlot,
}

--------------------------------------------------
-- TYPES -- 
--------------------------------------------------

type Plot = Plot.PlotObject

--------------------------------------------------
-- STATE --
--------------------------------------------------
local PlotService = {} 
PlotService.Services = {}
PlotService.Signals = {
	PlotAssigned = Signal.new(),
}

PlotService.ClaimedPlots = {} :: {[Folder]: Player}
PlotService.PlotObjects = {} :: {[Player]: Plot}

--------------------------------------------------
-- VARIABLES --
--------------------------------------------------

-- Constants

--------------------------------------------------
-- PRIVATE FUNCTIONS --
--------------------------------------------------

local function cleanupPlot(plotFolder: Folder) 
	
end

local function _setupPlots() 

end

local function _playerRemoved(player: Player)
	local plot: Plot = PlotService.PlotObjects[player]
	if plot then
		local plotFolder = plot.PlotFolder
		cleanupPlot(plotFolder)
		plot:Destroy()
		PlotService.PlotObjects[player] = nil
	end
end

--------------------------------------------------
-- PUBLIC FUNCTIONS --
--------------------------------------------------

function PlotService:AssignPlot(player: Player)
	if not player then return end
	
	-- already assigned guard
	if self.ClaimedPlots[player] then
		warn("Player already has a plot")
		return
	end
	
	
	-- find first available plot folder
	for i = 1, #PlotFolder:GetChildren() do
		local plotFolder = PlotFolder:FindFirstChild(tostring(i))
		if not plotFolder then continue end
		if self.ClaimedPlots[plotFolder] then continue end

		-- create new plot object for player
		local playerPlot: Plot = Plot.new(player, plotFolder, self.Services)
		if playerPlot == nil then 
			warn("[AssignPlot] Failed to create base for player:", player.Name)
			return
		end
		self.ClaimedPlots[plotFolder] = player
		self.PlotObjects[player] = playerPlot

		self.Signals.PlotAssigned:Fire(player, playerPlot)
		player:SetAttribute("PlotAssigned", i)
		
		print("[AssignPlot] Assigned plot to player:", player.Name, "Plot:", plotFolder.Name)
		return 
	end
end

function PlotService:GetPlot(player: Player): Plot?
	return self.PlotObjects[player]
end


--------------------------------------------------
-- MAIN --
--------------------------------------------------

function PlotService:Init(services)
	self.Services = services
	
	_setupPlots()
end

function PlotService:Start()
	
	self.Services.DataService.Signals.DataLoaded:Connect(function(player: Player)
		PlotService:AssignPlot(player)
	end)
	
	Players.PlayerRemoving:Connect(_playerRemoved)
	
end


return PlotService