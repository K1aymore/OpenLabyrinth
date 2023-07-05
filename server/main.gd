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
	$MainMenu.visible = true



func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(hostPort.text.to_int() if hostPort.text != "" else DEFAULTPORT)
	
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		print("Failed to start multiplayer server.")
		return
	
	multiplayer.multiplayer_peer = peer
	peer.peer_connected.connect(playerConnected)
	
	$MainMenu.visible = false
	$HBoxContainer/Panel/StartButton.visible = true



func playerConnected(peerID : int):
	await get_tree().create_timer(1).timeout
	
	var playerList : String = "Players:\n"
	for player in multiplayer.get_peers():
		playerList += str(player) + "\n"
	
	updatePlayerList.rpc(playerList)



func _on_start_button_pressed():
	startGame.rpc()


@rpc("call_local")
func startGame():
	get_tree().paused = false
	$MainMenu.visible = false
	$HBoxContainer/Panel/StartButton.visible = false
	nextTurn.rpc()


@rpc
func nextTurn():
	pass


@rpc("call_local")
func updatePlayerList(playerList : String):
	$HBoxContainer/Panel2/PlayersList/PlayersLabel.text = playerList


func _on_push_pressed():
	board.push()
	nextTurn.rpc(nextPlayer())


func _on_rotate_pressed():
	board.rotateSpareTile()


func nextPlayer() -> int:
	currentPlayerNum += 1
	if currentPlayerNum >= multiplayer.get_peers().size():
		currentPlayerNum = 0
	
	print(currentPlayerNum)
	print(multiplayer.get_peers())
	return multiplayer.get_peers()[currentPlayerNum]
