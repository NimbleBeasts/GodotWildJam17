extends Control


func setup(gameMode):
	if gameMode == Types.GameMode.MpLocalGame:
		$Mp.show()
	else:
		$Sp.show()

func updateGui(p1, p2 = {"rails": 0, "cities": 0, "stations": 0, "penalty": 0}): #{"rails": 0, "cities": 0, "stations": 0, "penalty": 0}
	var stringP1 = _buildString(p1)

	if $Sp.visible:
		$Sp/RtP1.bbcode_text = stringP1
	else:
		var stringP2 = _buildString(p2)
		$Mp/RtP1.bbcode_text = stringP1
		$Mp/RtP2.bbcode_text = stringP2


func _buildString(data):
	var string = "[center]Rails: " + "%+d" % data.rails + "\n\n" + \
		"Cities: " + "%+d" % data.cities + "\n\n" + \
		"Stations: " + "%+d" % data.stations + "\n\n" + \
		"Penalty: " + "%+d" % data.penalty + "\n\n" + \
		"Total: " + "%+d" % (data.cities + data.stations + data.penalty)
	return string
