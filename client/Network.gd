extends Node

class_name Network

const DEFAULTIP = "localhost"
const DEFAULTPORT = 4433


@export var main : Main
@export var board : Board
@export var mainMenu : MainMenu


@export var clientConnectButton : Button


var boardNum : int



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



func setupClient(ip, port):
	ip = ip.to_int() if ip.is_valid_int() else DEFAULTIP
	port = port.to_int() if port.is_valid_int() else DEFAULTPORT
	
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
	mainMenu.setShownMenu($"../MainMenu/LocalSetup")







func callPeers(method : Callable, args : Array):
	serverCall.rpc_id(1, boardNum, method.get_method(), args)


@rpc("any_peer")
func serverCall(boardID, methodName, args):
	pass

@rpc
func callFromServer(methodName, args):
	callv(methodName, args)



func printInputs(input1, input2):
	print(input1)
	print(input2)
