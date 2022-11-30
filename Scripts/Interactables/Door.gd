extends StaticBody

onready var animation = $AnimationPlayer

export var connectedObjectNumber = 0
export var locked = false

var state = "closed"

func use(method):
	print(method)
	if locked == false:
		if method == "Slow":
			interact(1)
		elif method == "Fast":
			interact(2)
	else:
		print("Door Locked")

func interact(speed):
	animation.playback_speed = speed
	if state == "closed":
		animation.play("open")
		state = "open"
	else:
		animation.play_backwards("open")
		state = "closed"
	

func unlock():
	print("Door unlocked")
	locked = false
