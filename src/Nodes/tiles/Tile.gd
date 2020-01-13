extends TextureButton

var coords = [0,0]

func _on_Tile_pressed():
	if get_child_count()==0 :
		var card = Sprite.new()
		card.texture = load('res://assets/art/tileset.png')
		card.vframes = Types.TileVframes
		card.hframes = Types.TileHframes
		card.frame = Global.gm.levelNode.TopCard
		card.centered = false
		add_child(card)
		
		Global.gm.levelNode.ShowNextCard()