extends Node2D

class_name PushArrow

signal arrowPressed(pos)


func _on_arrow_button_pressed():
	arrowPressed.emit(position)

