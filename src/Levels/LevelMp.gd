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
	LevelManager.InitializeGrid($Player1/TilesGrid)
	LevelManager.InitializeGrid($Player2/TilesGrid)
	LevelManager.InitializeTiles()
	LevelManager.FillGrid($Player1/TilesGrid)
	LevelManager.FillGrid($Player2/TilesGrid)
	totalTurns = 64 - $Player1/TilesGrid.OccupiedTilesCount
	ShowCurrentPlayerUI(LevelManager.CurrentPlayer)
	$TopBar.setup(gameMode, payLoad, totalTurns)
	InitializeUI()

func InitializeUI():
	var first_card1 = LevelManager.TopCard1
	var first_card2 = LevelManager.TopCard2
	$Player1/Deck.get_node('TopCard').frame = first_card1-3
	$Player2/Deck.get_node('TopCard').frame = first_card2-3

func ShowCurrentPlayerUI(player):
	var Opponent = 1 if player==2 else 2
	get_node('Player'+str(player)).visible = true
	get_node('Player'+str(Opponent)).visible = false
	var LastPlayer = '1' if LevelManager.FirstPlayer==2 else '2'
	$TopBar.updateGui(64 - get_node('Player'+LastPlayer+'/TilesGrid').OccupiedTilesCount,player)
	FillTileMap(player)

func FillTileMap(player):
	var displayPlayer = 2
	if player == 2:
		displayPlayer = 1
	
	$TileMap.clear()
	var data = get_node('Player'+str(displayPlayer)+'/TilesGrid').tilesContent
#	print("============================")
#	print("Player " + str(displayPlayer))
#	print(data)
	for i in range(8):
		for j in range(8):
			if data[[i,j]]:
				$TileMap.set_cell(i, j, data[[i,j]])