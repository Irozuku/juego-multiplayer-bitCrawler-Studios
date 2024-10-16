extends PlayerBase

@onready var hammer = $Hammer
@export var hooked = false
var breakable = null
var partner = null
const CHAIN_PULL = 100
var chain_velocity := Vector2(0,0)
@onready var player_2: CharacterBody2D = $"../Player2"

func update_animations(move_input) -> void:
	super(move_input)
	if move_input != 0:
		var new_facing_right = move_input > 0
		if new_facing_right != facing_right:
			facing_right = new_facing_right
			update_hammer_position.rpc(facing_right)
	
	if is_jumping == false and Input.is_action_just_pressed("hammer1") and is_multiplayer_authority():
		animation_tree.set("parameters/conditions/hammer", true)
		sync_hammer_animation.rpc(true)
		rpc("check_breakable")

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("hammer1"):
			rpc("check_breakable")
		if Input.is_action_just_pressed("hammer2"):
			superjump()

func _physics_process(delta):
	super(delta)
	if is_multiplayer_authority():
		update_hammer_position.rpc(facing_right)
		if hooked:
			#Debug.log("HOOKED")
			#Debug.log(player_2)
			var move_input = Input.get_axis("move_left", "move_right")
			# `to_local($Chain.tip).normalized()` is the direction that the chain is pulling
			chain_velocity = to_local(player_2.global_position).normalized() * CHAIN_PULL/2
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
			chain_velocity = Vector2.ZERO
		velocity += chain_velocity

@rpc("any_peer", "call_local", "reliable")
func update_hammer_position(facing_right: bool) -> void:
	if facing_right:
		hammer.position.x = abs(hammer.position.x)
	else:
		hammer.position.x = -abs(hammer.position.x)

func superjump() -> void:
	if partner:
		partner.make_superjump()
	if is_on_floor():
		velocity.y = -superjump_speed
		is_jumping = true
		_send_jump_action(superjump_speed)

@rpc("any_peer", "call_local", "reliable")
func check_breakable():
	animation_tree["parameters/conditions/hammer"] = true
	if (breakable != null):
		breakable.destroy()

func _on_hammer_body_entered(body):
	if body.is_in_group("breakable"):
		breakable = body

func _on_hammer_body_exited(body):
	if body.is_in_group("breakable"):
		breakable = null

func _on_jump_detector_body_entered(body):
	if body.is_in_group("partner"):
		partner = body

func _on_jump_detector_body_exited(body):
	if body.is_in_group("partner"):
		partner = null

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "hammer":
		animation_tree.set("parameters/conditions/hammer", false)
		if abs(velocity.x) > 10 and is_on_floor():
			playback.travel("Walk")
		else:
			playback.travel("Idle")
		sync_hammer_animation.rpc(false)

@rpc("any_peer", "call_local", "unreliable")
func sync_hammer_animation(is_hammering: bool) -> void:
	animation_tree.set("parameters/conditions/hammer", is_hammering)

func _get_pulled():
	rpc("get_pulled")

@rpc("any_peer", "call_local", "reliable")
func get_pulled() -> void:
	hooked = true

func _released_hook():
	rpc("released_hook")
	
@rpc("any_peer", "call_local", "reliable")
func released_hook():
	hooked = false
