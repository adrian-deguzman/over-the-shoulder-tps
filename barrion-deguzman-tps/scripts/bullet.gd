extends Node3D

var speed: float = 40.0 # Make sure this is slow enough to track!
@onready var raycast: RayCast3D = $RayCast3D

func _physics_process(delta: float) -> void:
	# Calculate how far the bullet will move this exact frame
	var move_distance = speed * delta
	
	# Point the raycast forward exactly that distance
	raycast.target_position = Vector3(0, 0, -move_distance)
	raycast.force_raycast_update() # Force it to check immediately
	
	if raycast.is_colliding():
		# It hit something! 
		# We will add the explosion here later. For now, destroy the bullet.
		queue_free()
	else:
		# If no collision, move the bullet forward
		global_translate(-global_basis.z * move_distance)
