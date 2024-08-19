extends CharacterBody2D
class_name Enemy

@export var speed := 100
@export var attack_damage := 20
@export var gravity := 40
@export var knockback := 300
@onready var direction_timer := $DirectionTimer
@onready var health := $Health
@onready var aggro_radius := $AggroRadius
@onready var hitbox := $Hitbox
@onready var player := $"../Mouse"
@onready var invincibility := $InvincibilityFrames

var is_aggro := false
var is_taking_damage := false
var direction : Vector2
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
	direction_timer.timeout.connect(_on_direction_timer_timeout)
	aggro_radius.body_entered.connect(_on_aggro_radius_entered)
	hitbox.body_entered.connect(_on_damage_dealt)
	invincibility.timeout.connect(_on_invincibility_ended)


func _on_died():
	queue_free()


func _on_damaged():
	is_taking_damage = true
	invincibility.start()

func _process(_delta):
	move()
	move_and_slide()


func _on_aggro_radius_entered(body):
	if body is Mouse:
		_set_aggro(true) # Replace with function body.


func _on_damage_dealt(body):
	if body is Mouse && !body.is_invincible:
		emit_signal("damage_player", self.position)
		body.health.take_damage(attack_damage)


func _on_invincibility_ended():
	is_taking_damage = false


func move():
	if !is_on_floor():
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
