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
	
	for arrow in arrows:
		arrow.arrowPressed.connect(arrowPressed)

@rpc
func loadTiles(newTiles : Array[Tile], newSpareTile):
	tiles = newTiles.duplicate(true)
	
	for tile in tiles:
		var newTileSprite := tileSpriteScene.instantiate()
		newTileSprite.tile = tile
		add_child(newTileSprite)
	
	spareTile = newSpareTile


@rpc
func updateTiles(newTiles : Array[Tile]):
	if tiles.size() < newTiles.size():
		tiles = newTiles
	
	for i in tiles.size():
		tiles[i].position = newTiles[i].position
		tiles[i].rotation = newTiles[i].rotation


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
