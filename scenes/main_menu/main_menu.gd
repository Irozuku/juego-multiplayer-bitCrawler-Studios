extends Control

@onready var start = %Start
@onready var credits = %Credits
@onready var exit = %Exit
@onready var tutorial = %Tutorial


# Called when the node enters the scene tree for the first time.
func _ready():
	if Game.multiplayer_test:
		get_tree().change_scene_to_file.call_deferred("res://scenes/lobby_test.tscn")
		return
	start.pressed.connect(_on_start_pressed)
	credits.pressed.connect(_on_credits_pressed)
	exit.pressed.connect(_on_exit_pressed)
	AudioMaster.play_music_mainmenu()

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")

func _on_credits_pressed():
	get_tree().change_scene_to_file("res://scenes/credits/GodotCredits.tscn")

func _on_exit_pressed():
	get_tree().quit()
