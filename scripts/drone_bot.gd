extends Node3D

var world_node

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("spin")
	world_node = get_tree().get_root().get_node("World")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_damage_area_body_entered(body):
	if body.name == "RobotHero":
		world_node.player_got_hit()
		$SFXEntered.play()


func _on_bullet_hit_area_body_entered(body):
	if body is Bullet:
		var scene = preload("res://scenes/drone_dead.tscn")
		var instance = scene.instantiate()
		instance.global_position = self.global_position
		get_tree().get_root().get_node("World").add_child(instance)
		queue_free()
