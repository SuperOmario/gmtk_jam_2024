extends CharacterBody2D
class_name Enemy

@export var speed := 100
@export var attack_damage := 20
@export var gravity := 40
@export var knockback := 500
@onready var direction_timer := $DirectionTimer
@onready var health := $Health
@onready var aggro_radius := $AggroRadius
@onready var hitbox := $Hitbox
@onready var player := $"../Mouse"
@onready var invincibility := $InvincibilityFrames
@onready var attack_box := $AttackBox
@onready var attack_timer := $AttackTimer
@onready var attack_anticipation := $AttackStartTimer
@onready var hurtbox := $HurtBox

var is_aggro := false
var is_taking_damage := false
var is_attacking := false
var direction : Vector2
var last_direction := direction
var rng := RandomNumberGenerator.new()
var knockback_direction : Vector2

signal damage_player

func _set_aggro(aggro : bool) -> void:
	is_aggro = aggro


func _get_aggro() -> bool:
	return is_aggro


func _on_direction_timer_timeout():
	direction_timer.wait_time = rng.randf_range(1, 2.5)
	if !is_aggro:
		direction = choose([Vector2.RIGHT, Vector2.LEFT])
		velocity.x = 0


func choose(array):
	array.shuffle()
	return array.front()


func _ready():
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)
	aggro_radius.body_entered.connect(_on_aggro_radius_entered)
	attack_box.body_entered.connect(_on_attack_box_entered)
	hitbox.body_entered.connect(_on_damage_dealt)
	invincibility.timeout.connect(_on_invincibility_ended)
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	direction_timer.timeout.connect(_on_direction_timer_timeout)


func _on_died():
	queue_free()


func _on_damaged():
	is_taking_damage = true
	invincibility.start()


func _process(_delta):
	if is_attacking:
		if hurtbox.has_overlapping_bodies():
			for i in hurtbox.get_overlapping_bodies():
				print("overlapping")
				if i is Mouse:
					_on_damage_dealt(i)
	if attack_box.has_overlapping_bodies() && !is_taking_damage:
		for i in attack_box.get_overlapping_bodies():
			if i is Mouse:
				_on_attack_box_entered(i)
	move()
	move_and_slide()


func _on_aggro_radius_entered(body):
	if body is Mouse:
		_set_aggro(true) 


func _on_damage_dealt(body):
	if body is Mouse && !body.is_invincible:
		emit_signal("damage_player", self.position)
		body.health.take_damage(attack_damage)
		print("damage player")


func _on_invincibility_ended():
	is_taking_damage = false


func _on_attack_box_entered(body):
	if body is Mouse && !is_attacking && !is_taking_damage:
		is_attacking = true
		attack_timer.start()
		_attack()


func _attack():
	attack_anticipation.start()

func _on_attack_timer_timeout():
	is_attacking = false


func move():
	if is_attacking:
		direction = Vector2.ZERO
		velocity = direction
	elif !is_on_floor():
		velocity.y = gravity * speed
		velocity.x = 0
	elif !is_aggro:
		velocity = direction * speed
	elif is_aggro && !is_taking_damage && player:
		direction = position.direction_to(player.position)
		velocity.x = direction.x * speed 
	elif is_taking_damage:
		knockback_direction = -(position.direction_to(player.position) * knockback)
		velocity.x = knockback_direction.x
