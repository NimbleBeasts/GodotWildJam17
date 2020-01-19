extends Control

func setup(gameMode, payLoad, turns):
	var title = ""
	
	$LPlayerTurn.hide()
	
	match gameMode:
		Types.GameMode.Tutorial:
			title = "Tutorial"
		Types.GameMode.CustomGame:
			title = "Custom Game [Seed:"+ str(payLoad.seed) +"]"
		Types.GameMode.DailyChallenge:
			var date = OS.get_date()
			title = "Daily Challenge [" + str(date.day) + "/" + str(date.month)+ "/" + str(date.year) + "]"
		Types.GameMode.MpHostGame:
			title = "Online Game [Host]"
		Types.GameMode.MpJoinGame:
			title = "Online Game [Client]"
		Types.GameMode.MpLocalGame:
			title = "Local Game"
			$LPlayerTurn.show()
		_:
			print("Error: Unhandled game mode requested")
	$LGameMode.set_text(title)
	
	$PbTurns.max_value = turns
	$PbTurns.value = turns
	$LTurns.set_text("Turns Left: "+ str(turns))

func updateGui(turn, player = 0):
	$PbTurns.value = turn
	$LTurns.set_text("Turns Left: "+ str(turn))
	if player > 0:
		$LPlayerTurn.set_text("Player " + str(player) + "'s Turn'")


func _on_BMenu_button_up():
	Global.menu._playClick()
	Global.gm.stateTransition(Types.GameStates.Menu)


func _on_BHelp_button_up():
	Global.menu._playClick()
	OS.shell_open("https://github.com/NimbleBeasts/GodotWildJam17/wiki")
