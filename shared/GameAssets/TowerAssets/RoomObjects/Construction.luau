--------------------------------------------------
-- MAIN -- 
--------------------------------------------------

local ConstructionRoom = {}
ConstructionRoom.__index = ConstructionRoom

function ConstructionRoom.new()
	local self = setmetatable({}, ConstructionRoom)
	
	return self
end

--------------------------------------------------
-- SETUP -- 
--------------------------------------------------



--------------------------------------------------
-- ACTIONS -- 
--------------------------------------------------

export type ConstructionRoom = typeof(setmetatable({} :: {}, ConstructionRoom))

return ConstructionRoom
