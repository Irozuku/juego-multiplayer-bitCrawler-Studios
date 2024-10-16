extends Node2D

@onready var p1 = $Players/Player1
@onready var p2 = $Players/Player2
@onready var camera1 = $Players/Player1/Camera2D
@onready var camera2 = $Players/Player2/Camera2D
@onready var door = $Door

func _ready():
	door.register_players([p1.get_instance_id(), p2.get_instance_id()])
	for player in Game.players:
		if player.role == 1:
			p1.setup(player)
			if player.id == multiplayer.get_unique_id():
				p1.set_multiplayer_authority(player.id)
				camera1.make_current()
		if player.role == 2:
			p2.setup(player)
			if player.id == multiplayer.get_unique_id():
				p2.set_multiplayer_authority(player.id)
				camera2.make_current()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("door"):
		if p1.has_multiplayer_authority():
			door.handle_door_input(p1)
		elif p2.has_multiplayer_authority():
			door.handle_door_input(p2)
