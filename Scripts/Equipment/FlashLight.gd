extends Spatial

onready var light = $SpotLight

var state = "off"

func use():
	if state == "off":
		light.visible = true
		state = "on"
	elif state == "on":
		light.visible = false
		state = "off"
