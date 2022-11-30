extends KinematicBody

enum {
	ALIVE,
	OCCUPIED
}

onready var head = $Waist/Head
onready var waist = $Waist
onready var tiltTween = $Waist/TiltTween
onready var moveTween = $Waist/MoveTween
onready var sprintTimer = $SprintTimer
onready var interactRayCast = $Waist/Head/interactRayCast
onready var interactTimer = $Waist/Head/interactRayCast/InteractTimer

onready var headRayCastFront = $CrouchRaycasts/headRayCastFront
onready var headRayCastLeft = $CrouchRaycasts/headRayCastLeft
onready var headRayCastRight = $CrouchRaycasts/headRayCastRight
onready var headRayCastBack = $CrouchRaycasts/headRayCastBack

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
var isTiltedLeft = false
var isTiltedRight = false


var standSound = 0.1
var crouchSound = .2
var walkSound = .4
var sprintSound = 1
var jumpSound = .5
var interactSlowSound = .2
var interactFastSound = 1

var interactTimes = 0

var playerState = "ALIVE"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	if playerState == "ALIVE":
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
	if playerState == "ALIVE":
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
		if Input.is_action_pressed("move_tilt_left") and Input.is_action_pressed("move_tilt_right"):
			isTiltedLeft = false
			isTiltedRight = false
			tilt_player(0, 0)
		elif Input.is_action_pressed("move_tilt_left") and not isTiltedLeft:
			isTiltedLeft = true
			tilt_player(tiltAmount, -.5)
		elif Input.is_action_pressed("move_tilt_right") and not isTiltedRight:
			isTiltedRight = true
			tilt_player(-tiltAmount, .5)
		elif Input.is_action_just_released("move_tilt_left") and isTiltedLeft:
			isTiltedLeft = false
			tilt_player(0, 0)
		elif Input.is_action_just_released("move_tilt_right") and isTiltedRight:
			isTiltedRight = false
			tilt_player(0, 0)

		
		#Check if the player wants to crouch
		if Input.is_action_just_pressed("move_crouch"):
			sprintTimer.start()
			isCrouching = true
			max_speed = crouch_speed
			crouch_player(.5)
		elif not Input.is_action_pressed("move_crouch") and not headRayCastFront.is_colliding() and not headRayCastLeft.is_colliding() and not headRayCastRight.is_colliding() and not headRayCastBack.is_colliding():
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

		#Check if the player wants to interact
		if Input.is_action_just_pressed("interact"):
			if interactRayCast.is_colliding():
				if interactTimes < 2:
					interactTimer.stop()
					interactTimes += 1
					interactTimer.start()

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

func tilt_player(dir, amount):
	moveTween.interpolate_property(waist, "translation:x", waist.translation.x, amount, .2, moveTween.TRANS_LINEAR, moveTween.EASE_IN_OUT)
	tiltTween.interpolate_property(waist, "rotation_degrees:z", waist.rotation_degrees.z, dir, .2, tiltTween.TRANS_LINEAR, tiltTween.EASE_IN_OUT)
	tiltTween.start()
	moveTween.start()

func crouch_player(dir):
	tiltTween.interpolate_property($CollisionShape, "scale:y", $CollisionShape.scale.y, dir, .2, tiltTween.TRANS_LINEAR, tiltTween.EASE_IN_OUT)
	tiltTween.start()

func _on_SprintTimer_timeout():
	isSprintRecharging = true


func _on_InteractTimer_timeout():
	if playerState == "ALIVE":
		if interactRayCast.get_collider().has_method("use"):
			if interactTimes == 1:
				interactRayCast.get_collider().use("Slow")
			else:
				interactRayCast.get_collider().use("Fast")
			playerState = "OCCUPIED"
		else:
			print("This interactable has no use method yet...")
		interactTimes = 0

func itemDone():
	playerState = "ALIVE"
