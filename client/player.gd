class_name Player

var tile : Tile
var name : String
var color : Tile.COLOR
var homeTile : Tile
var ownedClientID : int
var neededItems : Array[Tile.ITEM]
var foundItems : Array[Tile.ITEM]


func displayColor() -> Color:
	return getColor(color)


static func getColor(inColor : Tile.COLOR):
	match inColor:
		Tile.COLOR.BLUE:
			return Color.DODGER_BLUE
		Tile.COLOR.GREEN:
			return Color.FOREST_GREEN
		Tile.COLOR.YELLOW:
			return Color.GOLD
		Tile.COLOR.RED:
			return Color.RED
	
	return Color.TRANSPARENT


