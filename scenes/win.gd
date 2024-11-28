extends CanvasLayer

@onready var next = $PanelContainer/VBoxContainer/VBoxContainer/Next
@onready var main_menu = $PanelContainer/VBoxContainer/VBoxContainer/MainMenu
@onready var quit = $PanelContainer/VBoxContainer/VBoxContainer/Quit

func _ready():
	AudioMaster.play_music_victory()
	next.pressed.connect(_on_next_level)
	main_menu.pressed.connect(_on_main_menu_pressed)
	quit.pressed.connect(_on_quit_pressed)

func _on_next_level():
	#Next Level
	change_to_tutorial_scene.rpc()

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")

func _on_quit_pressed():
	get_tree().quit()

@rpc("any_peer", "call_local", "reliable")
func change_to_tutorial_scene():
	LevelManager.load_next_level()
