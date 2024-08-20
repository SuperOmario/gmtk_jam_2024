extends Node2D

@onready var player := $Mouse
@onready var UI := $UI

# Called when the node enters the scene tree for the first time.
func _ready():
	player.health_changed.connect(_on_mouse_health_changed)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_cheese_entered(body):
	if body is Mouse:
		get_tree().change_scene_to_file("res://code/menu/end_menu.tscn")


func _on_mouse_health_changed(new_health):
	print(new_health)
