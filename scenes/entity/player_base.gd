class_name PlayerBase
extends CharacterBody2D

@export var hp: int = 1
@export var speed: float = 600
@export var acceleration: float = 1000
@export var jump_speed: int = 500
@export var superjump_speed: int = 700
var partner_position := Vector2.ZERO

#animations
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var sprite: Sprite2D = $Sprite2D

var current_animation: String = "Idle"
var facing_right: bool = true
var is_jumping: bool = false
var is_overDoor: bool = false
var is_hidden: bool = false

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
		
		update_animations(move_input)
		send_state.rpc(position, velocity, current_animation, facing_right)
	move_and_slide()

func has_multiplayer_authority() -> bool:
	return multiplayer.get_unique_id() == get_multiplayer_authority()

# Makes the character jump and calls the rpc to send this action
func jump() -> void:
	if is_on_floor():
		velocity.y = -jump_speed
		is_jumping = true
		_send_jump_action(jump_speed)

#Changes the animations of the characters and calls the rpc to send this action
func update_animations(move_input: float) -> void:
	if move_input != 0:
		facing_right = move_input > 0
		sprite.flip_h = not facing_right
	
	var new_animation: String
	if abs(velocity.x) > 10 and is_on_floor():
		new_animation = "Walk"
	elif not is_on_floor():
		new_animation = "Jump"
	else:
		new_animation = "Idle"
	
	if new_animation != current_animation:
		current_animation = new_animation
		playback.travel(current_animation)

# RPC to send the action of jumping with reliable protocol
@rpc("authority", "call_remote", "reliable")
func _send_jump_action(jump_speed: int) -> void:
	velocity.y = -jump_speed
	is_jumping = true

@rpc("authority", "call_remote", "unreliable")
func send_state(pos: Vector2, vel: Vector2, anim: String, facing_right: bool) -> void:
	if not is_multiplayer_authority():
		position = pos
		velocity = vel
		if anim != current_animation:
			current_animation = anim
			playback.travel(current_animation)
		sprite.flip_h = not facing_right

func setup(player_data: Statics.PlayerData) -> void:
	set_multiplayer_authority(player_data.id)

@rpc("authority", "call_local")
func send_position_for_usability(pos: Vector2) -> void:
	partner_position = pos
