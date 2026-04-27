extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 7
const SENSITIVITY = 0.003

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# FIX 1: Rotate the entire actor (CharacterBody3D) left and right
		rotate_y(-event.relative.x * SENSITIVITY)
		
		# FIX 3: Rotate the Head up and down instead of just the Camera.
		# Because the Gun is a child of the Head, this makes the gun 
		# pitch up and down in perfect sync with your crosshair view!
		head.rotate_x(-event.relative.y * SENSITIVITY)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	
	# FIX 2: Use the actor's main transform basis instead of the head's
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0 # move_toward(velocity.x, 0, SPEED)
		velocity.z = 0.0 # move_toward(velocity.z, 0, SPEED)

	move_and_slide()
