extends Node

const DEFAULTIP = "localhost"
const DEFAULTPORT = 4433

@onready var hostPort : String = $"../MainMenu/VBoxContainer/HBoxContainer/HostPort".text
@onready var connectIP : String = $"../MainMenu/VBoxContainer/HBoxContainer2/ConnectIP".text
@onready var connectPort : String = $"../MainMenu/VBoxContainer/HBoxContainer2/ConnectPort".text

var playerIDs : Array
var currentPlayerNumber := 0


func createServer():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(hostPort.to_int() if hostPort != "" else DEFAULTPORT)
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("Failed to start multiplayer server.")
		return
	
	multiplayer.multiplayer_peer = peer
	playerIDs.append(multiplayer.get_unique_id())
	peer.peer_connected.connect(playerConnected)


func joinAsClient():
	var ip = connectIP if connectIP != "" else DEFAULTIP
	var port = connectPort.to_int() if connectPort != "" else DEFAULTPORT
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("Failed to start multiplayer client.")
		return
	
	multiplayer.multiplayer_peer = peer


@rpc
func setPlayerIDList(list : Array):
	playerIDs = list


func playerConnected(peerID : int):
	playerIDs.append(peerID)
	await get_tree().create_timer(1).timeout
	setPlayerIDList.rpc(playerIDs)


func nextPlayer() -> int:
	currentPlayerNumber += 1
	if currentPlayerNumber >= playerIDs.size():
		currentPlayerNumber = 0
	
	return playerIDs[currentPlayerNumber]

