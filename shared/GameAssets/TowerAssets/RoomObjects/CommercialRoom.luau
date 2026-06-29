local ResidentialRoom = {}
ResidentialRoom.__index = ResidentialRoom

function ResidentialRoom.new()
	local self = setmetatable({}, ResidentialRoom)
	
	return self
end

export type ResidentialRoom = typeof(setmetatable({} :: {}, ResidentialRoom))

return ResidentialRoom
