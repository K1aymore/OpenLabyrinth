extends Panel

class_name MainMenu

@export var main : Main
@export var board : Board
@export var network : Network


@onready var connectIP : LineEdit  = $MainMenu/MainMenu/HBoxContainer2/ConnectIP
@onready var connectPort : LineEdit  = $MainMenu/MainMenu/HBoxContainer2/ConnectPort


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func setShownMenu(menu : Node):
	for child in get_children():
		child.visible = false
	
	menu.visible = true





func _on_start_local_pressed():
	setShownMenu($LocalSetup)


func _on_start_lan_pressed():
	network.setupServer($MainMenu/Buttons/HBoxContainer3/LanPort.text)


func _on_connect_client_pressed():
	network.setupClient($MainMenu/Buttons/HBoxContainer2/ConnectIP.text, $MainMenu/Buttons/HBoxContainer2/ConnectPort.text)


# start local game
func _on_start_game_pressed():
	main.startGame()


func _on_add_player_pressed():
	pass # Replace with function body.


func _on_create_new_board_pressed():
	pass # Replace with function body.
