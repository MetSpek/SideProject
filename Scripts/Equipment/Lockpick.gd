extends StaticBody

onready var camera = $Camera
onready var pick = $RotationPin
onready var pin = $RotationPin/Pick
onready var unlock = $RotationUnlock
onready var unlockPin = $RotationUnlock/Pick

var isPlaying = false
var correctPoint
var correctRange
var closeRange
var maxRangeDegrees = 120
var rotationSpeed = 1
var correctOffset = 5
var closeOffset = 15

var openMax = 90
var openClose = 35

export var connectedObjectNumber = 0

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	correctPoint  = rng.randi_range(-maxRangeDegrees, maxRangeDegrees)
	correctRange = [correctPoint - correctOffset, correctPoint + correctOffset]
	closeRange = [correctPoint - closeOffset, correctPoint + closeOffset]
	
	print(correctPoint)
	print(correctRange)
	print(closeRange)

func use(method):
	if isPlaying == false:
		get_tree().call_group("Player", "occupyPlayer")
		isPlaying = true
		camera.current = true
		pin.visible = true
		unlockPin.visible = true


func _physics_process(delta):
	if isPlaying == true:
		if Input.is_action_pressed("move_left"):
			if pick.rotation_degrees.z < maxRangeDegrees:
				pick.rotation_degrees.z += rotationSpeed
		elif Input.is_action_pressed("move_right"):
			if pick.rotation_degrees.z > -maxRangeDegrees:
				pick.rotation_degrees.z -= rotationSpeed
		elif Input.is_action_pressed("item_use"):
			if pick.rotation_degrees.z >= correctRange[0] and pick.rotation_degrees.z <= correctRange[1]:
				if unlock.rotation_degrees.z < openMax:
					unlock.rotation_degrees.z += rotationSpeed
				else:
					isPlaying = false
					$Timer.start()
			elif pick.rotation_degrees.z > correctRange[1] and pick.rotation_degrees.z <= closeRange[1] or pick.rotation_degrees.z < correctRange[0] and pick.rotation_degrees.z >= closeRange[0]:
				if unlock.rotation_degrees.z < openClose:
					unlock.rotation_degrees.z += rotationSpeed
		elif not Input.is_action_pressed("item_use"):
			if unlock.rotation_degrees.z > 0:
				unlock.rotation_degrees.z -= rotationSpeed
			elif unlock.rotation_degrees.z < 0:
				unlock.rotation_degrees.z = 0
#		print(pick.rotation_degrees.z)

func finish():
	isPlaying = false
	camera.current = false
	get_tree().call_group("Player", "itemDone")
	get_tree().call_group("Object", "unlock")
	queue_free()


func _on_Timer_timeout():
	finish()
