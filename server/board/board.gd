extends Node2D

var currentPlayer := false

var tileScene := preload("res://board/tile.tscn")
var tileSpriteScene := preload("res://board/tile_sprite.tscn")
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
	
	for vertNum in range(0, 7):
		for horzNum in range(0, 7):
			addNewTile(horzNum, vertNum)
	
	spareTile = addNewTile(3, -1)
	spareTile.isSpare = true



func addNewTile( col : int, row : int) -> Tile:
	var newTile := Tile.new()
	newTile.pos = Vector2(col, row)
	tiles.append(newTile)
	var newTileSprite := tileSpriteScene.instantiate()
	newTileSprite.tile = newTile
	add_child(newTileSprite)
	return newTile


func updateRemoteTiles():
	var tilePositions : Array
	var tileRotations : Array
	
	for i in tiles.size():
		tilePositions.append(tiles[i].pos)
		tileRotations.append(tiles[i].rot)
	
	updateTiles.rpc(tilePositions, tileRotations, tiles.find(spareTile))

@rpc
func updateTiles(tilePositions : Array, tileRotations : Array, spareTileNum : int):
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
	updateRemoteTiles()



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


@rpc("any_peer")
func rotateSpareTile():
	spareTile.rot = snappedi(spareTile.rot + 90, 90)
	updateRemoteTiles()



@rpc("any_peer")
func moveSpareTile(pos : Vector2):
	spareTile.pos = pos
	updateRemoteTiles()
