extends CharacterBody2D


const SPEED = 300.0
const WALKSPEED = 100
const JUMP_VELOCITY = -400.0

@export_range(0.01, 20) var shoot_cooldown: float = 20
@export var can_shoot = true

@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var shoot_timer = $shootTimer

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	shoot_timer.wait_time = shoot_cooldown
	
	
func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_axis("move_left", "move_right")
	if direction:
		if Input.is_action_pressed("sprint"):
			velocity.x = direction * SPEED
		else:
			velocity.x = direction * WALKSPEED
	else:
		if is_on_floor():
			velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction > 0:
		if Input.is_action_pressed("sprint"):
			animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("walk")
		animated_sprite_2d.flip_h = false
		
	elif direction < 0:
		if Input.is_action_pressed("sprint"):
			animated_sprite_2d.play("run")
		else:
			animated_sprite_2d.play("walk")
		animated_sprite_2d.flip_h = true
		
	else:
		if is_on_floor():
			if Input.is_action_pressed("shoot_1"):
				animated_sprite_2d.play("shot_1")
				shoot("chest")
			elif Input.is_action_pressed("shoot_2"):
				animated_sprite_2d.play("shot_2")
				shoot("head")
			else:
				animated_sprite_2d.play("idle")
				
	move_and_slide()



func _on_shoot_timer_timeout():
	can_shoot = true

func shoot(height):
	if can_shoot:
		check_for_hitting(height)
		can_shoot = false
		$shootTimer.start()
		
func check_for_hitting(height):
	var damage = 0
	var raycasts = $raycasts
	if height == "head":
		damage = 2
		raycasts = $"raycasts/raycasts_head".get_children()
	elif height == "chest":
		damage = 1
		raycasts = $"raycasts/raycasts_chest".get_children()
	else:
		print("not working")
		
	for raycast in raycasts:
		if raycast.is_colliding() and can_shoot:
			var object_hit = raycast.get_collider()
			if object_hit and object_hit.has_method("take_damage"):
					object_hit.take_damage(damage)
			break
