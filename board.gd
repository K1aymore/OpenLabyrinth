extends Node2D

var tileScene := preload("res://tile.tscn")

var tiles : Array


# Called when the node enters the scene tree for the first time.
func _ready():
	$Icon.visible = false
	for vertNum in range(0, 7):
		for horzNum in range(0, 7):
			var newTile := tileScene.instantiate()
			newTile.position = Vector2(vertNum * Tile.TILESIZE, horzNum * Tile.TILESIZE)
			add_child(newTile)
			tiles.append(newTile)



func _on_button_pressed():
	var pushedTiles := getRow(3)
	
	for tile in pushedTiles:
		tile.push(Tile.DIR.DOWN)



func getRow(rowNum : int) -> Array:
	var rowTiles : Array
	
	for tile in tiles:
		if snappedi(tile.position.x, 1) == rowNum * Tile.TILESIZE:
			rowTiles.append(tile)
	
	return rowTiles
