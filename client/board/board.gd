extends Node2D

var isCurrentPlayer := false

var tileScene := preload("res://board/tile.tscn")
var tileSpriteScene := preload("res://board/tile_sprite.tscn")
var pushArrowScene := preload("res://board/push_arrow.tscn")

var tiles : Array[Tile]
var arrows : Array[PushArrow]
var spareTile : Tile

var playerPos := Vector2.ZERO

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
			var newTile = addNewTile(randi_range(0, Tile.TYPE.size()-1), randi_range(0, Tile.ITEM.size()-1))
			newTile.pos = Vector2(horzNum, vertNum)
			newTile.rot = randi_range(0, 3) * 90
	
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
	if is_equal_approx(spareTile.pos.x, -1):
		pushLine(snappedi(spareTile.pos.y, 1), ROW, Vector2.RIGHT)
	elif is_equal_approx(spareTile.pos.x, 7):
		pushLine(snappedi(spareTile.pos.y, 1), ROW, Vector2.LEFT)
	elif is_equal_approx(spareTile.pos.y, -1):
		pushLine(snappedi(spareTile.pos.x, 1), COL, Vector2.DOWN)
	elif is_equal_approx(spareTile.pos.y, 7):
		pushLine(snappedi(spareTile.pos.x, 1), COL, Vector2.UP)


func pushLine(lineNum : int, rowCol, dir : Vector2):
	var pushedTiles : Array
	
	pushedTiles = getTileLine(lineNum, rowCol)
	for tile in pushedTiles:
		tile.push(dir)
	
	spareTile.isSpare = false
	for tile in tiles:
		if tile.pos.x > 6 || tile.pos.x < 0 || tile.pos.y > 6 || tile.pos.y < 0:
			spareTile = tile
			continue
	spareTile.isSpare = true
	updateServerTiles()


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
	if isCurrentPlayer:
		moveSpareTile(pos)


func moveSpareTile(pos : Vector2):
	spareTile.pos = pos
	updateServerTiles()


func rotateSpareTile():
	spareTile.rot = snappedi(spareTile.rot + 90, 90)
	updateServerTiles()



func movePlayer(dir : Vector2):
	var currTile = getTile(playerPos)
	var nextTile = getTile(playerPos + dir)
	if currTile != null && nextTile != null && currTile.canMoveThrough(dir) && nextTile.canMoveThrough(-dir):
		playerPos += dir.round()
		$PlayerSprite.position = playerPos * Tile.TILESIZE


func getTile(pos : Vector2) -> Tile:
	for tile in tiles:
		if tile.pos.is_equal_approx(pos):
			return tile
	
	return null
