extends Sprite2D

class_name TileSprite

var tile : Tile

var cornerSprite := preload("res://assets/basic/corner.png")
var straightSprite := preload("res://assets/basic/straight.png")
var tshapeSprite := preload("res://assets/basic/t-shape.png")

@onready var itemSprite : Sprite2D = $ItemSprite

const itemImages : Array[Resource] = [
	null,
	preload("res://assets/basic/pieces/Bat.svg"),
	preload("res://assets/basic/pieces/Bomb.svg"),
	preload("res://assets/basic/pieces/Book.svg"),
	preload("res://assets/basic/pieces/Bug.svg"),
	preload("res://assets/basic/pieces/Candles.svg"),
	preload("res://assets/basic/pieces/Cannon.svg"),
	preload("res://assets/basic/pieces/Cat.svg"),
	preload("res://assets/basic/pieces/Coins.svg"),
	preload("res://assets/basic/pieces/Crown.svg"),
	preload("res://assets/basic/pieces/Dagger.svg"),
	preload("res://assets/basic/pieces/Diamond.svg"),
	preload("res://assets/basic/pieces/Dinosaur.svg"),
	preload("res://assets/basic/pieces/Ghost.svg"),
	preload("res://assets/basic/pieces/Grail.svg"),
	preload("res://assets/basic/pieces/Helmet.svg"),
	preload("res://assets/basic/pieces/Keys.svg"),
	preload("res://assets/basic/pieces/Lizard.svg"),
	preload("res://assets/basic/pieces/Mermaid.svg"),
	preload("res://assets/basic/pieces/Mouse.svg"),
	preload("res://assets/basic/pieces/Owl.svg"),
	preload("res://assets/basic/pieces/Pony.svg"),
	preload("res://assets/basic/pieces/Potion.svg"),
	preload("res://assets/basic/pieces/Ring.svg"),
	preload("res://assets/basic/pieces/Treasure.svg"),
]

# Called when the node enters the scene tree for the first time.
func _ready():
	scale = Vector2.ONE * 0.2
	position = Vector2(3, 3) * Tile.TILESIZE
	
	match tile.type:
		Tile.TYPE.CORNER:
			texture = cornerSprite
		Tile.TYPE.STRAIGHT:
			texture = straightSprite
		Tile.TYPE.TSHAPE:
			texture = tshapeSprite
		_:
			push_error()
	
	itemSprite.texture = itemImages[tile.item]
	
	if tile.homePlayer != null:
		$HomeCircle.self_modulate = tile.homePlayer.displayColor() * 0.70
	else:
		$HomeCircle.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	z_index = 1 if tile.isSpare else 0
	
	if !position.is_equal_approx(tile.pos * Tile.TILESIZE):
		position = position.lerp(tile.pos * Tile.TILESIZE, delta * 10)
	
	if !is_equal_approx(rotation_degrees, tile.rot):
		rotation = lerp_angle(rotation, deg_to_rad(tile.rot), delta * 10)
	
	itemSprite.global_rotation_degrees = 0


static func getItemImage(num : int) -> Resource:
	if num >= itemImages.size() || num < 0:
		return null
	
	return itemImages[num]
