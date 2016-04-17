
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
var JUMP_WATER_VELOCITY = 230
var MAX_JUMP = 1


var airborne_time = 1e20
var inwater = 0
var jump_count = 0
var can_jump = true

var red_texture = preload("res://assets/sprites/red.png")
var green_texture = preload("res://assets/sprites/green.png")
var blue_texture = preload("res://assets/sprites/blue.png")

# 0 = green circle
# 1 = red cube
# 2 = blue triangle
var currentshape=0
var justchangedshape=false

var spawn_pos = null
var reset = 0

func setInWater(val):
	inwater = val


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_process_input(true)
	spawn_pos = self.get_transform()

func _process(delta):
	pass
	
func _input(event):
	if(event.type == InputEvent.KEY):
		if(Input.is_action_pressed("RESET")):
			self.reset = 1
			
func setshape(v):
	if (self.currentshape == v or self.reset != 0):
		return
	self.currentshape = v
	var sprite = get_node("playerSprite")
	var shape = get_node("CollisionShape2D")
	
	if (v == 1):
		sprite.set_texture(red_texture)
		#var newshape = RectangleShape2D.new()
		#newshape.set_extents(Vector2(20,20))
		var newshape = CircleShape2D.new()
		newshape.set_radius(20)
		self.clear_shapes()
		self.add_shape(newshape)
		JUMP_VELOCITY = 1
		JUMP_WATER_VELOCITY = 1
		MAX_JUMP = 0
	elif (v == 0):
		sprite.set_texture(green_texture)
		var newshape = CircleShape2D.new()
		newshape.set_radius(20)
		self.clear_shapes()
		self.add_shape(newshape)
		JUMP_VELOCITY = 460
		JUMP_WATER_VELOCITY = 230
		MAX_JUMP = 1
	elif (v == 2):
		sprite.set_texture(blue_texture)
		var newshape = CircleShape2D.new()
		newshape.set_radius(20)
		self.clear_shapes()
		self.add_shape(newshape)
		JUMP_VELOCITY = 460
		JUMP_WATER_VELOCITY = 230
		MAX_JUMP = 2
	
	self.justchangedshape = true
		
	
func _integrate_forces(s):
	var lv = s.get_linear_velocity()
	var step = s.get_step()
	
	if (self.reset > 0):
		if (self.reset == 1):
			s.set_transform(self.spawn_pos)
		self.reset += step
		if (self.reset > 1.1):
			self.reset = 0
			self.setshape(0)
			
		
		return
		
	
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
	
	if (found_floor and not jumping):
		self.jump_count= 0
	
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
	print(self.jump_count," ",airborne_time)
	if ( can_jump and jump and self.jump_count < MAX_JUMP):
		jump_count += 1
		lv.y = -JUMP_VELOCITY
		jumping = true
		can_jump = false
	if ( not can_jump and not jump):
		can_jump = true
	
	if (jumping):
		if (lv.y > 0):
			# Set off the jumping flag if going down
			jumping = false
	

	
	# In in water, we want to float, else apply gravity.
	if (self.currentshape == 1):
		if (inwater != 0):
			lv += s.get_total_gravity()*step / 2
		else:
			lv += s.get_total_gravity()*step
	elif (self.currentshape == 2):
		#We die if we hit waters as triangle
		if (inwater != 0):
			s.set_transform(self.spawn_pos)
			self.setshape(0)
			return
		lv += s.get_total_gravity()*step
	else:
		if (inwater != 0):
			if (jump):
				lv.y= -JUMP_WATER_VELOCITY
			else:
				lv.y=(1-inwater)*98
			inwater = 0
		else:
			lv += s.get_total_gravity()*step
	
	if (self.justchangedshape):
		if (on_floor):
			lv.y= -10
		self.justchangedshape = false
	
	s.set_linear_velocity(lv)

