local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileTemplate = {
	Money = 10000,
	Gems = 0,
	
	TowerData = {
		rooms = {
			--{
			--	id = "firstRoomEva",
			--	roomDefKey = "Rustic Apartments",
			--	state = "Occupied",
			--	column = 1,
			--	floor = 1,
			--	customName = nil,
			--	customRoomColors = nil,
			--},
			--{
			--	id = "secondRoomEva",
			--	roomDefKey = "Rustic Apartments",
			--	state = "Occupied",
			--	column = -1,
			--	floor = 1,
			--	customName = nil,
			--	customRoomColors = nil,
			--},
		},
		
		elevatorData = {
			speedLevel = 1,
			elevatorSkin = nil,
		},
		
		lobbyData = {
			lobbyOccupants = {},
			lobbySkin = nil,
		},
		
	} :: TowerData,
	
}

export type ProfileTemplate = typeof(ProfileTemplate) 

export type TowerData = {
	rooms: { SerializedRoom },
	elevatorData: ElevatorData,
	lobbyData: LobbyData,
}

export type SerializedRoom = {
	id: string,
	roomDefKey: string, -- room def key
	column: number,
	floor: number,
	state: "Constructing" | "Empty" | "Occupied",
	customName: string?,
	customRoomColors: {[string]: Color3}?,
	
	-- construction
	constructionEndTime: number?,
	
	-- commercial
	stockSlots: { [number]: StockData }?,
}

export type ElevatorData = {
	speedLevel: number,
	elevatorSkin: string?,
}

export type LobbyData = {
	lobbyOccupants: {},
	lobbySkin: string?,
}

export type StockData = {
	amount: number,
	restockEndsAt: number?,
}

export type ResidentData = {
	id: string,
	name: string,
	stats: {[string]: number},
	dreamJob: string?,
	
	homeRoomId: string?, -- residential room,
	jobRoomId: string?, -- commercial room
	jobSlot: number?, -- 1..3 
}


return ProfileTemplate
