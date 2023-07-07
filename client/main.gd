extends Control

const DEFAULTIP = "localhost"
const DEFAULTPORT = 4433

@onready var board := $HBoxContainer/SubViewportContainer/SubViewport/Board

@onready var connectIP : LineEdit  = $MainMenu/VBoxContainer/HBoxContainer2/ConnectIP
@onready var connectPort : LineEdit  = $MainMenu/VBoxContainer/HBoxContainer2/ConnectPort

var currentPlayerID := 1
var isCurrentPlayer := false

var turnStage := TURNSTAGE.TILE

enum TURNSTAGE {
	TILE,
	MOVE,
}


func _ready():
	# Start paused.
	get_tree().paused = true
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false
	get_tree().get_multiplayer().allow_object_decoding = true
	$MainMenu.visible = true
	$HBoxContainer/Panel/GameActions.visible = false
	$MainMenu/LocalSetup.visible = true



func _process(delta):
	if isCurrentPlayer && turnStage == TURNSTAGE.MOVE:
		if Input.is_action_just_pressed("up"):
			board.movePlayer(Vector2.UP)
		if Input.is_action_just_pressed("left"):
			board.movePlayer(Vector2.LEFT)
		if Input.is_action_just_pressed("right"):
			board.movePlayer(Vector2.RIGHT)
		if Input.is_action_just_pressed("down"):
			board.movePlayer(Vector2.DOWN)


func _on_start_local_pressed():
	$MainMenu/MainMenu.visible = false
	$MainMenu/LocalSetup.visible = true


func _on_start_game_pressed():
	board.generateMap()
	closeMainMenu()
	startGame()


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



func startGame():
	get_tree().paused = false
	$MainMenu.visible = false
	$HBoxContainer/Panel/GameActions.visible = true
	isCurrentPlayer = true
	board.isCurrentPlayer = true


func nextTurn(nextPlayer : int):
	currentPlayerID = nextPlayer
	$HBoxContainer/Panel2/PlayersList/CurrPlayerLabel.text = "Current Player: " + str(currentPlayerID)
	isCurrentPlayer = currentPlayerID == multiplayer.get_unique_id()
	board.currentPlayer = isCurrentPlayer
	for button in $HBoxContainer/Panel/GameActions.get_children():
		if button is Button:
			button.disabled = !isCurrentPlayer


func setupMovePlayer():
	turnStage = TURNSTAGE.MOVE
	for button in $HBoxContainer/Panel/GameActions.get_children():
		if button is Button:
			button.disabled = true


func updatePlayerList(playerList : String):
	$HBoxContainer/Panel2/PlayersList/PlayersLabel.text = playerList


func _on_push_pressed():
	if isCurrentPlayer:
		board.push()
		setupMovePlayer()


func _on_rotate_pressed():
	board.rotateSpareTile()





