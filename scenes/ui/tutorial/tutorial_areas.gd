extends Area2D

var tutorial_texts = {
	"Area1": ["Use ", "res://resources/ui/a_key_light.png", "res://resources/ui/d_light.png", " to move and ", "res://resources/ui/space_light.png", " to jump."],
	"Area2": ["You can't jump very high on your own.", "Hammer can perform a high jump by pressing ", "res://resources/ui/k_light.png", " or ", "res://resources/ui/right_mouse_button_light.png", "If Hook is close, they'll jump higher too!"],
	"Area3": ["The ceiling here looks different.", "Hook can grab onto it and swing across using ", "res://resources/ui/left_mouse_button_light.png"],
	"Area4": ["Activate the hook again with ", "res://resources/ui/left_mouse_button_light.png", " to pull Hammer across."],
	"Area5": ["Hammer can break blocks with ", "res://resources/ui/left_mouse_button_light.png", " or ", "res://resources/ui/j_light.png"],
	"Area6": ["Enter the door using ", "res://resources/ui/w_light.png", " to finish the level."]
}

@onready var tutorial_ui = $".."
var tutorial_active = false
var player_in_area = []
static var active_tutorial_areas = {}


func _ready() -> void:
	var area_number = int(name.replace("Area", ""))
	active_tutorial_areas[get_instance_id()] = area_number

func _exit_tree() -> void:
	active_tutorial_areas.erase(get_instance_id())

func should_show_tutorial() -> bool:
	var this_area_number = int(name.replace("Area", ""))
	
	for area_id in active_tutorial_areas.keys():
		var other_area = instance_from_id(area_id)
		if other_area and other_area != self:
			var other_area_number = active_tutorial_areas[area_id]
			if other_area_number > this_area_number and not other_area.player_in_area.is_empty():
				return false
	
	return true

func update_tutorial_visibility() -> void:
	if not player_in_area.is_empty() and should_show_tutorial():
		if not tutorial_active:
			tutorial_active = true
			var area_elements = tutorial_texts.get(name, [])
			tutorial_ui.set_text(area_elements)
	else:
		if tutorial_active:
			tutorial_ui.hide_text()
			tutorial_active = false

func _on_area_entered(body: Node2D) -> void:
	if body.is_in_group("players"):
		if not player_in_area.has(body):
			player_in_area.append(body)
		for area_id in active_tutorial_areas.keys():
			var area = instance_from_id(area_id)
			if area:
				area.update_tutorial_visibility()

func _on_area_exited(body: Node2D) -> void:
	if body.is_in_group("players"):
		if player_in_area.has(body):
			player_in_area.erase(body)
		for area_id in active_tutorial_areas.keys():
			var area = instance_from_id(area_id)
			if area:
				area.update_tutorial_visibility()
