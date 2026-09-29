extends Node

const IP_ADDRESS: String = "100.111.59.8"
const PORT: int = 021022

var peer = ENetMultiplayerPeer.new()

var drawing: Node = null

func _ready() -> void:
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(_on_peer_connected)

func startServer() -> void:
	peer.create_server(PORT)
	multiplayer.multiplayer_peer = peer

func startClient() -> void:
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer

func _on_peer_connected(id: int) -> void:
	if not drawing:
		return
		
	var linesData: Array = []
	for child in drawing.lines.get_children():
		var lineInfo = {
			"name": child.name,
			"width": child.get_width(),
			"color": child.default_color,
			"points": child.points
		}
		linesData.append(lineInfo)
	
	drawing.newPlayerJoined(id, linesData)
