extends CharacterBody2D

@export var speed = 100  # movement speed
var av = Vector2.ZERO  # avoidance vector
var avoid_weight = 0.01  # how strongly to avoid other units
var target_radius = 10  # stop when this close to target
var direction : Vector2 = Vector2.ZERO
@export var sprite : Sprite2D

var selected = false:
	set = set_selected
var target = null:
	set = set_target


func _ready():
	sprite.material = sprite.material.duplicate()
	pass

func _physics_process(delta):
	velocity = Vector2.ZERO
	if target:
		velocity = position.direction_to(target)
		if position.distance_to(target) < target_radius:
			target = null
	av = avoid()
	velocity = (velocity + av * avoid_weight).normalized() * speed
	if velocity.length() > 0:
		rotation = velocity.angle()
	move_and_slide()

func set_selected(value):
	selected = value
	if selected:
		sprite.material.set_shader_parameter("aura_width", 1)
	else:
		sprite.material.set_shader_parameter("aura_width", 0)
	#
func set_target(value):
	target = value

func avoid():
	var result = Vector2.ZERO
	var neighbors = $Detect.get_overlapping_bodies()
	if neighbors:
		for n in neighbors:
			result += n.position.direction_to(position)
		result /= neighbors.size()
	return result.normalized()
