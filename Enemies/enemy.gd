extends Node2D

@onready var cMovement := $MovementComponent as MovementComponent
@onready var controller: Node = get_parent()
@export var tile_map: TileMapLayer

var dead_texture = preload("res://kenney_scribble-dungeons/PNG/Default (64px)/Characters/purple_character.png")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().enemy_hit.connect(_on_hit)
	cMovement.tile_map = tile_map
	cMovement.controller = controller
	pass # Replace with function body.


func _on_hit(enemy: Node2D, direction: Vector2i) -> void:
	if enemy == self:
		var current_tile: Vector2i = tile_map.local_to_map(global_position)
		controller.enemies.erase(current_tile)
		var target_position: = cMovement.move(direction, current_tile)
		controller.enemies[tile_map.local_to_map(target_position)] = self


func _finished_movement(direction: Vector2i, hit: Node2D) -> void:
	var spr: Sprite2D = $Sprite2D as Sprite2D
	spr.texture = dead_texture
