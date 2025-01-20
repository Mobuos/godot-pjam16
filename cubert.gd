extends Node2D

@export var curve: Curve

@onready var tile_map := $"../Background" as TileMapLayer
@onready var sprite := $Sprite2D as Sprite2D

var is_moving := false
var input_queue: Array[String] = []

var DEBUG := false
var debug_label: RichTextLabel

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
	var target_tile := current_tile
	while true:
		var next_tile := Vector2i(
				target_tile.x + direction.x,
				target_tile.y + direction.y
		)
		var tile_data: TileData = tile_map.get_cell_tile_data(next_tile)
		if tile_data.get_custom_data("walkable"):
			target_tile = next_tile
		else:
			break
	
	if target_tile == current_tile:
		return
	
	# Move the player
	#TODO: Re-do movement logic to use actual acceleration and speed for movement instead of animation
	is_moving = true
	global_position = tile_map.map_to_local(target_tile)
	sprite.global_position = tile_map.map_to_local(current_tile)
	
	var tween := create_tween()
	tween.tween_property(sprite, "global_position", global_position, 0.05 * current_tile.distance_to(target_tile)) \
			.set_custom_interpolator(movement_curve)
	await tween.finished
	
	is_moving = false
	
	#if DEBUG:
		#debug_label.global_position = tile_map.map_to_local(target_tile) - Vector2(16., 16.)
		#debug_label.text = "[color=black]%s[/color]" % target_tile
func movement_curve(value: float) -> float:
	return curve.sample_baked(value)
