extends CanvasLayer
class_name UI

@onready var health_bar = $Control/MarginContainer/VBoxContainer/HBoxContainer/HealthBar
@onready var player = $'../Mouse'

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_spawn(max_health : int):
	health_bar.max_value = max_health
	health_bar.value = max_health


func _on_player_health_changed(new_health : int):
	health_bar.value = new_health
	#health_bar.progress
