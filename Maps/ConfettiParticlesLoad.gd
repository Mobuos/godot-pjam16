extends GPUParticles2D

func _ready() -> void:
	await(get_tree().create_timer(0.1, true, false, true).timeout)
	emitting = false
