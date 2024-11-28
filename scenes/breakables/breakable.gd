extends StaticBody2D
@onready var animation_player = $AnimationPlayer
@onready var collision_shape_2d = $CollisionShape2D

func destroy():
	animation_player.play("Break")
	collision_shape_2d.set_deferred("disabled",true)
	


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Break":
		queue_free()
