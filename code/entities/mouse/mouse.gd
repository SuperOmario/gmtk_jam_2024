extends CharacterBody2D

class_name Mouse

var speed := 300.0 * 60
var gravity := 1
var direction : Vector2
var last_direction := direction


func get_input(delta) -> Vector2:
	direction = Vector2(Input.get_axis("move_left", "move_right"), gravity).normalized()
	return direction * speed * delta


func _physics_process(delta) -> void:
	direction = get_input(delta)
	if direction != Vector2.ZERO:
		last_direction = direction.normalized()
		velocity = direction 
		move_and_slide()
	
	#if is_on_floor() and Input.is_action_just_pressed("jump"):


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
