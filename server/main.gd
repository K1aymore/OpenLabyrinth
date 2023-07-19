extends Control

class_name Main

@onready var network : Network = $Network

const DEFAULTIP = "localhost"
const DEFAULTPORT = 4433


var boards : Dictionary



func _ready():
	# Start paused.
	get_tree().paused = false
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false
	get_tree().get_multiplayer().allow_object_decoding = false
	
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(DEFAULTPORT)
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("Failed to start multiplayer server.")
		return
	
	multiplayer.multiplayer_peer = peer
	peer.peer_connected.connect(playerConnected)
	peer.peer_disconnected.connect(playerDisconnected)



func playerConnected(peerID : int):
	await get_tree().create_timer(1).timeout
	print(str(peerID) + " connected")
	network.requestBoardList(peerID)


func playerDisconnected(peerID : int):
	await get_tree().create_timer(1).timeout
	print(str(peerID) + " disconnected")
	for boardName in boards.keys():
		boards[boardName].peerIDs.erase(peerID)
		if boards[boardName].peerIDs.size() <= 0:
			boards.erase(boardName)

