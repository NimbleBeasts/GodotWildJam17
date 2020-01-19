extends TextureButton


func _on_SecondChanceButton_pressed():
	Global.gm.levelNode.LevelManager.GimmeSecondChance()
	$SFX.play()
	disabled = true
