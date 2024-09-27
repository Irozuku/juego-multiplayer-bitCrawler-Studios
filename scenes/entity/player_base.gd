class_name PlayerBase
extends CharacterBody2D

@export var hp: int = 1
@export var speed: float = 600
@export var acceleration: float = 1000
@export var jump_speed: int = 500


func _physics_process(delta: float) -> void:
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity += get_gravity() * delta
		
		var move_input = Input.get_axis("move_left", "move_right")
		velocity.x = move_toward(velocity.x, speed * move_input, acceleration * delta)
		
		if Input.is_action_just_pressed("jump"):
			if is_on_floor():
				velocity.y = -jump_speed
			
		send_position.rpc(position, velocity)
	move_and_slide()
	

func setup(player_data: Statics.PlayerData) -> void:
	set_multiplayer_authority(player_data.id)

@rpc("authority", "call_remote")
func send_position(pos: Vector2, vel: Vector2) -> void:
	position = lerp(position, pos, 0.5)
	velocity = lerp(velocity, vel, 0.5)
