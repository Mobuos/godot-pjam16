class_name Map
extends Node

@onready var TILE_MAP := $Background as TileMapLayer

signal enemy_hit(direction: Vector2i, speed: Vector2, enemy: Node2D)

var enemies := {}


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for enemy: Node2D in get_tree().get_nodes_in_group("Enemies"):
		var tile_position := TILE_MAP.local_to_map(enemy.global_position)
		enemy_hit.connect(enemy._on_hit)
		assert(not enemies.has(tile_position))
		enemies[tile_position] = enemy

## Updates the position of an enemy in the logical map
## Returns false if the enemy wasn't found
func update_enemy(old_pos: Vector2i, new_pos: Vector2i) -> bool:
	if enemies.has(old_pos):
		var enemy: Enemy = enemies[old_pos]
		enemies.erase(old_pos)
		enemies[new_pos] = enemy
		return true
	return false

## Returns if a tile is empty / walkable
func is_empty_tile(tile: Vector2i) -> bool:
	var tile_data: TileData = TILE_MAP.get_cell_tile_data(tile)
	return tile_data.get_custom_data("walkable") and \
		not enemies.has(tile)


## Returns the position of first collision of a ray shot from origin
## towards direction
func tile_raycast(origin_tile: Vector2i, direction: Vector2i) -> Vector2i:
	var hit_tile := origin_tile
	while true:
		hit_tile = hit_tile + direction
		if not is_empty_tile(hit_tile):
			return hit_tile
	
	assert(false) # Should not reach this point
	return Vector2i.MIN


## Returns the empty at a given tile if any, otherwise returns null
func get_enemy(tile: Vector2i) -> Enemy:
	return enemies.get(tile)
	


func map_to_local(tile: Vector2i) -> Vector2:
	return TILE_MAP.map_to_local(tile)


func local_to_map(position: Vector2) -> Vector2i:
	return TILE_MAP.local_to_map(position)
