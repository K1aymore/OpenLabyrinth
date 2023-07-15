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
	print(str(peerID) + " connected")


func playerDisconnected(peerID : int):
	await get_tree().create_timer(1).timeout
	print(str(peerID) + " disconnected")
	for game in games:
		game.peerIDs.erase(peerID)



@rpc("any_peer")
func serverHostNewGame(peerID : int):
	var newGame = Game.new()
	newGame.peerIDs.append(peerID)
	games.append(newGame)


@rpc("any_peer")
func serverClientJoinGame(gameNum : int, peerID : int):
	if gameNum < games.size():
		games[gameNum].peerIDs.append(peerID)


@rpc("any_peer")
func serverLoadTiles(boardNum, tileTypes, tileItems):
	clientLoadTiles.rpc(tileTypes, tileItems)


@rpc("any_peer")
func serverLoadPlayers():
	pass


@rpc("any_peer")
func serverStartGame(boardNum : int, tileTypes, tileItems):
	for peerID in games[boardNum].peerIDs:
		clientStartGame.rpc_id(peerID, tileTypes, tileItems)


@rpc("any_peer")
func serverUpdateTiles(boardNum : int, tilePositions, tileRotations):
	for peerID in games[boardNum].peerIDs:
		clientUpdateTiles.rpc_id(peerID, tilePositions, tileRotations)


@rpc("any_peer")
func serverUpdatePlayers(boardNum : int, player1Items, player2Items, player3Items, player4Items):
	for peerID in games[boardNum].peerIDs:
		clientUpdatePlayers.rpc_id(peerID, player1Items, player2Items, player3Items, player4Items)



@rpc
func clientLoadTiles():
	pass

@rpc
func clientLoadPlayers():
	pass

@rpc
func clientStartGame():
	pass

@rpc
func clientUpdateTiles():
	pass

@rpc
func clientUpdatePlayers():
	pass
