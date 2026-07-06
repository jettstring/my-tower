local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileTemplate = {
	
	Money = 1000,
	
	TowerData = {
		rooms = {
			{
				id = "firstRoomEva",
				roomDefKey = "Rustic Apartments",
				column = 1,
				floor = 1,
				customName = nil,
				customRoomColors = nil,
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

	
	customName: string,
	customRoomColors: {[string]: Color3},
	
}

export type ConstructionCell = {
	floor: number,
	column: number,
	state: "Constructing" | "Empty",
	constructionTime: number,
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
