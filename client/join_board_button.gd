extends Button

class_name JoinBoardButton


var id : int

signal pressedWithID


func _pressed():
	pressedWithID.emit(id)
