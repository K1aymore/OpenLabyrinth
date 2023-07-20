extends Node

class_name Network

const DEFAULTIP = "localhost"
const DEFAULTPORT = 4433


@export var main : Main
@export var board : Board
@export var mainMenu : MainMenu


@export var clientConnectButton : Button

var isBoardLeader : bool

var boardName : String


func _ready():
	setIsBoardLeader(false)
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false
	get_tree().get_multiplayer().allow_object_decoding = false


func setIsBoardLeader(value : bool):
	isBoardLeader = value
	$"../MainMenu/GameSetup/Menu/StartGame".disabled = !value


func callClients(method : Callable, args : Array):
	serverCall.rpc_id(1, boardName, method.get_method(), args)



@rpc("any_peer", "call_local")
func serverCall(boardID, methodName, args):
	callFromServer.rpc(methodName, args)


@rpc("call_local")
func callFromServer(methodName, args):
	main.callv(methodName, args)




func setupServer(port):
	var peer = ENetMultiplayerPeer.new()
	
	
	peer.create_server(DEFAULTPORT)
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("Failed to start multiplayer server.")
		return
	
	multiplayer.multiplayer_peer = peer
	peer.peer_connected.connect(lanPlayerConnected)
	peer.peer_disconnected.connect(lanPlayerDisconnected)



func lanPlayerConnected(peerID : int):
	await get_tree().create_timer(1).timeout
	main.loadServerPlayers()


func lanPlayerDisconnected(peerID : int):
	await get_tree().create_timer(1).timeout
	main.loadServerPlayers()



func setupClient(ip : String, port : int):
	ip = ip if ip != "" else DEFAULTIP
	port = port if port != 0 else DEFAULTPORT
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(connectSuccess)
	
	clientConnectButton.disabled = true
	clientConnectButton.text = "Connecting..."
	
	await get_tree().create_timer(2).timeout
	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		peer.close()
		multiplayer.multiplayer_peer = null
		print("couldn't connect in 2 secs")
		clientConnectButton.disabled = false
		clientConnectButton.text = "Connect"


func connectSuccess():
	print("Connected to server")
	clientConnectButton.disabled = false
	clientConnectButton.text = "Connect"
	mainMenu.setShownMenu($"../MainMenu/BoardList")
	requestBoardList()





@rpc("any_peer")
func requestBoardList(peerID : int = 1):
	requestBoardList.rpc_id(1, multiplayer.get_unique_id())


@rpc
func recieveBoardList(boardList : Array):
	var typedBoardList : Array[String]
	
	for str in boardList:
		if str is String:
			typedBoardList.append(str)
	
	mainMenu.addBoardButtons(typedBoardList)



@rpc("any_peer")
func serverCreateNewBoard(peerID : int, boardName : String):
	pass


@rpc("any_peer", "call_local")
func serverClientJoinBoard(peerID : int, boardName : String):
	main.joinBoard(boardName)


func sendServerTiles():
	var tileTypes : Array
	var tileItems : Array
	
	for tile in board.tiles:
		tileTypes.append(tile.type)
		tileItems.append(tile.item)
	
	callClients(main.loadTiles, [tileTypes, tileItems])



func sendServerPlayers():
	var playerNames : Array
	var playerOwnedClients : Array
	var playerColors : Array
	
	for player in main.players:
		playerNames.append(player.name)
		playerOwnedClients.append(player.ownedClientID)
		playerColors.append(player.color)
	
	callClients(main.loadPlayers, [playerNames, playerOwnedClients, playerColors])

