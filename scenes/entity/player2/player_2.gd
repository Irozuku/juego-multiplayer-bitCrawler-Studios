extends PlayerBase
@onready var chain: Node2D = $Chain

const CHAIN_PULL = 105

var chain_velocity := Vector2(0,0)


func _physics_process(delta: float) -> void:
	super(delta)
	if is_multiplayer_authority():
		var move_input = Input.get_axis("move_left", "move_right")
		# Hook physics
		if $Chain.hooked:
			# `to_local($Chain.tip).normalized()` is the direction that the chain is pulling
			chain_velocity = to_local($Chain.tip).normalized() * CHAIN_PULL
			if chain_velocity.y > 0:
				# Pulling down isn't as strong
				chain_velocity.y *= 0.55
			else:
				# Pulling up is stronger
				chain_velocity.y *= 1.65
			if sign(chain_velocity.x) != sign(move_input):
				# if we are trying to walk in a different
				# direction than the chain is pulling
				# reduce its pull
				chain_velocity.x *= 0.7
		else:
			# Not hooked -> no chain velocity
			chain_velocity = Vector2(0,0)
		velocity += chain_velocity


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event is InputEventMouseButton:
			if event.pressed:
				# We clicked the mouse -> shoot()
				$Chain.shoot(get_local_mouse_position())
			else:
				# We released the mouse -> release()
				$Chain.release()


#when chain pressed, send a line.
	#If contact with hook, make swing.
		#allow chain pressed to let go
	#If contact with p1, grab
		#allow roll with wheel to drag player and chain pressed to let go
