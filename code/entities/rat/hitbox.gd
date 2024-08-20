extends Area2D

@export var left_position : Vector2
@export var right_position : Vector2

func _on_direction_change(direction : String):
	if direction == "left":
		self.position = left_position
	elif direction == "right":
		self.position = right_position
