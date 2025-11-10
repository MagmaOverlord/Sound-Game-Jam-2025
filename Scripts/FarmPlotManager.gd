extends Node3D

var plantTracker: Array = []

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
	plantTracker = []
	for node in get_children():
		node.queue_free()
		
func _create_grid() -> void:
	for height in range(farmHeight):
		plantTracker.append([])
		for width in range(farmWidth):
			plantTracker[height].append(null)
			var dirtPile = DIRT_PILE.instantiate()
			dirtPile.farmPos = Vector2i(height, width)
			add_child(dirtPile)
			
			var offset = Vector3(width * cellSize.x, 0, height * cellSize.y)
			dirtPile.global_position = global_position + offset

func plant(plantPreload, farmPos: Vector2i, plantPos: Vector3) -> bool:
	var canPlant: bool = true
	var plant = plantPreload.instantiate()
	for i in range(plant.RHYTHM):
		for j in range(plant.RHYTHM):
			var plant1ToCheck = plantTracker[clamp(farmPos.x + i, 0, farmHeight - 1)][clamp(farmPos.y + j, 0, farmWidth - 1)]
			var plant2ToCheck = plantTracker[clamp(farmPos.x - i, 0, farmHeight - 1)][clamp(farmPos.y - j, 0, farmWidth - 1)]
			if (plant1ToCheck != null and plant1ToCheck.RHYTHM == plant.RHYTHM) or (plant2ToCheck != null and plant2ToCheck.RHYTHM == plant.RHYTHM):
				canPlant = false
				break
		if not canPlant:
			break
	if canPlant:
		get_tree().get_root().add_child(plant)
		plant.global_position = plantPos
		plantTracker[farmPos.x][farmPos.y] = plant
		for i in range(plantTracker.size()):
			print(plantTracker[i])
	
	return canPlant
