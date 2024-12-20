extends Node2D

@export var sprite : Sprite2D
@export var marker_1 : Marker2D
@export  var marker_2 : Marker2D
var spawn_position : Vector2 = Vector2.ZERO
@export var unit_1 : PackedScene
@export var unit_2 : PackedScene
@export var timer : Timer
var inty : int

func _enter_tree():
	print('name','   ',name.to_int())
	set_multiplayer_authority(name.to_int(),true)
 
func _ready():

	#timer.timeout.connect(_on_timer_timeout)
	spawn_position = marker_1.global_position
	pass

func _process(delta):
	pass

func set_values(integer):
	inty = integer
	print('inty','   ',inty)
	if integer >=2:
		var texture : CompressedTexture2D = sprite.get_texture()
		sprite.set_region_rect(Rect2(Vector2(32,0),Vector2(32,32)))
		pass

func _on_start_spawn():
	call_deferred("start_timer")

func start_timer():
	timer.start()

func _on_timer_timeout():
	if inty <=1:
		spawn_position = marker_1.global_position
		var unit = unit_1.instantiate()
		unit.global_position = spawn_position
		unit.direction = Vector2(1,1)
		call_deferred("add_child",unit,true)
	elif inty >=2:
		spawn_position = marker_2.global_position
		var unit = unit_2.instantiate()
		unit.global_position = spawn_position
		unit.direction = Vector2(-1,-1)
		call_deferred("add_child",unit,true)
