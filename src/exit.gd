
extends Sprite


var playershape = null
var playersprite = null
var boxself = null


func _ready():
	boxself = get_node("exitCollision").get_shape()
	playershape = get_node("../player/CollisionShape2D")
	playersprite = get_node("../player")
	set_process(true)
	
func _process(delta):
	var boxplayer = playershape.get_shape()
	if(boxplayer.collide(playersprite.get_transform(),boxself,self.get_transform())):
		get_node("/root/global").setScene("res://scenes/title.scn")
		
