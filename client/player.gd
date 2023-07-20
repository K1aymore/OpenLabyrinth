class_name Player

var tile : Tile
var name : String
var color : Tile.COLOR
var colorColor : Color
var homeTile : Tile
var ownedClientID : int
var neededItems : Array[Tile.ITEM]
var foundItems : Array[Tile.ITEM]


func displayColor() -> Color:
	match color:
		Tile.COLOR.BLUE:
			return Color.DODGER_BLUE
		Tile.COLOR.GREEN:
			return Color.FOREST_GREEN
		Tile.COLOR.YELLOW:
			return Color.GOLD
		Tile.COLOR.RED:
			return Color.RED
	
	return Color.BLACK
