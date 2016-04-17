extends Node

#The currently active scene
var currentScene = null
var nextlevel = null
var progress = []

func _ready():
	#On load set the current scene to the last scene available
	currentScene = get_tree().get_root().get_child(get_tree().get_root().get_child_count() -1)
	self.loadProgress()
	
func saveProgress():
	var savegame = File.new()
	savegame.open("user://shapegame.save", File.WRITE)
	for p in self.progress:
		savegame.store_line(p)
	savegame.close()
	
func loadProgress():
	progress.clear()
	var savegame = File.new()
	if !savegame.file_exists("user://shapegame.save"):
        return #Error!  We don't have a save to load
	savegame.open("user://shapegame.save", File.READ)
	while (!savegame.eof_reached()):
		progress.append(savegame.get_line())
	savegame.close()
	
   

# create a function to switch between scenes 
func setScene(scene):
	#clean up the current scene
	currentScene.queue_free()
	#load the file passed in as the param "scene"
	var s = ResourceLoader.load(scene)
	#create an instance of our scene
	currentScene = s.instance()
	# add scene to root
	get_tree().get_root().add_child(currentScene)
   
func setNextLevel(level):
	nextlevel = level
	
func completeLevel():
	progress.append(nextlevel)
	self.saveProgress()
	self.setScene("res://scenes/title.scn")
	
func getProgress():
	return progress
	