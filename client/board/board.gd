extends Node2D

class_name Board

@export var main : Main
@export var network : Network

var tileScene := preload("res://board/tile.tscn")
var tileSpriteScene := preload("res://board/tile_sprite.tscn")
var playerSpriteScene := preload("res://board/player_sprite.tscn")
var pushArrowScene := preload("res://board/push_arrow.tscn")

var tiles : Array[Tile]
var arrows : Array[PushArrow]
var spareTile : Tile
var disabledArrowPos : Vector2


enum {
	ROW,
	COL,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	$Icon.visible = false
	
	for col in [1, 3, 5]:
		var arrow := pushArrowScene.instantiate()
		arrow.pos = Vector2(col, -1)
		arrow.rotation_degrees = 180
		add_child(arrow)
		arrows.append(arrow)
	
	for col in [1, 3, 5]:
		var arrow := pushArrowScene.instantiate()
		arrow.pos = Vector2(col, 7)
		add_child(arrow)
		arrows.append(arrow)
	
	for row in [1, 3, 5]:
		var arrow := pushArrowScene.instantiate()
		arrow.pos = Vector2(-1, row)
		arrow.rotation_degrees = 90
		add_child(arrow)
		arrows.append(arrow)
		
	for row in [1, 3, 5]:
		var arrow := pushArrowScene.instantiate()
		arrow.pos = Vector2(7, row)
		arrow.rotation_degrees = 270
		add_child(arrow)
		arrows.append(arrow)
	
	for arrow in arrows:
		arrow.arrowPressed.connect(arrowPressed)


func generateMap():
	var itemList : Array[Tile.ITEM]
	for item in Tile.ITEM.values():
		itemList.append(item)
	
	itemList.erase(Tile.ITEM.NONE)
	itemList.shuffle()
	
	var newTile : Tile
	
	newTile = addNewTile(Tile.TYPE.CORNER, Tile.ITEM.NONE)
	newTile.pos = Vector2(0, 0)
	newTile.rot = 90
	newTile.color = Tile.COLOR.BLUE
	
	newTile = addNewTile(Tile.TYPE.CORNER, Tile.ITEM.NONE)
	newTile.pos = Vector2(6, 0)
	newTile.rot = 180
	newTile.color = Tile.COLOR.GREEN
	
	newTile = addNewTile(Tile.TYPE.CORNER, Tile.ITEM.NONE)
	newTile.pos = Vector2(0, 6)
	newTile.rot = 0
	newTile.color = Tile.COLOR.YELLOW
	
	newTile = addNewTile(Tile.TYPE.CORNER, Tile.ITEM.NONE)
	newTile.pos = Vector2(6, 6)
	newTile.rot = 270
	newTile.color = Tile.COLOR.RED
	
	
	for vertNum in [0, 2, 4, 6]:
		for horzNum in [0, 2, 4, 6]:
			match Vector2(horzNum, vertNum):
				Vector2(0, 2):
					newTile = addSolidTile(itemList)
				Vector2(0, 4):
					newTile = addSolidTile(itemList)
				Vector2(2, 0):
					newTile = addSolidTile(itemList)
					newTile.rot = 90
				Vector2(4, 0):
					newTile = addSolidTile(itemList)
					newTile.rot = 90
				Vector2(2, 6):
					newTile = addSolidTile(itemList)
					newTile.rot = 270
				Vector2(4, 6):
					newTile = addSolidTile(itemList)
					newTile.rot = 270
				Vector2(6, 2):
					newTile = addSolidTile(itemList)
					newTile.rot = 180
				Vector2(6, 4):
					newTile = addSolidTile(itemList)
					newTile.rot = 180
				
				Vector2(2, 2):
					newTile = addSolidTile(itemList)
				Vector2(4, 2):
					newTile = addSolidTile(itemList)
					newTile.rot = 90
				Vector2(4, 4):
					newTile = addSolidTile(itemList)
					newTile.rot = 180
				Vector2(2, 4):
					newTile = addSolidTile(itemList)
					newTile.rot = 270
				_:
					continue
			
			newTile.pos = Vector2(horzNum, vertNum)
	
	
	for vertNum in range(0, 7):
		for horzNum in range(0, 7):
			if getTile(Vector2(horzNum, vertNum)) != null:
				continue
			
			newTile = addNewTile(null, Tile.ITEM.NONE)
			newTile.rot = randi_range(0, 3) * 90
			newTile.pos = Vector2(horzNum, vertNum)
	
	
	while itemList.size() > 0:
		var tile : Tile = tiles.pick_random()
		
		while !(tile.item == Tile.ITEM.NONE && tile.color == Tile.COLOR.NONE):
			tile = tiles.pick_random()
		
		tile.item = itemList.pop_back()
	
	spareTile = addNewTile(Tile.TYPE.STRAIGHT, 0)
	spareTile.pos = Vector2(3, -1)
	spareTile.isSpare = true
	



func addSolidTile(itemList : Array[Tile.ITEM]) -> Tile:
	return addNewTile(Tile.TYPE.TSHAPE, itemList.pop_back())


func addNewTile(type, item) -> Tile:
	if item == null || !(item is Tile.ITEM):
		item = Tile.ITEM.NONE
	
	if type == null || !(type is Tile.TYPE):
		var rand = randi_range(0, 99)
		if rand < 40:
			type = Tile.TYPE.CORNER
		elif rand < 80:
			type = Tile.TYPE.STRAIGHT
		else:
			type = Tile.TYPE.TSHAPE
	
	var newTile := Tile.new()
	newTile.type = type
	newTile.item = item
	tiles.append(newTile)
	return newTile


func addTileSprites():
	for tile in tiles:
		var newTileSprite := tileSpriteScene.instantiate()
		newTileSprite.tile = tile
		add_child(newTileSprite)


func addPlayerSprites():
	for player in main.players:
		var newSprite : PlayerSprite = playerSpriteScene.instantiate()
		newSprite.player = player
		add_child(newSprite)


func loadTiles(tileTypes : Array, tileItems : Array, tileColors : Array):
	tiles.clear()
	for child in get_children():
		if child is TileSprite:
			child.queue_free()
	
	for i in tileTypes.size():
		var newTile = addNewTile(tileTypes[i], tileItems[i])
		newTile.color = tileColors[i]
	
	addTileSprites()


func updateTiles(tilePositions : Array, tileRotations : Array, spareTileNum : int):
	for i in tiles.size():
		var tile := tiles[i]
		tile.pos = tilePositions[i]
		tile.rot = snappedi(tileRotations[i], 90)
	
	if spareTile != null:
		spareTile.isSpare = false
	spareTile = tiles[spareTileNum]
	spareTile.isSpare = true



func push():
	var pushedTiles : Array
	var dir : Vector2
	
	if is_equal_approx(spareTile.pos.x, -1):
		pushedTiles = getTileLine(spareTile.pos.y, ROW)
		dir = Vector2.RIGHT
	elif is_equal_approx(spareTile.pos.x, 7):
		pushedTiles = getTileLine(spareTile.pos.y, ROW)
		dir = Vector2.LEFT
	elif is_equal_approx(spareTile.pos.y, -1):
		pushedTiles = getTileLine(spareTile.pos.x, COL)
		dir = Vector2.DOWN
	elif is_equal_approx(spareTile.pos.y, 7):
		pushedTiles = getTileLine(spareTile.pos.x, COL)
		dir = Vector2.UP
	
	for tile in pushedTiles:
		tile.push(dir)
	
	spareTile.isSpare = false
	for tile in tiles:
		if tile.pos.x > 6 || tile.pos.x < 0 || tile.pos.y > 6 || tile.pos.y < 0:
			spareTile = tile
			continue
	spareTile.isSpare = true
	
	disableArrow(spareTile.pos)
	
	checkPlayersOffBoard()
	main.updateServerTiles()
	main.updateServerPlayers()


func getTileLine(lineNum : int, rowCol) -> Array:
	var lineTiles : Array
	for tile in tiles:
		var check : int
		match rowCol:
			ROW:
				check = snappedi(tile.pos.y, 1)
			COL:
				check = snappedi(tile.pos.x, 1)
		
		if check == lineNum:
			lineTiles.append(tile)
	
	return lineTiles


func checkPlayersOffBoard():
	for player in main.players:
		if player.tile.isSpare:
			var newTilePos := player.tile.pos
			if player.tile.pos.x > 6:
				newTilePos.x = 0
			elif player.tile.pos.x < 0:
				newTilePos.x = 6
			elif player.tile.pos.y > 6:
				newTilePos.y = 0
			else:
				newTilePos.y = 6
			player.tile = getTile(newTilePos)



func arrowPressed(pos):
	if main.isCurrentClient && main.turnStage == Main.TURNSTAGE.TILE:
		moveSpareTile(pos)


func disableArrow(pos : Vector2):
	for arrow in arrows:
		arrow.visible = true
	
	var arrow = getArrow(pos)
	if arrow == null:
		return
	
	arrow.visible = false
	disabledArrowPos = pos


func moveSpareTile(pos : Vector2):
	if getArrow(pos) != null || pos == Vector2(-1,-1) || pos == Vector2(7,-1) || \
			pos == Vector2(-1,7) || pos == Vector2(7, 7):
		
		spareTile.pos = pos
		network.callClients(main.updateSpareTile, [spareTile.pos, spareTile.rot])



func rotateSpareTile():
	spareTile.rot = snappedi(spareTile.rot + 90, 90)
	network.callClients(main.updateSpareTile, [spareTile.pos, spareTile.rot])



func getTile(pos : Vector2) -> Tile:
	for tile in tiles:
		if tile.pos.round().is_equal_approx(pos.round()):
			return tile
	
	return null


func getArrow(pos : Vector2) -> PushArrow:
	for arrow in arrows:
		if arrow.pos.round().is_equal_approx(pos.round()):
			return arrow
	
	return null
