extends Node

const DEFAULTIP = "localhost"
const DEFAULTPORT = 4433

@onready var main = get_parent()

@onready var hostPort : LineEdit = $"../MainMenu/VBoxContainer/HBoxContainer/HostPort"
@onready var connectIP : LineEdit  = $"../MainMenu/VBoxContainer/HBoxContainer2/ConnectIP"
@onready var connectPort : LineEdit  = $"../MainMenu/VBoxContainer/HBoxContainer2/ConnectPort"

var playerIDs : Array
var currentPlayerNumber := 0


func createServer():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(hostPort.text.to_int() if hostPort.text != "" else DEFAULTPORT)
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("Failed to start multiplayer server.")
		return
	
	multiplayer.multiplayer_peer = peer
	playerIDs.append(multiplayer.get_unique_id())
	peer.peer_connected.connect(playerConnected)
	get_parent().updatePlayerList()


func joinAsClient():
	var ip = connectIP.text if connectIP.text != "" else DEFAULTIP
	var port = connectPort.text.to_int() if connectPort.text != "" else DEFAULTPORT
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(connectSuccess)
	
	await get_tree().create_timer(2).timeout
	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		peer.close()
		multiplayer.multiplayer_peer = null
		print("couldn't connect in 2 secs")


func connectSuccess():
	get_parent().closeMainMenu()


func connectFail():
	print("Failed to start multiplayer client.")


@rpc("any_peer", "call_local")
func setPlayerIDList(list : Array):
	playerIDs = list.duplicate()


func playerConnected(peerID : int):
	playerIDs.append(peerID)
	await get_tree().create_timer(1).timeout
	setPlayerIDList.rpc(playerIDs)
	get_parent().updatePlayerList.rpc()


func setCurrentPlayer():
	rpcSetCurrPlayer.rpc(currentPlayerNumber)


@rpc("call_local")
func rpcSetCurrPlayer(num : int):
	currentPlayerNumber = num


func nextPlayer() -> int:
	currentPlayerNumber += 1
	if currentPlayerNumber >= playerIDs.size():
		currentPlayerNumber = 0
	
	print(currentPlayerNumber)
	print(playerIDs)
	return playerIDs[currentPlayerNumber]

