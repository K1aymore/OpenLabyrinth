extends Sprite2D

class_name TileSprite

var tile : Tile

var cornerSprite := preload("res://assets/basic/corner.svg")
var straightSprite := preload("res://assets/basic/straight.svg")
var tshapeSprite := preload("res://assets/basic/t-shape.svg")

# Called when the node enters the scene tree for the first time.
func _ready():
	scale = Vector2.ONE * 0.2
	
	match tile.type:
		Tile.TYPE.CORNER:
			texture = cornerSprite
		Tile.TYPE.STRAIGHT:
			texture = straightSprite
		Tile.TYPE.TSHAPE:
			texture = tshapeSprite


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var tilePos = Vector2(tile.row, tile.col)
	if !position.is_equal_approx(tilePos):
		position = position.lerp(tilePos * Tile.TILESIZE, delta * 10)
		
	if !is_equal_approx(rotation, tile.rotation):
		rotation = lerp_angle(rotation, tile.rotation, delta * 10)