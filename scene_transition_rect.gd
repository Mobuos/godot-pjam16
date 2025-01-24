class_name SceneTransition
extends ColorRect

@onready var _anim_player := $AnimationPlayer as AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	_anim_player.play_backwards("Fade")
