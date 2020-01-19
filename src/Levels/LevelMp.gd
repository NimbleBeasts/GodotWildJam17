extends Node2D
var gameMode = null
var payLoad = null
var totalTurns = 0
onready var LevelManager = $LevelManager
func setup(gameMode, payload):
	self.gameMode = gameMode
	self.payLoad = payLoad

	LevelManager.DecideFirstPlayer()
	LevelManager.InitializeComponents(gameMode,payload)
	LevelManager.InitializeTiles()
	LevelManager.InitializeGrid($Player1/TilesGrid)
	LevelManager.InitializeGrid($Player2/TilesGrid)
	totalTurns = 64 - $Player1/TilesGrid.OccupiedTilesCount
	ShowCurrentPlayerUI(LevelManager.CurrentPlayer)
	$TopBar.setup(gameMode, payLoad, totalTurns)

func InitializeUI():
	var first_card1 = LevelManager.TopCard1
	var first_card2 = LevelManager.TopCard2
	$Player1/Deck.get_node('TopCard').frame = first_card1-3
	$Player2/Deck.get_node('TopCard').frame = first_card2-3
func ShowCurrentPlayerUI(player):
	var Opponent = 1 if player==2 else 2
	get_node('Player'+str(player)).visible = true
	get_node('Player'+str(Opponent)).visible = false
	$TopBar.updateGui(64 - $Player1/TilesGrid.OccupiedTilesCount,player)
	#TODO: Add a Label to display current player. Set Its text value to str(LevelManager.CurrentPlayer)