extends CharacterBody3D 

#constants
const SPEED: float = 5.0 #movement speed
const SENSITIVITY: float = 0.003 #camera sensitivity
const BOB_FREQ: float = 2.0 #camera bob frequency
const BOB_AMP: float = 0.04 #camera bob amplitude
const RAY_LENGTH: float = 3.0 #maximum distance to interact with an object
const PLANT_COLLISION_MASK: int = 2
#the plants in the array position of their rhythm (might need to tweak later)
const PLANTS: Array = [null, null, preload("res://Objects/Plants/Rhythm3Plant.tscn"), preload("res://Objects/Plants/Rhythm4Plant.tscn"), 
preload("res://Objects/Plants/Rhythm5Plant.tscn"), preload("res://Objects/Plants/Rhythm6Plant.tscn"), preload("res://Objects/Plants/Rhythm7Plant.tscn")] 
const MIN_PLANT: int = 3 #minimum rhythm
const MAX_PLANT: int = 7 #maximum rhythm

#get gravity from project settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

#pause menu
@onready var pause_menu = $Neck/Camera3D/PauseMenu
var paused: bool = false

#inventory
var selected = 1
var seedSelected = 3
@onready var hotbar = $Neck/Camera3D/Hotbar
@onready var seedSelectedText = $Neck/Camera3D/SeedSelectedText

#camera stuff
@onready var neck: Node3D = $Neck
@onready var camera: Camera3D = $Neck/Camera3D
var t_bob: float = 0.0 #how far along the camera bob we are

#Audio Stuff
var vol3 : int = -80
var vol4 : int = -80
var vol6 : int = -80
var vol57 : int = -80
var plantTracker: Array = []
@onready var plantDetector: Area3D = $PlantDetection

func _ready() -> void:
	pause_menu.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hotbar.select(0)
	plantTracker.resize(PLANTS.size())
	plantTracker.fill(false)
	
	#Triggers Game Audio
	#$"FmodEventEmitter3D - Music".play()

func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		neck.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-75), deg_to_rad(75))

func _physics_process(delta) -> void:
	var direction: Vector3 = Vector3.ZERO
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	#detect plants in vicinity
	var items_found = plantDetector.get_overlapping_bodies()
	plantTracker.fill(false)
	for item in items_found:
		if item.get_parent() is Plant and item.get_parent().status == "fullgrown":
			plantTracker[item.get_parent().RHYTHM - 1] = true
	
	#handle raycasts
	#actions
	if Input.is_action_just_pressed("use_item"):
		var space_state = get_world_3d().direct_space_state
		var cam = $Neck/Camera3D
		var mousepos = get_viewport().get_mouse_position() #kinda dumb since mouse is always in middle, might fix later

		var origin = cam.project_ray_origin(mousepos)
		var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
		var query = PhysicsRayQueryParameters3D.create(origin, end, PLANT_COLLISION_MASK, [self])
		query.collide_with_areas = true
		var result = space_state.intersect_ray(query)
		if result:
			if selected == 3 and result.collider.get_parent() is Plant:
				#the collider is a child of the base node
				result.collider.get_parent().water()
			elif selected == 2 and result.collider.get_parent() is Plant:
				#remove plant (easy) and add back dirt pile (harder)
				result.collider.get_parent().associatedDirtPile.enable()
				result.collider.get_parent().queue_free()
				pass
			elif selected == 1 and result.collider is DirtPile:
				#the collider is the base node (very intelligent to have it inconsistent, I know)
				result.collider.plant(PLANTS[seedSelected - 1])
	
	#handle directional movement
	var input_dir: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	direction = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 7.0)
		velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 7.0)
		
	#head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	
	#stepping effect
	if input_dir != Vector2.ZERO and fmod(snappedf(t_bob, 0.1), BOB_FREQ * 2) == 0: 
		$"FmodEventEmitter3D - Steps".play()
	
	move_and_slide()

#
func _process(_delta: float) -> void:
	if plantTracker[2] :
		if $"AudioStreamPlayer _ Piano3".volume_db < -2.0 :
			$"AudioStreamPlayer _ Piano3".volume_db += 0.1
	else :
		if $"AudioStreamPlayer _ Piano3".volume_db > -80.0 :
			$"AudioStreamPlayer _ Piano3".volume_db -= 0.1
	
	if plantTracker[3] :
		if $"AudioStreamPlayer _ Guitars4".volume_db < -2.0 :
			$"AudioStreamPlayer _ Guitars4".volume_db += 0.1
	else :
		if $"AudioStreamPlayer _ Guitars4".volume_db > -80.0 :
			$"AudioStreamPlayer _ Guitars4".volume_db -= 0.1
			
	if plantTracker[4] :
		if $"AudioStreamPlayer _ 5-7".volume_db < -2.0 :
			$"AudioStreamPlayer _ 5-7".volume_db += 0.1
	else :
		if $"AudioStreamPlayer _ 5-7".volume_db > -80.0 :
			$"AudioStreamPlayer _ 5-7".volume_db -= 0.1
			
	if plantTracker[5] :
		if $"AudioStreamPlayer _ Rodes6".volume_db < -2.0 :
			$"AudioStreamPlayer _ Rodes6".volume_db += 0.1
	else :
		if $"AudioStreamPlayer _ Rodes6".volume_db > -80.0 :
			$"AudioStreamPlayer _ Rodes6".volume_db -= 0.1
	# ----
	# Inputs (non-movemeent)
	# ----
	
	#inventory management
	if Input.is_action_just_pressed("select_seeds"):
		selected = 1
		hotbar.select(0)
	elif Input.is_action_just_pressed("select_shovel"):
		selected = 2
		hotbar.select(1)
	elif Input.is_action_just_pressed("select_watering_can"):
		selected = 3
		hotbar.select(2)
	elif Input.is_action_just_pressed("select_scissors"):
		selected = 4
		hotbar.select(3)
	elif Input.is_action_just_pressed("increase_selected_seed_rhythm"):
		seedSelected = clamp(seedSelected + 1, MIN_PLANT, MAX_PLANT)
		seedSelectedText.text = "Seed Rhythm: " + str(seedSelected)
	elif Input.is_action_just_pressed("decrease_selected_seed_rhythm"):
		seedSelected = clamp(seedSelected - 1, MIN_PLANT, MAX_PLANT)
		seedSelectedText.text = "Seed Rhythm: " + str(seedSelected)
	elif Input.is_action_just_pressed("pause"):
		#get_tree().paused = true
		pauseMenu()
		

func _headbob(time: float) -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	
	return pos

func pauseMenu() -> void:
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		pause_menu.show()
		Engine.time_scale = 0
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	paused = !paused
	
#func _fade_in(Audio):
#	if vol
