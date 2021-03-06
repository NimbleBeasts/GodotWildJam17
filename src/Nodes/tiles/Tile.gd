extends TextureButton

var coords = [0,0]

func _on_Tile_pressed():
	if get_child_count()==0 :
		var tile_type
		var TilesGrid
		var card = Sprite.new()
		card.texture = load('res://assets/art/tileset.png')
		card.hframes = Types.TileHframes
		card.vframes = Types.TileVframes
		card.centered = false
		var gamemode = Global.gm.levelNode.LevelManager.gameMode
		var LevelManager = Global.gm.levelNode.LevelManager
		var current_player = LevelManager.CurrentPlayer
		LevelManager.get_node("SFX").play()
		match gamemode:
			Types.GameMode.MpLocalGame:
				tile_type = LevelManager.get('TopCard'+str(current_player))
				TilesGrid = LevelManager.get('TilesGrid'+str(current_player))
				TilesGrid.OccupiedTilesCount += 1
				
			_: #All SP now
				tile_type = LevelManager.TopCard1
				TilesGrid = LevelManager.TilesGrid1
				TilesGrid.OccupiedTilesCount += 1

		card.frame = tile_type
		TilesGrid.tilesContent[coords]=tile_type
		add_child(card)
		if tile_type in [Types.Tile.Park, Types.Tile.PowerPlant]:
			TilesGrid.SpecialTilesCoords.append([tile_type,coords])
		elif tile_type in [Types.Tile.Station_UD, Types.Tile.Station_LR]:
			TilesGrid.DisconnectedStations.append([tile_type,coords])
		match gamemode:
			Types.GameMode.MpLocalGame:
				Global.gm.levelNode.LevelManager.NextPlayer()
				Global.gm.levelNode.LevelManager.ShowNextCard()
			_:
				Global.gm.levelNode.LevelManager.NextRound()
				Global.gm.levelNode.LevelManager.ShowNextCard()
