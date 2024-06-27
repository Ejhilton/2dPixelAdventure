extends CharacterBody2D


@export var SPEED = 300.0
const WALKSPEED = 100
const JUMP_VELOCITY = -400.0

@export_range(0.01, 20) var shoot_cooldown: float = 20
@export var can_shoot = true
@export var head_damage = 2
@export var chest_damage = 1

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
		if direction < 0:
			animated_sprite_2d.flip_h = true
		else:
			animated_sprite_2d.flip_h = false
			
		if Input.is_action_pressed("sprint"):
			velocity.x = direction * SPEED
			animated_sprite_2d.play("run")
		else:
			velocity.x = direction * WALKSPEED
			animated_sprite_2d.play("walk")
			
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if Input.is_action_pressed("shoot_1"):
			animated_sprite_2d.play("shot_1")
			shoot("chest")
		elif Input.is_action_pressed("shoot_2"):
			animated_sprite_2d.play("shot_2")
			shoot("head")
		else:
			animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")
		
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
	var raycast_direction = null
	if height == "head":
		damage = head_damage
	elif height == "chest":
		damage = chest_damage
	else:
		print("not working")
		
	if animated_sprite_2d.flip_h:
		raycast_direction = "left"
	else:
		raycast_direction = "right"
		
	var raycast_path = "raycasts/raycasts_" + height + "/RayCast2D_" + height + "_" + raycast_direction
	var raycast = get_node(raycast_path)
	if raycast.is_colliding() and can_shoot:
		var object_hit = raycast.get_collider()
		if object_hit and object_hit.has_method("take_damage"):
				object_hit.take_damage(damage)
