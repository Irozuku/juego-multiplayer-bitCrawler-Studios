extends PlayerBase
@onready var chain = $Chain


const CHAIN_PULL = 100

var chain_velocity := Vector2(0,0)


func _physics_process(delta: float) -> void:
	super(delta)
	if is_multiplayer_authority():
		var move_input = Input.get_axis("move_left", "move_right")
		# Hook physics
		if chain.hooked:
			# `to_local($Chain.tip).normalized()` is the direction that the chain is pulling
			chain_velocity = to_local(chain.tip).normalized() * CHAIN_PULL
			if chain_velocity.y > 0:
				# Pulling down isn't as strong
				chain_velocity.y *= 0.6
			else:
				# Pulling up is stronger
				chain_velocity.y *= 1.30
			if sign(chain_velocity.x) != sign(move_input):
				# if we are trying to walk in a different
				# direction than the chain is pulling
				# reduce its pull
				chain_velocity.x *= 0.55
		else:
			# Not hooked -> no chain velocity
			chain_velocity = Vector2(0,0)
		velocity += chain_velocity
		send_chain_data.rpc(chain.global_position, chain.global_rotation)


func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event is InputEventMouseButton:
			if event.pressed:
				# We clicked the mouse -> shoot()
				chain.shoot(get_local_mouse_position())
			else:
				# We released the mouse -> release()
				chain.release()
			send_chain_visibility.rpc(event.pressed, get_local_mouse_position())

@rpc("authority", "call_remote")
func send_chain_data(chain_position: Vector2, chain_rotation: float):
	Debug.log("send_chain_data", 10)
	Debug.log(chain.global_position, 10)
	Debug.log(chain_position, 10)
	chain.global_position = chain_position

@rpc("authority", "call_remote", "reliable")
func send_chain_visibility(visible: bool, dir: Vector2):
	chain.flying = visible
	chain.direction = dir.normalized()

#when chain pressed, send a line.
	#If contact with hook, make swing.
		#allow chain pressed to let go
	#If contact with p1, grab
		#allow roll with wheel to drag player and chain pressed to let go
