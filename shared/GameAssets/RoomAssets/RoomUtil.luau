local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameAssets = ReplicatedStorage.GameAssets

-- Room Assets
local RoomAssets = GameAssets.RoomAssets
local RoomDefinitions = require(RoomAssets.RoomDefinitions)
local RoomModels = RoomAssets.RoomModels
local RoomTemplate = RoomAssets.RoomTemplate

type RoomDefinition = RoomDefinitions.RoomDefinition



local RoomUtil = {}

function RoomUtil.getRoomModel(roomDefKey: string): Model
	local roomDef: RoomDefinition = RoomDefinitions.ByName[roomDefKey]
	if not roomDef then
		warn("[getRoomModel] No room definition found for key: " .. roomDefKey)
		return
	end
	
	return RoomModels:FindFirstChild(roomDefKey)
end

return RoomUtil
