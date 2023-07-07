extends Control

@onready var board := $HBoxContainer/SubViewportContainer/SubViewport/Board

const DEFAULTIP = "localhost"
const DEFAULTPORT = 4433

@onready var main = get_parent()

@onready var hostPort : LineEdit = $MainMenu/HBoxContainer/HostPort

var currentPlayerNum := 0


func _ready():
	# Start paused.
	get_tree().paused = true
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false
	get_tree().get_multiplayer().allow_object_decoding = true
	$MainMenu.visible = true



func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(hostPort.text.to_int() if hostPort.text != "" else DEFAULTPORT)
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("Failed to start multiplayer server.")
		return
	
	multiplayer.multiplayer_peer = peer
	peer.peer_connected.connect(playerConnected)
	peer.peer_disconnected.connect(playerDisconnected)
	
	$MainMenu.visible = false
	$HBoxContainer/Panel/StartButton.visible = true



func playerConnected(peerID : int):
	await get_tree().create_timer(1).timeout
	remoteUpdatePlayerList()
	board.remoteLoadTiles()


func playerDisconnected(peerID : int):
	await get_tree().create_timer(1).timeout
	remoteUpdatePlayerList()
	nextTurn.rpc(currentPlayerID())



func remoteUpdatePlayerList():
	var playerList : String = "Players:\n"
	for player in multiplayer.get_peers():
		playerList += str(player) + "\n"
	updatePlayerList.rpc(playerList)


@rpc("call_local")
func updatePlayerList(playerList : String):
	$HBoxContainer/Panel2/PlayersList/PlayersLabel.text = playerList



func _on_start_button_pressed():
	startGame.rpc()


@rpc("call_local")
func startGame():
	get_tree().paused = false
	$MainMenu.visible = false
	$HBoxContainer/Panel/StartButton.visible = false
	nextTurn.rpc(currentPlayerID())



@rpc
func nextTurn(nextPlayerID : int):
	pass

func currentPlayerID() -> int:
	if currentPlayerNum >= multiplayer.get_peers().size():
		currentPlayerNum = 0
	
	if multiplayer.get_peers().size() < 1:
		return 1
	
	return multiplayer.get_peers()[currentPlayerNum]
