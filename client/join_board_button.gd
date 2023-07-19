extends Button

class_name JoinBoardButton

var boardName : String

signal pressedWithName


func _ready():
	text = "Join Board " + boardName

func _pressed():
	pressedWithName.emit(boardName)
