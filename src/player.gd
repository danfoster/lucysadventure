
extends RigidBody2D

# member variables here, example:
# var a=2
# var b="textvar"
var jumping = false

var MAX_FLOOR_AIRBORNE_TIME = 0.15
var WALK_ACCEL = 8000.0
var WALK_DEACCEL = 8000.0
var WALK_MAX_VELOCITY = 400.0
var JUMP_VELOCITY = 460
var JUMP_WATER_VELOCITY = 60

var airborne_time = 1e20
var inwater = 0

func setInWater(val):
	inwater = val
	

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	#self.move(Vector2(movex*mag*delta,movey*mag*delta))
	pass
	
func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var step = s.get_step()
	
	
	# Get the controls
	var move_left = Input.is_action_pressed("MOVE_LEFT")
	var move_right = Input.is_action_pressed("MOVE_RIGHT")
	var jump = Input.is_action_pressed("JUMP")
	
	# Find the floor (a contact with upwards facing collision normal)
	var found_floor = false
	var floor_index = -1
	
	for x in range(s.get_contact_count()):
		var ci = s.get_contact_local_normal(x)
		if (ci.dot(Vector2(0, -1)) > 0.6):
			found_floor = true
			floor_index = x
	
	
	if (found_floor):
		airborne_time = 0.0
	else:
		airborne_time += step # Time it spent in the air
	
	var on_floor = airborne_time < MAX_FLOOR_AIRBORNE_TIME
	
	# Process left/right movement
	if (move_left and not move_right):
		if (lv.x > -WALK_MAX_VELOCITY):
			lv.x -= WALK_ACCEL*step
	elif (move_right and not move_left):
		if (lv.x < WALK_MAX_VELOCITY):
			lv.x += WALK_ACCEL*step
	else:
		var xv = abs(lv.x)
		xv -= WALK_DEACCEL*step
		if (xv < 0):
			xv = 0
		lv.x = sign(lv.x)*xv
		
	# Process jumping
	if (not jumping and jump and on_floor):
		lv.y = -JUMP_VELOCITY
		jumping = true
	if (jumping):
		if (lv.y > 0):
			# Set off the jumping flag if going down
			jumping = false
	
	# In in water, we want to float, else apply gravity.
	if (inwater != 0):
		if (jump):
			lv.y= -JUMP_WATER_VELOCITY
		else:
			lv.y=(1-inwater)*98
		inwater = 0
	else:
		lv += s.get_total_gravity()*step
	
	
	s.set_linear_velocity(lv)

