extends Node2D

var currentPlayer := false

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
func loadTiles(tileTypes : Array, tileItems : Array):
	if tiles.size() >= tileTypes.size():
		return
	
	for i in tileTypes:
		addNewTile(tileTypes[i], tileItems[i])


@rpc
func updateTiles(tilePositions : Array, tileRotations : Array, spareTileNum : int):
	for i in tiles.size():
		var tile := tiles[i]
		tile.pos = tilePositions[i]
		tile.rot = snappedi(tileRotations[i], 90)
	
	if spareTile != null:
		spareTile.isSpare = false
	spareTile = tiles[spareTileNum]
	spareTile.isSpare = true




@rpc("any_peer")
func rotateSpareTile():
	pass


func arrowPressed(pos):
	if currentPlayer:
		moveSpareTile.rpc_id(1, pos)


@rpc("any_peer")
func moveSpareTile(pos : Vector2):
	pass


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
