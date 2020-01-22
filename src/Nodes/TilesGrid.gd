extends GridContainer
var tilesContent = {} #{[x,y]:content}
var OccupiedTilesCount = 0
var CitiesCoords = []
var SpecialTilesCoords = [] #[[type, coords]]
var DisconnectedStations = []#[[type, coords]]
var Connections = []#contains coords for starting city tile and the destination city tile for each connection (that is 2 cities)
var Paths = {}# {start_pos:path}
var score = 0
var Anim = []#array used for displaying tile bonus one by one

#vars used for score analysis:
var SA_CitiesFactories = 0
var SA_Rails = 0
var SA_Stations = 0
var SA_PenaltyBonus = 0


func IsTileEmpty(tile):
	return tilesContent[tile]==null

func CoordsToIndex(coords):
	return (coords[0]+coords[1]*columns)
func CitiesAlreadyConnected(a,b):
	return ([a,b] in Connections) or ([b,a] in Connections)
func AreValidCoords(coords):
	return coords[0] in range(columns) and coords[1] in range(columns)

func WhatsNearMeOnThe(direction,my_coords):#null when there's no tile or the tile is empty
	var result = [null,null]
	var movement = [[0,-1], [-1,0], [1,0], [0,1]] #which coordinate (x or y) to change to move in the direction
	var nearbytile_coords = [my_coords[0]+movement[direction][0], my_coords[1]+movement[direction][1]]
	if AreValidCoords(nearbytile_coords):
		result = [tilesContent[nearbytile_coords],nearbytile_coords]
	#print('WhatsNearMeOnThe(',direction,',',my_coords,')=',result)
	return result
	
func Opposite(direction):
	if direction == Types.Direction.Top:return Types.Direction.Down
	elif direction == Types.Direction.Down:return Types.Direction.Top
	elif direction == Types.Direction.Left:return Types.Direction.Right
	elif direction == Types.Direction.Right:return Types.Direction.Left
func Neighbor(direction):
	if direction==Types.Direction.Top: return Types.Direction.Left
	elif direction==Types.Direction.Left: return Types.Direction.Top
	elif direction==Types.Direction.Right: return Types.Direction.Down
	elif direction==Types.Direction.Down: return Types.Direction.Right
func DirToStr(type):
	match type:
		Types.Direction.Top: return 'U'
		Types.Direction.Left: return 'L'
		Types.Direction.Right: return 'R'
		Types.Direction.Down: return 'D'
func StrToDir(s):
	match s:
		'U': return Types.Direction.Top
		'L': return Types.Direction.Left
		'R': return Types.Direction.Right
		'D': return Types.Direction.Down
func SortDir(a,b):
	var order=  [Types.Direction.Top, Types.Direction.Left, Types.Direction.Right, Types.Direction.Down]
	return [order[min(order.find(a),order.find(b))],order[max(order.find(a),order.find(b))]]
func AreConnected(tile1,tile2, direction):#direction: tile2's position relative to tile1's
	var result =false
	var type1 = Types.TileStr[tile1]
	var type2=Types.TileStr[tile2]
	var x2 = null
	var y2 = null
	if '_' in type2:
		x2 = StrToDir(type2.split('_')[1][0])
		y2= StrToDir(type2.split('_')[1][1])
	
	if  tile1==Types.Tile.Buildings:
		if tile2==Types.Tile.Factory: result = false
		else: result = (Opposite(direction) in [x2,y2]) or tile2==Types.Tile.Rail_ULRD
	elif tile1==Types.Tile.Factory:
		if tile2==Types.Tile.Buildings: result = false
		else:result = (Opposite(direction) in [x2,y2]) or tile2==Types.Tile.Rail_ULRD
	elif tile2 in [Types.Tile.Buildings, Types.Tile.Factory]:
		result = true
	elif Types.Tile.Rail_ULRD in [tile1,tile2]:
		if tile2==Types.Tile.Rail_ULRD:
			result = true
		else:
			result = Opposite(direction) in [x2,y2]
	elif '_' in type1:
		result = Opposite(direction) in [x2,y2]
	#print('AreConnected(',tile1,',',tile2,',',direction,')=',result)
	return result
func IsAPath(type):#whether the tile type can connect two cities
	var result = false
	result =  type in [Types.Tile.Rail_UD, Types.Tile.Rail_LR, Types.Tile.Rail_LD, Types.Tile.Rail_RD, Types.Tile.Rail_UL, Types.Tile.Rail_UR, Types.Tile.Rail_ULRD, Types.Tile.Station_UD, Types.Tile.Station_LR]
	#print('IsAPath(',type,')=',result)
	return result
func PathEnd(tile,pos):
	var result = null
	var dirs = Types.TileDirs[tile].duplicate(true)
	if dirs.size()==2:
		dirs.erase(Opposite(pos))
		result =  dirs[0]
	else:
		pass#TODO: Code for handling the Intersection tile, Park, Generator,and Repair tiles
	#print('PathEnd(',tile,',',pos,')=',result)
	return result

func CheckForConnections():
	var score = 0
	for citiesTile in CitiesCoords:
		var directions = [Types.Direction.Top, Types.Direction.Left, Types.Direction.Right, Types.Direction.Down]
		for init_dir in directions:
			var dir_str = DirToStr(init_dir)
			var curr_tile = citiesTile
			var curr_tile_type = tilesContent[curr_tile]
			var railsCount = 0
			var dir = init_dir
			Paths[[citiesTile,init_dir]] = [[curr_tile_type,citiesTile]]
			while WhatsNearMeOnThe(dir,curr_tile)[0]!=null and AreConnected(curr_tile_type,WhatsNearMeOnThe(dir,curr_tile)[0],dir):
				var nearbyTile = WhatsNearMeOnThe(dir,curr_tile)
				if nearbyTile[0] in [Types.Tile.Buildings, Types.Tile.Factory] and railsCount>0 and !CitiesAlreadyConnected(nearbyTile[1],citiesTile):
					score +=1
					Connections.append([citiesTile,nearbyTile[1]])
					AddToPaths(citiesTile,init_dir,nearbyTile[0],nearbyTile[1])
					break
				elif IsAPath(nearbyTile[0]):
					if nearbyTile[0]!=Types.Tile.Rail_ULRD:
						dir = PathEnd(nearbyTile[0],dir)
					AddToPaths(citiesTile,init_dir,nearbyTile[0],nearbyTile[1])
					railsCount+=1
					
					var step_data = nearbyTile.duplicate(true)
					curr_tile_type = step_data[0]
					curr_tile = step_data[1]
				else: 
					break
	CalculateScore()

func AddToPaths(start_pos,dir,type,coords):
	var path = Paths[[start_pos,dir]]
	path.append([type,coords])
	#print("AddToPaths(",start_pos,",",type,",",coords)
func ClearUselessValues():
	#clear paths that contain one item or are an inverse path
	for path_key in Paths.keys():
		var path = Paths[path_key]
		if path.size()==1 or !(path[-1][0] in [Types.Tile.Buildings, Types.Tile.Factory]):
			Paths.erase(path_key)
	#remove Station tiles that are connected to cities and/or factories
		else:
			for station in DisconnectedStations:
				if station in path:
					DisconnectedStations.erase(station)
func getSpecialTilesBonus():
	var bonus = 0
	for tile in SpecialTilesCoords:
		var tile_bonus = 0
		var requirement_fullfilled = false
		if tile[0]==Types.Tile.Park:
			for dir in Types.Direction.values():
				if !requirement_fullfilled: requirement_fullfilled=(tile[0] ==Types.Tile.Buildings)
				var nearbytile = WhatsNearMeOnThe(dir,tile[1])[0]
				tile_bonus += int(nearbytile==Types.Tile.Buildings)*Types.ScoreCoef["ParkCityBonus"]+int(nearbytile==Types.Tile.Factory)*Types.ScoreCoef["ParkFactoryBonus"]
			if !requirement_fullfilled: tile_bonus=Types.ScoreCoef["LonelyPark"]
		if tile[0]==Types.Tile.PowerPlant:
			for dir in Types.Direction.values():
				if !requirement_fullfilled: requirement_fullfilled=(tile[0] ==Types.Tile.Factory)
				var nearbytile = WhatsNearMeOnThe(dir,tile[1])[0]
				tile_bonus += int(nearbytile==Types.Tile.Buildings)*Types.ScoreCoef["PowerPlantCityBonus"]+int(nearbytile==Types.Tile.Factory)*Types.ScoreCoef["PowerPlantFactoryBonus"]
			if !requirement_fullfilled: tile_bonus=Types.ScoreCoef["LonelyPowerPlant"]
		bonus += tile_bonus
		
		Anim.append([tile[1],tile_bonus])
	
	for station in DisconnectedStations:
		bonus += Types.ScoreCoef["LonelyStation"]
		Anim.append([station[1],Types.ScoreCoef["LonelyStation"]])
	return bonus

func CalculateScore():
	var score = 0
	ClearUselessValues()
	var bonus = getSpecialTilesBonus()
	SA_PenaltyBonus += bonus
	for path_data in Paths.keys():
		var path_score = 0
		var station_bonus_active = false
		var path = Paths[path_data]
		for tile in path:
			var value = getTileWorth(tile,path)
			Anim.append([tile[1],value])
			path_score+=value
			if !station_bonus_active and (tile[0] in [Types.Tile.Station_UD, Types.Tile.Station_LR]):station_bonus_active = true
		if station_bonus_active:
			path_score *=2
			SA_PenaltyBonus +=path_score
		score+=path_score
		
		Anim.append(["PAUSE",1])
	
	Anim.append(["PAUSE",2])

	score += bonus
	#print(score)
	return score

func getTileWorth(tile,path):
	var TileWorth = 0
	var type = tile[0]
	var coords = tile[1]
	match type:
		Types.Tile.Buildings:
			if tile==path[0] and path[-1][0]==Types.Tile.Buildings:
				TileWorth = Types.ScoreCoef["ConnectionToCities"]
			elif tile==path[0] and path[-1][0]==Types.Tile.Factory:
				TileWorth = Types.ScoreCoef["ConnectionToFactories"]
			SA_CitiesFactories += TileWorth
		Types.Tile.Factory:
			if tile==path[0] and path[-1][0]==Types.Tile.Factory:
				TileWorth = Types.ScoreCoef["ConnectionToCities"]
			elif tile==path[0] and path[-1][0]==Types.Tile.Buildings:
				TileWorth = Types.ScoreCoef["ConnectionToFactories"]
			SA_CitiesFactories += TileWorth
		_:
			if IsAPath(type):
				if 'Station' in Types.TileStr[type]:
					TileWorth = Types.ScoreCoef["Station"]
					SA_Stations += TileWorth
				else:
					TileWorth = Types.ScoreCoef["Rail"]
					SA_Rails += TileWorth
	#print("getTileWorth(",tile,",",path,")=",TileWorth)
	return TileWorth
