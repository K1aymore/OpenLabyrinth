extends Control

@onready var network := $Network
@onready var board := $HBoxContainer/SubViewportContainer/SubViewport/Board

var currentPlayerID := 1
var currentPlayer := false

func _ready():
	# Start paused.
	get_tree().paused = true
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false
	$MainMenu.visible = true
	$HBoxContainer/Panel/GameActions.visible = false



func _on_host_pressed():
	network.createServer()
	$MainMenu.visible = false
	$HBoxContainer/Panel/StartButton.visible = true


func _on_client_pressed():
	network.joinAsClient()
	$MainMenu.visible = false
	$HBoxContainer/Panel/StartButton.visible = false


func _on_start_button_pressed():
	startGame.rpc()


@rpc("call_local")
func startGame():
	get_tree().paused = false
	$MainMenu.visible = false
	$HBoxContainer/Panel/StartButton.visible = false
	$HBoxContainer/Panel/GameActions.visible = true
	nextTurn.rpc()


@rpc("any_peer", "call_local")
func nextTurn():
	currentPlayerID = network.nextPlayer()
	currentPlayer = currentPlayerID == multiplayer.get_unique_id()
	board.currentPlayer = currentPlayer
	for button in $HBoxContainer/Panel/GameActions.get_children():
		if button is Button:
			button.disabled = !currentPlayer




func _on_push_pressed():
	board.push()
	nextTurn.rpc()


func _on_rotate_pressed():
	board.rotateSpareTile()
