extends Node

@export var maps: Array[PackedScene]
@export var CAMERA: Camera2D
@onready var scene_transition: SceneTransition = %SceneTransitionRect

var curr_map_index := 0
var curr_map: Map

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_map(0)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		load_map(curr_map_index)
	if event.is_action_pressed("cheat_left"):
		if curr_map_index > 0:
			curr_map_index -= 1
			load_map(curr_map_index)
	if event.is_action_pressed("cheat_right"):
		next_map()


func next_map() -> void:
	if curr_map_index < maps.size() - 1:
		curr_map_index += 1
		load_map(curr_map_index)


func load_map(num: int) -> void:
	if maps.size() > curr_map_index:
		set_process_input(false)
		scene_transition._anim_player.play("Fade")
		await scene_transition._anim_player.animation_finished
		if curr_map:
			curr_map.queue_free()
			await curr_map.tree_exited
		var map: Map = maps[num].instantiate()
		curr_map = map
		map.level_clear.connect(next_map)
		add_child(map)
		
		scene_transition._anim_player.play_backwards("Fade")
		await scene_transition._anim_player.animation_finished
		
		set_process_input(true)


func _on_reset_button_pressed() -> void:
	load_map(curr_map_index)
