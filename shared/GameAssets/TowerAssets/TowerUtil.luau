local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameAssets = ReplicatedStorage.GameAssets

-- Tower Assets
local TowerAssets = GameAssets.TowerAssets

-- Room Assets
local RoomAssets = GameAssets.RoomAssets


-- CONSTANTS -- 

local TowerUtil = {}
TowerUtil.MAX_COLUMN_ROOMS = 10

-- TowerUtil
function TowerUtil.getCellPivot(columnBoundsPart: Part, floor: number): CFrame
	return columnBoundsPart:GetPivot() * CFrame.new(0, columnBoundsPart.Size.Y * math.max(floor - 1, 0), 0)
end

return TowerUtil
