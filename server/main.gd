extends Control


const DEFAULTIP = "localhost"
const DEFAULTPORT = 4433


var games : Array[Game]


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


func playerDisconnected(peerID : int):
	await get_tree().create_timer(1).timeout



@rpc("any_peer")
func serverClientJoinGame(gameNum : int, peerID : int):
	games[gameNum].peerIDs.append(peerID)



@rpc("any_peer")
func serverStartGame():
	pass


@rpc("any_peer")
func serverUpdateTiles():
	pass


@rpc("any_peer")
func serverUpdatePlayers():
	pass
