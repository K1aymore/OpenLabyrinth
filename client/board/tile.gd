class_name Tile

const TILESIZE = 60


var type := TYPE.STRAIGHT
var color := COLOR.NONE

var isSpare := false

var pos : Vector2
var rot : int

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
