extends Node2D

@onready var lines: Node2D = $Line2D

var Pressed: bool = false

var lineName: String = ""
@export var lineColor: = Color.PINK
@export var lineWidth: = 5

var listOfLines : Array
var listOfReactions : Array

var BrushType = "Line"
var ReactMode = false
var currentReaction : PackedScene = load("res://Prefab/Heart.tscn")

func _ready() -> void:
	NetworkHandler.drawing = self

func _input(event: InputEvent) -> void:
	if $UI/PainterUI/MenuButton.get_child(0).is_visible_in_tree():
		return

	if event is InputEventMouseButton:
		if $UI/PainterUI/MenuButton.get_global_rect().has_point(event.position):
			return
		if event.button_index == MOUSE_BUTTON_LEFT:
			Pressed = event.pressed
			
			if Pressed and BrushType == "Line":
				var newName = "Line_" + str(Time.get_ticks_msec())
				drawStroke.rpc(event.position, newName)
			elif BrushType == "Shape" and ReactMode == false:
				DrawReaction.rpc(event.position)
			elif BrushType == "Shape" and ReactMode == true:
				SpawnReaction.rpc()

	elif event is InputEventMouseMotion and Pressed:
		if Pressed and BrushType == "Line":
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

@rpc("any_peer", "call_local", "reliable")
func DrawReaction(pos) -> void:
	var reaction = currentReaction.instantiate()
	if currentReaction.get_state().get_node_name(0) == "Heart":
		reaction.get_node("TextureRect").modulate = lineColor
	reaction.scale *= 0.5
	reaction.global_position = pos
	reaction.canExpire = false
	add_child(reaction)
	listOfReactions.append(reaction)

@rpc("any_peer", "call_local", "reliable")
func SpawnReaction() -> void:
	var viewportSize = get_viewport_rect().size
	var xPos = randf_range(0.0, viewportSize.x)
	var yPos = randf_range(600, 500)
	var reaction = currentReaction.instantiate()
	reaction.global_position = Vector2(xPos, yPos)
	if currentReaction.get_state().get_node_name(0) == "Heart":
		reaction.get_node("TextureRect").modulate = lineColor
	add_child(reaction)

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
	for reaction in listOfReactions:
		reaction.queue_free()
	listOfReactions.clear()

func _on_clear_pressed() -> void:
	clearBoard.rpc()

@rpc("any_peer", "call_local", "reliable")
func undoLastLine() -> void:
	if listOfReactions.size() > 0:
		listOfReactions[listOfReactions.size() - 1].queue_free()
		listOfReactions.pop_back()

func _on_undo_pressed() -> void:
	undoLastLine.rpc()

func _on_swap_brush_type_pressed() -> void:
	if BrushType == "Line":
		BrushType = "Shape"
		$UI/PainterUI/MenuButton/SwapBrushType/ReactMode.show()
		$UI/PainterUI/MenuButton/SwapBrushType/Reactions.show()
	else:
		BrushType = "Line"
		$UI/PainterUI/MenuButton/SwapBrushType/Reactions.hide()
	$UI/PainterUI/MenuButton/SwapBrushType.text = BrushType

func _on_react_mode_pressed() -> void:
	if ReactMode == false:
		ReactMode = true
		$UI/PainterUI/MenuButton/SwapBrushType/ReactMode.text = "T"
	else:
		ReactMode = false
		$UI/PainterUI/MenuButton/SwapBrushType/ReactMode.text = "F"

func _on_reaction_1_pressed() -> void:
	SetShapeToHeart.rpc()

@rpc("any_peer", "call_local", "reliable")
func SetShapeToHeart() -> void:
	currentReaction = load("res://Prefab/Heart.tscn")

@rpc("any_peer", "call_local", "reliable")
func SetShapeToKiss() -> void:
	currentReaction = load("res://Prefab/Kiss.tscn")

func _on_reaction_2_pressed() -> void:
	SetShapeToKiss.rpc()
