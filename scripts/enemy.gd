extends CharacterBody2D

@export var health: float = 15
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var health_bar = $HealthBar
@onready var state_chart = $StateChart
var enemy_to_attack = null
var enemy_seen = 0
var enemy_speed = 100

var direction

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Called when the node enters the scene tree for the first time.
func _ready():
	health_bar.max_value = health
	health_bar.value = health


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health <= 0:
		global.add_kill()
		queue_free()

func _on_animated_sprite_2d_animation_finished():
	animated_sprite_2d.play("idle")

func take_damage(damage):
	animated_sprite_2d.play("hurt")
	health -= damage
	health_bar.value = health

func _on_vision_body_entered(body):
	if body.name == "player":
		enemy_to_attack = body
		enemy_seen += 1
		state_chart.set_expression_property("enemy_seen", enemy_seen)
		state_chart.send_event("player_entered")

func _on_vision_body_exited(body):
	if body.name == "player":
		state_chart.send_event("player_exited")
		enemy_to_attack = null
		direction = 0
		velocity.x = move_toward(velocity.x, 0, enemy_speed)
		
func _physics_process(delta):
	
	if enemy_to_attack:
		if enemy_to_attack.position.x < self.position.x:
			direction = -1
			animated_sprite_2d.flip_h = true
		else:
			direction = 1
			animated_sprite_2d.flip_h = false
		
		velocity.x = direction * enemy_speed
	
	
	if abs(velocity.x) > 0 and abs(velocity.x) <= 150:
		animated_sprite_2d.play("walk")
	elif abs(velocity.x) > 150 and abs(velocity.x) <= 250:
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
		
	if not is_on_floor():
		velocity.y += gravity * delta
	move_and_slide()

func _on_mad_state_entered():
	enemy_speed = 200

func _on_mad_state_exited():
	enemy_speed = 100
