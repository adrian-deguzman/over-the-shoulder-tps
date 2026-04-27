extends Node3D

var speed: float = 40.0 # Make sure this is slow enough to track!
var max_distance: float = 100.0 # The set distance before the bullet despawns
var traveled_distance: float = 0.0 # Counter to track how far it has flown

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
		
		# Add the distance moved this frame to our total traveled distance
		traveled_distance += move_distance
		
		# Clean up memory if the bullet has flown past the set maximum distance
		if traveled_distance >= max_distance:
			queue_free()
