extends RigidBody2D
class_name Enemy

var is_aggro := false


func _set_aggro(aggro : bool) -> void:
	is_aggro = aggro


func _get_aggro() -> bool:
	return is_aggro


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_died():
	queue_free()


func _on_damaged(health : int):
	print("Enemy Health: ", health)
