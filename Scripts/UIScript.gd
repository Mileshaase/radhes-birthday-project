extends Control

var menuOpen = false

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

func _on_menu_button_pressed() -> void:
	if menuOpen:
		for button in $PainterUI/MenuButton.get_children():
			button.hide()
			menuOpen = false
	else:
		for button in $PainterUI/MenuButton.get_children():
			button.show()
			menuOpen = true

func _on_color_picker_open_and_close_pressed() -> void:
	if $PainterUI/MenuButton/ColorPickerOpenAndClose/ColorRect.is_visible_in_tree():
		$PainterUI/MenuButton/ColorPickerOpenAndClose/ColorRect.hide()
	else:
		$PainterUI/MenuButton/ColorPickerOpenAndClose/ColorRect.show()

func _on_size_open_and_close_pressed() -> void:
	if $PainterUI/MenuButton/SizeOpenAndClose/Size.is_visible_in_tree():
		$PainterUI/MenuButton/SizeOpenAndClose/Size.hide()
	else:
		$PainterUI/MenuButton/SizeOpenAndClose/Size.show()
