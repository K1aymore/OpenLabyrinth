extends Node2D

class_name PushArrow

signal arrowPressed(pos)

var pos : Vector2


func _ready():
	position = pos * Tile.TILESIZE


func _on_arrow_button_pressed():
	arrowPressed.emit(pos)

