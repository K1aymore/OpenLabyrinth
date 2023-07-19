extends Control

class_name Main


@onready var board : Board = $Game/HBoxContainer/SubViewportContainer/SubViewport/Board
@onready var network : Network = $Network
@onready var mainMenu : MainMenu = $MainMenu

const MAX_PLAYERS = 4

var players : Array[Player]
var currentPlayer : Player
var isCurrentClient := false

var turnStage := TURNSTAGE.TILE

enum TURNSTAGE {
	TILE,
	MOVE,
}


func _ready():
	randomize()
	get_tree().paused = true
	


func _process(delta):
	if !isCurrentClient:
		for button in $Game/HBoxContainer/Panel/GameActions.get_children():
			if button is Button:
				button.disabled = true
		return
	
	
	$Game/HBoxContainer/Panel/GameActions/Push.disabled = turnStage == TURNSTAGE.MOVE
	$Game/HBoxContainer/Panel/GameActions/Rotate.disabled = turnStage == TURNSTAGE.MOVE
	$Game/HBoxContainer/Panel/GameActions/EndMove.disabled = turnStage == TURNSTAGE.TILE
	
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



func addPlayer(name : String, clientID : int):
	var newPlayer := Player.new()
	newPlayer.name = name if name != "" else str(randi())
	newPlayer.ownedClientID = clientID
	
	players.append(newPlayer)
	
	var playerDisplay : PlayerDisplay = preload("res://player_display.tscn").instantiate()
	playerDisplay.main = self
	playerDisplay.player = newPlayer
	$Game/HBoxContainer/Panel2/PlayersList.add_child(playerDisplay)
	$MainMenu/GameSetup/PlayerList.text = getPlayerList()


func startGame():
	currentPlayer = players[0]
	board.generateMap()
	network.sendServerTiles()
	network.sendServerPlayers()
	
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


func switchToGame():
	get_tree().paused = false
	$MainMenu.visible = false
	$Game.visible = true
	$Game/HBoxContainer/Panel/GameActions.visible = true
	$Game/HBoxContainer/Panel/GameActions/EndMove.disabled = true
	board.addPlayerSprites()


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
	for button in $Game/HBoxContainer/Panel/GameActions.get_children():
		if button is Button:
			button.disabled = true
	$Game/HBoxContainer/Panel/GameActions/EndMove.disabled = false


func movePlayer(dir : Vector2):
	var currTile = currentPlayer.tile
	var nextTile = board.getTile(currentPlayer.tile.pos + dir)
	if currTile != null && nextTile != null && currTile.canMoveThrough(dir) && nextTile.canMoveThrough(-dir):
		currentPlayer.tile = nextTile
		updateServerPlayers()


func setCurrentPlayer(newCurPlayerNum : int):
	currentPlayer = players[newCurPlayerNum]
	$Game/HBoxContainer/Panel2/PlayersList/CurrPlayerLabel.text = "Current Player: " + currentPlayer.name
	isCurrentClient = currentPlayer.ownedClientID == multiplayer.get_unique_id()



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


func startServerGame():
	network.callPeers(switchToGame, [])


func updateServerTiles():
	var tilePositions : Array[Vector2]
	var tileRotations : Array[int]
	
	for tile in board.tiles:
		tilePositions.append(tile.pos)
		tileRotations.append(tile.rot)
	
	network.callPeers(updateTiles, [tilePositions, tileRotations, board.tiles.find(board.spareTile), board.disabledArrowPos])


func updateServerPlayers():
	var playerPositions : Array[Vector2]
	var playersNeededItems : Array[Array]
	
	for i in players.size():
		var player := players[i]
		playerPositions.append(player.tile.pos)
		playersNeededItems.append(player.neededItems)
	
	network.callPeers(updatePlayers, [playerPositions, playersNeededItems, players.find(currentPlayer)])



func setBoardName(str : String):
	network.boardName = str


func loadTiles(tileTypes, tileItems):
	board.loadTiles(tileTypes, tileItems)


func loadPlayers(playerNames : Array, playerOwnedClients : Array):
	players.clear()
	for child in $Game/HBoxContainer/Panel2/PlayersList.get_children():
		if child is PlayerDisplay:
			child.queue_free()
	
	for i in playerNames.size():
		addPlayer(playerNames[i], playerOwnedClients[i])



func updateTiles(tilePositions, tileRotations, spareTileNum, disabledArrowPos):
	board.updateTiles(tilePositions, tileRotations, spareTileNum)
	board.disableArrow(disabledArrowPos)
	


func updatePlayers(playerPositions, playersNeededItems, newCurPlayerNum):
	setCurrentPlayer(newCurPlayerNum)
	
	for i in players.size():
		var player := players[i]
		player.tile = board.getTile(playerPositions[i])
		player.neededItems.clear()
		for item in playersNeededItems[i]:
			player.neededItems.append(item)

