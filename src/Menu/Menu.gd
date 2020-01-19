extends Control

enum MenuState {Main, Settings, Credits, Multiplayer, Singleplayer}
var dailyChallengeSeed = 123456

var dailyRng = RandomNumberGenerator.new()
var prng = RandomNumberGenerator.new()

func _ready():
	prng.randomize()
	Global.setMenu(self)
	$Version.bbcode_text = "[right]"+ Global.getVersionString() + "[/right]"
	stateTransition(MenuState.Main)
	
	#Seed Initialization
	_on_ButtonNewSeed_button_up() 
	dailySeed()
	$Main/ButtonContinue.hide()
	
	# Remove not supported features
	ShitGameJamsOver()


func ShitGameJamsOver():
	$SinglePlayer/Custom/ButtonTutorial.disabled = true #SOOORRRYY
	$Multiplayer/CnJoinGame/ButtonJoin.disabled = true
	$Multiplayer/CnHostGame/ButtonHost.disabled = true
	

func updateGui():
	stateTransition(MenuState.Main)
	if Global.gm.levelNode:
		$Main/ButtonContinue.show()
	else:
		$Main/ButtonContinue.hide()

func dailySeed():
	var date = OS.get_date()
	var seedString = "" + str(date.day) + str(date.month) + str(date.year)
	dailyRng = RandomNumberGenerator.new() #Reset it each time
	dailyRng.set_seed(seedString.hash())
	dailyChallengeSeed = dailyRng.randi_range(0, 99999)


func generateSeed():
	return prng.randi_range(0, 99999)

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
	
	if Global.userConfig.fullscreen:
		$Settings/ButtonFullscreen/Text.bbcode_text = "[center]Fullscreen: On[/center]"
	else:
		$Settings/ButtonFullscreen/Text.bbcode_text = "[center]Fullscreen: Off[/center]"

	if Global.userConfig.music:
		$Settings/ButtonMusic/Text.bbcode_text = "[center]Music: On[/center]"
	else:
		$Settings/ButtonMusic/Text.bbcode_text = "[center]Music: Off[/center]"

	if Global.userConfig.sound:
		$Settings/ButtonSound/Text.bbcode_text = "[center]Sound: On[/center]"
	else:
		$Settings/ButtonSound/Text.bbcode_text = "[center]Sound: Off[/center]"

func trim(string):
	var retVal = string.lstrip(" ")
	retVal = retVal.rstrip(" ")
	return retVal

func _on_ButtonExit_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		_playClick()
		print("Ok, Bye! Thanks for playing.")
		get_tree().quit()

func _on_ButtonSettings_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		_playClick()
		stateTransition(MenuState.Settings)

func _on_ButtonPlay_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		_playClick()
		stateTransition(MenuState.Singleplayer)


func _on_ButtonBack_button_up():
	_playClick()
	stateTransition(MenuState.Main)

func _on_ButtonLights_button_up():
	_playClick()
	var lights = Global.getGameManager().getLights()
	Global.getGameManager().setLights(!lights)
	updateSettings()

func _on_ButtonFullscreen_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		_playClick()
		Global.fullscreen()
		updateSettings()


func _on_ButtonMusic_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		_playClick()
		Global.musicToggle()
		updateSettings()


func _on_ButtonSound_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		_playClick()
		Global.soundToggle()
		updateSettings()
		
	
func _on_BtnDbg_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		_playClick()
		Global.getGameManager().newGame(Types.GameMode.DailyChallenge)

func _on_ButtonCredits_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		_playClick()
		stateTransition(MenuState.Credits)


func _on_ButtonMp_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		_playClick()
		stateTransition(MenuState.Multiplayer)

func _on_ButtonContinue_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		_playClick()
		Global.getGameManager().continueGame()


# Multiplayer Related
func _on_ButtonLocal_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		_playClick()
		var cities = $Multiplayer/CnHostGame/SDifficulty.value
		var obstacles = $Multiplayer/CnHostGame/SObstacles.value
		Global.getGameManager().newGame(Types.GameMode.MpLocalGame, {"cities": cities, "obstacles": obstacles})


func _on_ButtonHost_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		_playClick()
		var port = int($Multiplayer/CnHostGame/TePort.text)
		var cities = $Multiplayer/CnHostGame/SDifficulty.value
		var obstacles = $Multiplayer/CnHostGame/SObstacles.value
		Global.getGameManager().newGame(Types.GameMode.MpHostGame, {"port": port, "cities": cities, "obstacles": obstacles})


func _on_ButtonJoin_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		_playClick()
		var rawIpText = $Multiplayer/CnJoinGame/TeIp.text
		var ipData = rawIpText.rsplit(":")
		
		if ipData.size() == 2:
			#Trim whitespaces
			var ip = trim(ipData[0])
			var port = int(trim(ipData[1]))
			
			if ip.is_valid_ip_address():
				Global.getGameManager().newGame(Types.GameMode.MpJoinGame, {"IP": ip, "port": port})
			else:
				print("Error: IP not valid")
		else:
			print("Error: IP not valid")
	#TODO: Using regex to check IP and port consistency.


# Singleplayer Related
func _on_ButtonCustom_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		_playClick()
		var difficulty = $SinglePlayer/Custom/SCgDifficulty.value
		var obstacles = $SinglePlayer/Custom/SCgObstacles.value
		var tSeed = int($SinglePlayer/Custom/TeSeed.text)
		Global.getGameManager().newGame(Types.GameMode.CustomGame, {"cities": difficulty, "obstacles": obstacles, "seed": tSeed})

func _on_ButtonNewSeed_button_up():
	_playClick()
	$SinglePlayer/Custom/TeSeed.text = str(generateSeed())

func _on_ButtonDaily_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		_playClick()
		dailySeed() #Reseed the rng
		Global.getGameManager().newGame(Types.GameMode.DailyChallenge, {"seed": dailyChallengeSeed})

func _on_ButtonTutorial_button_up():
	if Global.getGameManager().state == Types.GameStates.Menu:
		_playClick()
		Global.getGameManager().newGame(Types.GameMode.Tutorial)


# Sliders
func _on_SDifficulty_value_changed(value):
	$Multiplayer/CnHostGame/LabelDifficultyCount.set_text(str(int(value)))

func _on_SCgDifficulty_value_changed(value):
	$SinglePlayer/Custom/LabelCgDifficulty.set_text("Cities: "+ str(int(value)) )

func _on_SCgObstacles_value_changed(value):
	$SinglePlayer/Custom/LabelCgObstacles.set_text("Obstacles: " + str(int(value)))


func _on_SObstacles_value_changed(value):
	$Multiplayer/CnHostGame/LabelObstaclesCount.set_text(str(int(value)))

func _playClick():
	if Global.userConfig.sound:
		$ClickSound.play()


