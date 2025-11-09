extends Node3D

@export var farmWidth: int = 20:
	set(value):
		farmWidth = value
		_remove_grid()
		_create_grid()
@export var farmHeight: int = 20:
	set(value):
		farmHeight = value
		_remove_grid()
		_create_grid()
@export var cellSize: Vector2 = Vector2(1, 1)
@export var defaultColor: Color = Color.SADDLE_BROWN #temp-ish

const DIRT_PILE = preload("res://Objects/DirtPile.tscn")

func _ready() -> void:
	_create_grid()

func _remove_grid() -> void:
	for node in get_children():
		node.queue_free()
		
func _create_grid() -> void:
	for height in range(farmHeight):
		for width in range(farmWidth):
			var dirtPile = DIRT_PILE.instantiate()
			add_child(dirtPile)
			
			var offset = Vector3(width * cellSize.x, 0, height * cellSize.y)
			dirtPile.global_position = global_position + offset
