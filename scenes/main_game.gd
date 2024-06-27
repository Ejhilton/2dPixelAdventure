extends Node2D

const file_start = "res://levels/Level"
@onready var level_kill_count = $Level1/enemies.get_child_count()
var initial_kill_count = global.kill_count



# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if global.kill_count - level_kill_count == initial_kill_count:
		var current_scene = get_tree().current_scene.scene_file_path
		var next_level_number = current_scene.to_int() + 1
		
		var next_level_path = file_start + str(next_level_number) + ".tscn"
		get_tree().change_scene_to_file(next_level_path)
