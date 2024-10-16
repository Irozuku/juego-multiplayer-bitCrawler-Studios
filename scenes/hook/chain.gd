extends Node2D

@onready var links = $Links		# A slightly easier reference to the links
@export var direction := Vector2(0,0)	# The direction in which the chain was shot
@export var tip := Vector2(0,0)			# The global position the tip should be in
								# We use an extra var for this, because the chain is 
								# connected to the player and thus all .position
								# properties would get messed with when the player
								# moves.
@onready var player_hooked_timer: Timer = $PlayerHookedTimer

const SPEED = 50	# The speed with which the chain moves
const MAX_LENGTH = 500 # Max length of the hook

@export var flying = false	# Whether the chain is moving through the air
@export var hooked = false	# Whether the chain has connected to a wall
@export var player_hooked = false # Whether the chain has connected to a player
@export var partner = null

# shoot() shoots the chain in a given direction
func shoot(dir: Vector2) -> void:
	direction = dir.normalized()	# Normalize the direction and save it
	flying = true					# Keep track of our current scan
	tip = self.global_position		# reset the tip position to the player's position

# release() the chain
func release() -> void:
	player_hooked_timer.stop()
	if partner:
		partner._released_hook()
	flying = false	# Not flying anymore	
	hooked = false	# Not attached anymore
	player_hooked = false # Not attached to player anymore
	partner = null
	#Debug.log(partner)

# Every graphics frame we update the visuals
func _process(_delta: float) -> void:
	self.visible = flying or hooked	# Only visible if flying or attached to something
	if not self.visible:
		return	# Not visible -> nothing to draw
	if partner:
		tip = partner.global_position
	var tip_loc = to_local(tip)	# Easier to work in local coordinates
	# We rotate the links (= chain) and the tip to fit on the line between self.position (= origin = player.position) and the tip
	links.rotation = self.position.angle_to_point(tip_loc) + deg_to_rad(90)
	$Tip.rotation = self.position.angle_to_point(tip_loc) + deg_to_rad(90)
	links.position = tip_loc						# The links are moved to start at the tip
	links.region_rect.size.y = tip_loc.length()		# and get extended for the distance between (0,0) and the tip

# Every physics frame we update the tip position
func _physics_process(_delta: float) -> void:
	$Tip.global_position = tip	# The player might have moved and thus updated the position of the tip -> reset it
	if to_local(tip).length() >= MAX_LENGTH:
		release()
	
	if flying:
		# `if move_and_collide()` always moves, but returns true if we did collide
		var collider = $Tip.move_and_collide(direction * SPEED)
		if collider:
			#Debug.log(collider.get_collider().is_in_group("hookable"))
			if collider.get_collider().is_in_group("hookable"):
				collider.get_collider()._get_pulled()
				partner = collider.get_collider()
				player_hooked = true
				player_hooked_timer.start()
			hooked = true	# Got something!
			flying = false	# Not flying anymore
	tip = $Tip.global_position	# set `tip` as starting position for next frame

func _on_player_hooked_timer_timeout() -> void:
	release()
