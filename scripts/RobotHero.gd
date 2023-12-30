extends CharacterBody3D


@export var speed = 10
@export var acceleration = 0.1
@export var bump_jump = .2
@export var jump_velocity = 10
@export var eye_ramp: Gradient;

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") + 16
var _eye_material
var _eye_buffer = 0
var dead = false

func _ready():
	$HintLabel.text = "A - Move Left\nB - Move Right"
	$HintLabel.visible = true
	$TimerHint.start()
	
	#_eye_material = StandardMaterial3D.new()
	#_eye_material.roughness = .1
	#$EyeMesh.set_surface_material(0, _eye_material)
	$BodyParts/EyeMesh.mesh.material.albedo_color = eye_ramp.sample(0)
	$SFXMotor.play()
	
	
func _physics_process(delta):
	# Add the gravity.
	
	if dead:
		return
	
	if position.y < -60:
		dead=true
		$SFXFell.play()
	
	if _eye_buffer > 0:
		_eye_buffer -= .02
		$BodyParts/EyeMesh.mesh.material.albedo_color = eye_ramp.sample(_eye_buffer)
		
	# Handle Jump.
	if Input.is_action_just_pressed("move_jump") and is_on_floor():
		velocity.y = jump_velocity
		_eye_buffer = 1
		$BodyParts/EyeMesh.mesh.material.albedo_color = eye_ramp.sample(_eye_buffer)
		#https://sfxr.me/#1FEzRygKcVnK7ktUYatAg19J3oBpQYvMiBw8D8mXZ9sa5b1EVE4GQTTMkdWruiPr1H5syEH2Nqpkr2D54FEHpkH36iEL6zGbmCbtRh5gbwjtjGcfF1L4XkhuV
		$SFXJump.play()
	elif Input.is_action_pressed("move_jump"):
		velocity.y += bump_jump


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		if abs(velocity.x) < speed:
			velocity.x += direction.x * acceleration
		
	else:
		velocity.x = move_toward(velocity.x, 0, .5)
	
	
	if not is_on_floor():
		velocity.y -= gravity * delta
		$BodyParts/WheelParticles.emitting = false
		$SFXMotor.pitch_scale = maxf( .50, $SFXMotor.pitch_scale-.04) 
	else:
		if abs(velocity.x) > 0:
			if $SFXMotor.pitch_scale < 1:
				$SFXMotor.pitch_scale += .04
		else:
			if $SFXMotor.pitch_scale > 0:
				$SFXMotor.pitch_scale -= .03
		
		
		if absf(velocity.x) > .1:
			$BodyParts/WheelParticles.emitting = true
		else:
			$BodyParts/WheelParticles.emitting = false
		
	
	if velocity.x > 0:
		$BodyParts.rotation_degrees.y = 0
		if $BodyParts.rotation_degrees.z > -10:
			$BodyParts.rotation_degrees.z-=.5
		
	elif velocity.x < 0:
		$BodyParts.rotation_degrees.y = 180
		if $BodyParts.rotation_degrees.z > -10:
			$BodyParts.rotation_degrees.z-=.5
		
	else:
		if $BodyParts.rotation_degrees.z < 0:
			$BodyParts.rotation_degrees.z+=.5
		
	$BodyParts/WheelMesh.rotation_degrees.x += velocity.x;

	move_and_slide()

func show_hint(hint_text):
	$HintLabel.text = hint_text
	$HintLabel.visible = true
	$TimerHint.start()
	
func _on_timer_hint_timeout():
	$HintLabel.visible = false


func _on_sfx_fell_finished():
	get_tree().reload_current_scene()  
