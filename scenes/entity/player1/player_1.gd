extends PlayerBase

@onready var hammer = $Hammer

func _ready():
	jump_speed = 700

#when hammer1 pressed, create a collision shape, if that collision hits a breakable wall, break

#when hammer2 pressed, make a greater jump, if in contact with p2, make him jumo too
