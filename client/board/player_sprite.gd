extends Sprite2D

class_name PlayerSprite

var player : Player
var main : Main

# Called when the node enters the scene tree for the first time.
func _ready():
	position = Vector2(3, 3) * Tile.TILESIZE
	scale = Vector2(0.1, 0.1)
	
	self_modulate = player.displayColor()
	self_modulate.a = 1.0


func _process(delta):
	if player == null || player.tile == null || main == null:
		return
	
	var posOffset : Vector2
	var playersOnTile : Array[Player]
	
	for somePlayer in main.players:
		if somePlayer.tile == player.tile:
			playersOnTile.append(somePlayer)
	
	var alpha = 0.9 if playersOnTile.size() > 1 else 1.0
	self_modulate.a = lerpf(self_modulate.a, alpha, delta * 10)
	
	match playersOnTile.size():
		1:
			posOffset = Vector2.ZERO
		2:
			match playersOnTile.find(player):
				0:
					posOffset = Vector2(1, -1)
				1:
					posOffset = Vector2(-1, 1)
				_:
					posOffset = Vector2(10, 10)
		3:
			match playersOnTile.find(player):
				0:
					posOffset = Vector2(0, -1)
				1:
					posOffset = Vector2(-1, 1)
				2:
					posOffset = Vector2(1, 1)
				_:
					posOffset = Vector2(10, 10)
		4:
			match playersOnTile.find(player):
				0:
					posOffset = Vector2(-1, -1)
				1:
					posOffset = Vector2(1, -1)
				2:
					posOffset = Vector2(-1, 1)
				3:
					posOffset = Vector2(1, 1)
				_:
					posOffset = Vector2(10, 10)
	
	
	posOffset = posOffset * 0.15
	
	position = position.lerp((player.tile.pos + posOffset) * Tile.TILESIZE, delta * 10)
	
	global_rotation_degrees = 0
