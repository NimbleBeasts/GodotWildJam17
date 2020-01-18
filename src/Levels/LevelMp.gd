extends Node2D

onready var LevelManager = $LevelManager
func setup(payload):#no need for this in local multi, for now...
	pass
func _ready():
	LevelManager.DecideFirstPlayer()
	LevelManager.InitializeComponents(Types.GameMode.MpLocalGame)
	
	LevelManager.InitializeGrid($Player1/TilesGrid)
	LevelManager.InitializeGrid($Player2/TilesGrid)

	ShowCurrentPlayerUI(LevelManager.CurrentPlayer)
func InitializeUI():
	var first_card1 = LevelManager.TopCard1
	var first_card2 = LevelManager.TopCard2
	$Player1/Deck.get_node('TopCard').frame = first_card1-3
	$Player2/Deck.get_node('TopCard').frame = first_card2-3
func ShowCurrentPlayerUI(player):
	var Opponent = 1 if player==2 else 2
	get_node('Player'+str(player)).visible = true
	get_node('Player'+str(Opponent)).visible = false
	#TODO: Add a Label to display current player. Set Its text value to str(LevelManager.CurrentPlayer)