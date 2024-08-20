extends Enemy
class_name Rat

@onready var animated_sprite := $AnimatedSprite2D
@onready var hitbox_collision1 := $Hitbox/CollisionShape2D
@onready var hitbox_collision2 := $Hitbox/CollisionShape2D2
@onready var hurtbox_collision := $HurtBox/CollisionShape2D
@onready var attackbox_collision := $AttackBox/CollisionShape2D
@export var hitbox_collision1_left_position : Vector2
@export var hitbox_collision1_right_position : Vector2
@export var hitbox_collision2_left_position : Vector2
@export var hitbox_collision2_right_position : Vector2
@export var hurtbox_left_position : Vector2
@export var hurtbox_right_position : Vector2
@export var attackbox_left_position : Vector2
@export var attackbox_right_position : Vector2

func _ready():
	super._ready()


func _process(delta):
	if animated_sprite.flip_h == false:
		change_direction("left")
	elif animated_sprite.flip_h == true:
		change_direction("right")
	super._process(delta)
	get_animation()


func get_animation():
	if direction != Vector2.ZERO && !is_attacking:
		if direction.x < 0:
			animated_sprite.flip_h = false
		elif direction.x > 0: 
			animated_sprite.flip_h = true
		animated_sprite.play("walk")
	elif direction != Vector2.ZERO && is_attacking:
		if direction.x < 0:
			animated_sprite.flip_h = false
		elif direction.x > 0: 
			animated_sprite.flip_h = true
		animated_sprite.play("attack")
	elif direction == Vector2.ZERO && !is_attacking:
		if last_direction.x < 0:
			animated_sprite.flip_h = false
		elif last_direction.x > 0: 
			animated_sprite.flip_h = true
	elif direction == Vector2.ZERO && is_attacking:
		if last_direction.x < 0:
			animated_sprite.flip_h = false
		elif last_direction.x > 0: 
			animated_sprite.flip_h = true
		animated_sprite.play("attack")


func change_direction(directionString : String):
	if directionString == "left":
		hitbox_collision1.position = hitbox_collision1_left_position
		hitbox_collision2.position = hitbox_collision2_left_position
		hurtbox_collision.position = hurtbox_left_position
		attackbox_collision.position = attackbox_left_position
	if directionString == "right":
		hitbox_collision1.position = hitbox_collision1_right_position
		hitbox_collision2.position = hitbox_collision2_right_position
		hurtbox_collision.position = hurtbox_right_position
		attackbox_collision.position = attackbox_right_position
