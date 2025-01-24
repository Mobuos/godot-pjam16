class_name ShakerComponent
extends Node

@onready var camera := get_parent() as Camera2D

@export_range(0, 30, 0.1, "radians_as_degrees") var maxAngle := 0.05 * TAU
@export var maxOffset := 64.0

var _noiser := FastNoiseLite.new()
var _trauma := Vector2.ZERO


func _ready() -> void:
	Global.shaker = self
	_noiser.noise_type = FastNoiseLite.TYPE_PERLIN
	camera.ignore_rotation = false


func _process(delta: float) -> void:
	_trauma.x -= 1 * delta
	_trauma.y -= 1 * delta
	_trauma.x = clamp(_trauma.x, 0.0, 1.0)
	_trauma.y = clamp(_trauma.y, 0.0, 1.0)

	
	var shake: float = max(_trauma.x ** 2, _trauma.y ** 2)
	var shake2 := Vector2(_trauma.x ** 2, _trauma.y ** 2)
	
	camera.rotation = maxAngle * shake * _noiser.get_noise_1d(Time.get_ticks_msec())
	camera.offset.x = maxOffset * shake2.x * _noiser.get_noise_1d(Time.get_ticks_msec() + 10)
	camera.offset.y = maxOffset * shake2.y * _noiser.get_noise_1d(Time.get_ticks_msec() + 20)


# Trauma will always be withing 0.0 and 1.0
func increase_trauma2(trauma_increase: Vector2) -> void:
	_trauma += abs(trauma_increase)

func increase_trauma(trauma_increase: float) -> void:
	_trauma += Vector2(abs(trauma_increase), abs(trauma_increase))
