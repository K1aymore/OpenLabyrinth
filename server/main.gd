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
	
	var boardIDs : Array[int]
	
	for i in games.size():
		if games[i] is Game:
			boardIDs.append(i)
	
	clientLoadBoardIDs.rpc_id(peerID, boardIDs)


func playerDisconnected(peerID : int):
	await get_tree().create_timer(1).timeout
	print(str(peerID) + " disconnected")
	for game in games:
		game.peerIDs.erase(peerID)
		if game.peerIDs.size() <= 0:
			games.erase(game)



@rpc("any_peer")
func serverCreateNewGame(peerID : int):
	var newGame = Game.new()
	games.append(newGame)
	serverClientJoinGame(games.size()-1, peerID)


@rpc("any_peer")
func serverClientJoinGame(gameNum : int, peerID : int):
	if gameNum < games.size():
		games[gameNum].peerIDs.append(peerID)
		clientSetBoardID.rpc_id(peerID, gameNum)


@rpc("any_peer")
func serverLoadTiles(boardNum, tileTypes, tileItems):
	for peerID in games[boardNum].peerIDs:
		clientLoadTiles.rpc_id(peerID, tileTypes, tileItems)


@rpc("any_peer")
func serverLoadPlayers(boardNum, playerNames : Array, playerOwnedClients : Array):
	for peerID in games[boardNum].peerIDs:
		clientLoadPlayers.rpc_id(peerID, playerNames, playerOwnedClients)


@rpc("any_peer")
func serverStartGame(boardNum : int):
	for peerID in games[boardNum].peerIDs:
		clientStartGame.rpc_id(peerID)


@rpc("any_peer")
func serverUpdateTiles(boardNum : int, tilePositions, tileRotations, spareTileNum, disabledArrowPos):
	for peerID in games[boardNum].peerIDs:
		clientUpdateTiles.rpc_id(peerID, tilePositions, tileRotations, spareTileNum, disabledArrowPos)


@rpc("any_peer")
func serverUpdatePlayers(boardNum : int, playerPositions, playersNeededItems, newCurPlayerNum):
	for peerID in games[boardNum].peerIDs:
		clientUpdatePlayers.rpc_id(peerID, playerPositions, playersNeededItems, newCurPlayerNum)


@rpc
func clientSetBoardID(boardID):
	pass

@rpc
func clientLoadBoardIDs(boardIDs):
	pass

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





@rpc("any_peer")
func serverCall(boardNum, methodName, args):
	callFromServer.rpc(methodName, args)


@rpc
func callFromServer(methodName, args):
	pass
