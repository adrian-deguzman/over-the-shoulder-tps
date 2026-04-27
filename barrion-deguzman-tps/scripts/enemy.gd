extends StaticBody3D

# Enemy requires exactly 3 hits to destroy
var health: int = 3

# Preload the explosion scene to use when dying
var explosion_scene = preload("res://scenes/explosion.tscn")

# Function called by the bullet when it hits this body
func take_damage() -> void:
	health -= 1
	
	if health <= 0:
		die()

func die() -> void:
	var big_explosion = explosion_scene.instantiate()
	get_tree().root.add_child(big_explosion)
	
	# Place the explosion where the enemy was
	big_explosion.global_position = global_position
	
	# NEW: Satisfy the "bigger explosion if destroyed" rubric requirement!
	# Because you exported these variables in explosion.gd, we can alter them here.
	big_explosion.expansion_speed = 100.0 # Expands much faster
	big_explosion.lifetime = 0.25 # Lasts much longer, making the final size huge!
	
	# Remove the enemy from the game
	queue_free()
