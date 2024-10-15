extends Node2D

@onready var jump_anim = $JumpAnim

var p_pos = Vector2(0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position = p_pos
	jump_anim.play("superjump")

func _on_jump_anim_animation_finished(anim_name):
	if anim_name == "superjump":
		queue_free()
