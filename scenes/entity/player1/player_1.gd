extends PlayerBase

@onready var hammer = $Hammer
var breakable = null

func _ready():
	animation_tree.active = true
	jump_speed = 700

#func _physics_process(delta: float) -> void:
#	super(delta)
#	if is_multiplayer_authority():
#		var move_input = Input.get_axis("move_left", "move_right")
func update_animation_state() -> void:
	super()
	if is_jumping == false and Input.is_action_just_pressed("hammer1"):
		animation_tree.set("parameters/conditions/hammer", true)
		sync_hammer_animation.rpc(true)
		rpc("check_breakable")

func _input(event: InputEvent) -> void:
	if is_multiplayer_authority():
		if Input.is_action_just_pressed("hammer1"):
			rpc("check_breakable")
		#if Input.is_action_just_pressed("hammer2"):
			#when hammer2 pressed, make a greater jump, if in contact with p2, make him jumo too
			#return

@rpc("any_peer", "call_local", "reliable")
func check_breakable():
	animation_tree["parameters/conditions/hammer"] = true
	if (breakable != null):
		breakable.destroy()

func _on_hammer_area_entered(area):
	if area.is_in_group("breakable"):
		breakable = area

func _on_hammer_area_exited(area):
	if area.is_in_group("breakable"):
		breakable = null

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "hammer":
		animation_tree.set("parameters/conditions/hammer", false)
		sync_hammer_animation.rpc(false)

@rpc("any_peer", "call_local", "unreliable")
func sync_hammer_animation(is_hammering: bool) -> void:
	animation_tree.set("parameters/conditions/hammer", is_hammering)
