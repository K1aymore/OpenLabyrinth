extends Panel

class_name MainMenu

@export var main : Main
@export var board : Board
@export var network : Network


# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true
	setShownMenu($MainMenu)
	$MainMenu/Title/TextureRect.modulate *= 1.1
	$MainMenu/Title/TextureRect2.modulate *= 1.1
	$MainMenu/Options/Fullscreen.button_pressed = get_window().mode == Window.MODE_FULLSCREEN


func setShownMenu(menu : Node):
	for child in get_children():
		child.visible = false
	
	menu.visible = true





func _on_start_local_pressed():
	main.isLocalGame = true
	network.setIsBoardLeader(true)
	main.joinBoard("local")


func _on_start_lan_pressed():
	network.setIsBoardLeader(true)
	network.setupServer($MainMenu/Buttons/HBoxContainer3/LanPort.text)


func _on_connect_client_pressed():
	var ip = $MainMenu/Buttons/HBoxContainer2/ConnectIP.text
	var port : String = $MainMenu/Buttons/HBoxContainer2/ConnectPort.text
	
	network.setupClient(ip, port.to_int())


# start local game
func _on_start_game_pressed():
	main.startGame()



func _on_refresh_board_list_pressed():
	network.requestBoardList()


func addBoardButtons(boardList : Array[String]):
	for child in $BoardList/BoardList.get_children():
		if child is JoinBoardButton:
			child.queue_free()
	
	for boardName in boardList:
		var button := JoinBoardButton.new()
		button.boardName = boardName
		button.pressedWithName.connect(_on_join_board_pressed)
		$BoardList/BoardList.add_child(button)



func _on_create_new_board_pressed():
	network.setIsBoardLeader(true)
	var boardNameEntry : LineEdit = $BoardList/VBoxContainer/BoardName
	network.serverCreateNewBoard.rpc_id(1, multiplayer.get_unique_id(), boardNameEntry.text)
	setShownMenu($GameSetup)



func _on_join_board_pressed(boardName):
	network.serverClientJoinBoard.rpc_id(1, multiplayer.get_unique_id(), boardName)



func _on_add_player_pressed():
	var playerNameField : LineEdit = $GameSetup/Menu/HBoxContainer/PlayerName
	main.addPlayer(playerNameField.text, multiplayer.get_unique_id())
	playerNameField.text = ""
	network.sendServerPlayers()


func _on_fullscreen_toggled(buttonOn):
	if buttonOn:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_MAXIMIZED
