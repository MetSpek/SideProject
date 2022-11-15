extends KinematicBody



onready var head = $Waist/Head
onready var waist = $Waist
onready var tiltTween = $Waist/Tween
onready var sprintTimer = $SprintTimer

export var health = 100
export var mouseSensitivity = 0.1
export var tiltAmount = 15
export var sprintDrain = 2
export var sprintRecharge = 1
export var jumpImpulse = 6.0

var gravity = -20
var walk_speed = 4
var run_speed = 8
var crouch_speed = 2
var max_speed = walk_speed
var velocity = Vector3()
var isCrouching = false
var isSprintRecharging = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	velocity.y += gravity * delta
	var desired_velocity = get_input() * max_speed
	velocity.x = desired_velocity.x
	velocity.z = desired_velocity.z
	velocity = move_and_slide(velocity, Vector3.UP, true)
	if isSprintRecharging == true:
		GlobalPlayerVariables.sprintGauge += sprintRecharge
	
	if GlobalPlayerVariables.sprintGauge >= 100:
		GlobalPlayerVariables.sprintGauge = 100
		isSprintRecharging = false


func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		head.rotate_x(deg2rad(event.relative.y * mouseSensitivity * -1))
		self.rotate_y(deg2rad(event.relative.x * mouseSensitivity * -1))

		# Clamp yaw to [-89, 89] degrees so you can't flip over
		var yaw = head.rotation_degrees.x
		head.rotation_degrees.x = clamp(yaw, -89, 89)    
	
	#Check if the player wants to jump
	if Input.is_action_just_pressed("move_jump"):
		if is_on_floor():
			velocity.y = jumpImpulse
		
	
	#Check if the player wants to tilt
	if Input.is_action_just_pressed("move_tilt_left"):
		tilt_player(tiltAmount)
	elif Input.is_action_just_pressed("move_tilt_right"):
		tilt_player(-tiltAmount)
	elif Input.is_action_just_released("move_tilt_left") or Input.is_action_just_released("move_tilt_right") or Input.is_action_pressed("move_tilt_left") and Input.is_action_pressed("move_tilt_right"):
		tilt_player(0)
	
	#Check if the player wants to crouch
	if Input.is_action_just_pressed("move_crouch"):
		sprintTimer.start()
		isCrouching = true
		max_speed = crouch_speed
		crouch_player(.5)
	elif Input.is_action_just_released("move_crouch"):
		isCrouching = false
		max_speed = walk_speed
		crouch_player(1)

	#Check if the player wants to run
	if Input.is_action_pressed("move_run") and not isCrouching and GlobalPlayerVariables.sprintGauge > 0:
		isSprintRecharging = false
		sprintTimer.stop()
		max_speed = run_speed
		GlobalPlayerVariables.sprintGauge -= sprintDrain
	elif Input.is_action_just_released("move_run"):
		max_speed = walk_speed
		sprintTimer.start()

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

func tilt_player(dir):
	tiltTween.interpolate_property(waist, "rotation_degrees:z", waist.rotation_degrees.z, dir, .2, tiltTween.TRANS_LINEAR, tiltTween.EASE_IN_OUT)
	tiltTween.start()

func crouch_player(dir):
	tiltTween.interpolate_property($CollisionShape, "scale:y", $CollisionShape.scale.y, dir, .2, tiltTween.TRANS_LINEAR, tiltTween.EASE_IN_OUT)
	tiltTween.start()

func _on_SprintTimer_timeout():
	isSprintRecharging = true
