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


local GameAssets = ReplicatedStorage:WaitForChild("GameAssets")

-- Tower Assets
local TowersFolder = workspace.PlayerTowers
local TowerAssets = GameAssets.TowerAssets

local RoomAssets = GameAssets.RoomAssets
local RoomUtil = require(RoomAssets.RoomUtil)
local RoomDefinitions = require(RoomAssets.RoomDefinitions)

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local remotes = {}

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
}



--------------------------------------------------
-- VARIABLES --
--------------------------------------------------

-- Constants

--------------------------------------------------
-- PRIVATE FUNCTIONS --
--------------------------------------------------


--------------------------------------------------
-- PUBLIC FUNCTIONS --
--------------------------------------------------

function TowerController:OpenTowerView(towerFolder: Folder)
	
end

--------------------------------------------------
-- MAIN --
--------------------------------------------------

function TowerController:Init(controllers)
	self.Controllers = controllers

end

function TowerController:Start()
	
	
end


return TowerController