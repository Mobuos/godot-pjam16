extends Node

@onready var tile_map := $Background as TileMapLayer

var enemies := {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for enemy: Node2D in get_tree().get_nodes_in_group("Enemies"):
		var tile_position := tile_map.local_to_map(enemy.global_position)
		assert(not enemies.has(tile_position))
		enemies.get_or_add(tile_position)
		
