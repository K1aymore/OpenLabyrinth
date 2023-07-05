extends Control

const DEFAULTIP = "localhost"
const DEFAULTPORT = 4433

@onready var network := $Network
@onready var board := $HBoxContainer/SubViewportContainer/SubViewport/Board

@onready var connectIP : LineEdit  = $MainMenu/VBoxContainer/HBoxContainer2/ConnectIP
@onready var connectPort : LineEdit  = $MainMenu/VBoxContainer/HBoxContainer2/ConnectPort

var currentPlayerID := 1
var currentPlayer := false


func _ready():
	# Start paused.
	get_tree().paused = true
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false
	$MainMenu.visible = true
	$HBoxContainer/Panel/GameActions.visible = false



func _on_client_pressed():
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
	closeMainMenu()

func connectFail():
	print("Failed to start multiplayer client.")



func closeMainMenu():
	$MainMenu.visible = false



@rpc
func startGame():
	get_tree().paused = false
	$MainMenu.visible = false
	$HBoxContainer/Panel/GameActions.visible = true



@rpc
func nextTurn(nextPlayer : int):
	currentPlayerID = nextPlayer
	currentPlayer = currentPlayerID == multiplayer.get_unique_id()
	board.currentPlayer = currentPlayer
	for button in $HBoxContainer/Panel/GameActions.get_children():
		if button is Button:
			button.disabled = !currentPlayer


@rpc
func updatePlayerList(playerList : String):
	$HBoxContainer/Panel2/PlayersList/PlayersLabel.text = playerList


func _on_push_pressed():
	board.push()
	nextTurn.rpc()


func _on_rotate_pressed():
	board.rotateSpareTile()
