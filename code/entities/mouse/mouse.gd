extends CharacterBody2D

class_name Mouse

@export var speed := 300.0
@export var gravity := 40
@export var reduced_gravity := 5
@export var jump_velocity := 500
@export var health := 50
@export var max_health := 50

@onready var coyote_timer := $CoyoteTime
@onready var jump_buffer := $JumpBuffer
@onready var jump_timer := $JumpTimer
@onready var melee_cooldown := $Sword/Cooldown
@onready var sword := $Sword

var direction : Vector2
var last_direction := direction
var was_on_floor : bool
var is_jumping := false
var items := []
var can_attack := true


func get_movement_input(delta) -> Vector2:
	# Horizontal movement
	direction.x = Input.get_axis("move_left", "move_right") * speed
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer.start()  # Start the buffer timer when jump is pressed

	# Vertical movement
	if is_on_floor() or !coyote_timer.is_stopped():
		if Input.is_action_just_pressed("jump") || !jump_buffer.is_stopped():
			direction.y = -jump_velocity
			coyote_timer.stop()
			jump_buffer.stop()
			is_jumping = true
			jump_timer.start()  # Stop the timer once the player jumps
		elif is_on_floor():
			direction.y = 0  # Reset vertical velocity when on the floor
	else:
		if is_jumping:
			if Input.is_action_pressed("jump") && !jump_timer.is_stopped():
				direction.y += reduced_gravity
			else:
				# Apply reduced gravity after releasing jump or holding too long
				is_jumping = false
				direction.y += gravity
		else:
			# Apply normal gravity when in the air
			direction.y += gravity

	return direction	


func get_attack_input(delta) -> void:
	if Input.is_action_just_pressed("melee_attack") && can_attack:
		can_attack = false
		melee_cooldown.start()
		if sword.is_colliding():
			print("Hit!")


func _physics_process(delta) -> void:
	if can_attack == false && melee_cooldown.is_stopped():
		can_attack = true
	direction = get_movement_input(delta)
	get_attack_input(delta)
	if direction != Vector2.ZERO:
		last_direction = direction
		velocity = direction
		was_on_floor = is_on_floor()
		move_and_slide()
		if was_on_floor && !is_on_floor():
			coyote_timer.start()


func take_damage(damage):
	if (health - damage) < 0:
		health = 0
		die()
	else:
		health -= damage


func heal(healing):
	if (max_health - health) < healing:
		health = max_health
	else:
		health += healing


func die():
	print("You Died")
