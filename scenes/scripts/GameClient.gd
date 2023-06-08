extends Control

@onready var peer_id_label = $PeerIdLabel
@onready var status_label = $StatusLabel

const SERVER_HOST = "localhost"
const LOBBY_SERVER_HOST = "wss://localhost:59142/lobby"
var enet_peer = ENetMultiplayerPeer.new()
var steamAuthTicket
var wsClient : WebSocketPeer = WebSocketPeer.new()

func _ready():
	steamAuthTicket = Steam.getAuthSessionTicket()
	print(steamAuthTicket)
	
	var stink = ''
	var pack : Array = steamAuthTicket["buffer"]
	pack = pack.slice(0, steamAuthTicket["size"])
	for d in pack:
		stink = stink.insert(stink.length(), intToHex(d))
	var tlsOptions : TLSOptions = TLSOptions.client_unsafe()
	wsClient.set_handshake_headers(["x-steam-token: %s" % stink])
	wsClient.connect_to_url(LOBBY_SERVER_HOST, tlsOptions)
	
	print(wsClient.handshake_headers)
	OS.alert("We g a ticket! %s" % stink)
	
#	connectToServer()
	
func intToHex(integer: int):
	return ("%02X" % integer)
	
func connectToServer():
	print("Connecting to server %s%s" % [SERVER_HOST, GameServer.SERVER_PORT])
	enet_peer.create_client(SERVER_HOST, GameServer.SERVER_PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.connected_to_server.connect(on_connected_to_server)
	multiplayer.connection_failed.connect(on_connection_to_server_failed)
	
func on_connected_to_server():
	print("Connected to server!")
	peer_id_label.text = str(multiplayer.get_unique_id())
	
func on_connection_to_server_failed():
	print("Failed to connect to server!")

func _process(delta):
	wsClient.poll()
	var state = wsClient.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
#		print("Connection established")
		while wsClient.get_available_packet_count(): _on_data_received()
		
		
	elif state == WebSocketPeer.STATE_CLOSING:
	# Keep polling to achieve proper close.
		pass
	elif state == WebSocketPeer.STATE_CLOSED:
		var code = wsClient.get_close_code()
		var reason = wsClient.get_close_reason()
		print("WebSocket closed with code: %d, reason %s. Clean: %s" % [code, reason, code != -1])
		set_process(false) # Stop processing.


func _on_ready_button_pressed():
	var message = {"MessageType": Messages.ClientMessageType.StartMatchMaking}
	var json_string = JSON.stringify(message)
	print(json_string)
	wsClient.put_packet(json_string.to_utf8_buffer())

func _on_connection_established():
	pass
	
func _on_data_received():
	var packet = wsClient.get_packet()
	var isString = wsClient.was_string_packet()
	var messageData = JSON.parse_string(packet.get_string_from_utf8())
	print(messageData)
	if isString:
		var message = packet.get_string_from_utf8()
		_handle_message_received(message)

func _handle_message_received(message: String):
	var messageData = JSON.parse_string(message)
	print(messageData["MessageType"])
	match int(messageData["MessageType"]):
		Messages.ServerMessageType.ConnectionEstablished:
			var messageContent = messageData["MessageContent"]["Username"]
			status_label.text = "We are connected on the lobby server! %s" % messageContent
		Messages.ServerMessageType.MatchmakingStarted:
			status_label.text = "Matchmaking started!"
		Messages.ServerMessageType.MatchFound:
			status_label.text = "Match found!"
#			var matchFoundMessage = messageData["MessageContent"].Deserialize<MatchFoundMessage>();
#			this.ConnectToServer(matchFoundMessage.ServerUrl, matchFoundMessage.ServerPort);
			
			
#	private void HandleMessageReceived(string message) {
#		var messageData = JsonSerializer.Deserialize<JsonObject>(message);
#		switch ((ServerMessageType) (int) messageData["MessageType"]) {
#			case ServerMessageType.ConnectionEstablished:
#				var messageContent = messageData["MessageContent"].Deserialize<ConnectionEstablishedMessage>();
#				this._statusLabel.Text = $"We are connected on the lobby server! {messageContent.Username}";
#
#				break;
#			case ServerMessageType.MatchmakingStarted:
#				this._statusLabel.Text = $"Matchmaking started!";
#
#				break;
#			case ServerMessageType.MatchFound:
#				this._statusLabel.Text = $"Hey match found!";
#				var matchFoundMessage = messageData["MessageContent"].Deserialize<MatchFoundMessage>();
#				this.ConnectToServer(matchFoundMessage.ServerUrl, matchFoundMessage.ServerPort);
#
#				break;
#		}
#	}
#}
