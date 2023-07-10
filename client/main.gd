extends Control

class_name Main

const DEFAULTIP = "localhost"
const DEFAULTPORT = 4433

@onready var board : Board = $HBoxContainer/SubViewportContainer/SubViewport/Board

@onready var connectIP : LineEdit  = $MainMenu/MainMenu/HBoxContainer2/ConnectIP
@onready var connectPort : LineEdit  = $MainMenu/MainMenu/HBoxContainer2/ConnectPort

const MAX_PLAYERS = 4

var players : Array[Player]
var currentPlayer : Player
var isCurrentClient := false
var gameID : int

var turnStage := TURNSTAGE.TILE

enum TURNSTAGE {
	TILE,
	MOVE,
}


func _ready():
	randomize()
	# Start paused.
	get_tree().paused = true
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false
	get_tree().get_multiplayer().allow_object_decoding = true
	$MainMenu.visible = true
	$MainMenu/MainMenu.visible = true
	$HBoxContainer/Panel/GameActions.visible = false
	$MainMenu/LocalSetup.visible = false
	board.main = self
	



func _process(delta):
	if !isCurrentClient:
		return
	
	
	if turnStage == TURNSTAGE.MOVE:
		if Input.is_action_just_pressed("up"):
			movePlayer(Vector2.UP)
		if Input.is_action_just_pressed("left"):
			movePlayer(Vector2.LEFT)
		if Input.is_action_just_pressed("right"):
			movePlayer(Vector2.RIGHT)
		if Input.is_action_just_pressed("down"):
			movePlayer(Vector2.DOWN)
		
		if Input.is_action_just_pressed("ui_accept"):
			_on_end_move_pressed()
	
	
	if turnStage == TURNSTAGE.TILE:
		var pos : Vector2i = board.spareTile.pos.round()
		if Input.is_action_just_pressed("up"):
			if pos.y == 7 && pos.x != -1 && pos.x != 7:
				pos.y = -1
			else:
				pos += Vector2i.UP * 2
		if Input.is_action_just_pressed("left"):
			if pos.x == 7 && pos.y != -1 && pos.y != 7:
				pos.x = -1
			else:
				pos += Vector2i.LEFT * 2
		if Input.is_action_just_pressed("right"):
			if pos.x == -1 && pos.y != -1 && pos.y != 7:
				pos.x = 7
			else:
				pos += Vector2i.RIGHT * 2
		if Input.is_action_just_pressed("down"):
			if pos.y == -1 && pos.x != -1 && pos.x != 7:
				pos.y = 7
			else:
				pos += Vector2i.DOWN * 2
		
		board.moveSpareTile(pos)
		
		
		if Input.is_action_just_pressed("rotate"):
			_on_rotate_pressed()
		if Input.is_action_just_pressed("ui_accept"):
			_on_push_pressed()
	


func _on_start_local_pressed():
	$MainMenu/MainMenu.visible = false
	$MainMenu/LocalSetup.visible = true


func _on_add_player_pressed():
	if players.size() >= MAX_PLAYERS:
		return
	
	var newPlayer := Player.new()
	var text : String = $MainMenu/LocalSetup/HBoxContainer/PlayerName.text
	newPlayer.name = text if text != "" else str(randi())
	newPlayer.ownedClientID = multiplayer.get_unique_id()
	
	var playerDisplay := preload("res://player_display.tscn").instantiate()
	playerDisplay.player = newPlayer
	$HBoxContainer/Panel2/PlayersList.add_child(playerDisplay)
	
	players.append(newPlayer)
	$MainMenu/PlayerList.text = getPlayerList()
	$MainMenu/LocalSetup/HBoxContainer/PlayerName.text = ""


func _on_start_game_pressed():
	currentPlayer = players[0]
	closeMainMenu()
	startGame()




@rpc("any_peer")
func serverClientJoinGame(gameNum : int, peerID : int):
	pass



@rpc("any_peer")
func serverStartGame():
	pass



@rpc("any_peer")
func serverUpdateTiles(tilePositions, tileRotations, spareTileID):
	pass


@rpc("any_peer")
func serverUpdatePlayers(playerPositions):
	pass



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
	$HBoxContainer/Panel2/PlayersList/PlayersLabel.text = getPlayerList()
	setCurrentPlayer(players[0])
	board.generateMap()
	
	for i in players.size():
		var playerStart : Vector2
		match i:
			0:
				playerStart = Vector2(0, 0)
			1:
				playerStart = Vector2(6, 0)
			2:
				playerStart = Vector2(0, 6)
			3:
				playerStart = Vector2(6, 6)
		var startTile := board.getTile(playerStart)
		players[i].tile = startTile
		players[i].homeTile = startTile
	
	var itemsList : Array[Tile.ITEM]
	for i in range(1, Tile.ITEM.size()):
		itemsList.append(i)
	itemsList.shuffle()
	
	for player in players:
		for i in 24 / players.size():
			player.neededItems.append(itemsList.pop_back())
	
	board.addPlayerSprites(players)
	$HBoxContainer/Panel/GameActions/EndMove.disabled = true
	


func nextTurn():
	var nextPlayerNum : int = players.find(currentPlayer) + 1
	if nextPlayerNum >= players.size():
		nextPlayerNum = 0
	setCurrentPlayer(players[nextPlayerNum])
	turnStage = TURNSTAGE.TILE
	$HBoxContainer/Panel/GameActions/EndMove.disabled = true
	
	match currentPlayer.homeTile.pos.round():
		Vector2(0,0):
			board.spareTile.pos = Vector2(-1, -1)
		Vector2(6, 0):
			board.spareTile.pos = Vector2(7, -1)
		Vector2(0, 6):
			board.spareTile.pos = Vector2(-1, 7)
		Vector2(6, 6):
			board.spareTile.pos = Vector2(7, 7)
	
	


func setCurrentPlayer(newCurPlayer : Player):
	currentPlayer = newCurPlayer
	$HBoxContainer/Panel2/PlayersList/CurrPlayerLabel.text = "Current Player: " + currentPlayer.name
	isCurrentClient = currentPlayer.ownedClientID == multiplayer.get_unique_id()
	
	for button in $HBoxContainer/Panel/GameActions.get_children():
		if button is Button:
			button.disabled = !isCurrentClient


func getPlayerList() -> String:
	var playerNames := "Current Players:"
	for p in players:
		playerNames += "\n" + p.name
	
	return playerNames


func setupMovePlayer():
	turnStage = TURNSTAGE.MOVE
	for button in $HBoxContainer/Panel/GameActions.get_children():
		if button is Button:
			button.disabled = true
	$HBoxContainer/Panel/GameActions/EndMove.disabled = false


func movePlayer(dir : Vector2):
	var currTile = currentPlayer.tile
	var nextTile = board.getTile(currentPlayer.tile.pos + dir)
	if currTile != null && nextTile != null && currTile.canMoveThrough(dir) && nextTile.canMoveThrough(-dir):
		currentPlayer.tile = nextTile



func _on_push_pressed():
	if isCurrentClient && board.getArrow(board.spareTile.pos) != null && \
			board.getArrow(board.spareTile.pos).visible == true:
		
		board.push()
		for arrow in board.arrows:
			arrow.visible = true
		board.getArrow(board.spareTile.pos).visible = false
		setupMovePlayer()


func _on_rotate_pressed():
	board.rotateSpareTile()


func _on_end_move_pressed():
	if turnStage != TURNSTAGE.MOVE:
		return
	
	if currentPlayer.neededItems.size() > 0 && currentPlayer.neededItems[0] == currentPlayer.tile.item:
		currentPlayer.foundItems.append(currentPlayer.neededItems.pop_front())
	
	nextTurn()
