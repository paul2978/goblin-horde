# res://player/Player.gd  # This is the file path of the script
extends CharacterBody2D  # Use a 2D character body to handle movement and collisions

@export var speed: float = 300.0  # How fast the player moves left or right
@export var jump_velocity: float = -400.0  # Vertical speed applied for the first jump (negative is up)
@export var double_jump_velocity: float = -350.0  # Vertical speed applied for the double jump

# Get the gravity from the project settings to be synced with RigidBody nodes  # We read engine gravity so falling feels consistent
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")  # Store the default gravity value
var has_double_jump = false  # Tracks if the player can use a double jump

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

	# Get the input direction (WASD)  # Read player movement input from configured actions
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")  # Get a Vector2 input
	
	# Apply horizontal movement based on input  # Move left/right or slow down if no input
	if direction:  # If there is any movement input
		velocity.x = direction.x * speed  # Set horizontal velocity from input and speed
	else:  # No horizontal input
		velocity.x = move_toward(velocity.x, 0, speed)  # Gradually slow horizontal movement to zero

	move_and_slide()  # Move the character and handle collisions automatically
