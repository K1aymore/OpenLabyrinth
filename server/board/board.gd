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
	generateMap()


func generateMap():
	for vertNum in range(0, 7):
		for horzNum in range(0, 7):
			var newTile = addNewTile(randi_range(0, Tile.TYPE.size()-1), randi_range(0, Tile.ITEM.size()-1))
			newTile.pos = Vector2(horzNum, vertNum)
			newTile.rot = randi_range(0, 3) * 90
	
	spareTile = addNewTile(Tile.TYPE.STRAIGHT, 0)
	spareTile.pos = Vector2(3, -1)
	spareTile.isSpare = true
	remoteLoadTiles()

func addNewTile(type : Tile.TYPE, item : Tile.ITEM) -> Tile:
	var newTile := Tile.new()
	newTile.type = type
	newTile.item = item
	tiles.append(newTile)
	var newTileSprite := tileSpriteScene.instantiate()
	newTileSprite.tile = newTile
	add_child(newTileSprite)
	return newTile


func remoteLoadTiles():
	var tileTypes : Array
	var tileItems : Array
	
	for tile in tiles:
		tileTypes.append(tile.type)
		tileItems.append(tile.item)
	
	clientLoadTiles.rpc(tileTypes, tileItems)
	updateRemoteTiles()

@rpc
func clientLoadTiles(tileTypes : Array, tileItems : Array):
	pass


func updateRemoteTiles():
	var tilePositions : Array
	var tileRotations : Array
	
	for tile in tiles:
		tilePositions.append(tile.pos)
		tileRotations.append(tile.rot)
	
	clientUpdateTiles.rpc(tilePositions, tileRotations, tiles.find(spareTile))

@rpc
func clientUpdateTiles(tilePositions : Array, tileRotations : Array, spareTileNum : int):
	pass



@rpc("any_peer")
func serverUpdateTiles(tilePositions : Array, tileRotations : Array, spareTileNum : int):
	for i in tiles.size():
		var tile := tiles[i]
		tile.pos = tilePositions[i]
		tile.rot = snappedi(tileRotations[i], 90)
	
	if spareTile != null:
		spareTile.isSpare = false
	spareTile = tiles[spareTileNum]
	spareTile.isSpare = true
