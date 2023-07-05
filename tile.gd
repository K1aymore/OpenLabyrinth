extends Node2D

class_name Tile

var spritePos : Vector2
var spriteRot : float

const TILESIZE = 64

enum DIR {
	UP,
	DOWN,
	LEFT,
	RIGHT,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	spritePos = global_position
	spriteRot = global_rotation
	$Sprite2D.global_position = global_position



func _process(delta):
	if !global_position.is_equal_approx(spritePos):
		spritePos = spritePos.lerp(global_position, delta * 10)
		$Sprite2D.global_position = spritePos
	if !is_equal_approx(global_rotation, spriteRot):
		spriteRot = lerp_angle(spriteRot, global_rotation, delta * 10)
		$Sprite2D.global_rotation = spriteRot


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

