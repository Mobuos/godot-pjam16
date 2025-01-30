class_name Map
extends Node

@export var TILE_MAP: TileMapLayer

signal enemy_hit(direction: Vector2i, speed: Vector2, enemy: Node2D)
signal level_clear

var enemies_pos := {}
var num_enemies_alive := 0

#var debug_label: RichTextLabel

#func _input(event: InputEvent) -> void:
	## Mouse in viewport coordinates.
	#if event is InputEventMouseButton:
		#print("Mouse Click/Unclick at: ", event.position)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#debug_label = RichTextLabel.new()
	#debug_label.size = Vector2(100., 100.)
	#debug_label.bbcode_enabled = true
	#debug_label.text = "[color=white]test[/color]"
	#add_child(debug_label)
	# Initialize enemy info
	for enemy: Node2D in get_tree().get_nodes_in_group("Enemies"):
		var tile_position := TILE_MAP.local_to_map(enemy.global_position)
		enemy_hit.connect(enemy._on_hit)
		assert(not enemies_pos.has(tile_position))
		enemies_pos[tile_position] = enemy
		num_enemies_alive += 1

	# Position camera
	var rect: Rect2i = TILE_MAP.get_used_rect()
	Global.camera.position = TILE_MAP.map_to_local(rect.get_center())

#func _process(delta: float) -> void:
	#var mouse_pos = Global.camera.get_global_mouse_position()
	#debug_label.global_position = mouse_pos
	#debug_label.text = "[color=white]%s[/color]" % TILE_MAP.local_to_map(TILE_MAP.to_local(mouse_pos))


## Updates the position of an enemy in the logical map
## Returns false if the enemy wasn't found
func update_enemy(old_pos: Vector2i, new_pos: Vector2i) -> bool:
	if enemies_pos.has(old_pos):
		var enemy: Enemy = enemies_pos[old_pos]
		enemies_pos.erase(old_pos)
		enemies_pos[new_pos] = enemy
		return true
	return false


func kill_enemy() -> void:
	if num_enemies_alive > 0:
		num_enemies_alive -= 1
		if num_enemies_alive <= 0:
			level_clear.emit()


## Returns if a tile is empty / walkable
func is_empty_tile(tile: Vector2i) -> bool:
	var tile_data: TileData = TILE_MAP.get_cell_tile_data(tile)
	return tile_data.get_custom_data("walkable") and \
		not enemies_pos.has(tile)


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
	return enemies_pos.get(tile)


func map_to_local(tile: Vector2i) -> Vector2:
	return TILE_MAP.map_to_local(tile)


func local_to_map(position: Vector2) -> Vector2i:
	return TILE_MAP.local_to_map(position)
