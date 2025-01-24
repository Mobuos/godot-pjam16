class_name Enemy
extends Node2D

@export var cMovement: MovementComponent
@export var MAP: Map

@onready var shaker: ShakerComponent = Global.shaker

var target_position: Vector2i
var is_moving := false
var last_direction: Vector2i

var alive := true
var dead_texture: Texture2D = preload("res://kenney_scribble-dungeons/PNG/Default (64px)/Characters/purple_character.png")


func _physics_process(delta: float) -> void:
	if is_moving:
		# If we finished moving:
		if not cMovement.move_to(delta, self, target_position):
			is_moving = false
			#var last_velocity := cMovement.velocity
			cMovement.velocity = 0.0
			
			if alive:
				MAP.kill_enemy()
				alive = false
			
			#TODO: Signal further?
			# Remember to move this elsewhere if we signal further in the future
			shaker.increase_trauma2(last_direction * 0.1)
			#TODO: - Sound effect
			$Sprite2D.texture = dead_texture

func _on_hit(direction: Vector2i, velocity: float, enemy: Enemy) -> void:
	if enemy == self:
		last_direction = direction
		_freeze_frame(0.001, 0.05)
		
		shaker.increase_trauma2(direction * 0.3)
		#TODO: sound effect
		cMovement.velocity = max(1000.0, velocity * 1.2)
		
		# Find target position and start movement
		var current_tile := MAP.local_to_map(global_position)
		var hit_tile := MAP.tile_raycast(current_tile, direction)
		var target_tile := hit_tile - direction
		target_position = MAP.map_to_local(target_tile)
		is_moving = true
		
		# Enemy should exist in the logical map
		assert(MAP.update_enemy(current_tile, target_tile))


func _freeze_frame(time_scale: float, duration: float) -> void:
		Engine.time_scale = time_scale
		await(get_tree().create_timer(duration, true, false, true).timeout)
		Engine.time_scale = 1
