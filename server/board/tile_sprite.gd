extends Sprite2D

class_name TileSprite

var tile : Tile

var cornerSprite := preload("res://assets/basic/corner.svg")
var straightSprite := preload("res://assets/basic/straight.svg")
var tshapeSprite := preload("res://assets/basic/t-shape.svg")

@onready var itemSprite : Sprite2D = $ItemSprite

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
	
	match tile.item:
		Tile.ITEM.NONE:
			pass
		Tile.ITEM.BAT:
			itemSprite.texture = load("res://assets/basic/pieces/Bat.svg")
		Tile.ITEM.BOMB:
			itemSprite.texture = load("res://assets/basic/pieces/Bomb.svg")
		Tile.ITEM.BOOK:
			itemSprite.texture = load("res://assets/basic/pieces/Book.svg")
		Tile.ITEM.BUG:
			itemSprite.texture = load("res://assets/basic/pieces/Bug.svg")
		Tile.ITEM.CANDLES:
			itemSprite.texture = load("res://assets/basic/pieces/Candles.svg")
		Tile.ITEM.CANNON:
			itemSprite.texture = load("res://assets/basic/pieces/Cannon.svg")
		Tile.ITEM.CAT:
			itemSprite.texture = load("res://assets/basic/pieces/Cat.svg")
		Tile.ITEM.CROWN:
			itemSprite.texture = load("res://assets/basic/pieces/Crown.svg")
		Tile.ITEM.DAGGER:
			itemSprite.texture = load("res://assets/basic/pieces/Dagger.svg")
		Tile.ITEM.DIAMOND:
			itemSprite.texture = load("res://assets/basic/pieces/Diamond.svg")
		Tile.ITEM.DINOSAUR:
			itemSprite.texture = load("res://assets/basic/pieces/Dinosaur.svg")
		Tile.ITEM.GHOST:
			itemSprite.texture = load("res://assets/basic/pieces/Ghost.svg")
		Tile.ITEM.GRAIL:
			itemSprite.texture = load("res://assets/basic/pieces/Grail.svg")
		Tile.ITEM.HELMET:
			itemSprite.texture = load("res://assets/basic/pieces/Helmet.svg")
		Tile.ITEM.KEYS:
			itemSprite.texture = load("res://assets/basic/pieces/Keys.svg")
		Tile.ITEM.LIZARD:
			itemSprite.texture = load("res://assets/basic/pieces/Lizard.svg")
		Tile.ITEM.MERMAID:
			itemSprite.texture = load("res://assets/basic/pieces/Mermaid.svg")
		Tile.ITEM.MOUSE:
			itemSprite.texture = load("res://assets/basic/pieces/Mouse.svg")
		Tile.ITEM.OWL:
			itemSprite.texture = load("res://assets/basic/pieces/Owl.svg")
		Tile.ITEM.PONY:
			itemSprite.texture = load("res://assets/basic/pieces/Pony.svg")
		Tile.ITEM.POTION:
			itemSprite.texture = load("res://assets/basic/pieces/Potion.svg")
		Tile.ITEM.RING:
			itemSprite.texture = load("res://assets/basic/pieces/Ring.svg")
		Tile.ITEM.TREASURE:
			itemSprite.texture = load("res://assets/basic/pieces/Treasure.svg")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !position.is_equal_approx(tile.pos):
		position = position.lerp(tile.pos * Tile.TILESIZE, delta * 10)
		
	if !is_equal_approx(rotation_degrees, tile.rot):
		rotation = lerp_angle(rotation, deg_to_rad(tile.rot), delta * 10)
