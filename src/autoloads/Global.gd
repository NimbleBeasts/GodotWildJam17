###############################################################################
# (c) NimbleBeasts 2019 and counting
# This is template file
###############################################################################

# ToDos:
# TODO goes here

extends Node


###############################################################################
# Data
###############################################################################

# Version
const version = {
	"major": 0,
	"minor": 1
}

# Nb Plugin Config
const NbConfig = {
	"gameId": "gameId",
	"filePassword": "password",
	"magic": "magiccode"
}

# User Config
var userConfig = {
	"highscore": 0,
	"fullscreen": false,
	"music": true,
	"sound": true
}

# GameMasterNode
var gm = null
var cam = null
var hud = null
var menu = null

# Debug Label
var debugLabel = null
var debug = true

# RNG base
var rng = RandomNumberGenerator.new()
var stateSeed = int(3458764513820540928)

###############################################################################
# Functions
###############################################################################

func _ready():
	print("Starting: " + str(ProjectSettings.get_setting("application/config/name")) + " v" + getVersionString())
	rng.randomize()
	loadConfig()
	videoSetup(2)
	fullscreen(userConfig.fullscreen)



# Config Save
func saveConfig():
	var cfgFile = File.new()
	cfgFile.open("user://config.cfg", File.WRITE)
	cfgFile.store_line(to_json(userConfig))
	cfgFile.close()

# Config Load
func loadConfig():
	var cfgFile = File.new()
	if not cfgFile.file_exists("user://config.cfg"):
		saveConfig()
		return
	
	cfgFile.open("user://config.cfg", File.READ)
	var data = parse_json(cfgFile.get_line())
	userConfig.highscore = data.highscore
	userConfig.fullscreen = data.fullscreen
	userConfig.music = data.music
	userConfig.sound = data.sound
	# When stuck here, the config attributes have been changed.
	# Delete the Config.cfg to solve this issue.
	# Project->Open Project Data Folder-> Config.cfg

# Window Scaler
func videoSetup(scale = 2):
	var initSize = Vector2(ProjectSettings.get_setting("display/window/size/width"), ProjectSettings.get_setting("display/window/size/height"))
	var screen_size = OS.get_screen_size(OS.get_current_screen())
	var window_size = initSize * scale
	var centered_pos = (screen_size - window_size) / 2
	OS.set_window_position(centered_pos)
	OS.set_window_size(window_size)

# Fullscreen Toggle
func fullscreen(set = null):
	if set == null:
		userConfig.fullscreen = !userConfig.fullscreen
		saveConfig()
		
	if not userConfig.fullscreen:
		OS.window_fullscreen = false
		videoSetup(2)
	else:
		videoSetup(3)
		OS.window_fullscreen = true

func musicToggle():
	userConfig.music = !userConfig.music
	saveConfig()
	if userConfig.music:
		gm.startMusic()
	else:
		gm.stopMusic()

func soundToggle():
	userConfig.sound = !userConfig.sound
	saveConfig()

# PRNG
func prng():
	#TODO monte carlo simulation over rng
	stateSeed = int((rng.randi() + 1) * stateSeed) + 1
	return abs(stateSeed)

# PRNG by Chance in Percentage
func prngByChance(chanceInPercent):
	var value = prng() % 100
	if value <= chanceInPercent:
		return true
	return false


###############################################################################
# Getter/Setter
###############################################################################

# Get Version
func getVersion():
	return version
	
# Get Version String
func getVersionString():
	return "" + str(version.major) + "." + str(version.minor)

# GameManager Set
func setGameManager(node):
	gm = node

# GameManager Get
func getGameManager():
	return gm

func setMenu(node):
	menu = node

func getMenu():
	return menu

func setHUD(node):
	hud = node

func getHUD():
	return hud

func getCam():
	return cam

func getDebug():
	if debug:
		return debugLabel
	return null
