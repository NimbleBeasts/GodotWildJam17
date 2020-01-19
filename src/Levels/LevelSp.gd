extends Node2D

onready var LevelManager = $LevelManager

var totalTurns = -1
var gameMode = null
var payLoad = null

func setup(gameMode, payLoad):
	self.gameMode = gameMode
	self.payLoad = payLoad

	LevelManager.InitializeComponents(self.gameMode, self.payLoad)
	LevelManager.InitializeTiles()
	LevelManager.InitializeGrid($Player1/TilesGrid)
	totalTurns = 64 - $Player1/TilesGrid.OccupiedTilesCount

	$TopBar.setup(gameMode, payLoad, totalTurns)

	$Player1/Deck.get_node('TopCard').frame = LevelManager.TopCard1 - 3