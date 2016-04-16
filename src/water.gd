
extends Sprite

# member variables here, example:
# var a=2
# var b="textvar"
var playershape = null
var playersprite = null
var boxself = null
var waterlevel = null

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	boxself = RectangleShape2D.new()
	boxself.set_extents(Vector2(self.get_texture().get_size().width/2,self.get_texture().get_size().height/2))
	playershape = get_node("/root/Node/player/CollisionShape2D")
	playersprite = get_node("/root/Node/player")
	
	var playerheight = get_node("/root/Node/player/playerSprite").get_texture().get_size().height+20
	waterlevel = self.get_transform().get_origin().y - (self.get_transform().get_scale().y * self.get_texture().get_height())/2 - playerheight
	set_process(true)
	

func _process(delta):
	var boxplayer = playershape.get_shape()
	var t = self.get_transform()

	var contacts = boxplayer.collide_and_get_contacts(playersprite.get_transform(),boxself,self.get_transform())
	if(contacts != null):
		var sub = (contacts[0].y-waterlevel)/100
		if (sub>1.5):
			sub = 1.5
		playersprite.setInWater(sub)
		


