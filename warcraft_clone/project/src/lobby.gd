extends Control

var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene
@export var host_button : Button
@export var join_button : Button
@export var start_button : Button
@export var hud : CanvasLayer
@export var player_1_position : Marker2D
@export var player_2_position : Marker2D
var players : int = 1
var bases_ready : int = 0
@export var base_scene : PackedScene
signal start_spawn

@export var address = "127.0.0.1"
@export var port = 8080
const MAX_PLAYER = 2

func _ready():
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	start_button.pressed.connect(_on_start_pressed)

	multiplayer.peer_connected.connect(on_peer_connected)
	multiplayer.peer_disconnected.connect(on_peer_disconnected)
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_failed)

func _on_host_pressed():
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, MAX_PLAYER)
	if error != OK:
		print('cannot host: ' and error)
		return

	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)

	multiplayer.set_multiplayer_peer(peer)
	print("waiting for players")
	send_player_info("Jacob"+str(multiplayer.get_unique_id()), multiplayer.get_unique_id())

func _on_join_pressed():
	peer = ENetMultiplayerPeer.new()
	peer.create_client(address, port)
	peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.set_multiplayer_peer(peer)

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


func _on_start_pressed():
	start_game.rpc()
	pass

@rpc("any_peer", "call_local")
func start_game():
	var scene = load("res://src/main.tscn").instantiate()
	get_tree().root.add_child(scene)
	queue_free()

@rpc("any_peer")
func send_player_info(name, id):
	if !GameManager.Players.has(id):
		GameManager.Players[id] = {
			"name": name,
			"id": id,
			"score": 0
		}

	if multiplayer.is_server():
		for i in GameManager.Players:
			send_player_info.rpc(GameManager.Players[i].name, i)


func on_peer_connected(id):
	print('Player connected ' + str(id))

func on_peer_disconnected(id):
	print('Player disconnected ' + str(id))

func on_connected_to_server():
	print('Connected to server')
	send_player_info.rpc_id(1, "Jacob", multiplayer.get_unique_id())

func on_connection_failed():
	print('Couldnt connect')
