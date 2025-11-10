class_name Plant
extends Node3D

#constants
const GROWTH_TIME: float = 5 #in seconds
const FLOWER_VISIBLE_TIME_RATIO = 0.75 #fraction of time when flower becomes visible
@export var RHYTHM: int = 4 #changes per plant

#status tracking
var status: String = "seed" #placing, seed, growing, fullgrown

#models & model info
@onready var seedModel: MeshInstance3D = $SeedModel/Seed
@onready var stemModel: MeshInstance3D = $PlantModel/Stem
@onready var stemMaxScale: Vector3 = stemModel.scale
@onready var flowerModel: MeshInstance3D = $PlantModel/Flower
@onready var flowerMaxScale: Vector3 = flowerModel.scale
@onready var flowerFinalPos: Vector3 = flowerModel.position
var tween: Tween

@onready var growTimer: Timer = $GrowTimer

func _ready() -> void:
	#initialize values
	stemModel.scale = Vector3.ZERO
	stemModel.position.y = 0
	flowerModel.scale = Vector3.ZERO
	flowerModel.visible = false
	growTimer.wait_time = GROWTH_TIME
	seedModel.visible = true
	
func _process(delta) -> void:
	if status == "growing":
		var growthRatio = (GROWTH_TIME - growTimer.time_left) / GROWTH_TIME
		stemModel.position.y = stemModel.scale.y #might need to change for real models
		if growthRatio >= FLOWER_VISIBLE_TIME_RATIO:
			if not flowerModel.visible:
				flowerModel.visible = true
			flowerModel.position.y = stemModel.position.y * 2 #might need to change for real models
	elif status == "fullgrown":
		pass #play music associated with plant

func water() -> void:
	if status == "seed":
		seedModel.visible = false
		status = "growing"
		growTimer.start()
		#set up tween for growing "animation"
		tween = get_tree().create_tween()
		tween.set_parallel()
		tween.tween_property(stemModel, "scale", stemMaxScale, GROWTH_TIME)
		var timeToFlower = GROWTH_TIME * FLOWER_VISIBLE_TIME_RATIO
		tween.tween_property(flowerModel, "scale", flowerMaxScale, GROWTH_TIME - timeToFlower).set_delay(timeToFlower)

func _on_growth_timer_timeout() -> void:
	status = "fullgrown"
