extends Node3D

var world_node
@export var health = 2

@export var lock_x = false
@export var max_x = 3.0
@export var x_speed = .06

@export var lock_y = true
@export var max_y = 1.0
@export var y_speed = .01

@export var lock_z = true
@export var max_z = 4.0
@export var z_speed = .12

@export var dead_scene: PackedScene;


var start_y
var start_x
var xmove_state
var right_boundary
var left_boundary
var top_boundary
var hover_state
var sway_state
var sway_max
var sway_min

enum MotionState{
	move_left,
	move_right,
	idle,
	inactive
}

enum HoverState{
	up,
	down
}

#from camera position
enum SwayState{
	away,
	toward
}

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("spin")
	world_node = get_tree().get_current_scene()
	start_x = global_position.x
	xmove_state = MotionState.move_right	
	right_boundary = start_x + max_x
	left_boundary = start_x - max_x
	
	hover_state = HoverState.up
	start_y = global_position.y
	top_boundary = start_y + max_y 
	
	sway_state = SwayState.away
	sway_max = max_z
	sway_min = -max_z
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not lock_x:
		match xmove_state:
			MotionState.inactive:
				return
			MotionState.move_right:
				global_position.x += x_speed
				if global_position.x > right_boundary:
					xmove_state=MotionState.move_left
			MotionState.move_left:
				global_position.x -= x_speed
				if global_position.x < left_boundary:
					xmove_state=MotionState.move_right

			
	if not lock_y:
		match hover_state:
			HoverState.up:
				global_position.y += y_speed
				if global_position.y >= top_boundary:
					hover_state = HoverState.down
			HoverState.down:
				global_position.y -= y_speed
				if global_position.y <= start_y:
					hover_state = HoverState.up
					
	if not lock_z:
		match sway_state:
			SwayState.away:
				global_position.z -= z_speed
				if global_position.z <= sway_min:
					sway_state = SwayState.toward
			SwayState.toward:
				global_position.z += z_speed
				if global_position.z >= sway_max:
					sway_state = SwayState.away
				

func _on_damage_area_body_entered(body):
	if body.name == "RobotHero" and not is_queued_for_deletion():
		print(world_node)
		world_node.player_got_hit()
		$SFXEntered.play()


func _on_bullet_hit_area_body_entered(body):
	if body is Bullet:
		health -= 1
		$SFXShot.play()
		if not health:
			var instance = dead_scene.instantiate()
			instance.global_position = self.global_position
			get_tree().get_root().get_node("World").add_child(instance)
			queue_free()


func _on_soft_spot_body_entered(body):
	if body.name == "RobotHero":
		var instance = dead_scene.instantiate()
		instance.global_position = self.global_position
		get_tree().get_root().get_node("World").add_child(instance)
		queue_free()
