# Kickstart Template
# ------------------------------------------------
# Date       | Change
# ------------------------------------------------
# 18/11/2019 | Added Text Debug Menu

extends Control

const levels = [
	"res://src/Levels/LevelSp.tscn",
	"res://src/Levels/LevelMp.tscn"
]

var state = Types.GameStates.Menu
var lights = true

var levelNode = null
var levelId = 0

func _ready():
	Global.setGameManager(self)
	Global.debugLabel = $Debug
	
	$gameViewport/Viewport.size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
	$menuViewport/Viewport.size = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
	
	stateTransition(Types.GameStates.Menu)
	
	_on_MusicPlayer_finished()

func updateLights():
	for light in get_tree().get_nodes_in_group("light"):
		light.enabled = lights

func stateTransition(to):
	if to == Types.GameStates.Menu:
		$gameViewport.hide()
		$menuViewport.show()
		$menuViewport/Viewport/Menu.show()
		$menuViewport/Viewport/Menu.updateGui()
	elif to == Types.GameStates.Game:
		$gameViewport.show()
		$menuViewport.hide()
		$menuViewport/Viewport/Menu.hide()
		updateLights()
	state = to

func loadLevel(number = 0):
	levelNode = load(levels[number]).instance()
	$gameViewport.get_node("Viewport/LevelHolder").add_child(levelNode)
	updateLights()

func unloadLevel():
	$gameViewport.get_node("Viewport/LevelHolder").remove_child(levelNode)
	levelNode.queue_free()
	levelNode = null

func continueGame():
	stateTransition(Types.GameStates.Game)

func newGame(gameMode, payLoad = null):
	if levelNode:
		unloadLevel()

	match gameMode:
		Types.GameMode.Tutorial:
			loadLevel(0)
		Types.GameMode.CustomGame:
			loadLevel(0)
		Types.GameMode.DailyChallenge:
			loadLevel(0)
		Types.GameMode.MpHostGame:
			loadLevel(1)
		Types.GameMode.MpJoinGame:
			loadLevel(1)
		Types.GameMode.MpLocalGame:
			loadLevel(1)
		_:
			print("Error: Unhandled game mode requested")

	#Hand over payload
	levelNode.setup(gameMode, payLoad) 
	stateTransition(Types.GameStates.Game)

func setLights(state):
	lights = state

func getLights():
	return lights

func stopMusic():
	$MusicPlayer.stop()

func startMusic():
	_on_MusicPlayer_finished()

func _on_MusicPlayer_finished():
	if Global.userConfig.music:
		$MusicPlayer.play()
