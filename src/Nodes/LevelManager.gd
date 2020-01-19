extends Node2D

onready var ScoreAnimator = Global.gm.levelNode.get_node("ScoreAnimator")

# Gameplay Data
export var GridDimensions = 8 # x=y=GridDimensions
var ObstaclesCount = 16 # when game starts
var CitiesCount = 4
const FactoriesCount = 2
const DeckCardsCount = [0,0,0,0,8,8,6,6,6,6,2,2,2,2,2,4]

# Data
var gameMode = null
var FirstPlayer = -1
var CurrentPlayer = -1
var TurnsCount =0#TurnsCount is for tracking who played their turn each round.
var TilesGrid1#for player1
var TilesGrid2#for player2
var Deck1 = []
var Deck2 = []
var DeckNode1
var DeckNode2
var TopCard1 = Types.Tile.Rail_UD
var TopCard2 = Types.Tile.Rail_UD

var drng = RandomNumberGenerator.new()

func DecideFirstPlayer():
	randomize()
	FirstPlayer = (randi() %2)+1
	CurrentPlayer = FirstPlayer

func NextPlayer():
	#To prevent player from clicking more than once.
	#If you have a better way to do this, please use it :p
	#The 1 second delay is used to show the tile being placed before
	#switching to the other player's grid
	Global.gm.levelNode.get_node('SuperAntiCheatLayer').visible = true
	yield(get_tree().create_timer(1.0), "timeout")
	Global.gm.levelNode.get_node('SuperAntiCheatLayer').visible = false
	
	TurnsCount+=1
	if TurnsCount==2:#move on to next round
		NextRound()
	else:
		CurrentPlayer = int(CurrentPlayer==1) + 1
		match gameMode:
			Types.GameMode.MpLocalGame:
				Global.gm.levelNode.ShowCurrentPlayerUI(CurrentPlayer)

func NextRound():
		match gameMode:
			Types.GameMode.MpLocalGame:
				if TilesGrid1.OccupiedTilesCount==GridDimensions*GridDimensions and TilesGrid2.OccupiedTilesCount==GridDimensions*GridDimensions:#gameover
					GameOver()
				else:
					TurnsCount = 0
					CurrentPlayer = int(CurrentPlayer==1) + 1
					Global.gm.levelNode.ShowCurrentPlayerUI(CurrentPlayer)
			_:
				if TilesGrid1.OccupiedTilesCount==GridDimensions*GridDimensions:
					GameOver()#for SP
				else:
					Global.gm.levelNode.NextTurn()

func InitializeComponents(mode, payLoad):
	TilesGrid1= Global.gm.levelNode.get_node("Player1/TilesGrid")
	DeckNode1 = Global.gm.levelNode.get_node('Player1/Deck')
	DeckNode1.get_node('TopCard').frame = TopCard1-3
	#Init RNG
	_initializeRng(payLoad)
	
	#Deck Initialization
	_initializeDeck()
	TopCard1 = Deck1[0]
	
	#Set Mode
	gameMode = mode

	match gameMode:
		Types.GameMode.DailyChallenge:
			CurrentPlayer = 0
		Types.GameMode.CustomGame:
			CurrentPlayer = 0
			ObstaclesCount = payLoad.obstacles
			CitiesCount = payLoad.cities
		Types.GameMode.MpLocalGame:
			TilesGrid2= Global.gm.levelNode.get_node("Player2/TilesGrid")
			Deck2 = Deck1.duplicate(true)
			TopCard2 = Deck2[0]
			DeckNode2 = Global.gm.levelNode.get_node('Player2/Deck')
			DeckNode2.get_node('TopCard').frame = TopCard2-3
		_:
			print("Error: Unhandled Component")
			
var InitialGrid = {}

func _initializeRng(payLoad):
	if payLoad.get("seed") != null:
		#Use custom seed
		drng.set_seed(str(payLoad.seed).hash())
	else:
		#Else Randomize
		drng.randomize()

func _initializeDeck():
	randomize()
	#load a random deck
	for cardType in Types.Tile.keys():
		for n in DeckCardsCount[Types.Tile[cardType]]:
			Deck1.append(Types.Tile[cardType])
	Deck1.shuffle()

func WhatsNearMeOnThe(direction,my_coords,where):#null when there's no tile or the tile is empty
	var result = [null,null]
	var movement = [[0,-1], [-1,0], [1,0], [0,1]] #which coordinate (x or y) to change to move in the direction
	var coords = [my_coords[0]+movement[direction][0], my_coords[1]+movement[direction][1]]
	if  coords[0] in range(GridDimensions) and coords[1] in range(GridDimensions):
		result = [where[coords],coords]
	return result

func InitializeTiles():
	var FreeTiles = {}
	for j in range(GridDimensions):
		for i in range(GridDimensions):
			InitialGrid[[i,j]] =null
	FreeTiles = InitialGrid.duplicate(true)
	
	for i in range(ObstaclesCount):
		var type = [ Types.Tile.Mountains, Types.Tile.Forest][drng.randi() % 2]
		var coords = FreeTiles.keys()[drng.randi() % FreeTiles.keys().size()]
		InitialGrid[coords] = type
		FreeTiles.erase(coords)

	var quadrants = [{},{},{},{}]
	for limits in [[[0,0],[3,3]],[[4,0],[7,3]],[[0,4],[3,7]],[[4,4],[7,7]]]:
		for i in range(4):
			for y in range(limits[0][1],limits[1][1]+1):
				for x in range(limits[0][0],limits[1][0]+1):
					quadrants[i][[x,y]] = null
	#remove occupied tiles  from quadrants
	for n in range(CitiesCount):
		var type = Types.Tile.Buildings
		var coords = FreeTiles.keys()[drng.randi() % FreeTiles.keys().size()]
		InitialGrid[coords] = type
		
		FreeTiles.erase(coords)
		
	for n in range(Types.FactoriesCount):
		var type = Types.Tile.Factory
		var coords = FreeTiles.keys()[drng.randi() % FreeTiles.keys().size()]
		InitialGrid[coords] = type
		FreeTiles.erase(coords)

func InitializeGrid(grid):
	#load the grid
	grid.columns = GridDimensions
	var tileScene = load("res://src/Nodes/tiles/Tile.tscn")
	for j in range(GridDimensions):
		for i in range(GridDimensions):
			var tile = tileScene.instance()
			tile.coords = [i,j]
			grid.add_child(tile)
			grid.tilesContent[tile.coords]=null
func FillGrid(grid):
	#load the initial tiles
	var obstacleScene = load("res://src/Nodes/tiles/Obstacle.tscn")
	for coords in InitialGrid.keys():
		if InitialGrid[coords]!=null:
			grid.OccupiedTilesCount += 1
			var obstacle = obstacleScene.instance()
			obstacle.frame = InitialGrid[coords]
			#place the obstacle/city in the corresponding tile
			grid.get_child(grid.CoordsToIndex(coords)).add_child(obstacle)
		
	grid.tilesContent = InitialGrid.duplicate(true)
	for coords in InitialGrid.keys():
		if InitialGrid[coords] == Types.Tile.Buildings:
			grid.CitiesCoords.append(coords)
func ShowNextCard():
	var player = CurrentPlayer
	#var player = int(CurrentPlayer==1) + 1#because ShowNextCard() is called after NextPlayer() in Tile.gd
	match gameMode:
		Types.GameMode.MpLocalGame:
			var deck
			if player==1: 
				deck = Deck1
				TopCard1 = deck[1]
				DeckNode1.get_node('TopCard').frame = TopCard1-3
			elif player==2: 
				deck= Deck2
				TopCard2 = deck[1]
				DeckNode2.get_node('TopCard').frame = TopCard2-3
			deck.remove(0)
		_:#for test level. TODO: REMOVE IN RELEASE VERSION!
			Deck1.remove(0)
			TopCard1 = Deck1[0]
			DeckNode1.get_node('TopCard').frame = Deck1[0]-3

func GameOver():
	match gameMode:
		Types.GameMode.MpLocalGame:
			TilesGrid1.CheckForConnections()
			TilesGrid2.CheckForConnections()
			Global.gm.levelNode.ShowCurrentPlayerUI(1)
			var done = ScoreAnimator.Animate(TilesGrid1)
			Global.gm.levelNode.get_node('TopBar').updateGui(64,2)
			Global.gm.levelNode.ShowCurrentPlayerUI(2)
			yield(get_tree().create_timer(3), "timeout")
			
			ScoreAnimator.Animate(TilesGrid2)
		_: #for SP
			pass
