extends Label

func _on_Tween_tween_completed(object, key):
	queue_free()
