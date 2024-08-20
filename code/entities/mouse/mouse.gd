extends CharacterBody2D
class_name Mouse

@export var speed := 300.0
@export var gravity := 40
@export var reduced_gravity := 5
@export var jump_velocity := 500
@export var sword_damage := 20
@export var knockback := 500
@export var knockback_gravity := 20
@export var sprite_left_offset : Vector2 = Vector2(-150,0)
@export var sprite_right_offset : Vector2 = Vector2(0,0)

@onready var coyote_timer := $CoyoteTime
@onready var jump_buffer := $JumpBuffer
@onready var jump_timer := $JumpTimer
@onready var melee_cooldown := $Sword/Cooldown
@onready var sword := $Sword
@onready var animated_sprite := $AnimatedSprite2D
@onready var health := $Health
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
var hit_enemies := []

signal change_direction

func get_movement_input(_delta) -> Vector2:
	if is_taking_damage:
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


func damage_enemies():
	if sword.has_overlapping_bodies():
			for i in sword.get_overlapping_bodies():
				if i is Enemy && i not in hit_enemies:
					hit_enemies.append(i)
					i.health.take_damage(sword_damage)


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
		emit_signal("change_direction", "left")
		animated_sprite.offset = sprite_left_offset
	elif animated_sprite.flip_h == false:
		emit_signal("change_direction", "right")
		animated_sprite.offset = sprite_right_offset
	if can_attack == false && melee_cooldown.is_stopped():
		can_attack = true
		is_attacking = false
		hit_enemies = []
	direction = get_movement_input(delta)
	get_attack_input()
	get_animation()
	if is_attacking:
		damage_enemies()
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


func _on_invcinvibility_timeout():
	is_invincible = false


func _on_died():
	print("Dead")


func _on_enemy_damage_player(enemy_position):
	if invincibility.is_stopped:
		is_taking_damage = true
		invincibility.start()
		is_invincible = true
		direction = -(position.direction_to(enemy_position) * knockback)
		knockback_timer.start()
		can_attack = false
