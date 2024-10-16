extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]

var players = []
var finish = 0
var is_open: bool = false

func register_players(player_list: Array):
	players = player_list

func _ready():
	animation_tree.active = true

func _on_Door_body_entered(body: Node2D) -> void:
	if body.get_instance_id() in players:
		body.is_overDoor = true
		open_door()

func _on_Door_body_exited(body: Node2D) -> void:
	if body.get_instance_id() in players:
		body.is_overDoor = false
		close_door()

#animation
func open_door():
	if not is_open and any_player_over_door():
		playback.travel("Open")
		is_open = true

func close_door():
	if is_open and not any_player_over_door():
		playback.travel("Close")
		is_open = false

func any_player_over_door() -> bool:
	for player_id in players:
		var player = instance_from_id(player_id)
		if player and player.is_overDoor:
			return true
	return false

func handle_door_input(player: Node2D):
	if player.is_overDoor and not player.is_hidden:
		rpc("player_entered_door", player.name)
	elif player.is_hidden:
		rpc("player_exited_door", player.name)

@rpc("any_peer", "call_local", "reliable")
func player_entered_door(player_name: String) -> void:
	var player = get_node("/root/Main/Players/" + player_name)
	if player:
		player.is_hidden = true
		player.hide()
		player.set_physics_process(false)
		for child in player.get_children():
			if child is CollisionShape2D:
				child.set_deferred("disabled", true)
		finish += 1
		if finish == 2:
			print("Level Pass")
			#await get_tree().create_timer(0.4).timeout
			get_tree().change_scene_to_file("res://scenes/win.tscn")

@rpc("any_peer", "call_local", "reliable")
func player_exited_door(player_name: String) -> void:
	var player = get_node("/root/Main/Players/" + player_name)
	if player:
		player.is_hidden = false
		player.show()
		player.set_physics_process(true)
		for child in player.get_children():
			if child is CollisionShape2D:
				child.set_deferred("disabled", false)
		finish -= 1
