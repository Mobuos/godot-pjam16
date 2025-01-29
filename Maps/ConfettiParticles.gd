extends GPUParticles2D

func _on_map_level_clear() -> void:
	emitting = true
	var label := $"../Label" as RichTextLabel
	label.text = "THE END (real)"
