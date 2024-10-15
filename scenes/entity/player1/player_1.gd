extends PlayerBase

const CHAIN_PULL = 100

@onready var hammer = $Hammer
@onready var player_2: CharacterBody2D = $"../Player2"

@export var hooked = false

var breakable = []
var partner = null
var chain_velocity := Vector2(0,0)

func update_animation_state() -> void:
	super()
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


func superjump() -> void:
	if partner:
		partner.make_superjump()
	if is_on_floor():
		velocity.y = -superjump_speed
		is_jumping = true
		_send_jump_action(superjump_speed)
		rpc("play_superjump")

@rpc("any_peer", "call_local", "reliable")
func check_breakable():
	print(breakable)
	animation_tree["parameters/conditions/hammer"] = true
	for obj in breakable:
		obj.destroy()
		breakable.erase(obj)

@rpc("any_peer", "call_local", "reliable")
func play_superjump():
	var sp_fx = load("res://scenes/entity/player1/super_jump_fx.tscn")
	var jump_node = sp_fx.instantiate()
	jump_node.p_pos = position + Vector2(0, 25)
	get_parent().add_child(jump_node)

func _on_hammer_body_entered(body):
	if body.is_in_group("breakable"):
		if not breakable.has(body):
			print("Breakable IN")
			breakable.append(body)

func _on_hammer_body_exited(body):
	if body.is_in_group("breakable"):
		print("Breakable OUT")
		breakable.erase(body)

func _on_jump_detector_body_entered(body):
	if body.is_in_group("partner"):
		partner = body

func _on_jump_detector_body_exited(body):
	if body.is_in_group("partner"):
		partner = null

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "hammer":
		animation_tree.set("parameters/conditions/hammer", false)
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
