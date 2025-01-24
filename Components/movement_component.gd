class_name MovementComponent
extends Node

#var _is_overshooting: bool = false

@export var acceleration := 40.0
@export var max_velocity := 120.0
@export var overshoot_distance: float = 8.0
var velocity := 10.0

## Moves given node towards target given current speed, acceleration and
## overshoot. Returns if the object is still moving
## Should be called inside _physics_process()
## Does not reset its own speed after finishing.
func move_to(delta: float, node: Node2D, 
		target_position: Vector2) -> bool:
	
	var direction: Vector2i = (target_position - node.global_position).normalized()
	var distance_to_target: float = node.global_position.distance_to(target_position)
	
	velocity += acceleration * delta
	node.global_position += direction * velocity * delta 
	
	if distance_to_target < velocity * delta:
		node.global_position = target_position
		return false
	else:
		return true
	
	#speed += acceleration * delta
	#speed = max(0.0, max_speed)
	#
	#if target_position == node.global_position:
		#return false
	#
	#if _is_overshooting:
		## Snap back to the target position after overshooting
		#if distance_to_target <= 5.0:
			#node.global_position = target_position
			#_is_overshooting = false
			#return false
		#else:
			#node.global_position += direction * speed * delta
			#return true
	#else:
		## Normal movement logic
		#if distance_to_target < abs(speed):
			## Allow overshoot
			#node.global_position = target_position
			#node.global_position += direction * delta * overshoot_distance
			#_is_overshooting = true
		#else:
			#node.global_position += direction * speed * delta
		#return true
	
	
