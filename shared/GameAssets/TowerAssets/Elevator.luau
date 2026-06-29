local Elevator = {}
Elevator.__index = Elevator

function Elevator.new()
	local self = setmetatable({}, Elevator)
	
	return self
end

export type Elevator = typeof(setmetatable({} :: {}, Elevator))

return Elevator
