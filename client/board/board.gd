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


func addNewTile( col : int, row : int) -> Tile:
	var newTile := Tile.new()
	newTile.pos = Vector2(col, row)
	tiles.append(newTile)
	var newTileSprite := tileSpriteScene.instantiate()
	newTileSprite.tile = newTile
	add_child(newTileSprite)
	return newTile


@rpc
func updateTiles(tilePositions : Array, tileRotations : Array, spareTileNum : int):
	
	for i in tiles.size():
		var tile := tiles[i]
		tile.pos = tilePositions[i]
		tile.rot = snappedi(tileRotations[i], 90)
	
	spareTile.isSpare = false
	spareTile = tiles[spareTileNum]
	spareTile.isSpare = true


@rpc("any_peer")
func push():
	pass



@rpc("any_peer")
func rotateSpareTile():
	pass


func arrowPressed(pos):
	if currentPlayer:
		moveSpareTile.rpc(pos)


@rpc("any_peer")
func moveSpareTile(pos : Vector2):
	pass
