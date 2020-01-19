extends Node2D

func Animate(grid):
	var bonusLabel_scene = load('res://src/Nodes/ScoreAnimLabel.tscn')
	var tiles = grid.Anim
	for tile in tiles:
		if tile[0].size()==1:#check if it's a pause
			yield(get_tree().create_timer(tile[1]), "timeout")
		else:
			var bonusLabel = bonusLabel_scene.instance()
			var txtColor = Color.green if (tile[1]>0) else Color.red
			bonusLabel.set("custom_colors/font_color", txtColor)
			bonusLabel.text = '+' + str(tile[1]) if tile[1]>=0 else '-' + str(tile[1])
			bonusLabel.rect_position = grid.get_child(grid.CoordsToIndex(tile[0])).rect_position
			
			add_child(bonusLabel)
			
			bonusLabel.get_child(0).interpolate_property(bonusLabel,'rect_position:y',bonusLabel.rect_position.y,bonusLabel.rect_position.y-50,2,Tween.TRANS_LINEAR,Tween.EASE_IN)
			bonusLabel.get_child(0).interpolate_property(bonusLabel,'modulate:a',1,0,2,Tween.TRANS_LINEAR,Tween.EASE_IN)
			
			bonusLabel.get_child(0).start()
			yield(get_tree().create_timer(0.5), "timeout")
	return true