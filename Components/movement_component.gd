class_name MovementComponent
extends Node

@export var tile_map: TileMapLayer
@export var controller: Node

signal _finished_movement(direction: Vector2i, hit: Node2D)

var _is_moving := false

var speed := Vector2.ZERO
var acc := 250.0
var max_speed := 800.0
var overshoot_distance: float = 8.0
var is_overshooting: bool = false
var target_position: Vector2
var hit_target: Node = null
var move_direction: Vector2i

func _physics_process(delta: float) -> void:
	if not _is_moving:
		return
	
	var direction: Vector2i = (target_position - get_parent().global_position).normalized()
	var distance_to_target: float = get_parent().global_position.distance_to(target_position)
	
	speed += direction * acc * delta
	speed.clamp(Vector2.ZERO, Vector2(max_speed, max_speed))
	
	if is_overshooting:
		# Snap back to the target position after overshooting
		if distance_to_target <= 5.0:
			get_parent().global_position = target_position
			speed = Vector2.ZERO
			_is_moving = false
			is_overshooting = false
			_finished_movement.emit(move_direction, hit_target)
		else:
			get_parent().global_position += speed
	else:
		# Normal movement logic
		if distance_to_target < max(abs(speed.x), abs(speed.y)):
			# Allow overshoot
			get_parent().global_position = target_position
			get_parent().global_position += direction * overshoot_distance
			speed = Vector2.ZERO
			is_overshooting = true
		else:
			get_parent().global_position += speed


func is_moving() -> bool:
	return _is_moving


func move(direction: Vector2i, current_tile: Vector2i) -> Vector2:
	if _is_moving:
		return target_position
	
	move_direction = direction
	
	# Find target_tile
	var target_tile := current_tile
	while true:
		var next_tile := Vector2i(
				target_tile.x + direction.x,
				target_tile.y + direction.y
		)
		var tile_data: TileData = tile_map.get_cell_tile_data(next_tile)
		if tile_data.get_custom_data("walkable") and \
			not controller.enemies.has(next_tile):
			target_tile = next_tile
		elif controller.enemies.has(next_tile):
			# If the collision is with an enemy, add a reference to it to hit_target
			hit_target = controller.enemies.get(next_tile)
			break
		else:
			hit_target = null
			break
	
	if target_tile == current_tile:
		_finished_movement.emit(move_direction, hit_target)
			
		#TODO: add small overshoot when trying to hit the wall
		return target_position
	else:
		target_position = tile_map.map_to_local(target_tile)
		_is_moving = true
	
	return target_position
