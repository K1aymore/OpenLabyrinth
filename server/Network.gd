extends Node

class_name Network

@onready var main : Main = get_parent()



@rpc("any_peer")
func serverCall(boardNum, methodName, args):
	callFromServer.rpc(methodName, args)


@rpc
func callFromServer(methodName, args : Array):
	pass




@rpc("any_peer")
func serverCreateNewBoard(peerID : int, boardName : String):
	var newBoard = Board.new()
	newBoard.boardName = boardName
	newBoard.id = randi()
	main.boards[boardName] = newBoard
	serverClientJoinBoard(peerID, boardName)


@rpc("any_peer")
func serverClientJoinBoard(peerID : int, boardName : String):
	main.boards[boardName].peerIDs.append(peerID)
	callFromServer.rpc_id(peerID, "setBoardName", [boardName])



@rpc("any_peer")
func requestBoardList(peerID : int):
	recieveBoardList.rpc_id(peerID, main.boards.keys())


@rpc
func recieveBoardList(boardList : Array[String]):
	pass
