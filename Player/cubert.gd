extends Node2D

@onready var tile_map := $"../Background" as TileMapLayer

var is_moving := false
var input_queue: Array[String] = []

var DEBUG := false
var debug_label: RichTextLabel

var speed := Vector2.ZERO
var acc := 250.0
var max_speed := 800.0
var target_tile := Vector2i.ZERO
var overshoot_distance: float = 8.0
var is_overshooting: bool = false


func _ready() -> void:
	if DEBUG:
		debug_label = RichTextLabel.new()
		debug_label.size = Vector2(100., 100.)
		debug_label.bbcode_enabled = true
		debug_label.text = "[color=black]test[/color]"
		add_child(debug_label)


func _input(event: InputEvent) -> void:
	#TODO: Revise input queue to be able to customize how many frames in the past of input we are
	#      storing. Don't add same input to the queue, don't consume the queue until !is_moving
	#      Might even reduce the queue to just a single item.
	var actions: Array[String] = ["ui_up", "ui_down", "ui_left", "ui_right"]
	for action_name in actions:
		if event.is_action_pressed(action_name):
			if not input_queue.has(action_name):
				input_queue.push_front(action_name)
			break
		elif event.is_action_released(action_name):
			input_queue.erase(action_name)
			break


func _physics_process(delta: float) -> void:
	if not is_moving:
		return
	
	var target_position := tile_map.map_to_local(target_tile)
	var direction := (target_position - global_position).normalized()
	var distance_to_target := global_position.distance_to(target_position)
	
	speed += direction * acc * delta
	speed.clamp(Vector2.ZERO, Vector2(max_speed, max_speed))
	
	if is_overshooting:
		# Snap back to the target position after overshooting
		if distance_to_target <= 5.0:
			position = target_position
			speed = Vector2.ZERO
			is_moving = false
			is_overshooting = false
		else:
			position += speed
	else:
		# Normal movement logic
		if distance_to_target < max(abs(speed.x), abs(speed.y)):
			# Allow overshoot
			position = target_position
			position += direction * overshoot_distance
			speed = Vector2.ZERO
			is_overshooting = true
		else:
			position += speed


func _process(_delta: float) -> void:
	for action_name in input_queue:
		if action_name == "ui_up":
			move(Vector2i.UP)
		elif action_name == "ui_down":
			move(Vector2i.DOWN)
		elif action_name == "ui_left":
			move(Vector2i.LEFT)
		elif action_name == "ui_right":
			move(Vector2i.RIGHT)
		
	#if DEBUG:
		#var mouse_pos = get_viewport().get_mouse_position()
		#debug_label.global_position = mouse_pos + Vector2(10, 10)
		#debug_label.text = "[color=black]%s[/color]" % tile_map.local_to_map(mouse_pos)


func move(direction: Vector2i) -> void:
	if is_moving:
		return
		
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	
	# Find target_tile
	target_tile = current_tile
	while true:
		var next_tile := Vector2i(
				target_tile.x + direction.x,
				target_tile.y + direction.y
		)
		var tile_data: TileData = tile_map.get_cell_tile_data(next_tile)
		if tile_data.get_custom_data("walkable") and \
			not get_parent().enemies.has(next_tile):
			target_tile = next_tile
		else:
			break
	
	if target_tile == current_tile:
		#TODO: add small overshoot when trying to hit the wall
		return
	else:
		is_moving = true
