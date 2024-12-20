extends Node2D


@export var player_points = 0
@export var enemy_points = 0

@export var player_scene:PackedScene =  preload("res://src/player.tscn")

func _ready():
	print(GameManager.Players)
	var index = 0
	for i in GameManager.Players:
		print(i)
		var current_player = player_scene.instantiate()
		current_player.name = str(GameManager.Players[i].id)
		add_child(current_player)
		for spawn in get_tree().get_nodes_in_group("PlayerSpawns"):
			
			if spawn.name == str(index):
				
				current_player.global_position = spawn.global_position
		index += 1

func enemy_scored():
	update_enemy_scored.rpc()

@rpc("any_peer", "call_local")
func update_enemy_scored():
	enemy_points += 1
	#UI.update_enemy_points(enemy_points)
	reset_game_state()

func player_scored():
	update_player_scored.rpc()

@rpc("any_peer", "call_local")
func update_player_scored():
	player_points += 1
	#UI.update_player_point(player_points)
	reset_game_state()
	
func reset_game_state():
	pass

var dragging = false  # are we currently dragging?
var selected = []  # array of selected units
var drag_start = Vector2.ZERO  # location where the drag begian
var select_rect = RectangleShape2D.new()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			print(event.position)
			# If the mouse was clicked and nothing is selected, start dragging
			if selected.size() == 0:
				dragging = true
				drag_start = event.position
			# Otherwise a click tells the selected units to move
			else:
				for item in selected:
					item.collider.target = event.position
					item.collider.selected = false
				selected = []
		# If the mouse is released and is dragging, stop dragging and select the units
		elif dragging:
			dragging = false
			queue_redraw()
			var drag_end = event.position
			select_rect.extents = abs(drag_end - drag_start) / 2
			var space = get_world_2d().direct_space_state
			var q = PhysicsShapeQueryParameters2D.new()
			q.shape = select_rect
			q.collision_mask = 2
			q.transform = Transform2D(0, (drag_end + drag_start) / 2)
			selected = space.intersect_shape(q)
			for item in selected:
				item.collider.selected = true
	if event is InputEventMouseMotion and dragging:
		queue_redraw()
		
func _draw():
	if dragging:
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start),
				Color.YELLOW, false, 2.0)
