--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameAssets = ReplicatedStorage:WaitForChild("GameAssets")

export type StockItem = {} -- TODO

export type Room = {
	displayName: string,
	displayImage: string, 
}

export type Residential = {
	roomType: "Residential",
	displayName: string,
	displayImage: string,
}

export type Commercial = {
	roomType: "Commercial",
	displayName: string,
	displayImage: string,
	category: "Food" | "Retail" | "Service" | "Recreation",
	products: { [string]: StockItem },
	maxWorkers: number,
}

export type RoomDefinition = Residential | Commercial

export type RoomType = {
	displayName: string, 
	rooms: { [string]: RoomDefinition },
}



local Rooms: { [string]: RoomType } = {

	Residential = {
		displayName = "Residential",
		rooms = {
			["Rustic Apartments"] = {
				roomType = "Residential",
				displayName = "Rustic Apartments",
				displayImage = "",
			} :: Residential,

			["Modern Apartments"] = {
				roomType = "Residential",
				displayName = "Modern Apartments",
				displayImage = "",
			} :: Residential,
		}
	},

	Commercial = {
		displayName = "Commercial",
		rooms = {
			
			-- [FOOD] --
			
			["Food place #1"] = {
				roomType = "Commercial",
				displayName = "Food buiz",
				displayImage = "",
				category = "Food",
			} :: Commercial,
			
			-- [RETAIL] -- 
			
			["Retail place #1"] = {
				roomType = "Commercial",
				displayName = "Retail buiz",
				displayImage = "",
				category = "Retail",
			} :: Commercial,
			
			-- [RECREATION] -- 
			
			["Recreation place #1"] = {
				roomType = "Commercial",
				displayName = "Recreation buiz",
				displayImage = "",
				category = "Recreation",
			} :: Commercial,
			
			-- [SERVICE] -- 
			
			["Service place #1"] = {
				roomType = "Commercial",
				displayName = "Service buiz",
				displayImage = "",
				category = "Service",
			} :: Commercial,

		}
	}
}



local ByName = {}
for _, group in Rooms do
	for name, def in group.rooms do
		ByName[name] = def
	end
end

-- Roll buckets: "Residential", "Food", "Retail", "Service", "Recreation"
local RollBuckets: { [string]: { string } } = {}
for _, group in Rooms do
	for name, def in group.rooms do
		local key = if def.roomType == "Commercial" then def.category else def.roomType
		local bucket = RollBuckets[key]
		if not bucket then
			bucket = {}
			RollBuckets[key] = bucket
		end
		table.insert(bucket, name)
	end
end

return {
	ByRoomType = Rooms,
	ByName = ByName,
	RollBuckets = RollBuckets,
}