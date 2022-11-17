extends KinematicBody

onready var head = $Head

var gravity = -20
var max_speed = 4
var velocity = Vector3()
export var mouseSensitivity = 0.1
export var jumpImpulse = 6.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	velocity.y += gravity * delta
	var desired_velocity = get_input() * max_speed
	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_x(deg2rad(event.relative.y * mouseSensitivity * -1))
		rotate_y(deg2rad(event.relative.x * mouseSensitivity * -1))

		# Clamp yaw to [-89, 89] degrees so you can't flip over
		var yaw = head.rotation_degrees.x
		head.rotation_degrees.x = clamp(yaw, -89, 89)    
	
	#Check if the player wants to jump
	if Input.is_action_just_pressed("move_jump"):
		if is_on_floor():
			velocity.y = jumpImpulse

func get_input():
	var input_dir = Vector3()
	# desired move in camera direction
	if Input.is_action_pressed("move_forward"):
		input_dir += -global_transform.basis.z
	if Input.is_action_pressed("move_backward"):
		input_dir += global_transform.basis.z
	if Input.is_action_pressed("move_left"):
		input_dir += -global_transform.basis.x
	if Input.is_action_pressed("move_right"):
		input_dir += global_transform.basis.x
	input_dir = input_dir.normalized()
	return input_dir
