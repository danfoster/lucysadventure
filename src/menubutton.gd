
extends MenuButton

# member variables here, example:
# var a=2
# var b="textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	var name = self.get("text")
	
	
	var progress = global.getProgress()

	if name in progress:
		self.set_disabled(false)


