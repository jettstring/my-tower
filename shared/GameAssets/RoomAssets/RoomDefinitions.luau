local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameAssets = ReplicatedStorage:WaitForChild("GameAssets")
local BuildAssets = GameAssets.BuildAssets

export type StockItem = {} -- TODO

export type Room = {
	displayName: string,
	displayImage: string, 
}

export type Residential = Room & {
	roomType: "Residential",
}

export type Commercial = Room & {
	roomType: "Commercial",
	category: "Food" | "Retail" | "Service" | "Recreation",
	products: { [string]: StockItem },
	maxWorkers: number,
}

export type RoomDefinition = Residential | Commercial

export type RoomType = {
	displayName: string, 
	rooms: { [string]: RoomDefinition },
}

local ResidentialRooms: {[string]: Residential} = {
	
	["Rustic Apartments"] = {
		roomType = "Residential",
		displayName = "Rustic Apartments",
		displayImage = "",
	},
	
	["Modern Apartments"] = {
		roomType = "Residential",
		displayName = "Modern Apartments",
		displayImage = "",
	},
	
}

local CommercialRooms: {[string]: Residential} = {

}

local ByRoomType: { [string]: RoomType } = {
	
}

local ByName = {}
for _, group in ByRoomType do
	for name, def in group.rooms do
		ByName[name] = def
	end
end

return {
	ByRoomType = ByRoomType,
	ByName = ByName,
}