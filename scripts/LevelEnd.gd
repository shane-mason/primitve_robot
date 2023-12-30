extends Area3D

@export var hint_text: String = "Placeholder"
var player_node
var world_node

# Called when the node enters the scene tree for the first time.
func _ready():
	player_node = get_tree().get_root().get_node("World").get_node("RobotHero")
	world_node = get_tree().get_root().get_node("World")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	if body.name == "RobotHero":
		player_node.show_hint(hint_text)
		$SFXEntered.play()
		world_node.level_end()
