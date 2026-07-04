extends CharacterBody2D # Inherits a buncha handy functions and attributes that all CharacterBody2D nodes share

# SET MARIOS MOVEMENT PHYSICS........
const SPEED_BASE = 150.0
const RUN_MULT = 1.5
const JUMP_VELOCITY = -335.0
const DECELLERATION_RATE = 6
const ACCELERATION_RATE = 8

# This pulls the AnimatedSprite2D node from our Scene and lets us interact with it in code world
@onready var sprite = $AnimatedSprite2D 
 
# @TODO track last animation played instead (or do sum fancy FSM shit)
var jumped = false 

# This function gets called periodically by the engine to handle physics-related stuffs
func _physics_process(delta: float) -> void: 
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions eventually 
	# ("mario_walk_left", for example)
	# You can define them in Project->Project Settings->Input Map
	var direction := Input.get_axis("ui_left", "ui_right")

	# Handle animations and velocity based on whether or not Mario's on the ground
	if is_on_floor():
		if jumped:
			jumped = false
		sprite.play("Walk" if direction else "Idle")
	else:
		# Add the gravity.
		velocity += get_gravity() * delta
		if jumped:
			sprite.play("Jump")
			if is_on_ceiling(): #Handle getting stuck under block (needs more work)
				velocity.x = direction * SPEED_BASE
		
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		sprite.play("Jump")
		jumped = true
		
	# Handle run
	var SPEED := SPEED_BASE
	if Input.is_action_pressed("ui_cancel"):
		SPEED *= RUN_MULT
		
	# Handle left/right input
	if direction and not Input.is_action_pressed("ui_down"):
		# Constant horizontal velocity in direction of movement
		velocity.x = direction * SPEED
		
		# Make character "look" in the proper direction 
		# (sprite itself is "facing" right, so that's the default, "non-flipped" state)
		
		# Flip sprite horizontally if moving left (x is moving towards negative on axis, `direction < 0` is true)
		# If looking right, sets it back to normal (x is moving towards positive on axis, `direction < 0` is false)
		sprite.flip_h = direction < 0
	else:
		var JankDecelleration = DECELLERATION_RATE 
		if Input.is_action_pressed("ui_down") and not jumped and velocity.x:
			JankDecelleration = 50 
		# Gradually decrease velocity
		velocity.x = move_toward(velocity.x, 0, SPEED / JankDecelleration)
	
	#Handle Crouch 
	if Input.is_action_pressed("ui_down") and not jumped:
		sprite.play("Crouch")
		$CollisionShape2D.set_disabled(true)
		$CrouchCollision.set_disabled(false)
	else: 
		$CollisionShape2D.set_disabled(false)
		$CrouchCollision.set_disabled(true)
	move_and_slide() # This just does the default Godot physics handling shit
