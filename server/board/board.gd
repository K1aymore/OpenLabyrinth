extends Node2D

var currentPlayer := false

var tileScene := preload("res://board/tile.tscn")
var tileSpriteScene := preload("res://board/tile_sprite.tscn")
var pushArrowScene := preload("res://board/push_arrow.tscn")

var tiles : Array[Tile]
var arrows : Array[PushArrow]
@onready var spareTile : Tile = $startingSpareTile

enum {
	ROW,
	COL,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	$Icon.visible = false
	tiles.append(spareTile)
	spareTile.row = 3
	spareTile.col = -1
	
	for vertNum in range(0, 7):
		for horzNum in range(0, 7):
			var newTile := Tile.new()
			newTile.row = horzNum
			newTile.col = vertNum
			tiles.append(newTile)
			var newTileSprite := tileSpriteScene.instantiate()
			newTileSprite.tile = newTile
			add_child(newTileSprite)
	
	
	for col in [1, 3, 5]:
		var arrow := pushArrowScene.instantiate()
		arrow.position.x = col * Tile.TILESIZE
		arrow.position.y = -Tile.TILESIZE
		arrow.rotation_degrees = 180
		add_child(arrow)
		arrows.append(arrow)
	
	for col in [1, 3, 5]:
		var arrow := pushArrowScene.instantiate()
		arrow.position.x = col * Tile.TILESIZE
		arrow.position.y = Tile.TILESIZE * 7
		add_child(arrow)
		arrows.append(arrow)
	
	for row in [1, 3, 5]:
		var arrow := pushArrowScene.instantiate()
		arrow.position.y = row * Tile.TILESIZE
		arrow.position.x = -Tile.TILESIZE
		arrow.rotation_degrees = 90
		add_child(arrow)
		arrows.append(arrow)
		
	for row in [1, 3, 5]:
		var arrow := pushArrowScene.instantiate()
		arrow.position.y = row * Tile.TILESIZE
		arrow.position.x = Tile.TILESIZE * 7
		arrow.rotation_degrees = 270
		add_child(arrow)
		arrows.append(arrow)


func loadRemoteTiles():
	loadTiles.rpc(tiles.duplicate(true), spareTile.duplicate())

@rpc
func loadTiles(newTiles : Array[Tile], newSpareTile : Tile):
	pass


func updateRemoteTiles():
	updateTiles.rpc(tiles, spareTile)

@rpc
func updateTiles(newTiles : Array[Tile], newStartingTile : Tile):
	pass



@rpc("any_peer")
func push():
	var canPush := false
	for arrow in arrows:
		if arrow.position.is_equal_approx(spareTile.position) && arrow.visible:
			canPush = true
	
	if !canPush:
		return
	
	if is_equal_approx(spareTile.position.x, -Tile.TILESIZE):
		pushLine.rpc(snappedi(spareTile.position.y, 1) / Tile.TILESIZE, ROW, Vector2.RIGHT)
	elif is_equal_approx(spareTile.position.x, Tile.TILESIZE * 7):
		pushLine.rpc(snappedi(spareTile.position.y, 1) / Tile.TILESIZE, ROW, Vector2.LEFT)
	elif is_equal_approx(spareTile.position.y, -Tile.TILESIZE):
		pushLine.rpc(snappedi(spareTile.position.x, 1) / Tile.TILESIZE, COL, Vector2.DOWN)
	elif is_equal_approx(spareTile.position.y, Tile.TILESIZE * 7):
		pushLine.rpc(snappedi(spareTile.position.x, 1) / Tile.TILESIZE, COL, Vector2.UP)


func pushLine(lineNum : int, rowCol, dir : Vector2):
	var pushedTiles : Array
	
	pushedTiles = getTileLine(lineNum, rowCol)
	for tile in pushedTiles:
		tile.push(dir)
	
	spareTile.z_index = 0
	
	for tile in tiles:
		if tile.position.x > Tile.TILESIZE * 6 || tile.position.x < 0 \
			|| tile.position.y > Tile.TILESIZE * 6 || tile.position.y < 0:
			
			spareTile = tile
			continue
	spareTile.z_index = 1
	
	for arrow in arrows:
		arrow.visible = !arrow.position.is_equal_approx(spareTile.position)



func getTileLine(lineNum : int, rowCol) -> Array:
	var lineTiles : Array
	
	for tile in tiles:
		var check : int
		match rowCol:
			ROW:
				check = tile.row
			COL:
				check = tile.col
		
		if snappedi(check, 1) == lineNum * Tile.TILESIZE:
			lineTiles.append(tile)
	
	return lineTiles


@rpc("any_peer")
func rotateSpareTile():
	spareTile.rotation_degrees = snappedi(spareTile.rotation_degrees + 90, 90)
	updateRemoteTiles()



@rpc("any_peer")
func moveSpareTile(pos : Vector2):
	spareTile.position = pos
	updateRemoteTiles()
