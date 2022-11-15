extends Label

func _process(delta):
	self.text = String(GlobalPlayerVariables.sprintGauge)
	
