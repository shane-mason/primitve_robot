extends Camera3D

@export var followNode:Node3D
@export var x_pad = 8

# Called when the node enters the scene tree for the first time.
func _ready():
	global_position.x = followNode.global_position.x+x_pad
	global_position.y = 2.5
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_instance_valid(followNode):
		global_position.x = followNode.global_position.x+x_pad;
		var y_diff = global_position.y - followNode.global_position.y
		
		if y_diff > 2:
			global_position.y -= .025
		elif y_diff < 3:
			global_position.y += .025
			
		if abs(followNode.velocity.x) > 0:
			if global_position.z < 12:
				global_position.z +=  .025
			elif global_position.z > 8:
				global_position.z -=  .025
		elif global_position.z > 8:
			global_position.z -=  .05
	

