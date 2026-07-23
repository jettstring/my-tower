--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameAssets = ReplicatedStorage:WaitForChild("GameAssets")

export type Room = {
	displayName: string,
	displayImage: string, 
}

export type Residential = {
	roomType: "Residential",
	displayName: string,
}

export type Commercial = {
	roomType: "Commercial",
	displayName: string,
	category: "Food" | "Retail" | "Service" | "Recreation",
	stockItems: { StockDefinition },
}

export type StockDefinition = {
	displayName: string,
	displayImage: string,
	cost: number,
	stockTime: number,
	quantity: number,
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
			} :: Residential,

			["Modern Apartments"] = {
				roomType = "Residential",
				displayName = "Modern Apartments",
			} :: Residential,
		}
	},

	Commercial = {
		displayName = "Commercial",
		rooms = {
			
			-- [FOOD] --
			
			["Cafe"] = {
				roomType = "Commercial",
				displayName = "Cafe",
				category = "Food",
				stockItems = {
					{ displayName = "Coffee", displayImage = "79575738222080", cost = 10, stockTime = 10, quantity = 50 },
					{ displayName = "Bagel", displayImage = "110424742559084", cost = 25, stockTime = 10, quantity = 30 },
					{ displayName = "Sandwich", displayImage = "107040465106427", cost = 50, stockTime = 10, quantity = 15 },
				}
			} :: Commercial,
			
			-- [RETAIL] -- 
			
			["Retail place #1"] = {
				roomType = "Commercial",
				displayName = "Retail buiz",
				category = "Retail",
			} :: Commercial,
			
			-- [RECREATION] -- 
			
			["Recreation place #1"] = {
				roomType = "Commercial",
				displayName = "Recreation buiz",
				category = "Recreation",
			} :: Commercial,
			
			-- [SERVICE] -- 
			
			["Service place #1"] = {
				roomType = "Commercial",
				displayName = "Service buiz",
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