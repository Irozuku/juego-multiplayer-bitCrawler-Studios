extends Node2D

@onready var p1 = $Player1
@onready var p2 = $Player2
@onready var camera1 = $Player1/Camera2D
@onready var camera2 = $Player2/Camera2D

func _ready():
	for player in Game.players:
		if player.role == 1:
			p1.setup(player)
			if player.id == multiplayer.get_unique_id():
				camera1.make_current()
		if player.role == 2:
			p2.setup(player)
			if player.id == multiplayer.get_unique_id():
				camera2.make_current()
