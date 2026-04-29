extends StaticBody3D

# takes exactly 3 hits to destroy
var health: int = 3

# load the explosion effect
var explosion_scene = preload("res://scenes/explosion.tscn")

func take_damage() -> void:
	health -= 1
	
	if health <= 0:
		die()

func die() -> void:
	var big_explosion = explosion_scene.instantiate()
	get_tree().root.add_child(big_explosion)
	
	# put the explosion exactly where the enemy died
	big_explosion.global_position = global_position
	
	# make a bigger explosion when destroyed to meet specs
	big_explosion.expansion_speed = 100.0 
	big_explosion.lifetime = 0.25 
	
	queue_free()
