extends TextureButton

var coords = [0,0]

func _on_Tile_pressed():
	if get_child_count()==0 :
		var tile_type = Global.gm.levelNode.TopCard
		var TilesGrid = Global.gm.levelNode.TilesGrid
		var card = Sprite.new()
		card.texture = load('res://assets/art/tileset.png')
		card.vframes = Types.TileVframes
		card.hframes = Types.TileHframes
		card.frame = tile_type
		card.centered = false
		TilesGrid.tilesContent[coords]=tile_type
		add_child(card)

		if tile_type in [Types.Tile.Park, Types.Tile.PowerPlant]:
			TilesGrid.SpecialTilesCoords.append([tile_type,coords])
		elif tile_type in [Types.Tile.Station_UD, Types.Tile.Station_LR]:
			TilesGrid.DisconnectedStations.append([tile_type,coords])
		Global.gm.levelNode.ShowNextCard()