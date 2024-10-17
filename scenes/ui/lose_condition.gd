extends Control

@onready var lose_container: PanelContainer = %LoseContainer
@onready var retry_button: Button = %RetryButton
@onready var main_menu_button: Button = %MainMenuButton

@export var lobby_scene: PackedScene
signal retry

func _ready() -> void:
	retry_button.pressed.connect(_on_retry_pressed)
	#main_menu_button.pressed.connect(_on_main_menu_pressed)

func _on_retry_pressed():
	if is_multiplayer_authority():
		get_tree().paused = false
		retry_game.rpc()

@rpc("any_peer", "call_local", "reliable")
func retry_game():
	emit_signal("retry")

#func _on_main_menu_pressed():
	#if is_multiplayer_authority():
		#get_tree().paused = false
		#back_to_menu.rpc()
#
#@rpc("any_peer", "call_local", "reliable")
#func back_to_menu():
	#if get_multiplayer_authority() == 1:
		## we wait 1 second for the other player to go back to the lobby and
		## then we close his connection
		#await get_tree().create_timer(1).timeout
		#multiplayer.multiplayer_peer.close()
	#Debug.log("Going to main menu")
	#get_tree().change_scene_to_packed.call_deferred(lobby_scene)
