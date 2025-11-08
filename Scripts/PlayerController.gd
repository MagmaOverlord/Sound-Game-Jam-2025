extends CharacterBody3D

#constants
const SPEED: float = 5.0 #movement speed
const SENSITIVITY: float = 0.003 #camera sensitivity
const BOB_FREQ: float = 2.0 #camera bob frequency
const BOB_AMP: float = 0.04 #camera bob amplitude

#get gravity from project settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

#camera stuff
@onready var neck: Node3D = $Neck
@onready var camera: Camera3D = $Neck/Camera3D
var t_bob: float = 0.0 #how far along the camera bob we are

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	#Triggers Game Audio
	$FmodEventEmitter3D.play()
	print("sound test")
	

func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		neck.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-75), deg_to_rad(75))

func _physics_process(delta) -> void:
	var direction: Vector3 = Vector3.ZERO
	if not is_on_floor():
		velocity.y -= gravity * delta
	
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

func _headbob(time: float) -> Vector3:
	var pos: Vector3 = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
