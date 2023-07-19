extends Sprite2D

class_name PlayerSprite

var player : Player


# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(3, 3) * Tile.TILESIZE
	scale = Vector2(0.1, 0.1)
	
	self_modulate = player.colorColor


func _process(delta):
	if player == null || player.tile == null:
		return
	
	if !position.is_equal_approx(player.tile.pos * Tile.TILESIZE):
		position = position.lerp(player.tile.pos * Tile.TILESIZE, delta * 10)
	
	global_rotation_degrees = 0
