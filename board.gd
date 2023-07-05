extends Node2D

var tileScene := preload("res://tile.tscn")
var pushArrowScene := preload("res://push_arrow.tscn")

var tiles : Array
var arrows : Array
@onready var spareTile : Tile = $startingSpareTile

enum {
	ROW,
	COL,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	$Icon.visible = false
	tiles.append(spareTile)
	spareTile.position = Vector2(3 * Tile.TILESIZE, -Tile.TILESIZE)
	spareTile.z_index = 1
	
	for vertNum in range(0, 7):
		for horzNum in range(0, 7):
			var newTile := tileScene.instantiate()
			newTile.position = Vector2(vertNum * Tile.TILESIZE, horzNum * Tile.TILESIZE)
			add_child(newTile)
			tiles.append(newTile)
	
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


func _on_button_pressed():
	var canPush := false
	for arrow in arrows:
		if arrow.position.is_equal_approx(spareTile.position) && arrow.visible:
			canPush = true
	
	if !canPush:
		return
	
	if is_equal_approx(spareTile.position.x, -Tile.TILESIZE):
		pushLine.rpc(snappedi(spareTile.position.y, 1) / Tile.TILESIZE, ROW, Tile.DIR.RIGHT)
	elif is_equal_approx(spareTile.position.x, Tile.TILESIZE * 7):
		pushLine.rpc(snappedi(spareTile.position.y, 1) / Tile.TILESIZE, ROW, Tile.DIR.LEFT)
	elif is_equal_approx(spareTile.position.y, -Tile.TILESIZE):
		pushLine.rpc(snappedi(spareTile.position.x, 1) / Tile.TILESIZE, COL, Tile.DIR.DOWN)
	elif is_equal_approx(spareTile.position.y, Tile.TILESIZE * 7):
		pushLine.rpc(snappedi(spareTile.position.x, 1) / Tile.TILESIZE, COL, Tile.DIR.UP)


@rpc("any_peer", "call_local")
func pushLine(lineNum : int, rowCol, dir : Tile.DIR):	
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
				check = tile.position.y
			COL:
				check = tile.position.x
		
		if snappedi(check, 1) == lineNum * Tile.TILESIZE:
			lineTiles.append(tile)
	
	return lineTiles


