extends Node2D

class_name Board

var main : Main
var isCurrentPlayer := false

var tileScene := preload("res://board/tile.tscn")
var tileSpriteScene := preload("res://board/tile_sprite.tscn")
var playerSpriteScene := preload("res://board/player_sprite.tscn")
var pushArrowScene := preload("res://board/push_arrow.tscn")

var tiles : Array[Tile]
var arrows : Array[PushArrow]
var spareTile : Tile


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
	for vertNum in range(0, 7):
		for horzNum in range(0, 7):
			var newTile : Tile
			match Vector2(horzNum, vertNum):
				Vector2(0, 0):
					newTile = addNewTile(Tile.TYPE.CORNER, Tile.ITEM.NONE)
					newTile.color = Tile.COLOR.BLUE
					newTile.rot = 90
				Vector2(6, 0):
					newTile = addNewTile(Tile.TYPE.CORNER, Tile.ITEM.NONE)
					newTile.color = Tile.COLOR.YELLOW
					newTile.rot = 180
				Vector2(0, 6):
					newTile = addNewTile(Tile.TYPE.CORNER, Tile.ITEM.NONE)
					newTile.color = Tile.COLOR.GREEN
					newTile.rot = 0
				Vector2(6, 6):
					newTile = addNewTile(Tile.TYPE.CORNER, Tile.ITEM.NONE)
					newTile.color = Tile.COLOR.RED
					newTile.rot = 270
				_:
					newTile = addNewTile(randi_range(0, Tile.TYPE.size()-1), randi_range(0, Tile.ITEM.size()-1))
					newTile.rot = randi_range(0, 3) * 90
			
			newTile.pos = Vector2(horzNum, vertNum)
	
	spareTile = addNewTile(Tile.TYPE.STRAIGHT, 0)
	spareTile.pos = Vector2(3, -1)
	spareTile.isSpare = true


func addNewTile(type : Tile.TYPE, item : Tile.ITEM) -> Tile:
	var newTile := Tile.new()
	newTile.type = type
	newTile.item = item
	tiles.append(newTile)
	var newTileSprite := tileSpriteScene.instantiate()
	newTileSprite.tile = newTile
	add_child(newTileSprite)
	return newTile


func addPlayerSprites(players : Array[Player]):
	for player in players:
		var newSprite : PlayerSprite = playerSpriteScene.instantiate()
		newSprite.player = player
		add_child(newSprite)


@rpc
func clientLoadTiles(tileTypes : Array, tileItems : Array):
	if tiles.size() >= tileTypes.size():
		return
	
	for i in tileTypes:
		addNewTile(tileTypes[i], tileItems[i])


@rpc
func clientUpdateTiles(tilePositions : Array, tileRotations : Array, spareTileNum : int):
	for i in tiles.size():
		var tile := tiles[i]
		tile.pos = tilePositions[i]
		tile.rot = snappedi(tileRotations[i], 90)
	
	if spareTile != null:
		spareTile.isSpare = false
	spareTile = tiles[spareTileNum]
	spareTile.isSpare = true




func updateServerTiles():
	if is_multiplayer_authority():
		return
	
	var tilePositions : Array
	var tileRotations : Array
	
	for tile in tiles:
		tilePositions.append(tile.pos)
		tileRotations.append(tile.rot)
	
	serverUpdateTiles.rpc_id(1, tilePositions, tileRotations, tiles.find(spareTile))

@rpc
func serverUpdateTiles(tilePositions, tileRotations, spareTileID):
	pass




func push():
	pushLine()
	
	spareTile.isSpare = false
	for tile in tiles:
		if tile.pos.x > 6 || tile.pos.x < 0 || tile.pos.y > 6 || tile.pos.y < 0:
			spareTile = tile
			continue
	spareTile.isSpare = true
	updateServerTiles()


func pushLine():
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




func arrowPressed(pos):
	if isCurrentPlayer && main.turnStage == Main.TURNSTAGE.TILE:
		spareTile.pos = pos
		updateServerTiles()



func rotateSpareTile():
	spareTile.rot = snappedi(spareTile.rot + 90, 90)
	updateServerTiles()



func getTile(pos : Vector2) -> Tile:
	for tile in tiles:
		if tile.pos.round().is_equal_approx(pos.round()):
			return tile
	
	return null
