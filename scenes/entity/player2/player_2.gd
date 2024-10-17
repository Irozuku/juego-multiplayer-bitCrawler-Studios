extends PlayerBase
@onready var chain = $Chain

const CHAIN_PULL = 100

var chain_velocity := Vector2(0,0)
@onready var player_2: CharacterBody2D = $"../Player1"

func _physics_process(delta: float) -> void:
	super(delta)
	if is_multiplayer_authority():
		var move_input = Input.get_axis("move_left", "move_right")
		# Hook physics
		if chain.hooked:
			if !chain.player_hooked:
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
				# `to_local($Chain.tip).normalized()` is the direction that the chain is pulling
				chain_velocity = to_local(chain.tip).normalized() * CHAIN_PULL/3
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
		send_position_for_usability.rpc(global_position)

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if event is InputEventMouseButton:
			if event.pressed:
				# We clicked the mouse -> shoot()
				chain.shoot(get_local_mouse_position())
			else:
				# We released the mouse -> release()
				chain.release()

func make_superjump():
	rpc("superjump")

@rpc("any_peer", "call_local", "reliable")
func superjump() -> void:
	if is_on_floor():
		velocity.y = -superjump_speed
		is_jumping = true
