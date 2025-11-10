extends CharacterBody3D 

#constants
const SPEED: float = 5.0 #movement speed
const SENSITIVITY: float = 0.003 #camera sensitivity
const BOB_FREQ: float = 2.0 #camera bob frequency
const BOB_AMP: float = 0.04 #camera bob amplitude
const RAY_LENGTH: float = 3.0 #maximum distance to interact with an object
const PLANT_COLLISION_MASK: int = 2
#will later contain the plants in the array position of their rhythm (might need to tweak later)
const PLANTS: Array = [null, null, preload("res://Objects/Plants/Rhythm3Plant.tscn"), preload("res://Objects/Plants/Rhythm4Plant.tscn"), 
preload("res://Objects/Plants/Rhythm5Plant.tscn"), preload("res://Objects/Plants/Rhythm6Plant.tscn"), preload("res://Objects/Plants/Rhythm7Plant.tscn")] 

#get gravity from project settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

#inventory
var selected = 1
var seedSelected = 2
@onready var hotbar = $Neck/Camera3D/Hotbar
var rng = RandomNumberGenerator.new() #TEMP

#camera stuff
@onready var neck: Node3D = $Neck
@onready var camera: Camera3D = $Neck/Camera3D
var t_bob: float = 0.0 #how far along the camera bob we are

#Audio Stuff
var fmodParam3 : int
var fmodParam4 : int
var fmodParam6 : int
var fmodParam57 : int

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hotbar.select(0)
	
	#Triggers Game Audio
	$FmodEventEmitter3D.play()
	

func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		neck.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-75), deg_to_rad(75))

func _physics_process(delta) -> void:
	var direction: Vector3 = Vector3.ZERO
	if not is_on_floor():
		velocity.y -= gravity * delta
	
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
			elif selected == 1 and result.collider is DirtPile:
				#the collider is the base node (very intelligent to have it inconsistent, I know)
				result.collider.plant(PLANTS[seedSelected])
	
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
	
	move_and_slide()

#
func _process(_delta: float) -> void:
	#Set fmod parameters to distance between player and each matching garden
	#fmodParam3 = int(global_position.distance_to($"../Gardens/Temp garden for scale".global_position))
	#print(str($FmodEventEmitter3D.get_parameter_by_id(1450633991648769841)))
<<<<<<< HEAD
	
=======
	print(str($FmodEventEmitter3D["fmod_parameters/Dist3"]))
>>>>>>> 62bd4409c37fa459ea8e34b0c11d1f3e9117c657
	# ----
	# Inputs (non-movemeent)
	# ----
	
	#inventory management
	if Input.is_action_just_pressed("select_seeds"):
		selected = 1
		hotbar.select(0)
		#TEMP, to test plant types
		seedSelected = rng.randi_range(2, 6)
	elif Input.is_action_just_pressed("select_shovel"):
		selected = 2
		hotbar.select(1)
	elif Input.is_action_just_pressed("select_watering_can"):
		selected = 3
		hotbar.select(2)
	elif Input.is_action_just_pressed("select_scissors"):
		selected = 4
		hotbar.select(3)

func _headbob(time: float) -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
