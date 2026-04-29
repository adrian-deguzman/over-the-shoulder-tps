extends Node3D

# export to let enemy script trigger a bigger explosion
@export var expansion_speed: float = 10.0
# explosion size
@export var lifetime: float = 0.2

func _ready() -> void:
	# wait a bit then remove from game
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float) -> void:
	# rapidly grow the shape
	scale += Vector3.ONE * expansion_speed * delta
