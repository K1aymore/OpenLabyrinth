extends Sprite2D

class_name PlayerSprite

var player : Player


# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(3, 3) * Tile.TILESIZE
	scale = Vector2(0.3, 0.3)
	z_index = 20

func _process(delta):
	if !position.is_equal_approx(player.tile.pos * Tile.TILESIZE):
		z_index = 1 if player.tile.isSpare else 0
		position = position.lerp(player.tile.pos * Tile.TILESIZE, delta * 10)
	
	global_rotation_degrees = 0
