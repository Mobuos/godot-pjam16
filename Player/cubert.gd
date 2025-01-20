extends Node2D

@onready var tile_map := $"../Background" as TileMapLayer
@onready var cMovement := $MovementComponent as MovementComponent

var curr_input: String = ""
var last_input: String = ""
const input_buffer_time: float = 0.3
var input_life := input_buffer_time

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
			if action_name != last_input:
				curr_input = action_name
				input_life = input_buffer_time


func _process(delta: float) -> void:
	if input_life > 0.0:
		input_life -= delta
		
	var current_tile: Vector2i = tile_map.local_to_map(global_position)
	if not cMovement.is_moving() and input_life > 0.0:
		last_input = curr_input
		if curr_input == "ui_up":
			cMovement.move(Vector2i.UP, current_tile)
		elif curr_input == "ui_down":
			cMovement.move(Vector2i.DOWN, current_tile)
		elif curr_input == "ui_left":
			cMovement.move(Vector2i.LEFT, current_tile)
		elif curr_input == "ui_right":
			cMovement.move(Vector2i.RIGHT, current_tile)
		curr_input = ""
		
	#if DEBUG:
		#var mouse_pos = get_viewport().get_mouse_position()
		#debug_label.global_position = mouse_pos + Vector2(10, 10)
		#debug_label.text = "[color=black]%s[/color]" % tile_map.local_to_map(mouse_pos)


# Checks if we are supposed to emit a hit signal
# Called after impact
func _finished_movement(direction: Vector2i, hit: Node2D) -> bool:
	last_input = ""
	if hit != null:
		get_parent().enemy_hit.emit(hit, direction)
		return true
	else:
		return false
