extends Node2D

export var GridDimensions = 8 # x=y=GridDimensions
var ObstaclesCount = 16 # when game starts
var CitiesCount = 4
const FactoriesCount = 2
const DeckCardsCount = [0,0,0,0,8,8,6,6,6,6,2,2,2,2,2,4]
export(Types.GameMode) var gamemode

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

func DecideFirstPlayer():
	randomize()
	CurrentPlayer = (randi() %2)+1
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
		match gamemode:
			Types.GameMode.MpLocalGame:
				Global.gm.levelNode.ShowCurrentPlayerUI(CurrentPlayer)
func NextRound():
	if TilesGrid1.OccupiedTilesCount==GridDimensions*GridDimensions and TilesGrid2.OccupiedTilesCount==GridDimensions*GridDimensions:#gameover
		GameOver(1)#TODO: work on these
		GameOver(2)
	else:
		TurnsCount = 0
		CurrentPlayer = int(CurrentPlayer==1) + 1
		match gamemode:
			Types.GameMode.MpLocalGame:
				Global.gm.levelNode.ShowCurrentPlayerUI(CurrentPlayer)
func InitializeComponents(mode):#modes: 0=single_player, 1=shared_screen_multi, 2=network_multi
	match gamemode:
		Types.GameMode.MpLocalGame:
			TilesGrid1= Global.gm.levelNode.get_node("Player1/TilesGrid")
			TilesGrid2= Global.gm.levelNode.get_node("Player2/TilesGrid")
			#load a random deck
			for cardType in Types.Tile.keys():
				for n in DeckCardsCount[Types.Tile[cardType]]:
					Deck1.append(Types.Tile[cardType])
			randomize()
			Deck1.shuffle()
			Deck2 = Deck1.duplicate(true)
			TopCard1 = Deck1[0]
			TopCard2 = Deck2[0]
			DeckNode1 = Global.gm.levelNode.get_node('Player1/Deck')
			DeckNode2 = Global.gm.levelNode.get_node('Player2/Deck')
			InitializeGrid(TilesGrid1)
			InitializeGrid(TilesGrid2)
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
	#load the initial obstacles
	var obstacleScene = load("res://src/Nodes/tiles/Obstacle.tscn")
	var FreeTiles = grid.tilesContent.duplicate(true)
	for i in range(ObstaclesCount):
		grid.OccupiedTilesCount += 1
		var obstacle = obstacleScene.instance()
		randomize()
		var type = [ Types.Tile.Mountains, Types.Tile.Forest][randi() % 2]
		var coords = FreeTiles.keys()[randi() % FreeTiles.keys().size()]
		grid.tilesContent[coords] = type
		FreeTiles.erase(coords)
		obstacle.frame = type
		#place the obstacle in the corresponding tile
		grid.get_child(grid.CoordsToIndex(coords)).add_child(obstacle)
	#load cities tiles
	for n in range(CitiesCount):
		grid.OccupiedTilesCount += 1
		var cities = obstacleScene.instance()
		randomize()
		var type = Types.Tile.Buildings
		var coords = FreeTiles.keys()[randi() % FreeTiles.keys().size()]
		grid.tilesContent[coords] = type
		FreeTiles.erase(coords)
		cities.frame = type
		#place the cities tile in the corresponding tile
		grid.CitiesCoords.append(coords)
		grid.get_child(grid.CoordsToIndex(coords)).add_child(cities)
	#load factories tiles 
	for n in range(Types.FactoriesCount):
		grid.OccupiedTilesCount += 1
		var factory = obstacleScene.instance()
		randomize()
		var type = Types.Tile.Factory
		var coords = FreeTiles.keys()[randi() % FreeTiles.keys().size()]
		grid.tilesContent[coords] = type
		FreeTiles.erase(coords)
		factory.frame = type
		#place the factory tile in the corresponding tile
		grid.CitiesCoords.append(coords)
		grid.get_child(grid.CoordsToIndex(coords)).add_child(factory)
func ShowNextCard():
	var player = int(CurrentPlayer==1) + 1#because ShowNextCard() is called after NextPlayer() in Tile.gd
	match gamemode:
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

func GameOver(player):
	if player == 1: TilesGrid1.CheckForConnections()
	elif player == 2: TilesGrid2.CheckForConnections()