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
var boardNum : int = 0

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
	$MainMenu/BoardList.visible = false
	board.main = self
	


func _process(delta):
	if !isCurrentClient:
		for button in $HBoxContainer/Panel/GameActions.get_children():
			if button is Button:
				button.disabled = true
		return
	
	
	$HBoxContainer/Panel/GameActions/Push.disabled = turnStage == TURNSTAGE.MOVE
	$HBoxContainer/Panel/GameActions/Rotate.disabled = turnStage == TURNSTAGE.MOVE
	$HBoxContainer/Panel/GameActions/EndMove.disabled = turnStage == TURNSTAGE.TILE
	
	if turnStage == TURNSTAGE.MOVE:
		if Input.is_action_just_pressed("up"):
			movePlayer(Vector2.UP)
		if Input.is_action_just_pressed("left"):
			movePlayer(Vector2.LEFT)
		if Input.is_action_just_pressed("right"):
			movePlayer(Vector2.RIGHT)
		if Input.is_action_just_pressed("down"):
			movePlayer(Vector2.DOWN)
		
		if Input.is_action_just_pressed("push"):
			_on_end_move_pressed()
	
	
	if turnStage == TURNSTAGE.TILE && board.spareTile != null:
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
		if Input.is_action_just_pressed("push"):
			_on_push_pressed()


func _on_start_local_pressed():
	$MainMenu/MainMenu.visible = false
	$MainMenu/LocalSetup.visible = true


func _on_add_player_pressed():
	if players.size() >= MAX_PLAYERS:
		return
	
	var text : String = $MainMenu/LocalSetup/HBoxContainer/PlayerName.text
	addPlayer(text, multiplayer.get_unique_id())
	$MainMenu/LocalSetup/HBoxContainer/PlayerName.text = ""
	loadServerPlayers()


func addPlayer(name : String, clientID : int):
	var newPlayer := Player.new()
	newPlayer.name = name if name != "" else str(randi())
	newPlayer.ownedClientID = clientID
	
	players.append(newPlayer)
	
	var playerDisplay : PlayerDisplay = preload("res://player_display.tscn").instantiate()
	playerDisplay.main = self
	playerDisplay.player = newPlayer
	$HBoxContainer/Panel2/PlayersList.add_child(playerDisplay)
	$MainMenu/PlayerList.text = getPlayerList()


# start local game
func _on_start_game_pressed():
	startGame()


func _on_start_lan_pressed():
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
	loadServerPlayers()


func lanPlayerDisconnected(peerID : int):
	await get_tree().create_timer(1).timeout
	loadServerPlayers()



func _on_client_pressed():
	var ip = connectIP.text if connectIP.text != "" else DEFAULTIP
	var port = connectPort.text.to_int() if connectPort.text != "" else DEFAULTPORT
	
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(connectSuccess)
	
	$MainMenu/MainMenu/HBoxContainer2/ConnectClient.disabled = true
	$MainMenu/MainMenu/HBoxContainer2/ConnectClient.text = "Connecting..."
	
	await get_tree().create_timer(2).timeout
	if peer.get_connection_status() != MultiplayerPeer.CONNECTION_CONNECTED:
		peer.close()
		multiplayer.multiplayer_peer = null
		print("couldn't connect in 2 secs")
		$MainMenu/MainMenu/HBoxContainer2/ConnectClient.disabled = false
		$MainMenu/MainMenu/HBoxContainer2/ConnectClient.text = "Connect"


func connectSuccess():
	print("Connected to server")
	$MainMenu/MainMenu/HBoxContainer2/ConnectClient.disabled = false
	$MainMenu/MainMenu/HBoxContainer2/ConnectClient.text = "Connect"
	$MainMenu/MainMenu.visible = false
	$MainMenu/LocalSetup.visible = false
	$MainMenu/BoardList.visible = true


func _on_create_new_board_pressed():
	serverCreateNewGame.rpc_id(1, multiplayer.get_unique_id())
	$MainMenu/BoardList.visible = false
	$MainMenu/LocalSetup.visible = true


func _on_join_board_pressed(boardID):
	serverClientJoinGame.rpc_id(1, boardID, multiplayer.get_unique_id())
	$MainMenu/BoardList.visible = false
	$MainMenu/LocalSetup.visible = true


func startGame():
	currentPlayer = players[0]
	board.generateMap()
	loadServerTiles()
	loadServerPlayers()
	
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
	
	updateServerTiles()
	updateServerPlayers()
	startServerGame()


func nextTurn():
	var nextPlayerNum : int = players.find(currentPlayer) + 1
	if nextPlayerNum >= players.size():
		nextPlayerNum = 0
	currentPlayer = players[nextPlayerNum]
	isCurrentClient = currentPlayer.ownedClientID == multiplayer.get_unique_id()
	turnStage = TURNSTAGE.TILE
	
	updateServerPlayers()
	updateServerTiles()



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
		updateServerPlayers()



func _on_push_pressed():
	if isCurrentClient && board.getArrow(board.spareTile.pos) != null && \
			board.getArrow(board.spareTile.pos).visible == true:
		
		board.push()
		setupMovePlayer()


func _on_rotate_pressed():
	board.rotateSpareTile()


func _on_end_move_pressed():
	if turnStage != TURNSTAGE.MOVE:
		return
	
	if currentPlayer.neededItems.size() > 0 && currentPlayer.neededItems[0] == currentPlayer.tile.item:
		currentPlayer.foundItems.append(currentPlayer.neededItems.pop_front())
	
	nextTurn()




func h():
	pass

func loadServerPlayers():
	var playerNames : Array
	var playerOwnedClients : Array
	
	for player in players:
		playerNames.append(player.name)
		playerOwnedClients.append(player.ownedClientID)
	
	serverLoadPlayers.rpc_id(1, boardNum, playerNames, playerOwnedClients)


func loadServerTiles():
	var tileTypes : Array
	var tileItems : Array
	
	for tile in board.tiles:
		tileTypes.append(tile.type)
		tileItems.append(tile.item)
	
	serverLoadTiles.rpc_id(1, boardNum, tileTypes, tileItems)


func startServerGame():
	serverStartGame.rpc_id(1, boardNum)


func updateServerTiles():
	var tilePositions : Array[Vector2]
	var tileRotations : Array[int]
	
	for tile in board.tiles:
		tilePositions.append(tile.pos)
		tileRotations.append(tile.rot)
	
	serverUpdateTiles.rpc_id(1, boardNum, tilePositions, tileRotations, board.tiles.find(board.spareTile), board.disabledArrowPos)


func updateServerPlayers():
	var playerPositions : Array[Vector2]
	var playersNeededItems : Array[Array]
	
	for i in players.size():
		var player := players[i]
		playerPositions.append(player.tile.pos)
		playersNeededItems.append(player.neededItems)
	
	serverUpdatePlayers.rpc_id(1, boardNum, playerPositions, playersNeededItems, players.find(currentPlayer))



@rpc("any_peer", "call_local")
func serverCreateNewGame(peerID : int):
	if !is_multiplayer_authority():
		return
	pass


@rpc("any_peer", "call_local")
func serverClientJoinGame(boardNum : int, peerID : int):
	if !is_multiplayer_authority():
		return
	pass


@rpc("any_peer", "call_local")
func serverLoadTiles(boardNum, tileTypes, tileItems):
	if !is_multiplayer_authority():
		return
	clientLoadTiles.rpc(tileTypes, tileItems)

@rpc("any_peer", "call_local")
func serverLoadPlayers(boardNum, playerNames : Array, playerOwnedClients : Array):
	if !is_multiplayer_authority():
		return
	clientLoadPlayers.rpc(playerNames, playerOwnedClients)

@rpc("any_peer", "call_local")
func serverStartGame(boardNum : int):
	if !is_multiplayer_authority():
		return
	clientStartGame.rpc()

@rpc("any_peer", "call_local")
func serverUpdateTiles(boardNum : int, tilePositions, tileRotations, spareTileID, disabledArrowPos):
	if !is_multiplayer_authority():
		return
	clientUpdateTiles.rpc(tilePositions, tileRotations, spareTileID, disabledArrowPos)

@rpc("any_peer", "call_local")
func serverUpdatePlayers(boardNum : int, playerPositions, playersNeededItems, newCurPlayerNum : int):
	if !is_multiplayer_authority():
		return
	clientUpdatePlayers.rpc(playerPositions, playersNeededItems, newCurPlayerNum)



@rpc
func clientSetBoardID(num : int):
	boardNum = num


@rpc
func clientLoadBoardIDs(boardIDs : Array):
	for boardID in boardIDs:
		var button := JoinBoardButton.new()
		button.id = boardID
		button.pressedWithID.connect(_on_join_board_pressed)
		$MainMenu/BoardList/BoardList.add_child(button)


@rpc("call_local")
func clientLoadTiles(tileTypes, tileItems):
	board.loadTiles(tileTypes, tileItems)


@rpc("call_local")
func clientLoadPlayers(playerNames : Array, playerOwnedClients : Array):
	players.clear()
	for child in $HBoxContainer/Panel2/PlayersList.get_children():
		if child is PlayerDisplay:
			child.queue_free()
	
	for i in playerNames.size():
		addPlayer(playerNames[i], playerOwnedClients[i])


@rpc("call_local")
func clientStartGame():
	get_tree().paused = false
	$MainMenu.visible = false
	$HBoxContainer.visible = true
	$HBoxContainer/Panel/GameActions.visible = true
	$HBoxContainer/Panel/GameActions/EndMove.disabled = true
	board.addPlayerSprites()


@rpc("call_local")
func clientUpdateTiles(tilePositions, tileRotations : Array, spareTileNum : int, disabledArrowPos : Vector2):
	if isCurrentClient:
		return
	
	board.updateTiles(tilePositions, tileRotations, spareTileNum)
	board.disableArrow(disabledArrowPos)

@rpc("call_local")
func clientUpdatePlayers(playerPositions, playersNeededItems, newCurPlayerNum):
	currentPlayer = players[newCurPlayerNum]
	$HBoxContainer/Panel2/PlayersList/CurrPlayerLabel.text = "Current Player: " + currentPlayer.name
	isCurrentClient = currentPlayer.ownedClientID == multiplayer.get_unique_id()
	
	for i in players.size():
		var player := players[i]
		player.tile = board.getTile(playerPositions[i])
		player.neededItems.clear()
		for item in playersNeededItems[i]:
			player.neededItems.append(item)


