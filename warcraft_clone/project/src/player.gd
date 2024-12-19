extends CharacterBody2D
@export var unit_1 : PackedScene
@export var unit_2 : PackedScene
@export var timer : Timer

func _enter_tree():
	set_multiplayer_authority(name.to_int(),true)
 
func _ready():
	timer.timeout.connect(_on_timer_timeout)
	timer.start()
	print(multiplayer.get_unique_id(),"       dfdfdfdfdf")
func _physics_process(delta):
	if is_multiplayer_authority():
		velocity = Input.get_vector("ui_left","ui_right","ui_up","ui_down") * 400

	move_and_slide()

func _on_timer_timeout():
	var spawn_position = global_position + Vector2(0,10)
	var unit = unit_1.instantiate()
	unit.global_position = spawn_position
	unit.direction = Vector2(1,1)
	call_deferred("add_child",unit,true)
	#elif inty >=2:
		#var spawn_position = global_position + Vector2(0,10)
		#var unit = unit_2.instantiate()
		#unit.global_position = spawn_position
		#unit.direction = Vector2(-1,-1)
		#call_deferred("add_child",unit,true)
