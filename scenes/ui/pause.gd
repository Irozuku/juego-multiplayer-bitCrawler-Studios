extends CanvasLayer

@onready var paused: bool = false


func _ready() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if paused:
			unpause.rpc()
		else:
			pause.rpc()


@rpc("any_peer", "call_local", "reliable")
func pause() -> void:
	show()
	get_tree().paused = true
	paused = true


@rpc("any_peer", "call_local", "reliable")
func unpause():
	hide()
	get_tree().paused = false
	paused = false
