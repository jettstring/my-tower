local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileTemplate = {
	
	Money = 10000,
	
	TowerData = {
		rooms = {
			{
				id = "firstRoomEva",
				roomDefKey = "Rustic Apartments",
				state = "Occupied",
				column = 1,
				floor = 1,
				customName = nil,
				customRoomColors = nil,
			},
			{
				id = "secondRoom",
				roomDefKey = nil,
				state = "Empty",
				column = 1,
				floor = 2,
			}	
		},
		columns = {
			[1] = {
				elevatorData = {
					speedLevel = 1,
					elevatorSkin = nil,
				},
				lobbyData = {
					lobbyOccupants = {},
					lobbySkin = nil,
				},
			}
		}
	} :: TowerData,
	
}

export type ProfileTemplate = typeof(ProfileTemplate) 


export type SerializedRoom = {
	id: string,
	roomDefKey: string, -- room def key
	column: number,
	floor: number,
	state: "Constructing" | "Empty" | "Occupied",
	
	-- construction
	constructionTime: number?,
	
	customName: string?,
	customRoomColors: {[string]: Color3}?,
}

export type ElevatorData = {
	speedLevel: number,
	elevatorSkin: string?,
}

export type LobbyData = {
	lobbyOccupants: {},
	lobbySkin: string?,
}

export type ColumnData = {
	elevatorData: ElevatorData,
	lobbyData: LobbyData,
}

export type TowerData = {
	rooms: { SerializedRoom },
	columns: {[number]: ColumnData}
}

return ProfileTemplate
