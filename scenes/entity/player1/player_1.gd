extends PlayerBase

const CHAIN_PULL = 100
const HIGH_JUMP_FX_DELAY = 0.3  # Delay for jump effect

@onready var hammer = $Hammer
@onready var player_2: CharacterBody2D = $"../Player2"
@onready var jump_timer = Timer.new()
@onready var fx_timer = Timer.new()

@export var hooked = false

var breakable = []
var partner = null
var chain_velocity := Vector2(0,0)
var jump_queued := false

func _ready():
	super()
	add_to_group("players")
	if Game.get_current_player().role == 1:
		var bg_node = add_background()
		add_child(bg_node)
	
	# Timer para salto alto
	jump_timer.wait_time = 0.3
	jump_timer.one_shot = true
	jump_timer.timeout.connect(_on_jump_timer_timeout)
	add_child(jump_timer)
	
	# Timer FX
	fx_timer.wait_time = HIGH_JUMP_FX_DELAY
	fx_timer.one_shot = true
	fx_timer.timeout.connect(_on_fx_timer_timeout)
	add_child(fx_timer)


func update_animations(move_input) -> void:
	super(move_input)
	if move_input != 0:
		var new_facing_right = move_input > 0
		if new_facing_right != facing_right:
			facing_right = new_facing_right
			update_hammer_position.rpc(facing_right)
	
	if is_jumping == false and Input.is_action_just_pressed("hammer1") and is_multiplayer_authority():
		animation_tree.set("parameters/conditions/hammer", true)
		rpc("check_breakable")
	if Input.is_action_just_pressed("hammer2") and is_multiplayer_authority():
		animation_tree.set("parameters/conditions/highJump", true)
		rpc("start_high_jump_animation")
		#queue_superjump()

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("hammer1"):
			rpc("check_breakable")
		if Input.is_action_just_pressed("hammer2"):
			rpc("start_high_jump_animation")
			#queue_superjump()
			#superjump()

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

func queue_superjump() -> void:
	if not jump_queued and is_on_floor():
		jump_queued = true
		animation_tree.set("parameters/conditions/highJump", true)
		jump_timer.start()

@rpc("any_peer", "call_local", "reliable")
func start_high_jump_animation():
	if not jump_queued and is_on_floor():
		jump_queued = true
		animation_tree.set("parameters/conditions/highJump", true)
		jump_timer.start()
		fx_timer.start()
		rpc("prepare_high_jump")

@rpc("any_peer", "call_local", "reliable")
func prepare_high_jump():
	# Prepare for the high jump synchronization
	jump_queued = true
	animation_tree.set("parameters/conditions/highJump", true)

func superjump() -> void:
	if partner:
		partner.make_superjump()
	velocity.y = -superjump_speed
	is_jumping = true
	_send_jump_action(superjump_speed)
	rpc("play_superjump")
	jump_queued = false

func _on_jump_timer_timeout() -> void:
	if jump_queued:
		superjump()

func _on_fx_timer_timeout():
	if is_multiplayer_authority():
		rpc("play_superjump")

@rpc("any_peer", "call_local", "reliable")
func check_breakable():
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
		if abs(velocity.x) > 10 and is_on_floor():
			playback.travel("Walk")
		else:
			playback.travel("Idle")
	if anim_name == "hammer_jump":
		animation_tree.set("parameters/conditions/highJump", false)
		if abs(velocity.x) > 10 and is_on_floor():
			playback.travel("Walk")
		else:
			playback.travel("Idle")

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
