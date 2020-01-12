extends GridContainer
var tilesContent = {} #{[x,y]:content}
func IsTileEmpty(tile):
	return tilesContent[tile]==null

func CoordsToIndex(coords):
	return (coords[0]+coords[1]*columns)