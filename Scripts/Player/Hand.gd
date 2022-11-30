extends Spatial

var currentlyHolding
var inventorySize = GlobalPlayerVariables.inventory.size()
var inventorySpot = 0
onready var player = get_parent().get_parent().get_parent()

func _ready():
	if GlobalPlayerVariables.inventory.size() > 0:
		currentlyHolding = GlobalPlayerVariables.inventory[0]

	for x in GlobalPlayerVariables.inventory:
		add_to_hand(x)
	
	show_right_item()

func add_to_hand(item):
	self.add_child(item)

func show_right_item():
	for x in self.get_children():
		if x != currentlyHolding:
			x.visible = false
		else:
			x.visible = true

func _input(event):
	if player.playerState == "ALIVE":
		if Input.is_action_just_pressed("item_use"):
			if currentlyHolding.has_method("use"):
				currentlyHolding.use()

		if Input.is_action_just_pressed("inventory_next"):
			if inventorySpot + 1 < inventorySize:
				inventorySpot += 1
			else:
				inventorySpot = 0
			switch_item()
		elif Input.is_action_just_pressed("inventory_previous"):
			if inventorySpot > 0:
				inventorySpot -= 1
			else:
				inventorySpot = inventorySize - 1
			switch_item()
	
func switch_item():
	currentlyHolding = GlobalPlayerVariables.inventory[inventorySpot]
	show_right_item()
	print("Now holding item: " + str(currentlyHolding.name)) 
