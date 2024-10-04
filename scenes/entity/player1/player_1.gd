extends PlayerBase

@onready var hammer = $Hammer
var breakable = null
var partner = null

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
		sync_hammer_animation.rpc(false)

@rpc("any_peer", "call_local", "unreliable")
func sync_hammer_animation(is_hammering: bool) -> void:
	animation_tree.set("parameters/conditions/hammer", is_hammering)
