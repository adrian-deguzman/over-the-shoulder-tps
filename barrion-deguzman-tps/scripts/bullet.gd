extends Node3D

# slow enough to be visually trackable
var speed: float = 40.0 
var max_distance: float = 100.0 
var traveled_distance: float = 0.0 

@onready var raycast: RayCast3D = $RayCast3D

# load the explosion effect for impacts
var explosion_scene = preload("res://scenes/explosion.tscn")

# prevent hitting the player who shot it
var _exceptions: Array = []

func _ready() -> void:
	for node in _exceptions:
		raycast.add_exception(node)

func add_exception(node: CollisionObject3D) -> void:
	_exceptions.append(node)
	if raycast != null:
		raycast.add_exception(node)

func _physics_process(delta: float) -> void:
	# short-distance raycast per frame to check for hits
	var move_distance = speed * delta
	
	raycast.target_position = Vector3(0, 0, -move_distance)
	raycast.force_raycast_update() 
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		
		# check if we hit an enemy to deal damage
		if collider and collider.has_method("take_damage"):
			collider.take_damage()
		
		# spawn small explosion on impact
		spawn_explosion(raycast.get_collision_point())
		
		queue_free()
	else:
		# move projectile physically so it is not a hitscan
		global_translate(-global_basis.z * move_distance)
		
		traveled_distance += move_distance
		
		if traveled_distance >= max_distance:
			queue_free()

func spawn_explosion(impact_point: Vector3):
	var explosion = explosion_scene.instantiate()
	
	get_tree().root.add_child(explosion)
	
	explosion.global_position = impact_point
