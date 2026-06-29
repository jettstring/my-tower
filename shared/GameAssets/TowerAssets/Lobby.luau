local Lobby = {}
Lobby.__index = Lobby

function Lobby.new()
	local self = setmetatable({}, Lobby)
	
	return self
end

export type Lobby = typeof(setmetatable({} :: {}, Lobby))

return Lobby
