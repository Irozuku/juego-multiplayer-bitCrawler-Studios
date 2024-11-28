extends CanvasLayer

@onready var next: Button = $Control/PanelContainer/VBoxContainer/VBoxContainer/Next
@onready var main_menu: Button = $Control/PanelContainer/VBoxContainer/VBoxContainer/MainMenu
@onready var quit: Button = $Control/PanelContainer/VBoxContainer/VBoxContainer/Quit


func _ready():
	AudioMaster.play_music_victory()
	next.pressed.connect(_on_next_level)
	main_menu.pressed.connect(_on_main_menu_pressed)
	quit.pressed.connect(_on_quit_pressed)

func _on_next_level():
	# Next Level
	change_to_next_level_scene.rpc()

func _on_main_menu_pressed():
	# Disconnect from multiplayer and then switch to the main menu
	disconnect_multiplayer_and_change_scene()

func _on_quit_pressed():
	get_tree().quit()

# Make the function asynchronous
func disconnect_multiplayer_and_change_scene() -> void:
	var multiplayer_api = get_tree().get_multiplayer()  # Get the Multiplayer API
	
	if multiplayer_api.multiplayer_peer:
		# Close the connection (server or client)
		multiplayer_api.multiplayer_peer.close()
		multiplayer_api.multiplayer_peer = null  # Clean up

	# Wait for a frame to ensure proper cleanup before changing scenes
	await get_tree().process_frame
	await get_tree().process_frame

	# Now switch to the main menu
	change_to_main_menu_scene()

@rpc("any_peer", "call_local", "reliable")
func change_to_main_menu_scene():
	# Change the scene to the main menu
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")

@rpc("any_peer", "call_local", "reliable")
func change_to_next_level_scene():
	LevelManager.load_next_level()
