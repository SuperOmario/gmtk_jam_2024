extends Enemy
class_name Rat

@onready var health := $Health
@onready var aggro_radius := $AggroRadius

# Called when the node enters the scene tree for the first time.
func _ready():
	health.damaged.connect(_on_damaged)
	health.died.connect(_on_died)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if _get_aggro():	
		pass


func _on_aggro_radius_entered(body):
	_set_aggro(true) # Replace with function body.
