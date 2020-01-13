extends GridContainer
var tilesContent = {} #{[x,y]:content}
var CitiesCoords = []
var Connections = []
func IsTileEmpty(tile):
	return tilesContent[tile]==null

func CoordsToIndex(coords):
	return (coords[0]+coords[1]*columns)
func CitiesAlreadyConnected(a,b):
	return ([a,b] in Connections) or ([b,a] in Connections)
func WhatsNearMeOnThe(direction,my_coords):#null when there's no tile or the tile is empty
	if direction == Types.Direction.Top:
		if my_coords[1]==0:return [null,null]
		else: return [tilesContent[[my_coords[0],my_coords[1]-1]],[my_coords[0],my_coords[1]-1]]
	elif direction == Types.Direction.Left:
		if my_coords[0]==0:return [null,null]
		else: return [tilesContent[[my_coords[0]-1,my_coords[1]]],[my_coords[0]-1,my_coords[1]]]
	elif direction == Types.Direction.Right:
		if my_coords[0]==columns-1:return [null,null]
		else: return [tilesContent[[my_coords[0]+1,my_coords[1]]],[my_coords[0]+1,my_coords[1]]]
	elif direction == Types.Direction.Down:
		if my_coords[1]==columns-1:return [null,null]
		else: return [tilesContent[[my_coords[0],my_coords[1]+1]],[my_coords[0],my_coords[1]+1]]
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
func SortDir(a,b):
	var order=  ['U','L','R','D']
	return [order[max(order.find(a),order.find(b))],order[min(order.find(a),order.find(b))]]
func AreConnected(tile1,tile2, direction):#direction: tile2's position relative to tile1's
	var type1 = Types.Tile.keys()[tile1]
	var type2=Types.Tile.keys()[tile2]
	if Types.Tile.Buildings in [tile1,tile2]:return true
	elif '_' in type1:
		var x1 = type1.split('_')[0]
		var y1=type1.split('_')[1]
		var x2 = type2.split('_')[0]
		var y2=type2.split('_')[1]
		var dir = DirToStr(direction)
		if dir==x1:
			return ([x2,y2] in [SortDir(x1,Opposite(x1)),SortDir(Neighbor(y1),Opposite(x1)),SortDir(Opposite(Neighbor(y1)),Opposite(x1))])
		elif dir==y2:
			return ([x2,y2] in [SortDir(y1,Opposite(y1)),SortDir(Neighbor(x1),Opposite(y1)),SortDir(Opposite(Neighbor(x1)),Opposite(y1))])
	else:return false
func IsAPath(type):#whether the tile type can connect two cities
	return type in [Rail_UD,Rail_LR,Rail_LD,Rail_RD,Rail_UL,Rail_UR,Rail_ULRD,Station_UD,Station_LR]
func CheckForConnections():
	var score = 0
	for citiesTile in CitiesCoords:
		for dir in Types.Direction.values():
			var dir_str = DirToStr(dir)
			var curr_tile = citiesTile
			var curr_tile_type = Types.Tile.Buildings
			var railsCount = 0
			while WhatsNearMeOnThe(dir,curr_tile)[0]!=null and AreConnected(curr_tile_type,WhatsNearMeOnThe(dir,curr_tile)[0],dir):
				if WhatsNearMeOnThe(dir,curr_tile)[0]==Types.Tile.Buildings and railsCount>0 and !CitiesAlreadyConnected(WhatsNearMeOnThe(dir,curr_tile)[1],curr_tile):
					score +=1
					Connections.append([curr_tile,WhatsNearMeOnThe(dir,curr_tile)[0]])
					break
				elif IsAPath(WhatsNearMeOnThe(dir,curr_tile)[0]):
					railsCount+=1
					curr_tile_type = WhatsNearMeOnThe(dir,curr_tile)[0]
					curr_tile = WhatsNearMeOnThe(dir,curr_tile)[1]
				else: break
	OS.alert(str(score))