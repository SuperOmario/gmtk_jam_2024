extends CharacterBody2D
class_name Mouse

@export var speed := 300.0
@export var gravity := 40
@export var reduced_gravity := 5
@export var jump_velocity := 500
@export var sword_damage := 20
@export var knockback := 300
@export var knockback_gravity := 20

@onready var coyote_timer := $CoyoteTime
@onready var jump_buffer := $JumpBuffer
@onready var jump_timer := $JumpTimer
@onready var melee_cooldown := $Sword/Cooldown
@onready var sword := $Sword
@onready var animated_sprite := $AnimatedSprite2D
@onready var health := $Health
@onready var sword_target = sword.target_position.x
@onready var invincibility := $InvincibilityFrames
@onready var knockback_timer := $KnockbackTimer

var direction : Vector2
var last_direction := direction
var was_on_floor : bool
var is_jumping := false
var items := []
var can_attack := true
var is_attacking := false
var is_taking_damage := false
var is_invincible := false


func get_movement_input(delta) -> Vector2:
	if is_taking_damage:
		print("Taking Damage")
		direction.y += knockback_gravity
		return direction
	direction.x = Input.get_axis("move_left", "move_right") * speed
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer.start()

	if is_on_floor() or !coyote_timer.is_stopped():
		if Input.is_action_just_pressed("jump") || !jump_buffer.is_stopped():
			direction.y = -jump_velocity
			coyote_timer.stop()
			jump_buffer.stop()
			is_jumping = true
			jump_timer.start()
		elif is_on_floor():
			direction.y = 0
	else:
		if is_jumping:
			if Input.is_action_pressed("jump") && !jump_timer.is_stopped():
				direction.y += reduced_gravity
			else:
				is_jumping = false
				direction.y += gravity
		else:
			direction.y += gravity
	return direction


func get_attack_input() -> void:
	if Input.is_action_just_pressed("melee_attack") && can_attack:
		can_attack = false
		is_attacking = true
		melee_cooldown.start()
		if sword.is_colliding():
			for i in sword.get_collision_count():
				if sword.get_collider(i) is Enemy:
					sword.get_collider(i).health.take_damage(sword_damage)


func get_animation() -> void:
	if is_taking_damage:
		animated_sprite.play("jump")
	elif direction == Vector2.ZERO:
		if last_direction.x < 0:
			animated_sprite.flip_h = true
		elif last_direction.x > 0:
			animated_sprite.flip_h = false
		if is_attacking:
			animated_sprite.play("attack")
		else:
			animated_sprite.play("idle")
	elif direction != Vector2.ZERO && !is_taking_damage:
		if direction.x < 0:
			animated_sprite.flip_h = true
		elif direction.x > 0:
			animated_sprite.flip_h = false
		if is_attacking:
			animated_sprite.play("attack")
		elif is_on_floor():
			animated_sprite.play("walk")
		elif is_jumping:
			animated_sprite.play("jump")
	


func _physics_process(delta) -> void:
	if animated_sprite.flip_h == true:
		sword.target_position.x = -sword_target
	elif animated_sprite.flip_h == false:
		sword.target_position.x = sword_target
	if can_attack == false && melee_cooldown.is_stopped():
		can_attack = true
		is_attacking = false
	direction = get_movement_input(delta)
	get_attack_input()
	get_animation()
	if direction != Vector2.ZERO:
		if !is_invincible:
			last_direction = direction
		velocity = direction
		was_on_floor = is_on_floor()
		move_and_slide()
		if was_on_floor && !is_on_floor():
			coyote_timer.start()


func _ready():
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)
	knockback_timer.timeout.connect(_on_knockback_timeout)
	invincibility.timeout.connect(_on_invcinvibility_timeout)


func _on_damaged():
	pass


func _on_knockback_timeout():
	is_taking_damage = false
	can_attack = true


func _on_invcinvibility_timeout():
	is_invincible = false


func _on_died():
	print("You Died")


func _on_enemy_damage_player(enemy_position):
	print("RAT")
	if invincibility.is_stopped:
		is_taking_damage = true
		invincibility.start()
		is_invincible = true
		direction = -(position.direction_to(enemy_position) * knockback)
		knockback_timer.start()
		can_attack = false
