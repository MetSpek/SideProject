extends Spatial

onready var light = $SpotLight

func use():
	light.visible = !light.visible
