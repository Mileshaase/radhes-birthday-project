extends Control


func _on_client_pressed() -> void:
	NetworkHandler.startClient()
	CloseNetworkUI()
	OpenPainterUI()

func _on_host_pressed() -> void:
	NetworkHandler.startServer()
	CloseNetworkUI()

func CloseNetworkUI() -> void:
	$NetworkUI.hide()

func OpenPainterUI() -> void:
	$PainterUI.show()
	
func _on_color_picker_open_and_close_pressed() -> void:
	if $PainterUI/ColorPickerOpenAndClose/ColorPicker.is_visible_in_tree():
		$PainterUI/ColorPickerOpenAndClose/ColorPicker.hide()
	else:
		$PainterUI/ColorPickerOpenAndClose/ColorPicker.show()

func _on_size_open_and_close_pressed() -> void:
	if $PainterUI/SizeOpenAndClose/Size.is_visible_in_tree():
		$PainterUI/SizeOpenAndClose/Size.hide()
	else:
		$PainterUI/SizeOpenAndClose/Size.show()
