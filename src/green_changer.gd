
extends Sprite

# member variables here, example:
# var a=2
# var b="textvar"

var playershape = null
var playersprite = null
var boxself = null


func _ready():
	boxself = RectangleShape2D.new()
	boxself.set_extents(Vector2(self.get_texture().get_size().width/2,self.get_texture().get_size().height/2))
	playershape = get_node("../../player/CollisionShape2D")
	playersprite = get_node("../../player")
	
	set_process(true)
	
func _process(delta):
	var boxplayer = playershape.get_shape()
	var t = self.get_transform()

	if(boxplayer.collide(playersprite.get_transform(),boxself,self.get_transform())):
		playersprite.setshape(0)
		
