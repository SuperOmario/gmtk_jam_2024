extends Node

@export var health : int
@export var max_health : int

signal damaged
signal healed
signal died


func _ready() -> void:
	_set_health(max_health)


func _set_health(new_health : int) -> void:
	health = new_health


func _get_health() -> int:
	return health


func take_damage(damage : int) -> void:
	if (health - damage) <= 0:
		_set_health(0)
		_die()
	else:
		_set_health( _get_health() - damage )
		emit_signal("damaged")


func heal(healing : int) -> void:
	if (max_health - _get_health()) < healing:
		_set_health( max_health )
	else:
		_set_health( _get_health() + healing )
	emit_signal("healed", _get_health())


func _die() -> void:
	emit_signal("died")
