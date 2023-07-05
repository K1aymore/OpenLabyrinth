extends Node2D

class_name Tile

var spritePos : Vector2

const TILESIZE = 128

enum DIR {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	spritePos = global_position
	$Sprite2D.global_position = global_position



func _process(delta):
	if !global_position.is_equal_approx(spritePos):
		spritePos = spritePos.lerp(global_position, 0.1)
		$Sprite2D.global_position = spritePos


func push(direction : DIR):
	match direction:
		DIR.UP:
			position.y -= TILESIZE
		DIR.DOWN:
			position.y += TILESIZE
		DIR.LEFT:
			position.x -= TILESIZE
		DIR.RIGHT:
			position.x += TILESIZE

