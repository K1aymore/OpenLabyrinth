extends HBoxContainer

class_name PlayerDisplay

var main : Main

var player : Player


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player == null:
		return
	
	$Label.text = player.name
	$Label.modulate = player.colorColor * 1.5
	$Label/Sprite2D.visible = player == main.currentPlayer
	
	
	$ItemCountLabel.text = " Items left: " + str(player.neededItems.size())
	
	$ItemImage.texture = (TileSprite.getItemImage(player.neededItems[0])
		if player.neededItems.size() > 0 && player.ownedClientID == multiplayer.get_unique_id()\
		else null)
