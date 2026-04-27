extends Node3D

# @export makes these variables visible in the Godot Inspector panel!
@export var expansion_speed: float = 30.0
@export var lifetime: float = 0.05 # Increasing this will make the final explosion bigger!

func _ready() -> void:
	# Wait for the custom lifetime, then delete itself
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float) -> void:
	# Make the explosion rapidly expand based on the custom speed
	scale += Vector3.ONE * expansion_speed * delta
