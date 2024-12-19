extends Node2D
 
var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
@export var host_button : Button
@export var join_button : Button
@export var hud : CanvasLayer
@export var player_1_position : Marker2D
@export var player_2_position : Marker2D
var players : int = 1
var bases_ready : int = 0
@export var base_scene : PackedScene
signal start_spawn

func _ready():
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	
func _on_host_pressed():
	peer.create_server(135)
	print(peer)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	hud.hide()
	_add_player()
 
func _add_player(id = 1):
	print(id,'   ', 'id')
	var player = player_scene.instantiate()
	var base = base_scene.instantiate()
	base.name = str(id)
	player.name = str(id)
	base.set_values(players)
	start_spawn.connect(base._on_start_spawn)
	base.ready.connect(_on_base_ready)
	print(players,'   ', 'players')
	if players <= 1:
		base.global_position = player_1_position.global_position
		GameManager.player_1_id = id
	elif players >= 2:
		base.global_position = player_2_position.global_position
		GameManager.player_2_id = id
	players += 1
	#call_deferred("add_child",base,true)
	call_deferred("add_child",player,true)


 
func _on_join_pressed():
	peer.create_client("localhost", 135)
	print(peer,"    ",'is the peer join')
	multiplayer.multiplayer_peer = peer
	hud.hide()

func _on_base_ready():
	bases_ready +=1
	print('here')
	if bases_ready >=2:
		print('both ready')
		call_deferred("check_players")
		
func start_spawning():
	start_spawn.emit()

func check_players():
	if players >=3:
		start_spawning()

var dragging = false
var selected = []
var drag_start = Vector2.ZERO
var select_rect = RectangleShape2D.new()

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
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
		draw_rect(Rect2(drag_start, get_global_mouse_position() - drag_start), Color.YELLOW, false, 2.0)
