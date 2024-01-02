extends Camera3D

@export var followNode:Node3D
@export var x_pad = 8
@export var y_pad = -1

var _y_speed = .05
var _x_speed = .01
var _z_speed = .01

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position.x = followNode.global_position.x+x_pad
	global_position.y = followNode.global_position.y + 2
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(followNode):
		global_position.x = move_toward(followNode.global_position.x+x_pad,followNode.global_position.x, _x_speed)	
		var y_diff = abs(global_position.y+y_pad) - abs(followNode.global_position.y)
		
		
		if abs(y_diff) > 2:
			global_position.y = move_toward(global_position.y, followNode.global_position.y+y_pad, _y_speed)
			

			
		if abs(followNode.velocity.x) > 0:
			if global_position.z < 12:
				global_position.z +=  .025
			elif global_position.z > 8:
				global_position.z -=  .025
		elif global_position.z > 8:
			global_position.z -=  .05
	

