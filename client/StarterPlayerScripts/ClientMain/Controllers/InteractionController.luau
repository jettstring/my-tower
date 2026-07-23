local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Trove = require(ReplicatedStorage.Packages.Trove)
local Observers = require(ReplicatedStorage.Packages.Observers)

--------------------------------------------------
-- DEPENDENCIES -- 
--------------------------------------------------

local player = Players.LocalPlayer
local playerGui = player.PlayerGui
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

-- inputs
local inputs = ReplicatedStorage:WaitForChild("Inputs")
local towerInteractionContext = inputs.TowerInteraction
local interactObject = towerInteractionContext.InteractObject

local remotesFolder = ReplicatedStorage:WaitForChild("Remotes")
local remotes = {}

--------------------------------------------------
-- TYPES -- 
--------------------------------------------------


--------------------------------------------------
-- STATE --
--------------------------------------------------
local InteractionController = {}
InteractionController.Controllers = {}
InteractionController.Signals = {}

local trove = Trove.new()

--------------------------------------------------
-- VARIABLES --
--------------------------------------------------

-- Constants

--------------------------------------------------
-- PRIVATE FUNCTIONS --
--------------------------------------------------

local function _mountTowerInteractables()
	
	local HANDLERS = {
		["RoomCell"] = function(roomCell: Model)
			print("interacted with room cell", roomCell)
			InteractionController.Controllers.TowerController:PromptRoomManagement(roomCell)
		end,
		
		["Elevator"] = function(elevator: Model)
			print("interacted with elevator", elevator)
		end,
		
		["RoofDecoration"] = function(roofDecoration: Model)
			print("interacted with roof decoration", roofDecoration)
		end,
	}
	
	local interactables: {[Instance]: string} = {}
	local interactableList: {Instance} = {}
	for tagName in HANDLERS do
		trove:Add(Observers.observeTag(tagName, function(instance: Instance)
			interactables[instance] = tagName
			table.insert(interactableList, instance)
			return function()
				interactables[instance] = nil
				local i = table.find(interactableList, instance)
				if i then table.remove(interactableList, i) end
			end
		end))
	end
	
	
	local function resolveInteractableModel(hitPart: BasePart): Model?
		local current = hitPart
		while current do
			local interactableType = interactables[current]
			if interactableType then
				return current
			end
			current = current.Parent
		end
		return nil
	end

	local function getInteractableFromMouse()
		local ray = camera:ScreenPointToRay(mouse.X, mouse.Y)
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Include
		params.FilterDescendantsInstances = interactableList

		local result = workspace:Raycast(ray.Origin, ray.Direction * 500, params)
		if result and result.Instance then
			
			-- resolve resulting model
			local model = resolveInteractableModel(result.Instance)
			if model then
				return model
			else
				return nil
			end
		end
	end

	local currentInteractable = nil
	RunService.RenderStepped:Connect(function()
		local model = getInteractableFromMouse()
		if model then
			currentInteractable = model
			mouse.Icon = "http://www.roblox.com/asset?id=105991732318156"
		else
			currentInteractable = nil
			mouse.Icon = "rbxasset://SystemCursors/Arrow"
		end
	end)
	
	
	interactObject.Pressed:Connect(function()
		if not currentInteractable then return end
		local kind = interactables[currentInteractable]
		if kind then HANDLERS[kind](currentInteractable) end
	end)
	
	
end

--------------------------------------------------
-- PUBLIC FUNCTIONS --
--------------------------------------------------

function InteractionController:PublicFoo()

end

--------------------------------------------------
-- MAIN --
--------------------------------------------------

function InteractionController:Init(controllers)
	self.Controllers = controllers
	
	_mountTowerInteractables()
end

function InteractionController:Start()

end


return InteractionController