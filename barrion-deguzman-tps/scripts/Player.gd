extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 7
const SENSITIVITY = 0.003

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

# We need the aim ray and the muzzle to calculate shooting
@onready var aim_ray: RayCast3D = $Head/Camera3D/AimRay
@onready var muzzle: Marker3D = $Head/Gun/Muzzle

# Preload the bullet scene we just created
var bullet_scene = preload("res://scenes/Bullet.tscn")

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

	# Handle Shooting
	if Input.is_action_just_pressed("shoot"):
		shoot()

	# Get the input direction and handle the movement/deceleration.
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

# Function to handle the actual firing logic
func shoot():
	var bullet = bullet_scene.instantiate()
	
	# Add the bullet to the main scene tree, NOT as a child of the player.
	# If it's a child of the player, it will drag with you when you move!
	get_tree().root.add_child(bullet)
	
	# Start the bullet exactly at the tip of the gun
	bullet.global_position = muzzle.global_position
	
	# Figure out exactly where the camera crosshair is pointing
	var target_position: Vector3
	
	if aim_ray.is_colliding():
		# If looking at a wall or enemy, shoot toward that exact impact spot
		target_position = aim_ray.get_collision_point()
	else:
		# If looking at the sky, shoot straight forward 100 meters
		target_position = aim_ray.to_global(aim_ray.target_position)
		
	# Point the bullet directly at the target
	bullet.look_at(target_position, Vector3.UP)
