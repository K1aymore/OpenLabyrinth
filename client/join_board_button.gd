extends Button

class_name JoinBoardButton


var id : int

signal pressedWithID


func _ready():
	text = "Join Board " + str(id)

func _pressed():
	pressedWithID.emit(id)
