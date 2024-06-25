extends RigidBody2D

var health = 15
@onready var animated_sprite_2d = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if health <= 0:
		queue_free()


func _on_animated_sprite_2d_animation_finished():
	animated_sprite_2d.play("idle")
