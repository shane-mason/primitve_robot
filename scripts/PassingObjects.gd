extends PathFollow3D

@export var backwards = false
@export var speed = .1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if backwards:
		progress += speed
	else:
		progress -= speed
