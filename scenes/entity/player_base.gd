class_name PlayerBase
extends CharacterBody2D

@export var hp: int = 1
@export var speed: float = 600
@export var acceleration: float = 1000
@export var jump_speed: int = 500
@export var superjump_speed: int = 700
var partner_position := Vector2.ZERO

#animations
var is_idle: bool = true
var is_walking: bool = false
var is_jumping: bool = false

@onready var animation_tree: AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true

func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		var move_input = Input.get_axis("move_left", "move_right")
		velocity.x = move_toward(velocity.x, speed * move_input, acceleration * delta)
		
		if Input.is_action_just_pressed("jump"):
			jump()
		
		update_animation_state()
		sync_animation_state.rpc(is_walking, is_idle, is_jumping)
		send_position.rpc(position, velocity)
	move_and_slide()
	

# Makes the character jump and calls the rpc to send this action
func jump() -> void:
	if is_on_floor():
		velocity.y = -jump_speed
		is_jumping = true
		_send_jump_action(jump_speed)

#Changes the animations of the characters and calls the rpc to send this action
func update_animation_state():
	if is_on_floor():
		if (velocity == Vector2.ZERO):
			is_idle = true
			is_walking = false
			is_jumping = false
		else:
			is_idle = false
			is_walking = true
			is_jumping = false
	else:
		is_idle = false
		is_walking = false
		is_jumping = true
	
	animation_tree.set("parameters/conditions/idle", is_idle)
	animation_tree.set("parameters/conditions/is_walking", is_walking)
	animation_tree.set("parameters/conditions/is_jumping", is_jumping)

# RPC to send the action of jumping with reliable protocol
@rpc("authority", "call_remote", "reliable")
func _send_jump_action(jump_speed: int) -> void:
	velocity.y = -jump_speed
	is_jumping = true

@rpc("any_peer", "call_local", "unreliable")
func sync_animation_state(idle: bool, walk: bool, jump: bool) -> void:
	is_idle = idle
	is_walking = walk
	is_jumping = jump
	update_animation_state()

@rpc("authority", "call_remote")
func send_position(pos: Vector2, vel: Vector2) -> void:
	position = lerp(position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)

func setup(player_data: Statics.PlayerData) -> void:
	set_multiplayer_authority(player_data.id)

@rpc("authority", "call_local")
func send_position_for_usability(pos: Vector2) -> void:
	partner_position = pos
	
