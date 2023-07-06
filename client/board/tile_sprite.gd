extends Sprite2D

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
	if !position.is_equal_approx(tile.pos * Tile.TILESIZE):
		position = position.lerp(tile.pos * Tile.TILESIZE, delta * 10)
		
	if !is_equal_approx(rotation_degrees, tile.rot):
		rotation = lerp_angle(rotation, deg_to_rad(tile.rot), delta * 10)
