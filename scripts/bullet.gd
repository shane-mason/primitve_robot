extends RigidBody3D
class_name Bullet

@export var direction:Vector3 = Vector3(1,0,0)

# Called when the node enters the scene tree for the first time.
func _ready():
	apply_central_impulse(direction*30)
	$TimerLife.start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_life_timeout():
	queue_free()
