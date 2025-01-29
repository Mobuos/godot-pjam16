extends Node2D

@export var MAP: Map
@onready var cMovement := $MovementComponent as MovementComponent
@onready var shaker: ShakerComponent = Global.shaker
@onready var sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var HIT_PARTICLES := $HitParticles as GPUParticles2D

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
	# Fix position to closest tile, I don't know why this fixes
	# The issue I was having but it does
	# Also this isn't needed anywhere else, I really don't understand
	position = MAP.map_to_local(MAP.local_to_map(position))
	
	print("[DEBUG] Info at ready:")
	print(" pos: ", position)
	print(" global_pos: ", global_position)
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
			sprite.animation = "Idle"
			last_input = ""
			
			var last_velocity := cMovement.velocity
			cMovement.velocity = 0.0
			
			# Signal enemies if we hit one of them
			var enemy: Enemy = MAP.get_enemy(hit_tile)
			if enemy:
				MAP.enemy_hit.emit(direction, last_velocity, enemy)
			else:
				if (last_velocity < 50):
					pass
				else:
					# Hitting a wall
					Global.play(Global.Bangs.MEDIUM)
					shaker.increase_trauma2(direction * 0.5)
					
					match direction:
						Vector2i(0, 1):
							HIT_PARTICLES.rotation = PI * 0
						Vector2i(0, -1):
							HIT_PARTICLES.rotation = PI * 1
						Vector2i(1, 0):
							HIT_PARTICLES.rotation = PI * 1.5
						Vector2i(-1, 0):
							HIT_PARTICLES.rotation = PI * 0.5
					HIT_PARTICLES.restart()
					HIT_PARTICLES.emitting = true

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
		
		# Set movement sprite
		sprite.animation = "Move"
		
		print("[DEBUG] Info at hit_tile:")
		print(" pos: ", position)
		print(" global_pos: ", global_position)


func _freeze_frame(time_scale: float, duration: float) -> void:
		Engine.time_scale = time_scale
		await(get_tree().create_timer(duration, true, false, true).timeout)
		Engine.time_scale = 1
