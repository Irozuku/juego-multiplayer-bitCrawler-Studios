extends StaticBody2D
@onready var animation_player = $AnimationPlayer

func destroy():
	animation_player.play("Break")
	


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "Break":
		queue_free()
