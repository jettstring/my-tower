local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileTemplate = {
	TowerData = {} :: TowerData,
}

export type ProfileTemplate = typeof(ProfileTemplate) 


export type SerializedRoom = {
	id: string,
	roomName: string,
	column: number,
	floor: number,
}

export type ElevatorData = {
	speedLevel: number,
	elevatorSkin: string?,
}

export type ColumnData = {
	elevator: ElevatorData,
	lobbyOccupants: {},
	lobbySkin: string?,
}

export type TowerData = {
	rooms: { SerializedRoom },
	columns: {[number]: ColumnData}
}

return ProfileTemplate
