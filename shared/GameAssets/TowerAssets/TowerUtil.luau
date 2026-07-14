local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameAssets = ReplicatedStorage.GameAssets

-- Tower Assets
local TowerAssets = GameAssets.TowerAssets


-- CONSTANTS -- 

local TowerUtil = {}
TowerUtil.MAX_COLUMN_ROOMS = 10

function TowerUtil.getCellPivot(lobbyModel: Model, floor: number, cellHeight: number): CFrame
	return lobbyModel:GetPivot() * CFrame.new(0, cellHeight * floor, 0)
end

return TowerUtil
