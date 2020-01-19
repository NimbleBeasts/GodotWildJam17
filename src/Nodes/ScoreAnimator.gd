extends Node2D

var tilesCount = 0
var counter = 0
var tiles = null
var myGrid = null

var bonusLabel_scene = load('res://src/Nodes/ScoreAnimLabel.tscn')
var finished = null


func Animate(grid, display):
	myGrid = grid
	tiles = grid.Anim
	tilesCount = tiles.size()
	_on_Timer_timeout()
	finished = display

func AnimateFrame(count):
	if typeof(tiles[count][0])==TYPE_STRING :#check if it's a pause
		yield(get_tree().create_timer(tiles[count][1]), "timeout")
	else:
		var bonusLabel = bonusLabel_scene.instance()
		var txtColor = Color.green if (tiles[count][1]>0) else Color.red
		bonusLabel.set("custom_colors/font_color", txtColor)
		bonusLabel.text = '+' + str(tiles[count][1]) if tiles[count][1]>=0 else  str(tiles[count][1])
		bonusLabel.rect_global_position = myGrid.get_child(myGrid.CoordsToIndex(tiles[count][0])).rect_global_position
		
		add_child(bonusLabel)
		
		bonusLabel.get_child(0).interpolate_property(bonusLabel,'rect_position:y',bonusLabel.rect_position.y,bonusLabel.rect_position.y-20,2,Tween.TRANS_LINEAR,Tween.EASE_IN)
		bonusLabel.get_child(0).interpolate_property(bonusLabel,'modulate:a',1,0,2,Tween.TRANS_LINEAR,Tween.EASE_IN)
		
		bonusLabel.get_child(0).start()

func _on_Timer_timeout():
	if counter < tilesCount:
		AnimateFrame(counter)
		counter += 1
		$Timer.start()
	else:
		if finished:
			Global.gm.levelNode.get_node("ScoreBoard").visible = true

