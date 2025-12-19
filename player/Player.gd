# res://player/Player.gd  # This is the file path of the script
extends CharacterBody2D  # Use a 2D character body to handle movement and collisions

@export var speed: float = 500.0  # How fast the player moves left or right
@export var jump_velocity: float = -400.0  # Vertical speed applied for the first jump (negative is up)
@export var double_jump_velocity: float = -350.0  # Vertical speed applied for the double jump
@export var crouch_speed_multiplier: float = 0.5  # Speed multiplier when crouching (0.5 = half speed)
@export var crouch_height_scale: float = 0.6  # Visual scale of the player when crouching

# Get the gravity from the project settings to be synced with RigidBody nodes  # We read engine gravity so falling feels consistent
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")  # Store the default gravity value
var has_double_jump = false  # Tracks if the player can use a double jump
var is_crouching = false  # Tracks if the player is currently crouching

func _physics_process(delta):  # Called every physics frame to update physics-related movement
	# Add gravity to the player when in the air  # Increases downward speed over time
	if not is_on_floor():  # Check if the player is not standing on the ground
		velocity.y += gravity * delta  # Apply gravity to vertical velocity
	else:  # The player is on the ground
		has_double_jump = true  # Reset double jump availability when landing

	# Handle jump input  # React when the jump button is pressed
	if Input.is_action_just_pressed("ui_accept"):  # True on the frame the jump button is pressed
		if is_on_floor():  # If player is on the ground, do a normal jump
			velocity.y = jump_velocity  # Set vertical velocity for the jump
			has_double_jump = true  # Double jump only becomes available after the first jump
		elif has_double_jump:  # If in the air and a double jump is available
			velocity.y = double_jump_velocity  # Set vertical velocity for the double jump
			has_double_jump = false  # Use up the double jump so it can't be used again until landing

	# Handle crouch input  # Detect when the player wants to crouch
	if Input.is_action_pressed("ui_down") and is_on_floor():  # If down is held and player is on ground
		if not is_crouching:  # If just started crouching
			is_crouching = true  # Set crouching state to true
			scale.y = crouch_height_scale  # Make the player visually shorter
	else:  # If down is not pressed or player is in the air
		if is_crouching:  # If was crouching and should stop
			is_crouching = false  # Set crouching state to false
			scale.y = 1.0  # Return to normal height

	# Get the input direction (WASD)  # Read player movement input from configured actions
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")  # Get a Vector2 input
	
	# Apply horizontal movement based on input  # Move left/right or slow down if no input
	if direction:  # If there is any movement input
		var current_speed = speed  # Start with normal speed
		if is_crouching:  # If the player is crouching
			current_speed *= crouch_speed_multiplier  # Reduce speed when crouching
		velocity.x = direction.x * current_speed  # Set horizontal velocity from input and current speed
	else:  # No horizontal input
		velocity.x = move_toward(velocity.x, 0, speed)  # Gradually slow horizontal movement to zero

	move_and_slide()  # Move the character and handle collisions automatically