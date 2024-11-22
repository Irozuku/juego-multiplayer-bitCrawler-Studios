extends Node

@onready var levels = [
	"res://scenes/main.tscn",  # Tutorial is the first level
	"res://scenes/levels/level1.tscn",
]
var current_level_index = 0
@onready var current_scene = "res://scenes/main.tscn"

func load_level(index: int):
	if index < 0 or index >= levels.size():
		print("Invalid level index!")
		return

	_load_scene(levels[index])
	current_level_index = index

func load_next_level():
	if current_level_index + 1 < levels.size():
		load_level(current_level_index + 1)
	else:
		print("No more levels!")

func load_level_by_path(scene_path: String):
	if not ResourceLoader.exists(scene_path):
		print("Scene path does not exist:", scene_path)
		return
		
	_load_scene(scene_path)

func _load_scene(scene_path: String):
	var scene = scene_path
	current_scene = load(scene)
	get_tree().change_scene_to_packed(current_scene)
