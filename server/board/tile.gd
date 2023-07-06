extends Node

class_name Tile

const TILESIZE = 64


var type := TYPE.STRAIGHT
var color := COLOR.NONE


var row : int
var col : int
var rotation

enum TYPE {
	STRAIGHT,
	TSHAPE,
	CORNER,
}

enum ITEMS {
	BAT,
	BOMB,
	BOOK,
	BUG,
	CANDLES,
	CANNON,
	CAT,
	COINS,
	CROWN,
	DAGGER,
	DIAMOND,
	DINOSAUR,
	GHOST,
	GRAIL,
	HELMET,
	KEYS,
	LIZARD,
	MERMAID,
	MOUSE,
	OWL,
	PONY,
	POTION,
	RING,
	TREASURE,
}

enum COLOR {
	NONE,
	BLUE,
	RED,
	YELLOW,
	GREEN,
}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass



func push(dir : Vector2):
	row += snappedi(dir.x, 1)
	col += snappedi(dir.y, 1)


func canMoveThrough(dir : Vector2) -> bool:
	dir = dir.rotated(rotation)
	
	match type:
		TYPE.STRAIGHT:
			return moveNorth(dir) || moveSouth(dir)
		TYPE.T:
			return moveNorth(dir) || moveEast(dir) || moveSouth(dir)
		TYPE.CORNER:
			return moveNorth(dir) || moveEast(dir)
		_:
			return false



func moveNorth(dir : Vector2):
	return dir.snapped(Vector2.ONE).is_equal_approx(Vector2(0, -1))
func moveSouth(dir : Vector2):
	return dir.snapped(Vector2.ONE).is_equal_approx(Vector2(0, 1))
func moveEast(dir : Vector2):
	return dir.snapped(Vector2.ONE).is_equal_approx(Vector2(1, 0))
func moveWest(dir : Vector2):
	return dir.snapped(Vector2.ONE).is_equal_approx(Vector2(-1, 0))
