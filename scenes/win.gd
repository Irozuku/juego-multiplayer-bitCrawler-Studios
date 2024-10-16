extends CanvasLayer

@onready var next = $PanelContainer/VBoxContainer/VBoxContainer/Next
@onready var main_menu = $PanelContainer/VBoxContainer/VBoxContainer/MainMenu
@onready var quit = $PanelContainer/VBoxContainer/VBoxContainer/Quit

func _ready():
	next.pressed.connect(_on_next_level)
	main_menu.pressed.connect(_on_main_menu_pressed)
	quit.pressed.connect(_on_quit_pressed)

func _on_next_level():
	pass
	#Next Level
	#get_tree().change_scene("res://path_to_next_level.tscn")

func _on_main_menu_pressed():
	pass
	#get_tree().change_scene_to_file("res://MenuInicial.tscn")

func _on_quit_pressed():
	get_tree().quit()
