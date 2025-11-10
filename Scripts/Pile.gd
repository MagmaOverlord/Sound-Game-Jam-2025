class_name DirtPile
extends Area3D

@onready var pileModel: MeshInstance3D = $DirtPileModel
@onready var defaultColor: Color = pileModel.get_surface_override_material(0).albedo_color
@onready var pileCollision: CollisionShape3D = $DirtPileCollision

var pileSize: Vector2 = Vector2(0.7, 0.7)
var farmPos: Vector2i
var full = false

func change_color(newColor: Color) -> void:
	pileModel.mesh.material.albedo_color = newColor

func get_rect() -> Rect2:
	return Rect2(Vector2(global_position.x, global_position.y), pileSize)

func plant(plant) -> void:
	var shouldDisable: bool = get_parent().plant(plant, farmPos, global_position)
	if shouldDisable:
		disable()

func disable() -> void:
	hide()
	pileCollision.disabled = true
	
func enable() -> void:
	show()
	pileCollision.disabled = false
