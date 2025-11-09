extends Node3D

#constants
const growthTime: float = 30 #in seconds
const flowerVisibleTimeRatio = 0.75 #fraction of time when flower becomes visible
const rhythm: int = 4 #changes per plant, this one's for drums I believe

#status tracking
var isGrown: bool = false
var isGrowing: bool = false

#models & model info
@onready var stemModel: MeshInstance3D = $Model/PlantStem
@onready var stemMaxScale: Vector3 = stemModel.scale
@onready var flowerModel: MeshInstance3D = $Model/Flower
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
	growTimer.wait_time = growthTime
	
	water() #TEMP FOR TESTING
	
func _process(delta) -> void:
	if isGrowing:
		var growthRatio = (growthTime - growTimer.time_left) / growthTime
		stemModel.position.y = stemModel.scale.y #might need to change for real models
		if growthRatio >= flowerVisibleTimeRatio:
			if not flowerModel.visible:
				flowerModel.visible = true
			flowerModel.position.y = stemModel.position.y * 2 #might need to change for real models
	elif isGrown:
		print("fully grown!")
		#play musicassociated with plant

func water() -> void:
	if not (isGrowing or isGrown):
		isGrowing = true
		growTimer.start()
		#set up tween for growing "animation"
		tween = get_tree().create_tween()
		tween.set_parallel()
		tween.tween_property(stemModel, "scale", stemMaxScale, growthTime)
		var timeToFlower = growthTime * flowerVisibleTimeRatio
		tween.tween_property(flowerModel, "scale", flowerMaxScale, growthTime - timeToFlower).set_delay(timeToFlower)
		tween.connect("tween_all_completed",queue_free) #destroy the node once all tweens are completed
		

func _on_growth_timer_timeout() -> void:
	isGrowing = false
	isGrown = true
