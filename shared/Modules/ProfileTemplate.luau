local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileTemplate = {
	Money = 10000,
	Gems = 0,
	
	TowerData = {
		rooms = {
			{
				id = "1234",
				roomDefKey = "Rustic Apartments",
				state = "Occupied",
				column = 1,
				floor = 1,
				customName = nil,
				customRoomColors = nil,
			},
			{
				id = "54321",
				roomDefKey = "Food place #1",
				state = "Occupied",
				column = -1,
				floor = 1,
				customName = nil,
				customRoomColors = nil,
			},
		},
		
		elevatorData = {
			speedLevel = 1,
			elevatorSkin = nil,
		},
		
		lobbyData = {
			lobbyOccupants = {},
			lobbySkin = nil,
		},
		
		residents = {
			{
				id = "1",
				name = "Jett",
				skills = {
					Food = 1,
					Retail = 1,
					Service = 1,
					Recreation = 1,
				},
				dreamJob = "Food",
				homeRoomId = "1234",
				jobRoomId = "54321",
				jobSlot = 1,
			}
		},
		
	} :: TowerData,
	
}

export type ProfileTemplate = typeof(ProfileTemplate) 

export type TowerData = {
	rooms: { SerializedRoom },
	residents: { ResidentData },
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
	stockSlots: { [number]: SlotStockData }?,
}

export type ElevatorData = {
	speedLevel: number,
	elevatorSkin: string?,
}

export type LobbyData = {
	lobbyOccupants: {},
	lobbySkin: string?,
}

export type SlotStockData = {
	amount: number,
	restockEndsAt: number?,
}

export type ResidentData = {
	id: string,
	name: string,
	skills: {[string]: number},
	dreamJob: string?,
	
	homeRoomId: string?, -- residential room,
	jobRoomId: string?, -- commercial room
	jobSlot: number?, -- 1..3 
}


return ProfileTemplate
