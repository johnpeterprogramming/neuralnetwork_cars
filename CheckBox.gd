extends CheckBox


func _on_CheckBox_toggled(button_pressed):
	Singleton.showRaycasts = button_pressed
