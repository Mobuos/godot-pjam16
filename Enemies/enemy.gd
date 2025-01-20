class_name Enemy
extends Node2D

@export var cMovement: MovementComponent
@export var MAP: Map

var target_position: Vector2i
var is_moving := false

var dead_texture: Texture2D = preload("res://kenney_scribble-dungeons/PNG/Default (64px)/Characters/purple_character.png")


func _physics_process(delta: float) -> void:
	if is_moving:
		# If we finished moving:
		if not cMovement.move_to(delta, self, target_position):
			is_moving = false
			#var last_speed := cMovement.speed
			cMovement.speed = Vector2.ZERO
			
			#TODO: Signal further?
			
			#TODO: die
			$Sprite2D.texture = dead_texture

func _on_hit(direction: Vector2i, speed: Vector2, enemy: Enemy) -> void:
	if enemy == self:
		cMovement.speed = speed
		
		# Find target position and start movement
		var current_tile := MAP.local_to_map(global_position)
		var hit_tile := MAP.tile_raycast(current_tile, direction)
		var target_tile := hit_tile - direction
		target_position = MAP.map_to_local(target_tile)
		is_moving = true
		
		# Enemy should exist in the logical map
		assert(MAP.update_enemy(current_tile, target_tile))
