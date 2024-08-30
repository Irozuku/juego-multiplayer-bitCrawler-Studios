extends Node2D

@onready var p1 = $Player1
@onready var p2 = $Player2

func _ready():
	for player in Game.players:
		if player.role == 1:
			p1.setup(player)
		if player.role == 2:
			p2.setup(player)
