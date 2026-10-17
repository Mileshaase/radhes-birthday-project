extends Node2D

@onready var lines: Node2D = $Line2D

var Pressed: bool = false

var lineName: String = ""
@export var lineColor: = Color.PINK
@export var lineWidth: = 5

var listOfLines : Array

var BrushType = "Line"
var ReactMode = false
var currentReaction : PackedScene = load("res://Prefab/Heart.tscn")

var reactionTimer =  Timer.new()

func _ready() -> void:
	NetworkHandler.drawing = self

func _input(event: InputEvent) -> void:
	if $UI/PainterUI/MenuButton/ColorPickerOpenAndClose/ColorRect/ColorPicker.is_visible_in_tree() or $UI/PainterUI/MenuButton/SizeOpenAndClose/Size.is_visible_in_tree():
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			Pressed = event.pressed
			
			if Pressed and BrushType == "Line":
				var newName = "Line_" + str(Time.get_ticks_msec())
				drawStroke.rpc(event.position, newName)
			elif ReactMode == false:
				DrawReaction(event.position)
			elif ReactMode == true:
				SpawnReaction()
				
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
	if newLine not in listOfLines:
		listOfLines.append(newLine)

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
		if newLine not in listOfLines:
			listOfLines.append(newLine)

@rpc("authority", "call_local")
func DrawReaction(pos) -> void:
	var reaction = currentReaction.instantiate()
	reaction.global_position = pos

@rpc("authority", "call_local")
func SpawnReaction() -> void:
	var viewportSize = get_viewport_rect().size
	var xPos = randf_range(viewportSize.x - viewportSize.x - viewportSize.x * 0.5 / 2, viewportSize.x - viewportSize.x - viewportSize.x * 0.5 / 2 + viewportSize.x * 0.5)
	var reaction = currentReaction.instantiate()
	reaction.global_position = Vector2(xPos, 600)
	reactionTimer.set_one_shot(true)
	reactionTimer.timeout.connect(_on_timer_timeout)
	reactionTimer.start(0.01)
	reaction.add_child(reactionTimer)

@rpc("authority", "call_local")
func _on_timer_timeout() -> void:
	reactionTimer.get_parent().queue_free()

@rpc("any_peer", "call_local", "reliable")
func changeColor(color) -> void:
	lineColor = color
	currentReaction.modulate = color

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
	if listOfLines.size() > 0:
		for line in listOfLines:
			print(line.name + "\n")
		print("\n")
		print(listOfLines[listOfLines.size() - 1])
		listOfLines[listOfLines.size() - 1].queue_free()
		listOfLines.pop_back()

func _on_undo_pressed() -> void:
	undoLastLine.rpc()

func _on_swap_brush_type_pressed() -> void:
	if BrushType == "Line":
		BrushType = "Shape"
		$UI/PainterUI/MenuButton/SwapBrushType/ReactMode.show()
	else:
		BrushType = "Line"

func _on_react_mode_pressed() -> void:
	if ReactMode == false:
		ReactMode = true
		$UI/PainterUI/MenuButton/SwapBrushType/Reactions.show()
	else:
		ReactMode = false
		$UI/PainterUI/MenuButton/SwapBrushType/Reactions.hide()


func _on_reaction_1_pressed() -> void:
	currentReaction = load("res://Prefab/Kiss.tscn")

func _on_reaction_2_pressed() -> void:
	currentReaction = load("res://Prefab/Heart.tscn")
