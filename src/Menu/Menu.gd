extends Control

enum MenuState {Main, Settings, Credits, Multiplayer, Singleplayer}

func _ready():
	Global.setMenu(self)
	$Version.bbcode_text = "[right]"+ Global.getVersionString() + "[/right]"
	stateTransition(MenuState.Main)


func clearWindows():
	$Main.hide()
	$Settings.hide()
	$Credits.hide()
	$Multiplayer.hide()
	$SinglePlayer.hide()

func stateTransition(to):
	clearWindows()
	match to:
		MenuState.Main:
			$Main.show()
		MenuState.Settings:
			updateSettings()
			$Settings.show()
		MenuState.Credits:
			$Credits.show()
		MenuState.Multiplayer:
			$Multiplayer.show()
		MenuState.Singleplayer:
			$SinglePlayer.show()
		_:
			print("Unhandled Transition")


func updateSettings():
	var lights = Global.getGameManager().getLights()
	
	if lights:
		$Settings/ButtonLights/Text.bbcode_text = "[center]Light: On[/center]"
	else:
		$Settings/ButtonLights/Text.bbcode_text = "[center]Light: Off[/center]"


func _on_ButtonExit_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		print("Ok, Bye! Thanks for playing.")
		get_tree().quit()

func _on_ButtonSettings_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		stateTransition(MenuState.Settings)

func _on_ButtonPlay_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		stateTransition(MenuState.Singleplayer)


func _on_ButtonBack_button_up():
	stateTransition(MenuState.Main)

func _on_ButtonLights_button_up():
	var lights = Global.getGameManager().getLights()
	Global.getGameManager().setLights(!lights)
	updateSettings()


func _on_BtnDbg_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		Global.getGameManager().newGame()


func _on_ButtonCredits_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		stateTransition(MenuState.Credits)


func _on_ButtonMp_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		stateTransition(MenuState.Multiplayer)


# Multiplayer Related
func _on_ButtonLocal_button_up():
	pass # Replace with function body.


func _on_ButtonHost_button_up():
	pass # Replace with function body.


func _on_ButtonJoin_button_up():
	pass # Replace with function body.
