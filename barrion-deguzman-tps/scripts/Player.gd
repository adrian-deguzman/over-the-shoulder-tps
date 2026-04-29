extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 7
const SENSITIVITY = 0.003

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D

@onready var aim_ray: RayCast3D = $Head/Camera3D/AimRay
@onready var muzzle: Marker3D = $Head/Gun/Muzzle
@onready var gun: Node3D = $Head/Gun 

# load the bullet scene for shooting
var bullet_scene = preload("res://scenes/Bullet.tscn")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# stop aim ray from hitting the player
	aim_ray.add_exception(self)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		# rotate whole body so actor matches camera direction
		rotate_y(-event.relative.x * SENSITIVITY)
		
		# tilt head and gun up and down for aiming
		head.rotate_x(-event.relative.y * SENSITIVITY)
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-40), deg_to_rad(60))

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# figure out exactly where the crosshair is pointing
	var target_position: Vector3
	if aim_ray.is_colliding():
		target_position = aim_ray.get_collision_point()
	else:
		target_position = aim_ray.to_global(aim_ray.target_position)
		
	# smoothly point the gun at the crosshair target
	var distance_to_target = gun.global_position.distance_to(target_position)
	if distance_to_target > 1.0: 
		var target_transform = gun.global_transform.looking_at(target_position, Vector3.UP)
		gun.global_transform = gun.global_transform.interpolate_with(target_transform, 15.0 * delta)

	if Input.is_action_just_pressed("shoot"):
		shoot(target_position)

	var input_dir = Input.get_vector("left", "right", "up", "down")
	
	# make movement relative to the camera view
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0 
		velocity.z = 0.0 

	move_and_slide()

func shoot(target_pos: Vector3):
	var bullet = bullet_scene.instantiate()
	
	# spawn bullet independent of player so it doesn't drag
	get_tree().root.add_child(bullet)
	
	# start bullet at gun tip
	bullet.global_position = muzzle.global_position
	
	# aim bullet straight at target
	bullet.look_at(target_pos, Vector3.UP)
	
	# stop bullet from hitting player when it spawns
	if bullet.has_method("add_exception"):
		bullet.add_exception(self)
