extends Node2D

@onready var lines: Node2D = $Line2D

var Pressed: bool = false

var lineName: String = ""
@export var lineColor: = Color.PINK
@export var lineWidth: = 5

func _ready() -> void:
	NetworkHandler.drawing = self

func _input(event: InputEvent) -> void:
	if $UI/PainterUI/ColorPickerOpenAndClose/ColorPicker.is_visible_in_tree() or $UI/PainterUI/SizeOpenAndClose/Size.is_visible_in_tree():
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			Pressed = event.pressed
			
			if Pressed:
				var newName = "Line_" + str(multiplayer.get_unique_id()) + "_" + str(Time.get_ticks_msec())
				drawStroke.rpc(event.position, newName)
				
	elif event is InputEventMouseMotion and Pressed:
		addStrokePoint.rpc(event.position, lineName)

@rpc("any_peer", "call_local", "reliable")
func drawStroke(pos, linename) -> void:
	lineName = linename
	
	var newLine = Line2D.new()
	newLine.name = linename
	newLine.default_color = lineColor
	newLine.width = lineWidth

	lines.add_child(newLine)
	newLine.add_point(pos)

@rpc("any_peer", "call_local", "reliable")
func addStrokePoint(pos, linename) -> void:
	var line = lines.get_node_or_null(linename)
	if line is Line2D:
		line.add_point(pos)

func newPlayerJoined(id: int, linesData: Array) -> void:
	updateNewPlayerLines.rpc_id(id, linesData)

@rpc("authority", "call_local")
func updateNewPlayerLines(linesData: Array) -> void:
	for line in linesData:
		if lines.has_node(str(line["name"])):
			continue
		
		var newLine = Line2D.new()
		newLine.name = str(line["name"])
		newLine.width = line["width"]
		newLine.default_color = line["color"]
		newLine.points = line["points"]
			
		lines.add_child(newLine)

@rpc("any_peer", "call_local", "reliable")
func changeColor(color) -> void:
	lineColor = color

@rpc("any_peer", "call_local", "reliable")
func changeWidth(width) -> void:
	lineWidth = width

func _on_color_picker_color_changed(color: Color) -> void:
	changeColor.rpc(color)

func _on_size_value_changed(value: float) -> void:
	changeWidth.rpc(value)

@rpc("any_peer", "call_local", "reliable")
func clearBoard() -> void:
	for line in lines.get_children():
		line.queue_free()

func _on_clear_pressed() -> void:
	clearBoard.rpc()

@rpc("any_peer", "call_local", "reliable")
func undoLastLine() -> void:
	var linesList = lines.get_children()
	if linesList.size() > 0:
		var lastLine = linesList[-1]
		lastLine.queue_free()

func _on_undo_pressed() -> void:
	undoLastLine.rpc()
