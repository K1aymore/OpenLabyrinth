extends Node2D

var currentPlayer := false

var tileScene := preload("res://board/tile.tscn")
var pushArrowScene := preload("res://board/push_arrow.tscn")

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
	spareTile.spritePos = spareTile.global_position
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
	
	for arrow in arrows:
		arrow.arrowPressed.connect(arrowPressed)

@rpc("any_peer")
func push():
	if currentPlayer:
		push.rpc_id(1)



func rotateSpareTile():
	rotateTile.rpc()


@rpc("any_peer", "call_local")
func rotateTile():
	spareTile.rotation_degrees = snappedi(spareTile.rotation_degrees + 90, 90)


func arrowPressed(pos):
	if currentPlayer:
		moveSpareTile.rpc(pos)


@rpc("any_peer", "call_local")
func moveSpareTile(pos : Vector2):
	spareTile.position = pos
