extends Node2D

@export var MAP: Map
@onready var cMovement := $MovementComponent as MovementComponent

# Input
var curr_input: String = ""
var last_input: String = ""
const input_buffer_time: float = 0.3
var input_life := input_buffer_time

# Movement
var target_position: Vector2
var is_moving := false

# Collision
var direction: Vector2i
var hit_tile: Vector2i

var _input2direction = {
		"ui_up": Vector2i.UP,
		"ui_down": Vector2i.DOWN,
		"ui_right": Vector2i.RIGHT,
		"ui_left": Vector2i.LEFT
}


func _ready() -> void:
	pass


func _input(event: InputEvent) -> void:
	var actions: Array[String] = ["ui_up", "ui_down", "ui_left", "ui_right"]
	for action_name in actions:
		if event.is_action_pressed(action_name):
			if action_name != last_input:
				curr_input = action_name
				input_life = input_buffer_time


func _physics_process(delta: float) -> void:
	if is_moving:
		# If we finished moving:
		if not cMovement.move_to(delta, self, target_position):
			is_moving = false
			last_input = ""
			
			var last_speed := cMovement.speed
			cMovement.speed = Vector2.ZERO
			
			# Signal enemies if we hit one of them
			var enemy: Enemy = MAP.get_enemy(hit_tile)
			if enemy:
				MAP.enemy_hit.emit(direction, last_speed, enemy)


func _process(delta: float) -> void:
	if input_life > 0.0:
		input_life -= delta
		
	var current_tile: Vector2i = MAP.local_to_map(global_position)
	if not is_moving and input_life > 0.0 and curr_input != "":
		# Get direction of movement and clear input
		last_input = curr_input
		direction = _input2direction[curr_input]
		curr_input = ""
		
		# Find target position and start movement
		hit_tile = MAP.tile_raycast(current_tile, direction)
		var target_tile := hit_tile - direction
		target_position = MAP.map_to_local(target_tile)
		is_moving = true
