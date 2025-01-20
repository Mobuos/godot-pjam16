class_name MovementComponent
extends Node

var _is_overshooting: bool = false

@export var acceleration := 250.0
@export var max_speed := 800.0
@export var overshoot_distance: float = 8.0
var speed := Vector2.ZERO

## Moves given node towards target given current speed, acceleration and
## overshoot. Returns if the object is still moving
## Should be called inside _physics_process()
## Does not reset its own speed after finishing.
func move_to(delta: float, node: Node2D, 
		target_position: Vector2) -> bool:
	
	var direction: Vector2i = (target_position - node.global_position).normalized()
	var distance_to_target: float = node.global_position.distance_to(target_position)
	
	speed += direction * acceleration * delta
	speed.clamp(Vector2.ZERO, Vector2(max_speed, max_speed))
	
	if target_position == node.global_position:
		return false
	
	if _is_overshooting:
		# Snap back to the target position after overshooting
		if distance_to_target <= 5.0:
			node.global_position = target_position
			speed = Vector2.ZERO
			_is_overshooting = false
			return false
		else:
			node.global_position += speed
			return true
	else:
		# Normal movement logic
		if distance_to_target < max(abs(speed.x), abs(speed.y)):
			# Allow overshoot
			node.global_position = target_position
			node.global_position += direction * overshoot_distance
			speed = Vector2.ZERO
			_is_overshooting = true
		else:
			node.global_position += speed
		return true
