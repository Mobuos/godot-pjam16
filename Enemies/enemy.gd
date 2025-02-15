class_name Enemy
extends Node2D

@export var cMovement: MovementComponent
@export var MAP: Map

@onready var shaker: ShakerComponent = Global.shaker
@onready var sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var HIT_PARTICLES := $HitParticles as GPUParticles2D

var target_position: Vector2i
var is_moving := false
var last_direction: Vector2i

var alive := true

func _ready() -> void:
	# Use particles at the beginning to avoid freezes later
	if not Global.loaded_enemy:
		HIT_PARTICLES.emitting = true
		Global.loaded_enemy = true

func _physics_process(delta: float) -> void:
	if is_moving:
		# If we finished moving:
		if not cMovement.move_to(delta, self, target_position):
			is_moving = false
			#var last_velocity := cMovement.velocity
			cMovement.velocity = 0.0
			
			if alive:
				MAP.kill_enemy()
				Global.play(Global.Bangs.HEAVY)
				alive = false
				
			
			#TODO: Signal further?
			# Remember to move this elsewhere if we signal further in the future
			
			match last_direction:
				Vector2i(0, 1):
					HIT_PARTICLES.rotation = PI * 0.5
				Vector2i(0, -1):
					HIT_PARTICLES.rotation = PI * 1.5
				Vector2i(1, 0):
					HIT_PARTICLES.rotation = PI * 0
				Vector2i(-1, 0):
					HIT_PARTICLES.rotation = PI * 1
			HIT_PARTICLES.restart()
			HIT_PARTICLES.emitting = true
			
			shaker.increase_trauma2(last_direction * 0.1)
				
			sprite.animation = "Dead"

func _on_hit(direction: Vector2i, velocity: float, enemy: Enemy) -> void:
	if enemy == self:
		last_direction = direction
		_freeze_frame(0.001, 0.05)
		
		shaker.increase_trauma2(direction * 0.3)
		Global.play(Global.Bangs.LIGHT)
		cMovement.velocity = max(1000.0, velocity * 1.2)
		
		# Find target position and start movement
		var current_tile := MAP.local_to_map(global_position)
		var hit_tile := MAP.tile_raycast(current_tile, direction)
		var target_tile := hit_tile - direction
		target_position = MAP.map_to_local(target_tile)
		is_moving = true
		
		# Enemy should exist in the logical map
		MAP.update_enemy(current_tile, target_tile)


func _freeze_frame(time_scale: float, duration: float) -> void:
		Engine.time_scale = time_scale
		await(get_tree().create_timer(duration, true, false, true).timeout)
		Engine.time_scale = 1
