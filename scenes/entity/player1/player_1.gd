extends PlayerBase

@onready var hammer = $Hammer
@onready var animation_tree : AnimationTree = $AnimationTree

func _ready():
	animation_tree.active = true
	jump_speed = 700

func _process(delta):
	update_animation()

#when hammer1 pressed, create a collision shape, if that collision hits a breakable wall, break

#when hammer2 pressed, make a greater jump, if in contact with p2, make him jumo too

func update_animation():
	if(velocity == Vector2.ZERO):
		animation_tree["parameters/conditions/idle"] = true
		animation_tree["parameters/conditions/is_moving"] = false
	else:
		animation_tree["parameters/conditions/idle"] = false
		animation_tree["parameters/conditions/is_moving"] = true
