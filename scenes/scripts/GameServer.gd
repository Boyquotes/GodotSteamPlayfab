extends Control
class_name GameServer

@onready var _playersVBoxContainer = $PlayersVBoxContainer

const SERVER_PORT = 6575
var enet_peer = ENetMultiplayerPeer.new()

func _ready():
	start_server()
	
func _on_add_client_button_pressed():
	var executableFile = OS.get_executable_path()
	var projectPath = ProjectSettings.globalize_path("res://")
	var args = []
	
	args.append("--path")
	args.append(projectPath)
	args.append("scenes/GameClient.tscn")
	
	OS.execute(executableFile, args)
	
func start_server():
	enet_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(peer_connected)
	multiplayer.peer_disconnected.connect(peer_disconnected)
	
func peer_connected(peer_id):
	print("Peer connected: %s" % str(peer_id))
	var label = Label.new()
	label.name = str(peer_id)
	label.text = str(peer_id)
	_playersVBoxContainer.add_child(label)

func peer_disconnected(peer_id):
	_playersVBoxContainer.get_node_or_null(str(peer_id)).queue_free()
